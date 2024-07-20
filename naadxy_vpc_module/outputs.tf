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
