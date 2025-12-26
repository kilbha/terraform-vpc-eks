variable "aws-region" {}
variable "cidr_block" {}
variable "internet" {}
variable "pub_subnet_count" {}
variable "pvt_subnet_count" {}
variable "pub_availability_zones" {
  type = list(string)
}
variable "pvt_availability_zones" {
  type = list(string)
}
variable "pub_sub_cidr_block" {
  type = list(string)
}
variable "pvt_sub_cidr_block" {
  type = list(string)
}
variable "eip-ngw" {}
variable "ngw" {}
variable "vpc-name" {
  
}
variable "eks-sg" {
  
}

variable "cluster-name" {
  
}

variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))
}