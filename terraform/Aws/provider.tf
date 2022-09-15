terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.30.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-2"
  # access_key = "<access key>"
  # secret_key = "<secret key>"

  shared_config_files      = ["/Users/rsrighakollapu/.aws/confif"]
  shared_credentials_files = ["/Users/rsrighakollapu/.aws/credentials"]
  # profile                  = "customprofile"

  # assume_role {
  #   role_arn     = "arn:aws:iam::123456789012:role/ROLE_NAME"
  #   session_name = "SESSION_NAME"
  #   external_id  = "EXTERNAL_ID"
  # }

  # assume_role {
  #   role_arn                = "arn:aws:iam::123456789012:role/ROLE_NAME"
  #   session_name            = "SESSION_NAME"
  #   web_identity_token_file = "/Users/tf_user/secrets/web-identity-token"
  # }

}


#################
# export evn

#Types of authentication methods supoorted by terraform with aws provider
#export
#Paramters in the provider config
#shared credentials
#Shared Configuration files
#Container Credentials
#Instance profile credentials and region


# provider "aws" {
#   shared_config_files      = ["/Users/tf_user/.aws/conf"]
#   shared_credentials_files = ["/Users/tf_user/.aws/creds"]
#   profile                  = "customprofile"
# }
