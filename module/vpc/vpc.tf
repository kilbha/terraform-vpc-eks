resource "aws_vpc" "vpc_eks_vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.vpc-name
  }
}

resource "aws_subnet" "pub_subnet" {
  count                   = var.pub_subnet_count
  vpc_id                  = aws_vpc.vpc_eks_vpc.id
  cidr_block              = element(var.pub_sub_cidr_block, count.index)
  availability_zone       = element(var.pub_availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "pub_subnet-kilbha"
  }

  depends_on = [aws_vpc.vpc_eks_vpc]
}

resource "aws_internet_gateway" "vpc_eks_ig" {
  vpc_id = aws_vpc.vpc_eks_vpc.id

  tags = {
    Name = "ig-kilbha"
  }

  depends_on = [aws_vpc.vpc_eks_vpc]
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_eks_vpc.id

  route {
    cidr_block = var.internet
    gateway_id = aws_internet_gateway.vpc_eks_ig.id
  }

  tags = {
    Name = "public_rt_kilbha"
  }

  depends_on = [aws_vpc.vpc_eks_vpc]
}

resource "aws_route_table_association" "pub_rta" {
  count          = var.pub_subnet_count
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.pub_subnet[count.index].id

  depends_on = [aws_subnet.pub_subnet]
}

resource "aws_subnet" "pvt_subnet" {
  count                   = var.pvt_subnet_count
  vpc_id                  = aws_vpc.vpc_eks_vpc.id
  cidr_block              = element(var.pvt_sub_cidr_block, count.index)
  availability_zone       = element(var.pvt_availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "pvt_subnet_kilbha"
  }

  depends_on = [aws_vpc.vpc_eks_vpc]
}

resource "aws_eip" "ngw-eip" {
  domain = "vpc"

  tags = {
    Name = var.eip-ngw
  }

  depends_on = [aws_vpc.vpc_eks_vpc
  ]

}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw-eip.id
  subnet_id     = aws_subnet.pub_subnet[0].id

  tags = {
    Name = var.ngw
  }


  depends_on = [aws_eip.ngw-eip]
}

resource "aws_route_table" "pvt_rt" {
  vpc_id = aws_vpc.vpc_eks_vpc.id

  route {
    cidr_block     = var.internet
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "pvt_rt_kilbha"
  }

  depends_on = [aws_vpc.vpc_eks_vpc]
}

resource "aws_route_table_association" "pvt_rta" {
  count          = var.pvt_subnet_count
  route_table_id = aws_route_table.pvt_rt.id
  subnet_id      = aws_subnet.pvt_subnet[count.index].id

  depends_on = [aws_subnet.pvt_subnet]
}

resource "aws_security_group" "eks-cluster-sg" {
  name        = var.eks-sg
  description = "Allow 443 from Jump Server only"

  vpc_id = aws_vpc.vpc_eks_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // It should be specific IP range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.eks-sg
  }
}

resource "aws_security_group" "eks_node_sg" {
  name   = "${var.cluster-name}-nodes-sg"
  vpc_id = aws_vpc.vpc_eks_vpc.id

  # Allow nodes to talk to control plane on HTTPS
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks-cluster-sg.id]
  }

  tags = { Name = "${var.cluster-name}-node-sg" }
}
