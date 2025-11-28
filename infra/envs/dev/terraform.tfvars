# Development Environment Variables
# ===========================================

project = "multi-env-devops-platform"
region  = "us-east-1"
env     = "dev"

# VPC Configuration
vpc_cidr         = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

# EKS Configuration
kubernetes_version = "1.29"
instance_types     = ["t3.small"]
desired_size       = 1
min_size          = 1
max_size          = 2
disk_size         = 30

# Tags
# These are automatically applied via default_tags in provider configuration
