resource "aws_security_group" "web-sg" {
  name = "webapp-sg"
  
  ingress {
    from_port   = var.ports_web
    to_port     = var.ports_web
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}