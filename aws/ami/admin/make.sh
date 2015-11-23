#!/bin/bash

# makes an admin box, from linux hardened image
# ssh on 38142
# includes: rsyslog receiver for all logs; admin website; loganalyzer; mmonit; javaMail
# admin box needs an elastic ip address for the self-signed SSL cert

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./ami/admin/make.sh"
 exit
fi

# include global variables
. ./master/vars.sh

# EBS volume size specifier
bdm=[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"VolumeSize\":$adminebsvolumesize}}]
echo bdm=$bdm

# we don't need this
rm -f $sshknownhosts

cd $basedir

echo "building admin"

echo "check admin not exist"
exists=$(aws ec2 describe-key-pairs --key-names admin --output text --query 'KeyPairs[*].KeyName' 2>/dev/null)

if test "$exists" = "admin"; then
 echo "key admin already exists = exiting"
 #exit
else
 echo "key admin not found - proceeding"
fi

cd $basedir

# include passwords
source credentials/passwords.sh
rootpass=$password2
ec2pass=$password3

# get our ip from amazon
myip=$(curl http://checkip.amazonaws.com/)
echo myip=$myip

# make keypair
rm credentials/admin.pem
aws ec2 delete-key-pair --key-name admin
aws ec2 create-key-pair --key-name admin --query 'KeyMaterial' --output text > credentials/admin.pem
chmod 600 credentials/admin.pem
echo "keypair admin made"

# make security group
vpc_id=$(aws ec2 describe-vpcs --filters Name=tag-key,Values=vpcname --filters Name=tag-value,Values=$vpcname --output text --query 'Vpcs[*].VpcId')
echo vpc_id=$vpc_id
sg_id=$(aws ec2 create-security-group --group-name adminsg --description "admin security group" --vpc-id $vpc_id --output text --query 'GroupId')
echo sg_id=$sg_id
# tag it
aws ec2 create-tags --resources $sg_id --tags Key=sgname,Value=adminsg
# get its id
vpcadminsg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=adminsg --output text --query 'SecurityGroups[*].GroupId')
echo vpcadminsg_id=$vpcadminsg_id
# allow ssh
aws ec2 authorize-security-group-ingress --group-id $vpcadminsg_id --protocol tcp --port 38142 --cidr $myip/32
echo "adminsg made"

# get the main subnet
subnet_id=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpc_id --filters Name=tag-key,Values=subnet --filters Name=tag-value,Values=1 --output text --query 'Subnets[*].SubnetId')
echo subnet_id=$subnet_id

# get the shared image id
bslami_id=$(aws ec2 describe-images --filters 'Name=name,Values=Basic Secure Linux' --output text --query 'Images[*].ImageId')
echo bslami_id=$bslami_id

# make the instance
instance_id=$(aws ec2 run-instances --image $bslami_id --placement AvailabilityZone=$deployzone --key admin --security-group-ids $vpcadminsg_id --instance-type $admininstancetype --block-device-mapping $bdm --region $deployregion --subnet-id $subnet_id --private-ip-address 10.0.0.10 --output text --query 'Instances[*].InstanceId')
echo instance_id=$instance_id

# wait for it
echo -n "waiting for instance"
while state=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].State.Name'); test "$state" = "pending"; do
 echo -n . ; sleep 3;
done; echo " $state"

# find an unused eip or make one
eip=$(aws ec2 describe-addresses --output text --query 'Addresses[*].PublicIp')
echo eip=$eip

useeip=
eiparr=$(echo $eip | tr " " "\n")
for i in $eiparr
do
 echo found eip $i
 eipinsid=$(aws ec2 describe-addresses --filters Name=public-ip,Values=$i --output text --query 'Addresses[*].InstanceId')
 echo eip $i instanceid $eipinsid
 if test -z "$eipinsid"; then
  useeip=$i
 fi
done

# check if eip found, otherwise make one
if test -z "$useeip"; then
	echo "no eip, allocate one"
	useeip=$(aws ec2 allocate-address --output text --query 'PublicIp')
fi

# associate eip with admin instance
aws ec2 associate-address --instance-id $instance_id --public-ip $useeip
echo "associated eip with admin instance"

