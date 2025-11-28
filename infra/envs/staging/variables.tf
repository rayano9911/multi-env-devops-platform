# Staging Environment Variables
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
  default     = "staging"
  description = "Environment name"
}

# VPC Configuration for Staging
variable "vpc_cidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "CIDR block for VPC"
}

variable "public_subnets" {
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
  description = "CIDR blocks for public subnets"
}

variable "private_subnets" {
  type        = list(string)
  default     = ["10.1.11.0/24", "10.1.12.0/24"]
  description = "CIDR blocks for private subnets"
}

# EKS Configuration for Staging
variable "kubernetes_version" {
  type        = string
  default     = "1.29"
  description = "Kubernetes version"
}

variable "desired_size" {
  type        = number
  default     = 2
  description = "Desired number of worker nodes (staging)"
}

variable "min_size" {
  type        = number
  default     = 2
  description = "Minimum number of worker nodes (staging)"
}

variable "max_size" {
  type        = number
  default     = 4
  description = "Maximum number of worker nodes (staging)"
}

variable "instance_types" {
  type        = list(string)
  default     = ["t3.medium"]
  description = "EC2 instance types for staging"
}

variable "disk_size" {
  type        = number
  default     = 50
  description = "EBS volume size in GB"
}
