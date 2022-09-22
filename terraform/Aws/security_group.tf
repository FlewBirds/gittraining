resource "aws_security_group" "web-sg" {
  name = "webapp-sg"

  ingress {
    from_port   = var.ports_web
    to_port     = var.ports_web
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "tomcat-sg" {
  name = "tomcat-sg"

  ingress {
    from_port   = var.ports_tomcat
    to_port     = var.ports_tomcat
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

