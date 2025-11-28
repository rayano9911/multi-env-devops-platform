# Production Environment Variables
variable "project" {
  type        = string
  default     = "multi-env-devops-platform"
  description = "Project name"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "env" {
  type        = string
  default     = "prod"
  description = "Environment name"
}

# VPC Configuration for Production
variable "vpc_cidr" {
  type        = string
  default     = "10.2.0.0/16"
  description = "CIDR block for VPC"
}

variable "public_subnets" {
  type        = list(string)
  default     = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
  description = "CIDR blocks for public subnets"
}

variable "private_subnets" {
  type        = list(string)
  default     = ["10.2.11.0/24", "10.2.12.0/24", "10.2.13.0/24"]
  description = "CIDR blocks for private subnets"
}

# EKS Configuration for Production
variable "kubernetes_version" {
  type        = string
  default     = "1.29"
  description = "Kubernetes version"
}

variable "desired_size" {
  type        = number
  default     = 3
  description = "Desired number of worker nodes (prod)"
}

variable "min_size" {
  type        = number
  default     = 3
  description = "Minimum number of worker nodes (prod)"
}

variable "max_size" {
  type        = number
  default     = 6
  description = "Maximum number of worker nodes (prod)"
}

variable "instance_types" {
  type        = list(string)
  default     = ["t3.large"]
  description = "EC2 instance types for prod"
}

variable "disk_size" {
  type        = number
  default     = 100
  description = "EBS volume size in GB"
}
