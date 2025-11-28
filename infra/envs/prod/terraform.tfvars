# Production Environment Variables
# ===========================================

project = "multi-env-devops-platform"
region  = "us-east-1"
env     = "prod"

# VPC Configuration
vpc_cidr         = "10.2.0.0/16"
public_subnets  = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
private_subnets = ["10.2.11.0/24", "10.2.12.0/24", "10.2.13.0/24"]

# EKS Configuration
kubernetes_version = "1.29"
instance_types     = ["t3.large"]
desired_size       = 3
min_size          = 3
max_size          = 6
disk_size         = 100

# Tags
# These are automatically applied via default_tags in provider configuration
