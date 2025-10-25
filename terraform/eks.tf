# Use the official terraform-aws-modules/eks/aws module for simplicity
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = aws_vpc.this.id
  subnet_ids = concat(
    [for s in aws_subnet.public : s.id],
    [for s in aws_subnet.private : s.id]
  )

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
      instance_types   = ["t3.medium"]
      iam_role_arn     = aws_iam_role.eks_node_role.arn
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Data sources to allow helm provider to authenticate after cluster creation
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
  depends_on = [module.eks]
}

### FILE: outputs.tf
output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "kubeconfig_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}