resource "aws_dynamodb_table" "results" {
  name             = "results"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "requestId"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "requestId"
    type = "S"
  }
}