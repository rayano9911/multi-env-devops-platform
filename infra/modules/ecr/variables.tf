variable "project" {
  type        = string
  description = "Project name"
}

variable "env" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "image_tag_mutability" {
  type        = string
  default     = "MUTABLE"
  description = "The tag mutability setting for the repository"
}

variable "scan_on_push" {
  type        = bool
  default     = true
  description = "Indicates whether images are scanned after being pushed to the repository"
}
