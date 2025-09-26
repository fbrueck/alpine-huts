locals {
  bucket_name   = var.s3_bucket_name
  database_name = var.database_name
  table_name    = var.table_name
  columns       = jsondecode(file(var.glue_schema_location)).columns

  database_storage_key = replace(local.database_name, "_", "-")
  storage_key          = replace(local.table_name, "_", "-")
  storage_location     = "s3://${local.bucket_name}/${local.database_storage_key}/${local.storage_key}/"
}

resource "aws_glue_catalog_table" "table" {
  name          = local.table_name
  database_name = var.database_name

  storage_descriptor {
    location = local.storage_location

    dynamic "columns" {
      for_each = {
        for k in sort(keys(local.columns)) : k => local.columns[k]
      }

      content {
        name = columns.key
        type = columns.value
      }
    }

    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = local.database_name
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }
  }

  table_type = "EXTERNAL_TABLE"
}
