resource "aws_iam_user" "streamlit_user" {
  name = "streamlit-athena-user"
}

resource "aws_iam_user_policy_attachment" "user_policy_attach" {
  user       = aws_iam_user.streamlit_user.name
  policy_arn = aws_iam_policy.athena_query_policy.arn
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
          "athena:GetQueryResults",
          "athena:GetWorkGroup",
        ]
        Resource = "arn:aws:athena:${local.region}:${local.account_id}:workgroup/app"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.alpine_huts_data.bucket}/query-results/app/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.alpine_huts_data.bucket}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.alpine_huts_data.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.alpine_huts_data.bucket}"
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
