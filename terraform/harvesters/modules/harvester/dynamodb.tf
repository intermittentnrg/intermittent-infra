resource "aws_dynamodb_table" "this" {
  name         = var.name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "time"

  attribute {
    name = "time"
    type = "N"
  }
}
