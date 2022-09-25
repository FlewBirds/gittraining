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
### We can refer in the following way to launch resources in required az (us-east-2a, us-east-2b, us-east-2c) ####

### Create two public subnets ###
# resource "aws_subnet" "wsc_pub_sub_1" {
#   vpc_id     = aws_vpc.wsc_vpc.id
#   cidr_block = "10.0.1.0/24"
#   availability_zone = "${data.aws_availability_zones.us-east-2.names[0]}"  # [0] this will represent availablity zone us-east-2a

#   tags = {
#     Name = "wsc_pub_sub"
#   }
# }

# resource "aws_subnet" "wsc_pub_sub_2" {
#   vpc_id     = aws_vpc.wsc_vpc.id
#   cidr_block = "10.0.2.0/24"
#   availability_zone = "${data.aws_availability_zones.us-east-2.names[1]}"  # [1] this will represent availablity zone us-east-2b

#   tags = {
#     Name = "wsc_pub_sub"
#   }
# }

# create subnet using functions

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

### one Route table Associated to multiple subnets (sub 1 & 2) ####
# resource "aws_route_table_association" "wsc_pub_sub_rt_associate1" {
#       route_table_id = aws_route_table.wsc_pub_sub_rt.id
#       subnet_id = aws_subnet.wsc_pub_sub_1.id
# }
# resource "aws_route_table_association" "wsc_pub_sub_rt_associate2" {
#       route_table_id = aws_route_table.wsc_pub_sub_rt.id
#       subnet_id = aws_subnet.wsc_pub_sub_2.id
# }

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

#### Create private subnet using VPC seconday CIDR block ####
# resource "aws_subnet" "wsc_prv_sub_1" {
#   vpc_id     = aws_vpc.wsc_vpc.id
#   cidr_block = "172.2.1.0/24"
#   availability_zone = "${data.aws_availability_zones.us-east-2.names[0]}"  # [0] this will represent availablity zone us-east-2a

#   tags = {
#     Name = "wsc_prv_sub_1"
#   }
# }

# resource "aws_subnet" "wsc_prv_sub_2" {
#   vpc_id     = aws_vpc.wsc_vpc.id
#   cidr_block = "172.2.2.0/24"
#   availability_zone = "${data.aws_availability_zones.us-east-2.names[1]}"  # [1] this will represent availablity zone us-east-2b

#   tags = {
#     Name = "wsc_prv_sub_2"
#   }
# }

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

###### create EC2 Instances in each subnet one instance  ########

variable "instance_type" {
  type        = string
  description = "Type for EC2 Instnace"
  default     = "t2.micro"
}

data "aws_ssm_parameter" "ami" {
  name            = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# data "aws_subnet_ids" "exmaple" {
#   vpc_id = var.vpc_id
# }

# data "aws_subnet" "example" {
#   for_each = data.aws_subnet_ids.example.ids
#   id       = each.value
# }

# data "aws_subnets" "private" {
#   vpc_id = aws_vpc.wsc_vpc.id

#   tags = {
#     Tier = "Private"
#   }
# }

  resource "aws_instance" "wsc_ec2_vms_pub" {
    #for_each        = data.aws_subnets.private
    #for_each = aws_subnet.wsc_pub_subnets
    #count           = var.vpc_subnet_count
    #for_each = {for cnt in aws_subnet.wsc_pub_subnets[*]: cnt.aws_subnet_ids => cnt}
  #   for_each = {for cnt in aws_subnet.wsc_pub_subnets[*].id: 
  #   cnt. => cnt
  #   #if x.tags["Access"] == "public"
  #  # if cnt.tags["Tier"] == "Public"
  #   }
    count = "${length(aws_subnet.wsc_pub_subnets[*])}"
    ami             = nonsensitive(data.aws_ssm_parameter.ami.value)
    instance_type   = var.instance_type
    #subnet_id       = each.value.id
    subnet_id       = aws_subnet.wsc_pub_subnets[count.index].id
    
    depends_on = [
      aws_subnet.wsc_pub_subnets, aws_subnet.wsc_prv_subnets
    ]

  }


########## Create public network instances ##############
#   data "aws_subnet_ids" "public" {
#   vpc_id = aws_vpc.wsc_vpc.id

#   tags = {
#     Tier = "Public"
#   }
# }

#   resource "aws_instance" "wsc_ec2_vms_prv" {
#     #for_each        = data.aws_subnets.private
#     #for_each = aws_subnet.wsc_pub_subnets[*]
#     #count           = var.vpc_subnet_count
#     count           = 
#     ami             = nonsensitive(data.aws_ssm_parameter.ami.value)
#     instance_type   = var.instance_type
#     #subnet_id       = each.value.id
#     subnet_id       = aws_subnet.wsc_prv_subnets[*].id
    
#     depends_on = [
#       aws_subnet.wsc_pub_subnets, aws_subnet.wsc_prv_subnets
#     ]
#   }

