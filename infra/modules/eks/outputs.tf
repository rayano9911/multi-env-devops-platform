output "cluster_id" {
  value       = aws_eks_cluster.this.id
  description = "The name/id of the EKS cluster"
}

output "cluster_arn" {
  value       = aws_eks_cluster.this.arn
  description = "The Amazon Resource Name (ARN) of the cluster"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.this.endpoint
  description = "Endpoint for your Kubernetes API server"
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
  description = "Base64 encoded certificate data required to communicate with the cluster"
}

output "cluster_security_group_id" {
  value       = aws_security_group.eks_cluster_sg.id
  description = "Security group ID attached to the EKS cluster"
}

output "node_group_id" {
  value       = aws_eks_node_group.this.id
  description = "EKS node group ID"
}

output "node_security_group_id" {
  value       = aws_security_group.eks_node_sg.id
  description = "Security group ID attached to the EKS nodes"
}
