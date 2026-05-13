terraform {
  required_providers {
    aws = {
      version               = "~> 6.0"
      source                = "hashicorp/aws"
      configuration_aliases = [aws.bucket-replication]
    }
  }
  required_version = "~> 1.0"
}
