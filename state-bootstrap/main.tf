terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Bu dosya sadece local backend kullanır (geçici)
  backend "local" {}
}

# VARIABLES

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
  default     = "ecommerce"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# PROVIDER

provider "aws" {
  region = var.aws_region
}

# RESOURCES

# Rastgele suffix: bucket isimleri global unique olmalı
resource "random_id" "suffix" {
  byte_length = 4
}

# S3 bucket (Terraform state dosyasını burada tutacağız)
resource "aws_s3_bucket" "tf_state" {
  bucket        = "${var.project_name}-tfstate-${random_id.suffix.hex}"
  force_destroy = false

  tags = {
    Name        = "${var.project_name}-tf-state"
    Environment = "bootstrap"
  }
}

# Bucket versioning (state versiyonlarını saklar)
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket şifreleme (AES256)
resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.tf_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Public erişimi tamamen engelle
resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.tf_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB tablosu (Terraform state lock)
resource "aws_dynamodb_table" "tf_lock" {
  name         = "${var.project_name}-tf-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-tf-lock"
    Environment = "bootstrap"
  }
}

# OUTPUTS

output "state_bucket" {
  description = "Name of the S3 bucket for Terraform remote state"
  value       = aws_s3_bucket.tf_state.bucket
}

output "lock_table" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.tf_lock.name
}
