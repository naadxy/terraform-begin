provider "aws" {
  region = "us-east-1"
}

# Create the Security Group in the specified VPC
resource "aws_security_group" "naadxy_sg" {
  vpc_id      = "vpc-002ecc6073fff8640"
  name        = "naadxy-sg"
  description = "naadxy-ec2-sg"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "naadxy-sg"
  }
}

# Create the EC2 instance
resource "aws_instance" "naadxy_ec2" {
  ami           = "ami-0b72821e2f351e396"
  instance_type = "t2.micro"
  key_name      = "naadxy"
  subnet_id     = "subnet-02c83446ee6fc0e70"

  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.naadxy_sg.id]

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = "naadxy-ec2"
  }
}

# Output the instance ID, public IP, and security group ID
output "instance_id" {
  value       = aws_instance.naadxy_ec2.id
  description = "The ID of the EC2 instance."
}

output "public_ip" {
  value       = aws_instance.naadxy_ec2.public_ip
  description = "The public IP of the EC2 instance."
}

output "security_group_id" {
  value       = aws_security_group.naadxy_sg.id
  description = "The ID of the security group."
}
