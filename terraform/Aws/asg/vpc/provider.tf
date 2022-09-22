terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.31.0"
    }
  }
    backend "s3" {
    bucket = "fbstate1"
    key = "dev/tfstate/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "tfstate_lock"
    encrypt = true
    # depends_on = [ aws_dynamodb_table.tfstate_lock ]
  }

}

provider "aws" {
  profile = "srk"
  region = "us-east-2"
}

resource "aws_dynamodb_table" "tfstate_lock" {
  name = "tfstate_lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
    }
#   region = "us-east-2"
  }

