module "vpc" {
  source               = "../../modules/vpc"
  vpc_cidr_block       = var.vpc_cidr_block
  public_subnet_count  = var.public_subnet_count
  private_subnet_count = var.private_subnet_count
  private_subnet_cidr  = var.private_subnet_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  availability_zone    = var.availability_zone
  environment          = var.environment
}