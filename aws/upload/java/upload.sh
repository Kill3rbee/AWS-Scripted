#!/bin/bash

# uploads javaMail to admin server
# then runs the install script on the server
# data comes from from aws/data/java dir, run ./data/makedata.sh first

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./upload/java/upload.sh"
 exit
fi

# include global variables
. ./master/vars.sh

rm -f $sshknownhosts

echo "uploading javamail to admin server"

cd $basedir/credentials

# include passwords
source passwords.sh

# include smtp details
source smtp.sh

echo "connecting to admin"

myip=$(curl http://checkip.amazonaws.com/)
echo myip=$myip

# get ip of server
ip_address=$(aws ec2 describe-instances --filters Name=key-name,Values=admin --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ip_address=$ip_address

echo "getting db endpoint"
dbendpoint=$(aws rds describe-db-instances --db-instance-identifier $dbinstancename --output text --query 'DBInstances[*].Endpoint.Address')
echo dbendpoint=$dbendpoint

cd $basedir/data/java/javaMail

rm -f config_javaMail.properties

sed -e "s/SEDdbhostSED/$dbendpoint/g" -e "s/SEDdbnameSED/$dbname/g" -e "s/SEDDBPASS_javamailSED/$password6/g" -e "s/SEDSMTPHOSTSED/$smtp_server/g" -e "s/SEDSMTPPORTSED/$smtp_port/g" -e "s#SEDSMTPUSERSED#$smtp_user#g" -e "s#SEDSMTPPASSSED#$smtp_pass#g" config_template.properties > config_javaMail.properties

cd $basedir

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
scp -i credentials/admin.pem -P 38142 data/java/javaMail/javaMail.jar ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 data/java/javaMail/config_javaMail.properties ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 upload/java/install.sh ec2-user@$ip_address:
echo "transferred files"

rm -f data/java/javaMail/config_javaMail.properties

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
./expect.sh
rm expect.sh

# remove ssh in sg
aws ec2 revoke-security-group-ingress --group-id $vpcadminsg_id --protocol tcp --port 38142 --cidr $myip/32
echo "revoked sg access"

cd $basedir
