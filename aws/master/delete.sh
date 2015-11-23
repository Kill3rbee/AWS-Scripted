#!/bin/bash

# delete all aws assets

read -p "DELETE ALL AWS ASSETS? <Y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
  echo "PROCEEDING..."
else
  exit
fi

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./master/delete.sh"
 exit
fi

# include global variables
. ./master/vars.sh

# terminate instances
instances=$(aws ec2 describe-instances --output text --query 'Reservations[*].Instances[*].InstanceId')
echo instances=$instances
aws ec2 terminate-instances --instance-ids $instances

# terminate rds (with no final snapshot)
aws rds delete-db-instance --db-instance-identifier $dbinstancename --skip-final-snapshot

# terminate elb
aws elb delete-load-balancer --load-balancer-name $elbname

# delete the ssl cert
aws iam delete-server-certificate --server-certificate-name $elbcertname

# wait for instances (or subsequent deletes will fail)
echo -n "waiting for instances termination"
while state=$(aws ec2 describe-instances --output text --query 'Reservations[*].Instances[*].State.Name'); [[ $state == *shutting* ]]; do
 echo -n . ; sleep 5;
done; echo " $state"

# wait for rds (or subsequent deletes will fail)
echo -n "waiting for database termination"
while state=$(aws rds describe-db-instances --output text --query 'DBInstances[*].DBInstanceStatus'); [[ $state == deleting ]]; do
 echo -n . ; sleep 5;
done; echo " $state"

# delete rds parameter group
aws rds delete-db-parameter-group --db-parameter-group-name $dbpgname

# delete rds subnet group
aws rds delete-db-subnet-group --db-subnet-group-name $dbsubnetgroupname

# delete sns topics
topicarns=$(aws sns list-topics --output text --query 'Topics[*].TopicArn')
topicarnarr=$(echo $topicarns | tr " " "\n")
for i in $topicarnarr
do
 echo found topic $i
 aws sns delete-topic --topic-arn $i
done

# delete ses email identity
aws ses delete-identity --identity $emailsendfrom

# delete iam sesuser
aws iam delete-user-policy --user-name sesuser --policy-name SESAccess
sesuserkey=$(aws iam list-access-keys --user-name sesuser --output text --query 'AccessKeyMetadata[*].AccessKeyId')
aws iam delete-access-key --access-key $sesuserkey --user-name sesuser
aws iam delete-user --user-name sesuser

# deregister image
bslami_id=$(aws ec2 describe-images --filters 'Name=name,Values=Basic Secure Linux' --output text --query 'Images[*].ImageId')
echo bslami_id=$bslami_id
aws ec2 deregister-image --image-id $bslami_id

# delete snapshots
snapshot_ids=$(aws ec2 describe-snapshots --owner-ids self --output text --query 'Snapshots[*].SnapshotId')
echo snapshot_ids=$snapshot_ids
for snapshot_id in $snapshot_ids
do
 echo "deleting snapshot $snapshot_id"
 aws ec2 delete-snapshot --snapshot-id $snapshot_id
done

# delete key pairs
aws ec2 delete-key-pair --key-name basic
aws ec2 delete-key-pair --key-name admin
aws ec2 delete-key-pair --key-name web1
aws ec2 delete-key-pair --key-name web2
aws ec2 delete-key-pair --key-name web3
aws ec2 delete-key-pair --key-name web4
aws ec2 delete-key-pair --key-name web5
aws ec2 delete-key-pair --key-name web6

# release elastic ips
eip=$(aws ec2 describe-addresses --output text --query 'Addresses[*].AllocationId')
echo eip=$eip
eiparr=$(echo $eip | tr " " "\n")
for i in $eiparr
do
 echo found eip $i
 aws ec2 release-address --allocation-id $i
done

# delete vpc
# from the console (VPC), this can be done in one operation, but not from the cli...
vpc_id=$(aws ec2 describe-vpcs --filters Name=tag-key,Values=vpcname --filters Name=tag-value,Values=$vpcname --output text --query 'Vpcs[*].VpcId')
echo vpc_id=$vpc_id

# delete igw
igw_id=$(aws ec2 describe-internet-gateways --output text --query 'InternetGateways[*].InternetGatewayId')
aws ec2 detach-internet-gateway --internet-gateway-id $igw_id --vpc-id $vpc_id
aws ec2 delete-internet-gateway --internet-gateway-id $igw_id

