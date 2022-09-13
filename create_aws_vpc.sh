#!/bin/bash

set -ex

# Create VPC with Private and Public Subnets

#create vpc with name "FBVPC" with cidr 10.0.0.0/16

FBVPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=FBVPC}]'  --output text --query Vpc.VpcId)

sleep 5s

#Create Routetable for Pubsubnet - Named FB_RT_PUB

FB_RT_PUB_ID=$(aws ec2 create-route-table --vpc-id $FBVPC_ID --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=FB_RT_PUB}]' --output text --query RouteTable.RouteTableId)

sleep 5s

# Create Public Subnet - Name FB_PUB_SUB

FB_PUB_SUB_ID=$(aws ec2 create-subnet --vpc-id $FBVPC_ID --cidr-block 10.0.1.0/24 --availability-zone us-west-1b --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=FB_PUB_SUB}]' --output text --query Subnet.SubnetId)

sleep 5s

#Associate public route table(FB_RT_PUB_ID) to Public subnet(FB_PUB_SUB)

aws ec2 associate-route-table --route-table-id $FB_RT_PUB_ID --subnet-id $FB_PUB_SUB_ID

sleep 5s

# Create RT for prvsubnet - Name FB_RT_PRV

FB_RT_PRV_ID=$(aws ec2 create-route-table --vpc-id $FBVPC_ID --tag-specifications 'ResourceType=route-table,Tags=[{Key=Name,Value=FB_RT_PRV}]' --output text --query RouteTable.RouteTableId)

sleep 5s

# Create Private subnet - Named FB_PRV_SUB

FB_PRV_SUB_ID=$(aws ec2 create-subnet --vpc-id $FBVPC_ID --cidr-block 10.0.2.0/24 --availability-zone us-west-1c --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=FB_PRV_SUB}]' --output text --query Subnet.SubnetId)

sleep 5s

#Associate private route table(FB_RT_PRV_ID) to Private subnet(FB_PRV_SUB)

aws ec2 associate-route-table --route-table-id $FB_RT_PRV_ID --subnet-id $FB_PRV_SUB_ID

sleep 5s

# Create Internet Gateway Named FB_IGW

FB_IGW_ID=$(aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=FB_IGW}]' --output text --query InternetGateway.InternetGatewayId)

sleep 5s

# Attach Internet Gateway FB_IGW to VPC - FBVPC_ID

aws ec2 attach-internet-gateway --internet-gateway-id $FB_IGW_ID --vpc-id $FBVPC_ID

sleep 20s

# Now create a route in Public Subnet Route table FB_RT_PUB_ID

aws ec2 create-route --route-table-id $FB_RT_PUB_ID  --destination-cidr-block 0.0.0.0/0 --gateway-id  $FB_IGW_ID

# Allocate/procure ElasticIP EIP for NAT Gateway

FB_EIP_Allocation_ID=$(aws ec2 allocate-address --domain vpc --tag-specifications 'ResourceType=elastic-ip,Tags=[{Key=Name,Value=FB_EIP_NGW}]' --output text --query AllocationId)

# Now create Nat Gateway named FB_NGW which will be created in Public subnet (FB_PUB_SUB)

FB_NGW_ID=$(aws ec2 create-nat-gateway --subnet-id $FB_PUB_SUB_ID --allocation-id $FB_EIP_Allocation_ID --tag-specifications 'ResourceType=natgateway,Tags=[{Key=Name,Value=FB_NGW}]' --output text --query NatGateway.NatGatewayId)

sleep 120s

# Now enable internet access to private subnet (FB_PRV_SUB) by adding Natgateway Route to private subnet (FB_PRV_SUB)

aws ec2 create-route --route-table-id $FB_RT_PRV_ID --destination-cidr-block 0.0.0.0/0 --nat-gateway-id $FB_NGW_ID

echo "VPC ID:   FBVPC_ID"
echo "Route Table PubSub ID:  $FB_RT_PUB_ID"
echo "Public Subnet ID:   $FB_PUB_SUB"
echo "Route Table PrvSub ID:  $FB_RT_PRV_ID"
echo "Private Subnet ID: $FB_PRV_SUB_ID"
echo "Internet Gateway ID: $FB_IGW_ID"
echo "Nat Gateway ID: $FB_NGW_ID"

################################################

sleep 500s

aws ec2 deallocate-address $FB_EIP_Allocation_ID

sleep 5s

aws ec2 delete-nat-gateway --nat-gateway-id $FB_NGW_ID

sleep 120s

aws ec2 delete-internet-gateway --internet-gateway-id $FB_IGW_ID

deassociate delete routetables

delete subnets

aws ec2 delete-vpc --vpc-id $FBVPC_ID
