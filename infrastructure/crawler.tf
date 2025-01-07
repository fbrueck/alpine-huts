resource "aws_glue_crawler" "raw_alpine_huts" {
  name          = "${local.ingestion_prefix}"
  database_name = aws_glue_catalog_database.raw_alpine_huts.name
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${local.bucket_name}/${local.database_storage_key}"
  }

  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "LOG"
  }

  configuration = jsonencode({
    "Version" : 1.0,
    "Grouping" : {
      "TableGroupingPolicy" : "CombineCompatibleSchemas",
      "TableLevelConfiguration" : 3
    }
  })
}

resource "aws_iam_role" "glue_role" {
  name = "${local.ingestion_prefix}_glue_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = { Service = "glue.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_policy" "glue_s3_policy" {
  name = "${local.ingestion_prefix}_glue_s3_access_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws:s3:::fab-alpine-huts-data",
          "arn:aws:s3:::fab-alpine-huts-data/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetTableVersion",
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:CreateDatabase",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:DeleteTable",
          "glue:UpdatePartition",
          "glue:BatchCreatePartition",
          "glue:BatchDeletePartition",
          "glue:BatchGetPartition",
          "glue:GetPartitions",
        ],
        "Resource" : [
          "arn:aws:glue:${local.region}:${local.account_id}:catalog",
          "arn:aws:glue:${local.region}:${local.account_id}:database/raw_alpine_huts",
          "arn:aws:glue:${local.region}:${local.account_id}:table/raw_alpine_huts/*",
          "arn:aws:glue:${local.region}:${local.account_id}:table/raw_alpine_huts/raw_alpine_huts/*"
        ]
      }


    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_s3_policy.arn
}
