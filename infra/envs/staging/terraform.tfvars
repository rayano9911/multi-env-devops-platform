# Staging Environment Variables
# ===========================================

project = "multi-env-devops-platform"
region  = "us-east-1"
env     = "staging"

# VPC Configuration
vpc_cidr         = "10.1.0.0/16"
public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnets = ["10.1.11.0/24", "10.1.12.0/24"]

# EKS Configuration
kubernetes_version = "1.29"
instance_types     = ["t3.medium"]
desired_size       = 2
min_size          = 2
max_size          = 4
disk_size         = 50

# Tags
# These are automatically applied via default_tags in provider configuration
