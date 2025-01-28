region            = "us-east-1"
availability_zone = ["us-east-1a", "us-east-1b"]
environment       = "dev"

## EKS 
eks_cluster_role_policies = [
  "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
  "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy",
  "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy",
  "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
]


node_group_policies = [
  "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
  "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
]

## VPC
vpc_cidr_block       = "10.0.0.0/21"
private_subnet_count = 2
public_subnet_count  = 2
private_subnet_cidr  = ["10.0.0.0/24", "10.0.1.0/24"]
public_subnet_cidr   = ["10.0.2.0/24", "10.0.3.0/24"]
