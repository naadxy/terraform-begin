# Define the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Create an EC2 instance
resource "aws_instance" "this" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.public_subnet_id
  associate_public_ip_address = true

  vpc_security_group_ids = [var.security_group_id]

  tags = {
    Name = var.instance_name
  }

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
}

# Output blocks
output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value = aws_instance.this.public_ip
}
