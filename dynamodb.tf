resource "aws_dynamodb_table" "state-lock" {
  name         = var.dynamodb_table_name
  billing_mode = var.dynamodb_table_billing_mode
  hash_key     = var.lock_key_id

  attribute {
    name = var.lock_key_id
    type = "S"
  }

  server_side_encryption {
    enabled     = var.dynamodb_server_side_encryption
    kms_key_arn = aws_kms_key.s3_backend.arn
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = var.tags
}