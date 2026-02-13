provider "aws" {
  alias  = "management"
  region = "us-east-1"
}

provider "aws" {
  alias  = "member"
  region = "us-east-1"

  assume_role {
    role_arn     = "arn:aws:iam::${var.aws_account_id}:role/OrganizationAccountAccessRole"
    session_name = "terraform-access"
  }

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "all"
      Terraform   = "true"
    }
  }
}