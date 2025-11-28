# Development Environment Variables
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
  default     = "dev"
  description = "Environment name"
}

# VPC Configuration for Dev
variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for VPC"
}

variable "public_subnets" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "CIDR blocks for public subnets"
}

variable "private_subnets" {
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
  description = "CIDR blocks for private subnets"
}

# EKS Configuration for Dev
variable "kubernetes_version" {
  type        = string
  default     = "1.29"
  description = "Kubernetes version"
}

variable "desired_size" {
  type        = number
  default     = 1
  description = "Desired number of worker nodes (dev)"
}

variable "min_size" {
  type        = number
  default     = 1
  description = "Minimum number of worker nodes (dev)"
}

variable "max_size" {
  type        = number
  default     = 2
  description = "Maximum number of worker nodes (dev)"
}

variable "instance_types" {
  type        = list(string)
  default     = ["t3.small"]
  description = "EC2 instance types for dev"
}

variable "disk_size" {
  type        = number
  default     = 30
  description = "EBS volume size in GB"
}

