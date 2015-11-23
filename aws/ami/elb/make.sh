#!/bin/bash

# makes an elb
# elbselfsigned (in aws/master/vars.sh) decides if self-signed or valid cert is used

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

echo "launching ELB"

echo "check ELB does not exist"
exists=$(aws elb describe-load-balancers --load-balancer-names $elbname --output text --query 'LoadBalancerDescriptions[*].LoadBalancerName' 2>/dev/null)

if test "$exists" = $elbname; then
 echo "ELB already exists = exiting"
 exit
else
 echo "ELB not found - proceeding"
fi

if (($elbselfsigned == 1)); then

echo "making self-signed ssl"

# sleeps are needed or it won't work
cd $basedir/ami/elb/ssl
rm -f cert.pem
rm -f key.pem
rm -f server.crt
rm -f server.csr
rm -f server.key
rm -f server.key.org
echo deleted old files
./ssl1.sh
./ssl2.sh
cp server.key server.key.org
./ssl3.sh
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt
sleep 15
cp server.key key.pem
openssl x509 -inform PEM -in server.crt > cert.pem
sleep 15
aws iam delete-server-certificate --server-certificate-name $elbcertname
sleep 15
sslarn=$(aws iam upload-server-certificate --server-certificate-name $elbcertname --certificate-body file://cert.pem --private-key file://key.pem --output text --query 'ServerCertificateMetadata.Arn')
echo sslarn=$sslarn

else

echo "using valid ssl"

# read the valid SSL cert and upload to iam
echo "using valid ssl"
cd $basedir/ami/elb/validssl
cert=$(cat $elbvalidcertcertfile)
echo loaded cert
key=$(cat $elbvalidcertkeyfile)
echo loaded key
inter=$(cat $elbvalidcertinterfile)
echo loaded inter
echo deleting previous certificate
aws iam delete-server-certificate --server-certificate-name $elbcertname
echo uploading certificate
sslarn=$(aws iam upload-server-certificate --server-certificate-name $elbcertname --certificate-body "$cert" --private-key "$key" --certificate-chain "$inter" --output text --query 'ServerCertificateMetadata.Arn')
echo sslarn=$sslarn

fi

# let the cert cook
sleep 5

# make a security group to control access to the elb
echo "making sg"
vpc_id=$(aws ec2 describe-vpcs --filters Name=tag-key,Values=vpcname --filters Name=tag-value,Values=$vpcname --output text --query 'Vpcs[*].VpcId')
echo vpc_id=$vpc_id
sg_id=$(aws ec2 create-security-group --group-name elbsg --description "elb security group" --vpc-id $vpc_id --output text --query 'GroupId')
echo sg_id=$sg_id
# tag it
aws ec2 create-tags --resources $sg_id --tags Key=sgname,Value=elbsg
# get its id
vpcelbsg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=elbsg --output text --query 'SecurityGroups[*].GroupId')
echo vpcelbsg_id=$vpcelbsg_id
# allow 80, 443 from anywhere into the elb
aws ec2 authorize-security-group-ingress --group-id $vpcelbsg_id --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-id $vpcelbsg_id --protocol tcp --port 443 --cidr 0.0.0.0/0
echo "elbsg made"

# get our vpc subnets
subnet_ids=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpc_id --output text --query 'Subnets[*].SubnetId')
echo subnet_ids=$subnet_ids

# create an elb
# it listens for http on 80 and https on 443 and forwards both to 80 http (no SSL)
# you can tell if the request came in on SLL with $_SERVER['HTTP_X_FORWARDED_PROTO'] (should be "https") in PHP
aws elb create-load-balancer --load-balancer-name $elbname --listener LoadBalancerPort=80,InstancePort=80,Protocol=http,InstanceProtocol=http LoadBalancerPort=443,InstancePort=80,Protocol=https,InstanceProtocol=http,SSLCertificateId=$sslarn --security-groups $vpcelbsg_id --subnets $subnet_ids --region $deployregion

# set the elb health check
aws elb configure-health-check --load-balancer-name $elbname --health-check Target=HTTP:80/elb.htm,Interval=10,Timeout=5,UnhealthyThreshold=2,HealthyThreshold=2

# show the elb address
elbdns=$(aws elb describe-load-balancers --load-balancer-names $elbname --output text --query 'LoadBalancerDescriptions[*].DNSName')
echo elbdns=$elbdns

cd $basedir

echo "elb created"
