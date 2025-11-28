# VPC Outputs
output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "vpc_cidr" {
  value       = module.vpc.vpc_cidr
  description = "VPC CIDR block"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Private subnet IDs"
}

output "nat_gateway_ips" {
  value       = module.vpc.nat_gateway_ips
  description = "NAT Gateway IPs"
}

# ECR Outputs
output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "ECR Repository URL"
}

output "ecr_repository_name" {
  value       = module.ecr.repository_name
  description = "ECR Repository Name"
}

# EKS Outputs
output "eks_cluster_id" {
  value       = module.eks.cluster_id
  description = "EKS Cluster ID"
}

output "eks_cluster_endpoint" {
  value       = module.eks.cluster_endpoint
  description = "EKS Cluster Endpoint"
}

output "eks_cluster_certificate_authority_data" {
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
  description = "EKS Cluster Certificate Authority Data"
}

output "eks_node_group_id" {
  value       = module.eks.node_group_id
  description = "EKS Node Group ID"
}

# Summary
output "deployment_summary" {
  value = {
    project             = var.project
    environment         = var.env
    region              = var.region
    vpc_id              = module.vpc.vpc_id
    ecr_repository_url  = module.ecr.repository_url
    eks_cluster_name    = module.eks.cluster_id
    eks_cluster_endpoint = module.eks.cluster_endpoint
  }
  description = "Deployment Summary"
}
