locals {
  database_name = "raw_alpine_huts"
  database_storage_key = replace(local.database_name, "_", "-")
  bucket_name = "fab-alpine-huts-data"
}

resource "aws_s3_bucket" "alpine_huts_data" {
  bucket = local.bucket_name
}

resource "aws_glue_catalog_database" "raw_alpine_huts" {
  name = local.database_name
}
