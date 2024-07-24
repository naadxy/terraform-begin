variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC."
  type        = string
}

variable "availability_zones" {
  description = "The list of availability zones to create subnets in."
  type        = list(string)
}

variable "region" {
  description = "The AWS region."
  type        = string
}
