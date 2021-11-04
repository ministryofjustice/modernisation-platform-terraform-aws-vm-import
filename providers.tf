provider "aws" {
  alias  = "bucket-replication"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::${var.account_number}:role/MemberInfrastructureAccess"
  }
}
