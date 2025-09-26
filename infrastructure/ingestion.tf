locals {
  ingestion_repo_name = replace(local.ingestion_prefix, "_", "-")
  ecr_image_base_uri  = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${local.region}.amazonaws.com"
  ecr_image_uri       = "${local.ecr_image_base_uri}/${local.ingestion_repo_name}:latest"
}

resource "aws_ecr_repository" "alpine_huts_ingestion" {
  name = local.ingestion_repo_name
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "${local.ingestion_prefix}_role"
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

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name = "${local.ingestion_prefix}_s3_policy"
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

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_lambda_function" "alpine_huts_ingestion" {
  function_name = local.ingestion_prefix
  role          = aws_iam_role.lambda_execution_role.arn
  package_type  = "Image"
  image_uri     = local.ecr_image_uri

  timeout     = 900
  memory_size = 128
}
