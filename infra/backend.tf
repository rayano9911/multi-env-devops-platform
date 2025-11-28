terraform {
  backend "s3" {
    bucket         = "multi-env-rayan" 
    key            = "multi-env-platform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks" 
    encrypt        = true
  }
}
