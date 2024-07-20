variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/24"
}

variable "availability_zones" {
  description = "A list of availability zones."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "region" {
  description = "The AWS region to deploy the resources."
  type        = string
  default     = "us-east-1"
}
