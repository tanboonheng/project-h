output "account_id" {
  description = "Account ID of AWS"
  value       = data.aws_caller_identity.current.account_id
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS cluster"
  value       = module.eks.eks_cluster_endpoint
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}