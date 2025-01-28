module "web_sg" {
  source      = "../../modules/security_group"
  name        = "${var.environment}-web-sg"
  description = "Security group for the ${var.environment} web servers"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP traffic"
    }
  }

  tags = {
    Environment = "${var.environment}"
    Team        = "devops"
  }
}

module "eks_cluster_sg" {
  source      = "../../modules/security_group"
  name        = "${var.environment}-eks-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = {
    api = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_block]
      description = "Allow API server access from VPC"
    }
  }

  tags = {
    Environment = var.environment
  }
}

module "eks_nodes_sg" {
  source      = "../../modules/security_group"
  name        = "${var.environment}-eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = {
    cluster_to_node_all_traffic = {
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      cidr_blocks = [var.vpc_cidr_block]
      description = "Allow all traffic from cluster"
    }
  }
  tags = {
    Environment = var.environment
    "kubernetes.io/cluster/${var.environment}-eks-cluster" = "owned"
  }
}

module "mongodb_sg" {
  source      = "../../modules/security_group"
  name        = "${var.environment}-mongodb-sg"
  description = "Security group for MongoDB in ${var.environment}"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = {
    mongodb = {
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_block]
      description = "Allow MongoDB traffic within VPC"
    }
  }

  tags = {
    Environment = var.environment
    Team        = "devops"
    Service     = "mongodb"
  }
}

module "api_sg" {
  source      = "../../modules/security_group"
  name        = "${var.environment}-api-sg"
  description = "Security group for the ${var.environment} API service"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = {
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

  tags = {
    Environment = var.environment
    Team        = "devops"
    Service     = "api"
  }
}