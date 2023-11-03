resource "aws_dynamodb_table" "taggifiles_terraform_lock" {
  name         = "non-prod-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}