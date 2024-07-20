provider "aws" {
  region  = "us-east-1"
}

# VPC Creation
resource "aws_vpc" "NaadxyVPC" {
  cidr_block = "10.0.0.0/26"

  tags = {
    Name = "NaadxyVPC"
  }
}

# Subnet Creation
resource "aws_subnet" "NaadxySubnet1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/28"
  availability_zone = "us-east-1a"

  tags = {
    Name = "NaadxySubnet1"
  }
}

# Internet Gateway Creation
/* resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "NaadxyIGW"
  }
} */

# Attach Internet Gateway to VPC
resource "aws_internet_gateway_attachment" "gw_attachment" {
  internet_gateway_id = aws_internet_gateway.gw.id
  vpc_id              = aws_vpc.main.id
}

# Get VPC ID
output "vpc_id" {
  value = aws_vpc.main.id
}
