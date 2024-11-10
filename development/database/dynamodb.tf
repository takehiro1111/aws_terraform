#####################################################
# tfstate locks
#####################################################
resource "aws_dynamodb_table" "tfstate_locks" {
  name         = "tfstate-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
