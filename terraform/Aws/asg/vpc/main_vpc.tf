#wsc - Web Server Cluster

#Project Web Server Cluster - Created VPC #########

### - VPC with Multiple CIDR's - ###

#Step 1: created single CIDR Block - 10.0.0.0/16 is default
resource "aws_vpc" "wsc_vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

    tags = {
    Name = "wsc_vpc"
  }
}

#Step 2: created addition CIDR Block and attached to VPC wsc_vpc
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = aws_vpc.wsc_vpc.id
  cidr_block = "172.2.0.0/16"
}

### - completed creating VPC with Multiple CIDR's - ###

# Pull available zones information from provider aws
data "aws_availability_zones" "us-east-2" {
  state =  "available"
}
### We can refer in the following way to launch resources in required az (us-east-2a, us-east-2b, us-east-2c) ####

### Create two public subnets ###
resource "aws_subnet" "wsc_pub_sub_1" {
  vpc_id     = aws_vpc.wsc_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${data.aws_availability_zones.us-east-2.names[0]}"  # [0] this will represent availablity zone us-east-2a

  tags = {
    Name = "wsc_pub_sub"
  }
}

resource "aws_subnet" "wsc_pub_sub_2" {
  vpc_id     = aws_vpc.wsc_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${data.aws_availability_zones.us-east-2.names[1]}"  # [1] this will represent availablity zone us-east-2b

  tags = {
    Name = "wsc_pub_sub"
  }
}

#### internet gateway #### 
resource "aws_internet_gateway" "wsc_igw" {
    vpc_id = aws_vpc.wsc_vpc.id
}

#### Routing Table ####
resource "aws_route_table" "wsc_pub_sub_rt" {
    vpc_id = aws_vpc.wsc_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wsc_igw.id
  }
   
   tags = {
    Name = "wsc_pub_sub_rt"
   }
}

#### one Route table Associated to multiple subnets (sub 1 & 2) ####
resource "aws_route_table_association" "wsc_pub_sub_rt_associate1" {
      route_table_id = aws_route_table.wsc_pub_sub_rt.id
      subnet_id = aws_subnet.wsc_pub_sub_1.id
}
resource "aws_route_table_association" "wsc_pub_sub_rt_associate2" {
      route_table_id = aws_route_table.wsc_pub_sub_rt.id
      subnet_id = aws_subnet.wsc_pub_sub_2.id
}
#### Prepare Private Subnets ####
### allocate static public IP for ngw ###

resource "aws_eip" "wsc_eip_ngw" {
  vpc      = true
}

### Create NatGateway with eip allocation ###
resource "aws_nat_gateway" "wsc_ngw" {
  allocation_id = aws_eip.wsc_eip_ngw.id
  subnet_id = aws_subnet.wsc_prv_sub_1.id

  tags = {
    "Name" = "wsc_ngw"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency on the Internet Gateway for the VPC.
  depends_on = [
    aws_internet_gateway.wsc_igw
  ]
}

#### Create private subnet using VPC seconday CIDR block ####
resource "aws_subnet" "wsc_prv_sub_1" {
  vpc_id     = aws_vpc.wsc_vpc.id
  cidr_block = "172.2.1.0/24"
  availability_zone = "${data.aws_availability_zones.us-east-2.names[0]}"  # [0] this will represent availablity zone us-east-2a

  tags = {
    Name = "wsc_prv_sub_1"
  }
}

resource "aws_subnet" "wsc_prv_sub_2" {
  vpc_id     = aws_vpc.wsc_vpc.id
  cidr_block = "172.2.2.0/24"
  availability_zone = "${data.aws_availability_zones.us-east-2.names[1]}"  # [1] this will represent availablity zone us-east-2b

  tags = {
    Name = "wsc_prv_sub_2"
  }
}

#### Routing Table for Private Subnet ####
resource "aws_route_table" "wsc_prv_sub_rt" {
    vpc_id = aws_vpc.wsc_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.wsc_igw.id
  }
   
   tags = {
    Name = "wsc_prv_sub_rt"
   }
}




