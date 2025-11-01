#######################################################
# DynamoDB
#######################################################
resource "aws_dynamodb_table" "users" {
  name         = "users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  tags = {
    Env           = "production"
    Configuration = "terraform"
  }
}
