output "vpc_id" {
  value = module.vpc.vpc-id
}

output "jumpserver_ip" {
  value = module.vpc.jumpserver-ip
}

output "jenkins_ip" {
  value = module.vpc.jenkins-ip
}