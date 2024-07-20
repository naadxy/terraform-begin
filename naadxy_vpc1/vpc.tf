# Define the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "naadxy" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "naadxy"
  }
}

# Create private subnets in three different availability zones
resource "aws_subnet" "naadxy_private" {
  count = 3
  vpc_id = aws_vpc.naadxy.id
  # Use cidrsubnet() function to generate subnet CIDR block from the VPC CIDR block
  cidr_block = cidrsubnet(aws_vpc.naadxy.cidr_block, 4, count.index)
  availability_zone = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)

  tags = {
    Name = "naadxy-private-subnet-${count.index + 1}"
  }
}

# Create public subnets in three different availability zones
resource "aws_subnet" "naadxy_public" {
  count = 3
  vpc_id = aws_vpc.naadxy.id
  # Use cidrsubnet() function to generate subnet CIDR block from the VPC CIDR block
  # Add 8 to the count index to ensure the public subnets are in different CIDR blocks
  cidr_block = cidrsubnet(aws_vpc.naadxy.cidr_block, 4, count.index + 8)
  availability_zone = element(["us-east-1a", "us-east-1b", "us-east-1c"], count.index)

  tags = {
    Name = "naadxy-public-subnet-${count.index + 1}"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "naadxy" {
  vpc_id = aws_vpc.naadxy.id

  tags = {
    Name = "naadxy-igw"
  }
}

# Create a route table for public subnets and associate it with the Internet Gateway
resource "aws_route_table" "naadxy_public" {
  vpc_id = aws_vpc.naadxy.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.naadxy.id
  }

  tags = {
    Name = "naadxy-public-route-table"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count = 3
  subnet_id = element(aws_subnet.naadxy_public.*.id, count.index)
  route_table_id = aws_route_table.naadxy_public.id
}

# Create route tables for private subnets
resource "aws_route_table" "naadxy_private" {
  count  = 3
  vpc_id = aws_vpc.naadxy.id

  tags = {
    Name = "naadxy-private-route-table-${count.index + 1}"
  }
}

# Associate private subnets with their respective route tables
resource "aws_route_table_association" "private" {
  count = 3
  subnet_id = element(aws_subnet.naadxy_private.*.id, count.index)
  route_table_id = element(aws_route_table.naadxy_private.*.id, count.index)
}

# Create a VPC endpoint for S3 to allow private subnets to access S3 without NAT gateway
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.naadxy.id
  service_name = "com.amazonaws.us-east-1.s3"

  route_table_ids = aws_route_table.naadxy_private.*.id

  tags = {
    Name = "naadxy-s3-endpoint"
  }
}

# Output blocks
output "vpc_id" {
  value = aws_vpc.naadxy.id
  description = "The ID of the VPC."
}

output "s3_endpoint_id" {
  value = aws_vpc_endpoint.s3.id
  description = "The ID of the S3 VPC endpoint."
}

output "igw_id" {
  value = aws_internet_gateway.naadxy.id
  description = "The ID of the Internet Gateway."
}