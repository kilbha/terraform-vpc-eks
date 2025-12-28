resource "aws_instance" "kilbha_instance1" {

  ami                    = "ami-0e7938ad51d883574"
  instance_type          = var.ondemand_instance_types[0]
  key_name               = "rama-sobha"
  vpc_security_group_ids = [aws_security_group.jumpserver-sg.id]
  subnet_id              = aws_subnet.pub_subnet[0].id
  user_data              = base64encode(file("installation-jumpserver.sh"))

  depends_on = [ aws_subnet.pub_subnet[0], aws_security_group.jumpserver-sg ]

  tags = {
    Name = "kilbha_instance"
  }
}