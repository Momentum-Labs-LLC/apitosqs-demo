terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.32.1"
    }
  }
  backend "s3" {
    bucket       = "mll-infrastructure-management"
    key          = "demos/api-to-sqs/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}