# get adminhost private ip
adminhost=$(aws ec2 describe-instances --filters Name=key-name,Values=admin --output text --query 'Reservations[*].Instances[*].PrivateIpAddress')
echo adminhost=$adminhost

# ipaddress is new eib address
ip_address=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ip_address=$ip_address

# allow access to rds database
echo "allowing access to rds database"
vpcdbsg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=dbsg --output text --query 'SecurityGroups[*].GroupId')
echo vpcdbsg_id=$vpcdbsg_id
aws ec2 authorize-security-group-ingress --group-id $vpcdbsg_id --source-group $vpcadminsg_id --protocol tcp --port 3306

# get the database address
dbendpoint=$(aws rds describe-db-instances --db-instance-identifier $dbinstancename --output text --query 'DBInstances[*].Endpoint.Address')

cd $basedir

# remove old files
rm -f ami/admin/install_admin.sh
rm -f ami/admin/httpd.conf
rm -f ami/admin/config.inc.php
rm -f ami/admin/chp_ec2-user.sh
rm -f ami/admin/chp_root.sh
rm -f ami/admin/server.xml

# sed data files

sed "s/SEDadminpublicipSED/$ip_address/g" ami/admin/install_admin_template.sh > ami/admin/install_admin.sh
chmod +x ami/admin/install_admin.sh

sed -e "s/SEDdbhostSED/$dbendpoint/g" -e "s/SEDdbnameSED/$dbname/g" -e "s/SEDdbpass_adminrwSED/$password4/g" ami/admin/httpd_template.conf > ami/admin/httpd.conf

sed -e "s/SEDdbhostSED/$dbendpoint/g" -e "s/SEDdbmainuserpassSED/$password1/g" ami/admin/config_inc_template.php > ami/admin/config.inc.php

sed "s/SED-EC2-USER-PASS-SED/$ec2pass/g" ami/shared/chp_ec2-user.sh > ami/admin/chp_ec2-user.sh
chmod +x ami/admin/chp_ec2-user.sh

sed "s/SED-ROOT-PASS-SED/$rootpass/g" ami/shared/chp_root.sh > ami/admin/chp_root.sh
chmod +x ami/admin/chp_root.sh

sed -e "s/SEDadminpublicipSED/$ip_address/g" -e "s/SEDadminprivateipSED/$adminhost/g" ami/admin/server_template.xml > ami/admin/server.xml

# wait for ssh
echo -n "waiting for ssh"
while ! ssh -i credentials/admin.pem -p 38142 -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no ec2-user@$ip_address > /dev/null 2>&1 true; do
 echo -n . ; sleep 3;
done; echo " ssh ok"

# send files
echo "transferring files"
scp -i credentials/admin.pem -P 38142 ami/admin/httpd.conf ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 ami/admin/monit.conf ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 ami/admin/rsyslog.conf ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 ami/admin/config.php ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 ami/admin/config.inc.php ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 ami/admin/server.xml ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 ami/admin/install_admin.sh ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 ami/admin/chp_ec2-user.sh ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 ami/admin/chp_root.sh ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 ami/admin/logrotatehttp ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 ami/admin/mmonit-3.2.1-linux-x64.tar.gz ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 ami/admin/loganalyzer-3.6.5.tar.gz ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 ami/admin/launch_javaMail.sh ec2-user@$ip_address:
echo "transferred files"

# remove generated files
rm -f ami/admin/install_admin.sh
rm -f ami/admin/httpd.conf
rm -f ami/admin/config.inc.php
rm -f ami/admin/chp_ec2-user.sh
rm -f ami/admin/chp_root.sh
rm -f ami/admin/server.xml

# run the install script
echo "running install_admin.sh"
ssh -i credentials/admin.pem -p 38142 -t -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no ec2-user@$ip_address sudo ./install_admin.sh
echo "finished install_admin.sh"

# close the ssh port
echo "removing ssh access from sg"
aws ec2 revoke-security-group-ingress --group-id $vpcadminsg_id --protocol tcp --port 38142 --cidr $myip/32

cd $basedir

# done
echo "admin done - needs upload"
