# Define the AWS provider
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source             = "./vpc_module"
  cidr_block         = "10.0.0.0/24"
  vpc_name           = "naadxy-tf-vpc"
  availability_zones = ["us-east-1a", "us-east-1b"]
  region             = "us-east-1"
}

module "ec2" {
  source             = "./ec2_module"
  ami                = "ami-0b72821e2f351e396"
  instance_type      = "t2.micro"
  key_name           = "naadxy"
  public_subnet_id   = module.vpc.public_subnet_ids[0]
  security_group_id  = module.vpc.security_group_id
  instance_name      = "naadxy-tf-ec2"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_ip" {
  value = module.ec2.public_ip
}

output "instance_id" {
  value = module.ec2.instance_id
}

output "security_group_id" {
  value = module.vpc.security_group_id
}
