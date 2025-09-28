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

