# VPC Bilgileri

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "subnet_a_id" {
  description = "The ID of the created public subnet in us-east-1a"
  value       = aws_subnet.public_a.id
}

output "subnet_b_id" {
  description = "The ID of the created public subnet in us-east-1b"
  value       = aws_subnet.public_b.id
}

# EC2 Bilgileri

output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.test_ec2.id
}

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.test_ec2.public_ip
}

output "ec2_public_dns" {
  description = "The public DNS name of the EC2 instance"
  value       = aws_instance.test_ec2.public_dns
}

# Security Group Bilgisi

output "security_group_id" {
  description = "The ID of the security group attached to the EC2 instance"
  value       = aws_security_group.web_sg.id
}
