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
    Project = var.cluster-name
  }

  depends_on = [aws_vpc.vpc_eks_vpc]
}

resource "aws_internet_gateway" "vpc_eks_ig" {
  vpc_id = aws_vpc.vpc_eks_vpc.id

  tags = {
    Name = "ig-kilbha"
    Project = var.cluster-name
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
    Project = var.cluster-name
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
    Project = var.cluster-name
  }

  depends_on = [aws_vpc.vpc_eks_vpc]
}

resource "aws_eip" "ngw_eip" {
  count = 3

  domain = "vpc"

  tags = {
    Name = "ngw-eip-${count.index + 1}"
    Project = var.cluster-name
  }

  depends_on = [aws_vpc.vpc_eks_vpc
  ]
}



resource "aws_nat_gateway" "ngw" {
  count = 3

  allocation_id = aws_eip.ngw_eip[count.index].id
  subnet_id     = aws_subnet.pub_subnet[count.index].id

  tags = {
    Name = "nat-gateway-${count.index + 1}"
    Project = var.cluster-name
  }

  depends_on = [aws_eip.ngw_eip]
}

resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.vpc_eks_vpc.id

  route  {
    cidr_block = var.cidr_block
    gateway_id = "local"
  }

  depends_on = [ aws_vpc.vpc_eks_vpc ]

  tags = {
    Name = "kilbha_vpc_rt"
    Project = var.cluster-name
  }
}

resource "aws_main_route_table_association" "main_rta" {
  vpc_id         = aws_vpc.vpc_eks_vpc.id
  route_table_id = aws_route_table.main_rt.id
}



# Private Route Tables
resource "aws_route_table" "pvt_rt" {
  count = 3

  vpc_id = aws_vpc.vpc_eks_vpc.id

  route {
    cidr_block     = var.internet
    nat_gateway_id = aws_nat_gateway.ngw[count.index].id
  }

  tags = {
    Name    = "pvt-rt-${count.index + 1}"
    Project = var.cluster-name
  }

  depends_on = [aws_vpc.vpc_eks_vpc]
}

# Associate each private subnet with its route table
resource "aws_route_table_association" "pvt_rta" {
  count = 3

  subnet_id      = aws_subnet.pvt_subnet[count.index].id
  route_table_id = aws_route_table.pvt_rt[count.index].id
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
    Project = var.cluster-name
  }
}

resource "aws_security_group" "jumpserver-sg" {
  name        = "jumpserver-sg"
  

  vpc_id = aws_vpc.vpc_eks_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    Project = var.cluster-name
  }
}

resource "aws_security_group" "jenkins-sg" {
  name        = "jenkins-sg"
  

  vpc_id = aws_vpc.vpc_eks_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // It should be specific IP range
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // It should be specific IP range
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
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
    Project = var.cluster-name
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

  tags = { Name = "${var.cluster-name}-node-sg", Project = var.cluster-name }
}
