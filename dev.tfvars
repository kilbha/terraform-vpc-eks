cidr_block             = "10.0.0.0/16"
aws-region             = "ap-south-2"
internet               = "0.0.0.0/0"
pub_subnet_count       = 3
pvt_subnet_count       = 3
pub_availability_zones = ["ap-south-2a", "ap-south-2b", "ap-south-2c"]
pvt_availability_zones = ["ap-south-2a", "ap-south-2b", "ap-south-2c"]
pub_sub_cidr_block     = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
pvt_sub_cidr_block     = ["10.0.64.0/20", "10.0.80.0/20", "10.0.96.0/20"]
eip-ngw                = "elasticip-ngw-kilbha"
ngw                    = "nat-gateway-kilbha"
vpc-name               = "kilbha"
eks-sg                 = "eks-sg-kilbha"

cluster-name            = "vpc-eks"
ondemand_instance_types = ["t3.medium"]
onspot_instance_types   = ["t3.medium"]
endpoint_private_access = true
endpoint_public_access  = false
cluster-version         = "1.33"
addons = [
  {
    name    = "vpc-cni",
    version = "v1.20.0-eksbuild.1"
  },
  {
    name    = "coredns"
    version = "v1.12.2-eksbuild.4"
  },
  {
    name    = "kube-proxy"
    version = "v1.33.0-eksbuild.2"
  },
  {
    name    = "aws-ebs-csi-driver"
    version = "v1.46.0-eksbuild.1"
  }
  # Add more addons as needed
]