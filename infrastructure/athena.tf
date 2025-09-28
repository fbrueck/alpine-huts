resource "aws_athena_workgroup" "analyst" {
  name = "analyst"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.alpine_huts_data.bucket}/query-results/analyst/"
    }
  }

  state = "ENABLED"
}

resource "aws_athena_workgroup" "app" {
  name = "app"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.alpine_huts_data.bucket}/query-results/app/"
    }
  }

  state = "ENABLED"
}

resource "aws_iam_policy" "athena_query_policy" {
  name        = "athena-query-policy"
  description = "Policy to allow Athena queries and access results in S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.alpine_huts_data.bucket}/query-results/app",
          "arn:aws:s3:::${aws_s3_bucket.alpine_huts_data.bucket}/query-results/app/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetDatabase",
          "glue:GetDatabases"
        ]
        Resource = "*"
      }
    ]
  })
}
