output "eks_cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "eks_cluster_id" {
  value = aws_eks_cluster.this.id
}

output "eks_cluster_name" {
  value = aws_eks_cluster.this.name
}

output "node_group_iam_role_name" {
  value = aws_iam_role.node_group.name
}

output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_oidc_issuer_url" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}