resource "aws_athena_workgroup" "analyst" {
  name = "analyst"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.alpine_huts_data.bucket}/query-results/analyst/"
    }
  }

  state = "ENABLED"
}
