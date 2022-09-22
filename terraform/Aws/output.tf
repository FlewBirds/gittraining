output "instance_fb_id" {
  value = aws_instance.fb_default_instance.id
  description = "FB Instance ID"
}

output "dynamodb_table" {
  value = aws_dynamodb_table.tfstate_lock.name
  description = "Dynbamodb table name"
}

output "security_group_tomcat" {
  value = aws_security_group.tomcat-sg.id
  description = "tomcat security group"
}

output "security_group_web" {
  value = aws_security_group.web-sg.id
  description = "web security group"
}