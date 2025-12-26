
resource "aws_eks_cluster" "eks" {
  name     = var.cluster-name
  role_arn = aws_iam_role.eks_cluster_controle_plane_role.arn
  version  = var.cluster-version

  vpc_config {    
    subnet_ids              = [aws_subnet.pvt_subnet[0].id, aws_subnet.pvt_subnet[1].id, aws_subnet.pvt_subnet[2].id]
    endpoint_private_access = true   # recommended for production
    endpoint_public_access  = false  # restrict public access
    security_group_ids      = [aws_security_group.eks-cluster-sg.id]
  }
}

resource "aws_eks_node_group" "ondemand" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster-name}-ondemand"  
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids      = [aws_subnet.pvt_subnet[0].id, aws_subnet.pvt_subnet[1].id, aws_subnet.pvt_subnet[2].id]
  instance_types  = var.ondemand_instance_types
  scaling_config { 
    desired_size = 2
    min_size = 1
    max_size = 3
 }
  labels = { lifecycle = "ondemand" }
  capacity_type = "ON_DEMAND"

  depends_on = [ aws_eks_cluster.eks ]
}

resource "aws_eks_node_group" "spot" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster-name}-spot"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  subnet_ids      = [aws_subnet.pvt_subnet[0].id, aws_subnet.pvt_subnet[1].id, aws_subnet.pvt_subnet[2].id]
  instance_types  = var.onspot_instance_types
  scaling_config { 
    desired_size = 2
    min_size = 1
    max_size = 3
 }
  labels = { lifecycle = "spot", type="spot" }
  capacity_type = "SPOT"

  disk_size = 50

  depends_on = [ aws_eks_cluster.eks ]
}

# AddOns for EKS Cluster
resource "aws_eks_addon" "eks-addons" {
  for_each      = { for idx, addon in var.addons : idx => addon }
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = each.value.name
  addon_version = each.value.version

  depends_on = [
    aws_eks_node_group.ondemand,
    aws_eks_node_group.spot
  ]
}