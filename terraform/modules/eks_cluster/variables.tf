# variable "eks_role_arn" {
#   description = "The IAM role ARN for the EKS cluster"
#   type        = string
# }
# 
# variable "eks_node_role_arn" {
#   description = "The IAM role ARN for the EKS node group"
#   type        = string
# }

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for the EKS node group"
  type        = list(string)
}

variable "node_desired_size" {
  description = "Desired size of the EKS node group"
  type        = number
}

variable "node_max_size" {
  description = "Maximum size of the EKS node group"
  type        = number
}

variable "node_min_size" {
  description = "Minimum size of the EKS node group"
  type        = number
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "eks_cluster_role_policies" {
  description = "List of policies to attach to the EKS cluster role"
  type        = list(string)
} 

variable "node_group_policies" {
  description = "List of policies to attach to the EKS node group"
  type        = list(string)
}


