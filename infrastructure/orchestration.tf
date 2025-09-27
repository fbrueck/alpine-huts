###############################
# CloudWatch Event Rule
###############################

resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "${local.ingestion_prefix}_daily_trigger"
  schedule_expression = "cron(0 18 * * ? *)"
}

resource "aws_cloudwatch_event_target" "step_function_target" {
  rule     = aws_cloudwatch_event_rule.daily_trigger.name
  arn      = aws_sfn_state_machine.alpine_huts_ingestion_orchestration.arn
  role_arn = aws_iam_role.cloudwatch_invoke_step_function.arn
}


###############################
# Step Function
###############################

resource "aws_sfn_state_machine" "alpine_huts_ingestion_orchestration" {
  name     = "${local.ingestion_prefix}_orchestration"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment : "Runs the ingestion process for the Alpine Huts dataset",
    StartAt : "FetchAlpineHutData",
    States : {
      FetchAlpineHutData = {
        Type     = "Task"
        Resource = aws_lambda_function.alpine_huts_ingestion.arn
        Next     = "RunDbtBuild"
      }
      RunDbtBuild = {
        Type     = "Task"
        Resource = "arn:aws:states:::ecs:runTask.sync"
        Parameters = {
          LaunchType     = "FARGATE"
          Cluster        = aws_ecs_cluster.dbt_cluster.arn
          TaskDefinition = aws_ecs_task_definition.dbt_task.arn
          NetworkConfiguration = {
            AwsvpcConfiguration = {
              Subnets        = data.aws_subnets.default_subnets.ids
              SecurityGroups = [data.aws_security_group.default.id]
              AssignPublicIp = "ENABLED"
            }
          }
        }
        Next = "Success"
      }
      Success = {
        Type = "Succeed"
      }
    }
  })
}

data "aws_security_group" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

###############################
# IAM Cloudwatch Role
###############################

resource "aws_iam_role" "cloudwatch_invoke_step_function" {
  name = "${local.ingestion_prefix}-cloudwatch_invoke_step_function"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "invoke_step_function_policy" {
  name = "${local.ingestion_prefix}-invoke_step_function_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "states:StartExecution",
        Resource = aws_sfn_state_machine.alpine_huts_ingestion_orchestration.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.cloudwatch_invoke_step_function.name
  policy_arn = aws_iam_policy.invoke_step_function_policy.arn
}

###############################
# IAM Step Function Role
###############################

resource "aws_iam_role" "step_function_role" {
  name = "${local.ingestion_prefix}_step_function_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "step_function_policy" {
  name = "${local.ingestion_prefix}_step_function_policy"
  role = aws_iam_role.step_function_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "step_function_eventbridge_policy" {
  name = "${local.ingestion_prefix}_step_function_eventbridge_policy"
  role = aws_iam_role.step_function_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "events:PutRule",
          "events:PutTargets",
          "events:DeleteRule",
          "events:RemoveTargets",
          "events:DescribeRule"
        ]
        Resource = "arn:aws:events:${local.region}:${local.account_id}:rule/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "step_function_ecs_policy" {
  name = "${local.ingestion_prefix}_step_function_ecs_policy"
  role = aws_iam_role.step_function_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:DescribeTasks",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}
