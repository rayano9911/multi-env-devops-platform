variable "project" {
  type        = string
  description = "Project name"
}

variable "env" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the EKS cluster will be deployed"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for EKS cluster"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for EKS nodes"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.29"
  description = "Kubernetes version"
}

variable "instance_types" {
  type        = list(string)
  default     = ["t3.medium"]
  description = "EC2 instance types for the node group"
}

variable "desired_size" {
  type        = number
  default     = 2
  description = "Desired number of worker nodes"
}

variable "min_size" {
  type        = number
  default     = 1
  description = "Minimum number of worker nodes"
}

variable "max_size" {
  type        = number
  default     = 4
  description = "Maximum number of worker nodes"
}

variable "disk_size" {
  type        = number
  default     = 50
  description = "EBS volume size in GB for worker nodes"
}
