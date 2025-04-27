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

########################################################################
# Error Log Transfer V3
########################################################################
resource "aws_dynamodb_table" "error_logtransfer_v3" {
  name         = "error_logtransfer_v3"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "src"

  attribute {
    name = "src"
    type = "S"
  }
}

resource "aws_dynamodb_table_item" "error_logtransfer_v3" {
  for_each = toset([
    "test-error-logtransfer",
  ])
  table_name = aws_dynamodb_table.error_logtransfer_v3.name
  hash_key   = aws_dynamodb_table.error_logtransfer_v3.hash_key

  item = jsonencode({
    "src" = {
      "S" : each.key
    },
    "blacklist" = {
      "L" : [{ "S" : "INFO" }]
    },
    "channel_id" = {
      "S" : "C02PY437UM6"
    },
    "notification_setting" = {
      "L" : [{ "M" : { "level" : { "S" : "error" } } }]
    }
  })
}
