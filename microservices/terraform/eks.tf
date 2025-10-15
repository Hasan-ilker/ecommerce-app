
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"   
  cluster_name    = "${var.project_name}-ecommerce-eks"  
  cluster_version = "1.30"                    
  vpc_id          = aws_vpc.main.id           
  subnet_ids      = [aws_subnet.public_a.id, aws_subnet.public_b.id] # multi-AZ yapı
  cluster_endpoint_public_access = true    
  cluster_endpoint_private_access = false  
  enable_irsa = true                       

  eks_managed_node_groups = {
    default = {
      desired_size = 2  
      max_size     = 3
      min_size     = 1

      instance_types = ["t3.small"]  
      capacity_type  = "SPOT"        
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = var.project_name
  }
}

resource "aws_eks_access_entry" "hasan_ilker_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::952732862406:user/hasan-ilker"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "hasan_ilker_admin_policy" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = aws_eks_access_entry.hasan_ilker_admin.principal_arn

  access_scope {
    type = "cluster"
  }
}
# 🧠 EKS node grubunun ECR'dan imaj çekebilmesi için gerekli izin
resource "aws_iam_policy_attachment" "node_ecr_pull" {
  name       = "eks-node-ecr-pull"
  roles      = [module.eks.eks_managed_node_groups["default"].iam_role_name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version"
  value       = module.eks.cluster_version
}