# delete subnets
subnet_id=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpc_id --filters Name=tag-key,Values=subnet --filters Name=tag-value,Values=1 --output text --query 'Subnets[*].SubnetId')
echo subnet_id=$subnet_id
aws ec2 delete-subnet --subnet-id $subnet_id
subnet_id=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpc_id --filters Name=tag-key,Values=subnet --filters Name=tag-value,Values=2 --output text --query 'Subnets[*].SubnetId')
echo subnet_id=$subnet_id
aws ec2 delete-subnet --subnet-id $subnet_id

# delete security groups...
# first get all the ids
adminsg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=adminsg --output text --query 'SecurityGroups[*].GroupId')
echo adminsg_id=$adminsg_id
dbsg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=dbsg --output text --query 'SecurityGroups[*].GroupId')
echo dbsg_id=$dbsg_id
elbsg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=elbsg --output text --query 'SecurityGroups[*].GroupId')
echo elbsg_id=$elbsg_id
web1sg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=web1sg --output text --query 'SecurityGroups[*].GroupId')
echo web1sg_id=$web1sg_id
web2sg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=web2sg --output text --query 'SecurityGroups[*].GroupId')
echo web2sg_id=$web2sg_id
web3sg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=web3sg --output text --query 'SecurityGroups[*].GroupId')
echo web3sg_id=$web3sg_id
web4sg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=web4sg --output text --query 'SecurityGroups[*].GroupId')
echo web4sg_id=$web4sg_id
web5sg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=web5sg --output text --query 'SecurityGroups[*].GroupId')
echo web5sg_id=$web5sg_id
web6sg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=web6sg --output text --query 'SecurityGroups[*].GroupId')
echo web6sg_id=$web6sg_id
# remove all rules from adminsg
aws ec2 revoke-security-group-ingress --group-id $adminsg_id --protocol tcp --port 514 --source-group $web1sg_id
aws ec2 revoke-security-group-ingress --group-id $adminsg_id --protocol tcp --port 8080 --source-group $web1sg_id
aws ec2 revoke-security-group-ingress --group-id $adminsg_id --protocol tcp --port 514 --source-group $web2sg_id
aws ec2 revoke-security-group-ingress --group-id $adminsg_id --protocol tcp --port 8080 --source-group $web2sg_id
aws ec2 revoke-security-group-ingress --group-id $adminsg_id --protocol tcp --port 514 --source-group $web3sg_id
aws ec2 revoke-security-group-ingress --group-id $adminsg_id --protocol tcp --port 8080 --source-group $web3sg_id
aws ec2 revoke-security-group-ingress --group-id $adminsg_id --protocol tcp --port 514 --source-group $web4sg_id
aws ec2 revoke-security-group-ingress --group-id $adminsg_id --protocol tcp --port 8080 --source-group $web4sg_id
aws ec2 revoke-security-group-ingress --group-id $adminsg_id --protocol tcp --port 514 --source-group $web5sg_id
aws ec2 revoke-security-group-ingress --group-id $adminsg_id --protocol tcp --port 8080 --source-group $web5sg_id
aws ec2 revoke-security-group-ingress --group-id $adminsg_id --protocol tcp --port 514 --source-group $web6sg_id
aws ec2 revoke-security-group-ingress --group-id $adminsg_id --protocol tcp --port 8080 --source-group $web6sg_id
# remove all rules from dbsg
aws ec2 revoke-security-group-ingress --group-id $dbsg_id --protocol tcp --port 3306 --source-group $adminsg_id
aws ec2 revoke-security-group-ingress --group-id $dbsg_id --protocol tcp --port 3306 --source-group $web1sg_id
aws ec2 revoke-security-group-ingress --group-id $dbsg_id --protocol tcp --port 3306 --source-group $web2sg_id
aws ec2 revoke-security-group-ingress --group-id $dbsg_id --protocol tcp --port 3306 --source-group $web3sg_id
aws ec2 revoke-security-group-ingress --group-id $dbsg_id --protocol tcp --port 3306 --source-group $web4sg_id
aws ec2 revoke-security-group-ingress --group-id $dbsg_id --protocol tcp --port 3306 --source-group $web5sg_id
aws ec2 revoke-security-group-ingress --group-id $dbsg_id --protocol tcp --port 3306 --source-group $web6sg_id
# remove all rules from elbsg
aws ec2 revoke-security-group-ingress --group-id $elbsg_id --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 revoke-security-group-ingress --group-id $elbsg_id --protocol tcp --port 443 --cidr 0.0.0.0/0
# remove all rules from web1sg
aws ec2 revoke-security-group-ingress --group-id $web1sg_id --protocol tcp --port 80 --source-group $elbsg_id
aws ec2 revoke-security-group-ingress --group-id $web1sg_id --protocol tcp --port 443 --source-group $elbsg_id
aws ec2 revoke-security-group-ingress --group-id $web1sg_id --protocol tcp --port 2812 --source-group $adminsg_id
# remove all rules from web2sg
aws ec2 revoke-security-group-ingress --group-id $web2sg_id --protocol tcp --port 80 --source-group $elbsg_id
aws ec2 revoke-security-group-ingress --group-id $web2sg_id --protocol tcp --port 443 --source-group $elbsg_id
aws ec2 revoke-security-group-ingress --group-id $web2sg_id --protocol tcp --port 2812 --source-group $adminsg_id
# remove all rules from web3sg
aws ec2 revoke-security-group-ingress --group-id $web3sg_id --protocol tcp --port 80 --source-group $elbsg_id
aws ec2 revoke-security-group-ingress --group-id $web3sg_id --protocol tcp --port 443 --source-group $elbsg_id
aws ec2 revoke-security-group-ingress --group-id $web3sg_id --protocol tcp --port 2812 --source-group $adminsg_id
# remove all rules from web4sg
aws ec2 revoke-security-group-ingress --group-id $web4sg_id --protocol tcp --port 80 --source-group $elbsg_id
aws ec2 revoke-security-group-ingress --group-id $web4sg_id --protocol tcp --port 443 --source-group $elbsg_id
aws ec2 revoke-security-group-ingress --group-id $web4sg_id --protocol tcp --port 2812 --source-group $adminsg_id
# remove all rules from web5sg
aws ec2 revoke-security-group-ingress --group-id $web5sg_id --protocol tcp --port 80 --source-group $elbsg_id
aws ec2 revoke-security-group-ingress --group-id $web5sg_id --protocol tcp --port 443 --source-group $elbsg_id
aws ec2 revoke-security-group-ingress --group-id $web5sg_id --protocol tcp --port 2812 --source-group $adminsg_id
# remove all rules from web6sg
aws ec2 revoke-security-group-ingress --group-id $web6sg_id --protocol tcp --port 80 --source-group $elbsg_id
aws ec2 revoke-security-group-ingress --group-id $web6sg_id --protocol tcp --port 443 --source-group $elbsg_id
aws ec2 revoke-security-group-ingress --group-id $web6sg_id --protocol tcp --port 2812 --source-group $adminsg_id
# finally delete sgs
aws ec2 delete-security-group --group-id $adminsg_id
aws ec2 delete-security-group --group-id $dbsg_id
aws ec2 delete-security-group --group-id $elbsg_id
aws ec2 delete-security-group --group-id $web1sg_id
aws ec2 delete-security-group --group-id $web2sg_id
aws ec2 delete-security-group --group-id $web3sg_id
aws ec2 delete-security-group --group-id $web4sg_id
aws ec2 delete-security-group --group-id $web5sg_id
aws ec2 delete-security-group --group-id $web6sg_id

# now we can finally delete the vpc
# all remaining assets are also deleted (eg route table, default security group)
aws ec2 delete-vpc --vpc-id $vpc_id

# tags are deleted automatically when associated resource dies

# now delete some files which are useless
cd $basedir
rm -f credentials/*.pem
rm -f credentials/passwords.sh
rm -f credentials/sesuser_AccessKeyId
rm -f credentials/sesuser_SecretAccessKey
rm -f credentials/smtp.sh
rm -f ami/elb/ssl/cert.pem
rm -f ami/elb/ssl/key.pem
rm -f ami/elb/ssl/server.crt
rm -f ami/elb/ssl/server.csr
rm -f ami/elb/ssl/server.key
rm -f ami/elb/ssl/server.key.org

echo "all deleted"
