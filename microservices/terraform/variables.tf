variable "aws_region" {
    description = "The AWS region to deploy resources in"
    type        = string
    default     = "us-east-1"
  
}
variable "project_name" {
    description = "The name of the project"
    type        = string
    default     = "e-commerce-app"
  
}
variable "key_pair_name" {
    description = "The name of the AWS key pair to use for EC2 instances"
    type        = string
    default     = "hsn-keypair"
  
}