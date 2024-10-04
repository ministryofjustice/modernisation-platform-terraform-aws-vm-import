provider "aws" {
  alias  = "bucket-replication"
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${var.account_number}:role/MemberInfrastructureAccess"
  }
}
