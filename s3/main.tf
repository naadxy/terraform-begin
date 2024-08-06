terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create AWS S3
resource "aws_s3_bucket" "bucket" {
  bucket = "naadxy-tf-test-bucket" # Change to a globally unique name

  tags = {
    Name        = "naadxy Bucket" # Change to your own name
    Environment = "test"
  }
}


