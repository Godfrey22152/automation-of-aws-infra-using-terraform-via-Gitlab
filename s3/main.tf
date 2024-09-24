# VARIABLES
variable "bucket_name" {}
variable "name" {}
variable "environment" {}

output "remote_state_s3_bucket_name" {
  value = aws_s3_bucket.remote_state_bucket.id
}

# Resource to create S3 Bucket
resource "aws_s3_bucket" "remote_state_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

#resource to enable Server-side encryption in the S3
resource "aws_s3_bucket_server_side_encryption_configuration" "server_encrpt" {
  bucket = aws_s3_bucket.remote_state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# Resource to create DynamoDB-table
/*resource "aws_dynamodb_table" "statelock" {
  name           = "state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "env"
  }
}*/