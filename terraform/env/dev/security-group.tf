module "eks_cluster_sg" {
  source      = "../../modules/security_group"
  name        = "${var.environment}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP traffic"
    }
    api = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_block]
      description = "Allow API server access from VPC"
    }
    cluster_to_node = {
      from_port   = 10250
      to_port     = 10250
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_block]
      description = "Allow kubelet API access from cluster"
    }
    mongodb = {
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_block]
      description = "Allow MongoDB traffic within VPC"
    }
    service_port = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_block]
      description = "Allow traffic to service port"
    }
    container_port = {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_block]
      description = "Allow traffic to container port"
    }
  }

  egress_rules = {
    "all_outbound" = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  }

  tags = {
    Environment = var.environment
    Team        = "devops"
    Service     = "eks"
  }
}
