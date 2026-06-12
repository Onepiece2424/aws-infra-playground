output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "api_private_ip" {
  value = aws_instance.api.private_ip
}

output "vpc_id" {
  value = aws_vpc.main.id
}
