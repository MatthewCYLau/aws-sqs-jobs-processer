resource "aws_dynamodb_table" "jobs" {
  name             = "jobs"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "jobId"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "jobId"
    type = "S"
  }
}