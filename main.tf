module "vpc" {
  source = "./module/vpc"

  eip-ngw                = var.eip-ngw
  pvt_sub_cidr_block     = var.pvt_sub_cidr_block
  pvt_availability_zones = var.pvt_availability_zones
  cidr_block             = var.cidr_block
  pvt_subnet_count       = var.pvt_subnet_count
  internet               = var.internet
  pub_subnet_count       = var.pub_subnet_count
  pub_availability_zones = var.pub_availability_zones
  eks-sg                 = var.eks-sg
  vpc-name               = var.vpc-name
  pub_sub_cidr_block     = var.pub_sub_cidr_block
  ngw                    = var.ngw
  aws-region             = var.aws-region
  cluster-name           = var.cluster-name
  endpoint_public_access  = var.endpoint_public_access
  endpoint_private_access = var.endpoint_private_access
  cluster-version         = var.cluster-version
  ondemand_instance_types = var.ondemand_instance_types
  onspot_instance_types   = var.onspot_instance_types
  addons = var.addons
}
