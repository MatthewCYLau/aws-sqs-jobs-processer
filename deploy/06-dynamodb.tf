resource "aws_dynamodb_table" "jobs" {
  name             = "jobs"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "jobId"
  range_key        = "created"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "jobId"
    type = "S"
  }

  attribute {
    name = "created"
    type = "S"
  }

  local_secondary_index {
    name            = "byCreated"
    projection_type = "ALL"
    range_key       = "created"
  }
}