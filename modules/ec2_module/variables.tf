variable "ami" {
  description = "The AMI ID for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance."
  type        = string
}

variable "key_name" {
  description = "The key name to use for the EC2 instance."
  type        = string
}

variable "public_subnet_id" {
  description = "The ID of the public subnet to launch the EC2 instance in."
  type        = string
}

variable "security_group_id" {
  description = "The ID of the security group to associate with the EC2 instance."
  type        = string
}

variable "instance_name" {
  description = "The name tag for the EC2 instance."
  type        = string
}

variable "volume_size" {
  description = "The size of the root block device volume."
  type        = number
  default     = 8
}

variable "volume_type" {
  description = "The type of the root block device volume."
  type        = string
  default     = "gp3"
}
