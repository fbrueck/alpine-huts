locals {
  dbt_prefix        = "dbt"
  dbt_repo_name     = replace(local.dbt_prefix, "_", "-")
  dbt_ecr_image_uri = "${local.ecr_image_base_uri}/${local.dbt_repo_name}:latest"
}

resource "aws_ecs_cluster" "dbt_cluster" {
  name = "${local.dbt_prefix}-cluster"
}

resource "aws_ecr_repository" "dbt_repository" {
  name = local.dbt_repo_name
}

###################################
# ECS Task Definition
###################################

resource "aws_ecs_task_definition" "dbt_task" {
  family                   = "${local.dbt_prefix}_ecs_task"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.dbt_ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.dbt_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "dbt"
      image     = local.dbt_ecr_image_uri
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${local.dbt_prefix}"
          awslogs-region        = local.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "dbt_logs" {
  name              = "/ecs/${local.dbt_prefix}"
  retention_in_days = 14
}

###################################
# IAM Roles and Policies
###################################

resource "aws_iam_role" "dbt_ecs_task_execution_role" {
  name = "${local.dbt_prefix}_ecs_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "dbt_ecs_execution_role_policy" {
  role       = aws_iam_role.dbt_ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role (actual app permissions)
resource "aws_iam_role" "dbt_task_role" {
  name = "${local.dbt_prefix}_ecs_task_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "dbt_s3_policy" {
  name = "${local.dbt_prefix}_s3_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${local.bucket_name}",
          "arn:aws:s3:::${local.bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::*",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dbt_s3_policy_attachment" {
  role       = aws_iam_role.dbt_task_role.name
  policy_arn = aws_iam_policy.dbt_s3_policy.arn

}

resource "aws_iam_policy" "dbt_athena_policy" {
  name = "${local.dbt_prefix}_athena_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:StopQueryExecution",
          "athena:GetWorkGroup"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetTable",
          "glue:GetTables",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTableVersions",
          "glue:DeleteTable",
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dbt_athena_policy_attachment" {
  role       = aws_iam_role.dbt_task_role.name
  policy_arn = aws_iam_policy.dbt_athena_policy.arn
}
