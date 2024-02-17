resource "aws_dynamodb_table" "aeso" {
  name = "aeso"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "time"

  attribute {
    name = "time"
    type = "N"
  }
}
