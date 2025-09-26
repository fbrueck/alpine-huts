locals {
  dbt_prefix = "dbt_lambda"
  dbt_repo_name = replace(local.dbt_prefix, "_", "-")
  dbt_ecr_image_uri       = "${local.ecr_image_base_uri}/${local.dbt_repo_name}:latest"
}

resource "aws_ecr_repository" "dbt_lambda" {
  name = local.dbt_repo_name
}

resource "aws_iam_role" "dbt_lambda_execution_role" {
  name = "${local.dbt_prefix}_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dbt_lambda_basic_execution" {
  role       = aws_iam_role.dbt_lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "dbt_lambda_s3_policy" {
  name = "${local.dbt_prefix}_s3_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${local.bucket_name}",
          "arn:aws:s3:::${local.bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dbt_lambda_s3_policy_attachment" {
  role       = aws_iam_role.dbt_lambda_execution_role.name
  policy_arn = aws_iam_policy.dbt_lambda_s3_policy.arn
  
}

resource "aws_iam_policy" "dbt_lambda_athena_policy" {
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
          "glue:GetDatabases"
        ]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dbt_lambda_athena_policy_attachment" {
  role       = aws_iam_role.dbt_lambda_execution_role.name
  policy_arn = aws_iam_policy.dbt_lambda_athena_policy.arn
}

resource "aws_lambda_function" "dbt_lambda" {
  function_name = local.dbt_prefix
  role          = aws_iam_role.dbt_lambda_execution_role.arn
  package_type  = "Image"
  image_uri     = local.dbt_ecr_image_uri

  timeout     = 900
  memory_size = 128
}
