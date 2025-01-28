resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block
#  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-vpc"
  }
}

resource "aws_subnet" "private" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr[count.index]
  availability_zone = var.availability_zone[count.index]
  tags = {
    Name = "${var.environment}-private-subnet"
  }
}

resource "aws_subnet" "public" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidr[count.index]
  availability_zone       = var.availability_zone[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-public-subnet"
  }
}

# Internet Gateway - Enables internet connectivity for the VPC
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# Elastic IP for NAT Gateway - Static public IP
resource "aws_eip" "nat" {
  count = var.public_subnet_count
  domain   = "vpc"

  tags = {
    Name = "${var.environment}-nat-eip-${count.index + 1}"
  }

  # Ensure IGW exists before creating EIP
  depends_on = [aws_internet_gateway.this]
}

# NAT Gateway - Allows private subnets internet access
resource "aws_nat_gateway" "this" {
  count         = var.public_subnet_count
  allocation_id = aws_eip.nat[count.index].id
  
  # Place NAT Gateway in public subnets
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.environment}-nat-gw-${count.index + 1}"
  }

  # Ensure public subnet and internet gateway are ready
  depends_on = [
    aws_internet_gateway.this, 
    aws_subnet.public
  ]
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

# Route Table for Private Subnets - Using NAT Gateway
resource "aws_route_table" "private" {
  count  = var.public_subnet_count
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = {
    Name = "${var.environment}-private-rt-${count.index + 1}"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate Private Subnets with Private Route Tables
resource "aws_route_table_association" "private" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}