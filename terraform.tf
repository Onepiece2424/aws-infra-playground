terraform {
  backend "s3" {
    bucket       = "remote-backend-riorio-bucket"
    key          = "dev/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }
}
