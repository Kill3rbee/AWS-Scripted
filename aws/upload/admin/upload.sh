#!/bin/bash

# uploads the admin website to admin server
# then runs the install script on the server
# data comes from from aws/data/admin dir, run ./data/makedata.sh first

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./upload/admin/upload.sh"
 exit
fi

# include global variables
. ./master/vars.sh

rm -f $sshknownhosts

cd $basedir

echo building zip

rm -f -R data/admin/admin.zip
cd data/admin
# only zip php and css files (leave out the annoying DSStore files...)
zip -R admin '*.php' '*.css'

echo "uploading admin"

cd $basedir/credentials

source passwords.sh

echo connecting to admin

myip=$(curl http://checkip.amazonaws.com/)
echo myip=$myip

# get ip of server
ip_address=$(aws ec2 describe-instances --filters Name=key-name,Values=admin --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ip_address=$ip_address

# allow ssh in sg
vpcadminsg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=adminsg --output text --query 'SecurityGroups[*].GroupId')
echo vpcadminsg_id=$vpcadminsg_id
aws ec2 authorize-security-group-ingress --group-id $vpcadminsg_id --protocol tcp --port 38142 --cidr $myip/32

cd $basedir

# wait for ssh
echo -n "waiting for ssh"
while ! ssh -i credentials/admin.pem -p 38142 -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no ec2-user@$ip_address > /dev/null 2>&1 true; do
 echo -n . ; sleep 3;
done; echo " ssh ok"

# upload files
ssh -i credentials/admin.pem -p 38142 -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no ec2-user@$ip_address exit
echo "transferring files"
scp -i credentials/admin.pem -P 38142 data/admin/admin.zip ec2-user@$ip_address:
scp -i credentials/admin.pem -P 38142 upload/admin/install.sh ec2-user@$ip_address:
echo "transferred files"

rm -f -R data/admin/admin.zip

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
