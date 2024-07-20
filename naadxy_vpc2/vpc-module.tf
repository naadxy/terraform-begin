module "naadxy" {
  source           = "../naadxy_vpc_module"
  vpc_cidr_block   = "10.0.0.0/24"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  region           = "us-east-1"
}

output "vpc_id" {
  value = module.naadxy.vpc_id
}

output "s3_endpoint_id" {
  value = module.naadxy.s3_endpoint_id
}

output "igw_id" {
  value = module.naadxy.igw_id
}
