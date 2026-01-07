resource "aws_instance" "jenkins_instance" {

  ami                    = "ami-0e7938ad51d883574"
  instance_type          = var.ondemand_instance_types[0]
  key_name               = "rama-sobha"
  vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
  subnet_id              = aws_subnet.pub_subnet[0].id
  user_data              = base64encode(file("jenkins_installations.sh"))

  root_block_device {
    delete_on_termination = true    
    volume_size = 30
  }
  

  depends_on = [ aws_subnet.pub_subnet[0], aws_security_group.jenkins-sg ]

  tags = {
    Name = "jenkins_instance"
  }
}