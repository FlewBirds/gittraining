#wsc - Web Server Cluster

#Project Web Server Cluster - Created VPC #########

### - VPC with Multiple CIDR's - ###

#Step 1: created single CIDR Block - 10.0.0.0/16 is default
resource "aws_vpc" "wsc_vpc" {
  #cidr_block = "10.0.0.0/16"
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"

    tags = {
    Name = "wsc_vpc"
  }
}

output "vpc_cidr" {
  value = aws_vpc.wsc_vpc.cidr_block
}

#Step 2: created addition CIDR Block and attached to VPC wsc_vpc
resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = aws_vpc.wsc_vpc.id
  #cidr_block = "10.1.0.0/16"
  cidr_block = var.secondary_cidr
}

### - completed creating VPC with Multiple CIDR's - ###

# Pull available zones information from provider aws
data "aws_availability_zones" "us-east-2" {
  state =  "available"
}

resource "aws_subnet" "wsc_pub_subnets" {
  count = var.vpc_pub_subnet_count
  vpc_id     = aws_vpc.wsc_vpc.id
  #cidr_block = var.vpc_pub_subnets_cidr_block[count.index]
  #cidr_block = [for subnet in range(var.vpc_subnet_count) : cidrsubnet(aws_vpc.wsc_vpc.cidr_block, 8, subnet)]
  cidr_block = cidrsubnet(aws_vpc.wsc_vpc.cidr_block, 8, count.index)
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
      count = var.vpc_pub_subnet_count
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
  count = var.vpc_prv_subnet_count
  vpc_id     = aws_vpc.wsc_vpc.id
  #cidr_block = var.vpc_prv_subnets_cidr_block[count.index]
  cidr_block = cidrsubnet(aws_vpc_ipv4_cidr_block_association.secondary_cidr.cidr_block, 8, count.index)
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
      count = var.vpc_prv_subnet_count
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

  resource "aws_instance" "wsc_ec2_vms_pub" {
    count = "${length(aws_subnet.wsc_pub_subnets[*])}"
    ami             = nonsensitive(data.aws_ssm_parameter.ami.value)
    instance_type   = var.instance_type
    subnet_id       = aws_subnet.wsc_pub_subnets[count.index].id
    
    depends_on = [
      aws_subnet.wsc_pub_subnets, aws_subnet.wsc_prv_subnets
    ]

  }

  resource "aws_instance" "wsc_ec2_vms_prv" {
    count = "${length(aws_subnet.wsc_prv_subnets[*])}"
    ami             = nonsensitive(data.aws_ssm_parameter.ami.value)
    instance_type   = var.instance_type
    subnet_id       = aws_subnet.wsc_prv_subnets[count.index].id
    
    depends_on = [
      aws_subnet.wsc_pub_subnets, aws_subnet.wsc_prv_subnets
    ]
  }

#cidrsubnet(prefix, newbits, netnum)


###########

resource "aws_iam_user" "test" {
  count = 3
  name = "test.{count.index}"
}

for (i = 0; i < 3; i++) {
  resource "aws_iam_user" "test" {
  name = "test.${i}"
}
}

test.0
test.1
test.2

variable "iam_user"{
  type = list(string)
  defdefault = [ "ramesh", "vijay", "kishore", "krishna" ]
}


resource "aws_iam_user" "iamuser"{
  count = length(var.iam_user)
  name = var.iam_user[count.index]
}

resource "aws_iam_user" "test" {
  count = 3
  name = "test.{count.index}"
}

output "user_arns" {
  value = aws_iam_user.iamuser[*].arn
}

module "users" {
  source = "../../ec2_instances"
 count = length(var.iam_user)
 user_name = var.iam_user[count.index] 
}

variable "vpcs" {
  type = map(object({
    cidr = string
    tags = map(string)
    tenancy = string
  }))
  default = {
    vpc_one = {
      cidr = "10.0.0.0/16"
      tags = {
        Name = "vpc_one"
      }
      tenancy = "default"
    }
    vpc_two = {
       cidr = "10.1.0.0/16"
      tags = {
        Name = "vpc_two"
      }
      tenancy = "default"
    }
  }

}

resource "aws_vpc" "mul_pvc" {
  for_each = var.vpcs
  cidr_block = each.value["cidr"]
  instance_tenancy = each.value["tenancy"]
  tags = each.value["tags"]
}