terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.50"
    }
  }
  backend "s3" {
    bucket       = "amzn-s3-remote-backend-riorio-bucket"
    key          = "dev/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }

  required_version = ">= 1.2"
}
