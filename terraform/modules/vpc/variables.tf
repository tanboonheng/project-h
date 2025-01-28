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

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "public_subnet_count" {
  description = "Count of public subnet"
  type        = number
}

variable "private_subnet_count" {
  description = "Count of public subnet"
  type        = number
}