locals {
  database_name        = "raw_alpine_huts"
  database_storage_key = replace(local.database_name, "_", "-")
  bucket_name          = "fab-alpine-huts-data"

  hut_info_table_name     = "hut_info"
  availability_table_name = "availability"
}

resource "aws_s3_bucket" "alpine_huts_data" {
  bucket = local.bucket_name
}

resource "aws_glue_catalog_database" "raw_alpine_huts" {
  name = local.database_name
}

module "availability_table" {
  source               = "./modules/json_table"
  table_name           = local.availability_table_name
  database_name        = local.database_name
  s3_bucket_name       = local.bucket_name
  glue_schema_location = "${path.root}/../generated/${local.availability_table_name}.json"
}


module "hut_info_table" {
  source               = "./modules/json_table"
  table_name           = local.hut_info_table_name
  database_name        = local.database_name
  s3_bucket_name       = local.bucket_name
  glue_schema_location = "${path.root}/../generated/${local.hut_info_table_name}.json"
}
