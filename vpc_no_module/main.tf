# Define the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "naadxy_tf_vpc" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "naadxy-tf-vpc"
  }
}

# Create private subnets with specific CIDR blocks
resource "aws_subnet" "naadxy_private" {
  count = 2
  vpc_id = aws_vpc.naadxy_tf_vpc.id
  cidr_block = element(
    ["10.0.0.16/28", "10.0.0.32/28"],
    count.index
  )
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)

  tags = {
    Name = "naadxy-private-subnet-${count.index + 1}"
  }
}

# Create public subnets with specific CIDR blocks
resource "aws_subnet" "naadxy_public" {
  count = 2
  vpc_id = aws_vpc.naadxy_tf_vpc.id
  cidr_block = element(
    ["10.0.0.48/28", "10.0.0.64/28"],
    count.index
  )
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)

  tags = {
    Name = "naadxy-public-subnet-${count.index + 1}"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "naadxy" {
  vpc_id = aws_vpc.naadxy_tf_vpc.id

  tags = {
    Name = "naadxy-igw"
  }
}

# Create a route table for public subnets and associate it with the Internet Gateway
resource "aws_route_table" "naadxy_public" {
  vpc_id = aws_vpc.naadxy_tf_vpc.id

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
  count = 2
  subnet_id = element(aws_subnet.naadxy_public.*.id, count.index)
  route_table_id = aws_route_table.naadxy_public.id
}

# Create a single route table for private subnets
resource "aws_route_table" "naadxy_private" {
  vpc_id = aws_vpc.naadxy_tf_vpc.id

  tags = {
    Name = "naadxy-private-route-table"
  }
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private" {
  count = 2
  subnet_id = element(aws_subnet.naadxy_private.*.id, count.index)
  route_table_id = aws_route_table.naadxy_private.id
}

# Create a VPC endpoint for S3 to allow private subnets to access S3 without NAT gateway
resource "aws_vpc_endpoint" "naadxy_tf_vpce_s3" {
  vpc_id       = aws_vpc.naadxy_tf_vpc.id
  service_name = "com.amazonaws.us-east-1.s3"

  route_table_ids = [aws_route_table.naadxy_private.id]

  tags = {
    Name = "naadxy-tf-vpce-s3"
  }
}

# Create a security group that allows HTTP, HTTPS, and SSH from anywhere
resource "aws_security_group" "naadxy_tf_sg_allow_ssh_http_https" {
  vpc_id = aws_vpc.naadxy_tf_vpc.id
  name   = "naadxy-tf-sg-allow-ssh-http-https"
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
    Name = "naadxy-tf-sg-allow-ssh-http-https"
  }
}

/* # Create an EC2 instance
resource "aws_instance" "naadxy_tf_instance" {
  ami           = "ami-0b72821e2f351e396"
  instance_type = "t2.micro"
  key_name      = "naadxy"
  subnet_id     = aws_subnet.naadxy_public[0].id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.naadxy_tf_sg_allow_ssh_http_https.id]

  tags = {
    Name = "naadxy-tf-ec2"
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }
}*/

# Output blocks
output "vpc_id" {
  value = aws_vpc.naadxy_tf_vpc.id
  description = "The ID of the VPC."
}

output "s3_endpoint_id" {
  value = aws_vpc_endpoint.naadxy_tf_vpce_s3.id
  description = "The ID of the S3 VPC endpoint."
}

output "igw_id" {
  value = aws_internet_gateway.naadxy.id
  description = "The ID of the Internet Gateway."
}

output "security_group_id" {
  value = aws_security_group.naadxy_tf_sg_allow_ssh_http_https.id
  description = "The ID of the Security Group."
}
