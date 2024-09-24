terraform {
  backend "s3" {
    bucket         = "dev-project-remote-state-bucket-22152"
    dynamodb_table = "state-lock" 
    key            = "devops-project/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}
