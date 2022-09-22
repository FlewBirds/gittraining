#wsc - Web Server Cluster

resource "aws_vpc" "wsc_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

    tags = {
    Name = "wsc_vpc"
  }
}
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = aws_vpc.wsc_vpc.id
  cidr_block = "172.2.0.0/16"
}

data "aws_availability_zones" "us-east-2" {
  state =  "available"
}

resource "aws_subnet" "wsc_pub_sub_1" {
  vpc_id     = aws_vpc.wsc_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${data.aws_availability_zones.us-east-2.names[0]}"

  tags = {
    Name = "wsc_pub_sub"
  }
}

resource "aws_subnet" "wsc_pub_sub_2" {
  vpc_id     = aws_vpc.wsc_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${data.aws_availability_zones.us-east-2.names[1]}"

  tags = {
    Name = "wsc_pub_sub"
  }
}

resource "aws_internet_gateway" "wsc_igw" {
    vpc_id = aws_vpc.wsc_vpc.id
}

resource "aws_route_table" "wsc_pub_sub_rt" {
    vpc_id = aws_vpc.wsc_vpc.id

    route {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.wsc_igw.id
  }
   
   tags = {
    Name = "wsc_pub_sub_rt_1"

   }
  
}

resource "aws_route_table_association" "wsc_pub_sub_rt_associate" {
      route_table_id = aws_route_table.wsc_pub_sub_rt.id
      subnet_id = aws_subnet.wsc_pub_sub_1.id
}






