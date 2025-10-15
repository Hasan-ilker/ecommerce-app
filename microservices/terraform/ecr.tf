# ECR (Elastic Container Registry) - Docker image'larını saklamak için
variable "ecr_retain_images" {
  type        = number
  default     = 15
  description = "Her repo için tutulacak en yeni image sayısı"
}

# Backend ECR
resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-backend" 
  image_tag_mutability = "MUTABLE"                     
  force_delete         = true                          

  image_scanning_configuration {
    scan_on_push = true                                # Push'ta güvenlik taraması
  }

  tags = {
    Project = var.project_name
    Service = "backend"
    ManagedBy = "terraform"
  }
}

# Frontend ECR
resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-frontend" 
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = var.project_name
    Service = "frontend"
    ManagedBy = "terraform"
  }
}

# Backend lifecycle policy 
resource "aws_ecr_lifecycle_policy" "backend" {
  repository = aws_ecr_repository.backend.name
  policy     = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the latest ${var.ecr_retain_images} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.ecr_retain_images
        }
        action = { type = "expire" }
      }
    ]
  })
}

# Frontend lifecycle policy
resource "aws_ecr_lifecycle_policy" "frontend" {
  repository = aws_ecr_repository.frontend.name
  policy     = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the latest ${var.ecr_retain_images} images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = var.ecr_retain_images
        }
        action = { type = "expire" }
      }
    ]
  })
}


output "backend_repo_url" {
  description = "Backend ECR repository URL"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_repo_url" {
  description = "Frontend ECR repository URL"
  value       = aws_ecr_repository.frontend.repository_url
}
