terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.5.0"
}

# 1. VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "e-commerce-app-vpc"
  }
}

# 2. Public Subnet A (us-east-1a)
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name                                      = "e-commerce-app-public-a"
    "kubernetes.io/role/elb"                 = "1"
    # 🔥 EKS cluster adıyla birebir aynı
    "kubernetes.io/cluster/e-commerce-app-ecommerce-eks" = "shared"
  }
}

# 3. Public Subnet B (us-east-1b)
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.20.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name                                      = "e-commerce-app-public-b"
    "kubernetes.io/role/elb"                 = "1"
    # 🔥 Aynı cluster tag
    "kubernetes.io/cluster/e-commerce-app-ecommerce-eks" = "shared"
  }
}

# 4. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "e-commerce-app-igw"
  }
}

# 5. Route Table + Route
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "e-commerce-app-public-rt"
  }
}

# 6. Route Table Associations
resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# 7. Security Group
resource "aws_security_group" "web_sg" {
  vpc_id      = aws_vpc.main.id
  description = "Allow SSH (22) and HTTP (80) traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "e-commerce-app-sg"
  }
}

# 8. EC2 Instance (Test Amaçlı)
resource "aws_instance" "test_ec2" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = var.key_pair_name

  tags = {
    Name = "e-commerce-app-ec2"
  }
}
