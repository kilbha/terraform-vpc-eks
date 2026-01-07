output "vpc-id" {
  value = aws_vpc.vpc_eks_vpc.id
}

output "jumpserver-ip" {
  value = aws_instance.kilbha_instance1.public_ip
}

output "jenkins-ip" {
  value = aws_instance.jenkins_instance.public_ip
}