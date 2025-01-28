variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
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

variable "node_instance_types" {
  description = "List of instance types for the EKS node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of nodes in the EKS node group"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of nodes in the EKS node group"
  type        = number
  default     = 1
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = list(string)
}

variable "availability_zone" {
  description = "Availability zone for the subnets"
  type        = list(string)
}

variable "private_subnet_count" {
  description = "Count of private subnet"
  type        = number
}

variable "public_subnet_count" {
  description = "Count of public subnet"
  type        = number
}