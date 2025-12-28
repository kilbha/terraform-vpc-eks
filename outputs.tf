output "vpc_id" {
  value = module.vpc.vpc-id
}

output "instance_ip" {
  value = module.vpc.jumpserver-ip
}