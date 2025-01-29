data "aws_caller_identity" "current" {}

module "eks" {
  source                    = "../../modules/eks_cluster"
  environment               = var.environment
  eks_cluster_role_policies = var.eks_cluster_role_policies
  subnet_ids                = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)
  node_instance_types       = var.node_instance_types
  node_group_policies       = var.node_group_policies
  node_desired_size         = var.node_desired_size
  node_max_size             = var.node_max_size
  node_min_size             = var.node_min_size
  depends_on                = [module.vpc]
}


data "tls_certificate" "eks" {
  url = module.eks.cluster_oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = module.eks.cluster_oidc_issuer_url

  tags = {
    Name        = "${var.environment}-eks-oidc"
    Environment = var.environment
  }
}

resource "aws_iam_role" "ebs_csi_driver" {
  name = "${var.environment}-ebs-csi-driver"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" : "sts.amazonaws.com",
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

# Add the policy attachment for EBS CSI Driver
resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}

# Update EKS addon configuration
resource "aws_eks_addon" "ebs" {
  cluster_name             = module.eks.eks_cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  depends_on = [
    aws_iam_role_policy_attachment.ebs_csi_policy,
    aws_iam_openid_connect_provider.eks,
    module.eks
  ]
}
