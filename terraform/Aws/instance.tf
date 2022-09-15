resource "aws_instance" "fb_default_instance" {
  ami = "ami-0568773882d492fc8"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.web-sg.id ]

  user_data = <<-EOF
  #!/bin/bash
  echo "instance created using terraform" > /opt/test
  sudo yum install httpd -y
  sudo systemctl enable httpd
  sudo systemctl start httpd
  EOF

 user_data_replace_on_change = true

  tags = {
    "Name" = "FB_Training"
  }
}