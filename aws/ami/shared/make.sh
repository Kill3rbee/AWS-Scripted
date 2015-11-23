#!/bin/bash

# makes a secure linux box image, hardened
# ssh on 38142
# XGB EBS root volume

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./ami/shared/make.sh"
 exit
fi

# include global variables
. ./master/vars.sh

# a complex string needed to specify EBS volume size
bdm=[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"VolumeSize\":$sharedebsvolumesize}}]
echo bdm=$bdm

# hosts change, we don't need this
rm -f $sshknownhosts

cd $basedir

# get our ip from amazon
myip=$(curl http://checkip.amazonaws.com/)
echo myip=$myip

# make a new keypair
echo "making keypair"
rm credentials/basic.pem
aws ec2 delete-key-pair --key-name basic
aws ec2 create-key-pair --key-name basic --query 'KeyMaterial' --output text > credentials/basic.pem
chmod 600 credentials/basic.pem
echo "keypair made"

# make a security group
vpc_id=$(aws ec2 describe-vpcs --filters Name=tag-key,Values=vpcname --filters Name=tag-value,Values=$vpcname --output text --query 'Vpcs[*].VpcId')
echo vpc_id=$vpc_id
sg_id=$(aws ec2 create-security-group --group-name basicsg --description "basic security group" --vpc-id $vpc_id --output text --query 'GroupId')
echo sg_id=$sg_id
# tag it
aws ec2 create-tags --resources $sg_id --tags Key=sgname,Value=basicsg
vpcbasicsg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=basicsg --output text --query 'SecurityGroups[*].GroupId')
echo vpcbasicsg_id=$vpcbasicsg_id
# allow SSH in on port 22 from our ip only
aws ec2 authorize-security-group-ingress --group-id $vpcbasicsg_id --protocol tcp --port 22 --cidr $myip/32

# get our main subnet id
subnet_id=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpc_id --filters Name=tag-key,Values=subnet --filters Name=tag-value,Values=1 --output text --query 'Subnets[*].SubnetId')
echo subnet_id=$subnet_id

# make the instance on 10.0.0.9
instance_id=$(aws ec2 run-instances --image $baseami --key basic --security-group-ids $vpcbasicsg_id --placement AvailabilityZone=$deployzone --instance-type $sharedinstancetype --block-device-mapping $bdm --region $deployregion --subnet-id $subnet_id --private-ip-address 10.0.0.9 --associate-public-ip-address --output text --query 'Instances[*].InstanceId')
echo instance_id=$instance_id

# wait for it
echo -n "waiting for instance"
while state=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].State.Name'); test "$state" = "pending"; do
 echo -n . ; sleep 3;
done; echo " $state"

# get the new instance's public ip address
ip_address=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ip_address=$ip_address

# wait for ssh to work
echo -n "waiting for ssh"
while ! ssh -i credentials/basic.pem -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no ec2-user@$ip_address > /dev/null 2>&1 true; do
 echo -n . ; sleep 3;
done; echo " ssh ok"

# send required files
echo "transferring files"
scp -i credentials/basic.pem ami/shared/secure.sh ec2-user@$ip_address:
scp -i credentials/basic.pem ami/shared/check.sh ec2-user@$ip_address:
scp -i credentials/basic.pem ami/shared/sshd_config ec2-user@$ip_address:
scp -i credentials/basic.pem ami/shared/yumupdate.sh ec2-user@$ip_address:
echo "transferred files"

# run the secure script
echo "running secure.sh"
ssh -i credentials/basic.pem -t ec2-user@$ip_address sudo ./secure.sh
echo "finished secure.sh"

# now ssh is on 38142
echo "adding port 38142 to sg"
aws ec2 authorize-security-group-ingress --group-id $vpcbasicsg_id --protocol tcp --port 38142 --cidr $myip/32
echo "sg updated"

# instance is rebooting, wait for ssh again
echo -n "waiting for ssh"
while ! ssh -i credentials/basic.pem -p 38142 -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no ec2-user@$ip_address > /dev/null 2>&1 true; do
 echo -n . ; sleep 3;
done; echo " ssh ok"

# run a check script, you should check this output
echo "running check.sh"
ssh -i credentials/basic.pem -p 38142 -t -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no ec2-user@$ip_address sudo ./check.sh
echo "finished check.sh"

# make the image
echo "creating image"
image_id=$(aws ec2 create-image --instance-id $instance_id --name "Basic Secure Linux" --description "Basic Secure Linux AMI" --output text --query 'ImageId')
echo image_id=$image_id

# wait for the image
echo -n "waiting for image"
while state=$(aws ec2 describe-images --image-id $image_id --output text --query 'Images[*].State'); test "$state" = "pending"; do
 echo -n . ; sleep 3;
done; echo " $state"

# terminate the instance
aws ec2 terminate-instances --instance-ids $instance_id

# wait for termination
echo -n "waiting for instance termination"
while state=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].State.Name'); test "$state" != "terminated"; do
 echo -n . ; sleep 3;
done; echo " $state"

# delete the key
echo deleting key
rm credentials/basic.pem
aws ec2 delete-key-pair --key-name basic

# delete the security group
echo deleting security group
aws ec2 delete-security-group --group-id $vpcbasicsg_id

cd $basedir

echo "done - Image made; Key, Security Group and Instance deleted"
