provider "aws" {
  alias = "use2"
  region = "us-east-2"
}

module "ec2" {
  source = "./ec2"
  providers = {
    aws = "aws.use2"
  }
}

module "s3" {
  source = "./s3"
  providers = {
    aws = "aws.use2"
  }
}
