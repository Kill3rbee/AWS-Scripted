#!/bin/bash

# example script to make a new vpc
vpcname=MYVPC
deployzone=eu-west-1

# make a new vpc with a master 10.0.0.0/16 subnet
vpc_id=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --output text --query 'Vpc.VpcId')
echo vpc_id=$vpc_id

# enable dns support or modsecurity wont let apache start...
aws ec2 modify-vpc-attribute --vpc-id $vpc_id --enable-dns-support
aws ec2 modify-vpc-attribute --vpc-id $vpc_id --enable-dns-hostnames

# tag the vpc
aws ec2 create-tags --resources $vpc_id --tags Key=vpcname,Value=$vpcname

# wait for the vpc
echo -n "waiting for vpc..."
while state=$(aws ec2 describe-vpcs --filters Name=tag-key,Values=vpcname --filters Name=tag-value,Values=$vpcname --output text --query 'Vpcs[*].State'); test "$state" = "pending"; do
 echo -n . ; sleep 3;
done; echo " $state"

# create an internet gateway (to allow access out to the internet)
igw=$(aws ec2 create-internet-gateway --output text --query 'InternetGateway.InternetGatewayId')
echo igw=$igw

# attach the igw to the vpc
echo attaching igw
aws ec2 attach-internet-gateway --internet-gateway-id $igw --vpc-id $vpc_id

# create our main subnet
# we use 10.0.0.0/24 as our main subnet
subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.0.0/24 --availability-zone $deployzone --output text --query 'Subnet.SubnetId')
echo subnet_id=$subnet_id

# get the route table id for the vpc
rtb_id=$(aws ec2 describe-route-tables --filters Name=vpc-id,Values=$vpc_id --output text --query 'RouteTables[*].RouteTableId')
echo rtb_id=$rtb_id

# associate this subnet with our route table
aws ec2 associate-route-table --subnet-id $subnet_id --route-table-id $rtb_id

# create a route out from our route table to the igw
echo creating route from igw
aws ec2 create-route --route-table-id $rtb_id --gateway-id $igw --destination-cidr-block 0.0.0.0/0

# done
echo vpc setup done
