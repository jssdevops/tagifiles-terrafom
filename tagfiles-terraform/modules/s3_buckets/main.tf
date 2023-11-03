
//dynamo-db table Bucket

resource "aws_s3_bucket" "terraform_state" {
  bucket = "non-prod-tagifiles-tfstate"

}

// 

resource "aws_s3_bucket" "public-clients-dev-bucket" {
  bucket = "public-clients-dev-bucket"
  tags = {
    Name        = "Core Services Bucket"
    Environment = "Non-prod-core-services"
  }
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket = aws_s3_bucket.public-clients-dev-bucket.id
  acl    = "private"
}

resource "aws_s3_account_public_access_block" "public-clients-dev-bucket-acl" {
  block_public_acls   = true
  block_public_policy = true
}