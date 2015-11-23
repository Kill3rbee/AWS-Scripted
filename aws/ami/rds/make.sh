#!/bin/bash

# makes an rds database
# database is populated in admin server setup

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./ami/rds/make.sh"
 exit
fi

# include global variables
. ./master/vars.sh

cd $basedir

# include passwords
source credentials/passwords.sh

# create an rds db subnet group which spans both our subnets (10.0.0.0/24 and 10.0.10.0/24)
vpc_id=$(aws ec2 describe-vpcs --filters Name=tag-key,Values=vpcname --filters Name=tag-value,Values=$vpcname --output text --query 'Vpcs[*].VpcId')
echo vpc_id=$vpc_id
subnet_ids=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$vpc_id --output text --query 'Subnets[*].SubnetId')
echo subnet_ids=$subnet_ids
aws rds create-db-subnet-group --db-subnet-group-name $dbsubnetgroupname --db-subnet-group-description $dbsubnetgroupdesc --subnet-ids $subnet_ids

# create a vpc security group
# db sg will control access to the database
sg_id=$(aws ec2 create-security-group --group-name dbsg --description "rds database security group" --vpc-id $vpc_id --output text --query 'GroupId')
echo sg_id=$sg_id
# tag it
aws ec2 create-tags --resources $sg_id --tags Key=sgname,Value=dbsg
# get its id
vpcdbsg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=dbsg --output text --query 'SecurityGroups[*].GroupId')
echo vpcdbsg_id=$vpcdbsg_id

# we want to log slow queries and set the trigger time to be 1 second
# any query taking more than 1 second will be logged
echo making db parameter group
aws rds create-db-parameter-group --db-parameter-group-name $dbpgname --db-parameter-group-family MySQL5.6 --description $dbpgdesc
aws rds modify-db-parameter-group --db-parameter-group-name $dbpgname --parameters ParameterName=slow_query_log,ParameterValue=1,ApplyMethod=immediate
aws rds modify-db-parameter-group --db-parameter-group-name $dbpgname --parameters ParameterName=long_query_time,ParameterValue=1,ApplyMethod=immediate

# create the rds instance
# you can't specify the private ip address for an rds instance, but they tend to be in the 200s...

# the mysql version can change (if AWS force an upgrade for security reasons)
# enter the required mysql version here
# (attempt to launch an instance in the console to see minimum version)
mysqlversion=5.6.21

if (($rdsusemultiaz > 0)); then

 # multi-az : can't use --availability-zone with --multi-az
 aws rds create-db-instance --db-instance-identifier $dbinstancename --db-instance-class $rdsinstancetype --db-name $dbname --engine MySQL --engine-version $mysqlversion --port 3306 --allocated-storage $rdsvolumesize --no-auto-minor-version-upgrade --db-parameter-group-name $dbpgname --master-username mainuser --master-user-password $password1 --backup-retention-period 14 --no-publicly-accessible --region $deployregion --multi-az --vpc-security-group-ids $vpcdbsg_id --db-subnet-group-name $dbsubnetgroupname

else

 # no multi-az
 aws rds create-db-instance --db-instance-identifier $dbinstancename --db-instance-class $rdsinstancetype --db-name $dbname --engine MySQL --engine-version $mysqlversion --port 3306 --allocated-storage $rdsvolumesize --no-auto-minor-version-upgrade --db-parameter-group-name $dbpgname --master-username mainuser --master-user-password $password1 --backup-retention-period 14 --no-publicly-accessible --region $deployregion --availability-zone $deployzone --vpc-security-group-ids $vpcdbsg_id --db-subnet-group-name $dbsubnetgroupname

fi

echo database started, use make2.sh to check for completion

cd $basedir
