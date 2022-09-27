output "subnet_prv" {
  value = ["${aws_subnet.wsc_prv_subnets.*.id}"]
  description = "list public subnets"
}

output "vpc_wsc" {
  value = aws_vpc.wsc_vpc.id
  description = "print vpc id"
}

output "prv_instances" {
  value = ["${aws_instance.wsc_ec2_vms_prv.*.id}"]
  description = "print private instance id's"
}

output "pub_instnaces" {
  value = ["${aws_instance.wsc_ec2_vms_pub.*.id}"]
  description = "Print public instance id's"
}
output "pub_sunets" {
  value = ["${aws_subnet.wsc_pub_subnets.*.cidr_block}"]
  description = "list cidr blocks created for public subnet"
}

output "prv_sunets" {
  value = ["${aws_subnet.wsc_prv_subnets.*.cidr_block}"]
  description = "list cidr blocks created for public subnet"
}