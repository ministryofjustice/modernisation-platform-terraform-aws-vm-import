provider "aws" {
  alias  = "bucket-replication"
  region = "eu-west-2"
  assume_role {
    role_arn = "arn:aws:iam::276038508461:role/MemberInfrastructureAccess"
  }
}
