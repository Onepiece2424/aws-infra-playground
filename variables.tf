variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "my_ip" {
  type = string
}

variable "key_name" {
  default = "deployer-key"
}

variable "public_key_path" {
  default = "~/.ssh/terraform-aws-infra-playground.pub"
}
