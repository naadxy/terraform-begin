# Define the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.vpc_name
  }
}

# Create private subnets in two different availability zones
resource "aws_subnet" "private" {
  count = 2
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 4, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

# Create public subnets in two different availability zones
resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 4, count.index + 8)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Create a route table for public subnets and associate it with the Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.vpc_name}-public-route-table"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count = 2
  subnet_id = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# Create a single route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-private-route-table"
  }
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private" {
  count = 2
  subnet_id = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

# Create a VPC endpoint for S3 to allow private subnets to access S3 without NAT gateway
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${var.region}.s3"

  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name = "${var.vpc_name}-vpce-s3"
  }
}

# Create a security group that allows HTTP, HTTPS, and SSH from anywhere
resource "aws_security_group" "this" {
  vpc_id = aws_vpc.this.id
  name   = "${var.vpc_name}-sg"
  description = "Allow SSH, HTTP, and HTTPS ingress from anywhere, all egress."

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-sg"
  }
}

# Output blocks
output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "s3_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
}
