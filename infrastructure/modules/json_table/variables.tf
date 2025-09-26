variable "database_name" {
  type        = string
  description = "Name of the glue database"
}
variable "table_name" {
  type        = string
  description = "Name of the glue table"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name where the data is stored"
}

variable "glue_schema_location" {
  type        = string
  description = "Path to the JSON schema file for the Glue table"
}
