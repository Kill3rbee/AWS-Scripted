#!/bin/bash

# uploads database files to the admin server
# then runs the install script on the server
# data comes from from aws/data/database dir, run ./data/makedata.sh first

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./upload/database/upload.sh"
 exit
fi

# include global variables
. ./master/vars.sh

rm -f $sshknownhosts

cd $basedir

source credentials/passwords.sh

myip=$(curl http://checkip.amazonaws.com/)
echo myip=$myip

# get ip of server
ip_address=$(aws ec2 describe-instances --filters Name=key-name,Values=admin --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ip_address=$ip_address

# get database endpoint
dbendpoint=$(aws rds describe-db-instances --db-instance-identifier $dbinstancename --output text --query 'DBInstances[*].Endpoint.Address')

# build database scripts

cd $basedir

rm -f upload/database/dbs.sql
rm -f upload/database/dbusers.sql
rm -f upload/database/install.sh

sed "s/SEDdbnameSED/$dbname/g" data/database/dbs.sql > upload/database/dbs.sql

sed -e "s/SEDdbnameSED/$dbname/g" -e "s/SEDDBPASS_adminrwSED/$password4/g" -e "s/SEDDBPASS_webphprwSED/$password5/g" -e "s/SEDDBPASS_javamailSED/$password6/g" data/database/dbusers.sql > upload/database/dbusers.sql

sed -e "s/SEDdbhostSED/$dbendpoint/g" -e "s/SEDdbmainuserpasswordSED/$password1/g" -e "s/SEDdbnameSED/$dbname/g" upload/database/install_template.sh > upload/database/install.sh
chmod +x upload/database/install.sh

# allow ssh in sg
vpcadminsg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=adminsg --output text --query 'SecurityGroups[*].GroupId')
echo vpcadminsg_id=$vpcadminsg_id
aws ec2 authorize-security-group-ingress --group-id $vpcadminsg_id --protocol tcp --port 38142 --cidr $myip/32

# wait for ssh
echo -n "waiting for ssh"
while ! ssh -i credentials/admin.pem -p 38142 -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no ec2-user@$ip_address > /dev/null 2>&1 true; do
 echo -n . ; sleep 3;
done; echo " ssh ok"

# upload files
ssh -i credentials/admin.pem -p 38142 -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no ec2-user@$ip_address exit
echo "transferring files"
scp -i credentials/admin.pem -P 38142 upload/database/dbs.sql ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 upload/database/dbusers.sql ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 upload/database/install.sh ec2-user@$ip_address:
echo "transferred files"

rm -f upload/database/dbs.sql
rm -f upload/database/dbusers.sql
rm -f upload/database/install.sh

cd $basedir/credentials

# make and run expect script
echo "#!/usr/bin/expect -f" > expect.sh
echo "set timeout -1" >> expect.sh
echo "spawn ssh -i admin.pem -p 38142 -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no ec2-user@$ip_address" >> expect.sh
echo "sleep 3" >> expect.sh
echo "send \"sudo su\n\"" >> expect.sh
echo "expect \"password for ec2-user:\"" >> expect.sh
echo "send \"$password3\n\"" >> expect.sh
echo "expect \"]\"" >> expect.sh
echo "send \"./install.sh\n\"" >> expect.sh
echo "expect \"install.sh finished\"" >> expect.sh
echo "exit" >> expect.sh
echo "exit" >> expect.sh
echo "interact" >> expect.sh
chmod +x expect.sh
#echo "start expect.sh"
#cat expect.sh
#echo "end expect.sh"
./expect.sh
rm expect.sh

# remove ssh in sg
aws ec2 revoke-security-group-ingress --group-id $vpcadminsg_id --protocol tcp --port 38142 --cidr $myip/32
echo "revoked sg access"

cd $basedir
