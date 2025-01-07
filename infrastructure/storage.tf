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

locals {
  hut_info_columns = jsondecode(file("${path.module}/../generated/hut_info.json")).columns
  availability_columns = jsondecode(file("${path.module}/../generated/availability.json")).columns
}

resource "aws_glue_catalog_table" "hut_info" {
  name          = "hut_info"
  database_name = aws_glue_catalog_database.raw_alpine_huts.name

  storage_descriptor {
    location = "s3://${aws_s3_bucket.alpine_huts_data.bucket}/raw-alpine-huts/hut-info/"
    
    dynamic "columns" {
      for_each = local.hut_info_columns

      content {
        name = columns.key
        type = columns.value
      }
    }

    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "raw_alpine_huts"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }
  }

  table_type = "EXTERNAL_TABLE"
}

resource "aws_glue_catalog_table" "availability" {
  name          = "availability"
  database_name = aws_glue_catalog_database.raw_alpine_huts.name

  storage_descriptor {
    location = "s3://${aws_s3_bucket.alpine_huts_data.bucket}/raw-alpine-huts/availability/"
    
    dynamic "columns" {
      for_each = local.availability_columns

      content {
        name = columns.key
        type = columns.value
      }
    }

    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "raw_alpine_huts"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }
  }

  table_type = "EXTERNAL_TABLE"
}
