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
  cidr_block = "10.1.0.0/16"
}

### - completed creating VPC with Multiple CIDR's - ###

# Pull available zones information from provider aws
data "aws_availability_zones" "us-east-2" {
  state =  "available"
}

resource "aws_subnet" "wsc_pub_subnets" {
  count = var.vpc_subnet_count
  vpc_id     = aws_vpc.wsc_vpc.id
  cidr_block = var.vpc_pub_subnets_cidr_block[count.index]
  availability_zone = "${data.aws_availability_zones.us-east-2.names[count.index]}"  # [0] this will represent availablity zone us-east-2a
  map_public_ip_on_launch = true
  tags = {
    Name = "wsc_pub_sub_${count.index}"
    Tier = "Public"
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

resource "aws_route_table_association" "wsc_pub_sub_rt_associate" {
      count = var.vpc_subnet_count
      route_table_id = aws_route_table.wsc_pub_sub_rt.id
      subnet_id = aws_subnet.wsc_pub_subnets[count.index].id
}

#### Prepare Private Subnets ####
### allocate static public IP for ngw ###

resource "aws_eip" "wsc_eip_ngw" {
  vpc      = true
}

### Create NatGateway with eip allocation ###
resource "aws_nat_gateway" "wsc_ngw" {
  allocation_id = aws_eip.wsc_eip_ngw.id
  subnet_id = aws_subnet.wsc_prv_subnets[0].id

  tags = {
    "Name" = "wsc_ngw"
  }
  # To ensure proper ordering, it is recommended to add an explicit dependency on the Internet Gateway for the VPC.
  depends_on = [
    aws_internet_gateway.wsc_igw
  ]
}

resource "aws_subnet" "wsc_prv_subnets" {
  count = var.vpc_subnet_count
  vpc_id     = aws_vpc.wsc_vpc.id
  cidr_block = var.vpc_prv_subnets_cidr_block[count.index]
  availability_zone = "${data.aws_availability_zones.us-east-2.names[count.index]}"  # [0] this will represent availablity zone us-east-2a
  map_public_ip_on_launch = false

  tags = {
    Name = "wsc_prv_sub_${count.index}"
    Tier = "Private"
  }
}

#### Routing Table for Private Subnet ####
resource "aws_route_table" "wsc_prv_sub_rt" {
    vpc_id = aws_vpc.wsc_vpc.id

    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.wsc_ngw.id
  }
   
   tags = {
    Name = "wsc_prv_sub_rt"
   }
}


resource "aws_route_table_association" "wsc_prv_sub_rt_associate" {
      count = var.vpc_subnet_count
      route_table_id = aws_route_table.wsc_prv_sub_rt.id
      subnet_id = aws_subnet.wsc_prv_subnets[count.index].id
}


