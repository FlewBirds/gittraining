module "vpc_stage" {
    source = "/Users/rsrighakollapu/Documents/FB_Training/gittraining/terraform/aws/functions"
   
   vpc_pub_subnet_count = 3
   vpc_prv_subnet_count = 3
   vpc_cidr = "10.0.0.0/16"
   secondary_cidr = "10.1.0.0/16"

}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.30.0"
    }

  }
}
provider "aws" {
  profile = "srk"
}

#   }

#   backend "s3" {
#     bucket = "fbstate1"
#     key = "dev/tfstate/terraform.tfstate"
#     region = "us-east-2"

#     dynamodb_table = "tfstate_lock"
#     encrypt = true
#   }