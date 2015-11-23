#!/bin/bash

# uploads the website to a webN instance
# parameters <N> where this is the Nth web box

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./upload/website/upload.sh ..."
 exit
fi

# include global variables
. ./master/vars.sh

rm -f $sshknownhosts

cd $basedir

webid=$1
if test -z "$webid"; then
 exit
fi

echo "uploading web$webid"

cd $basedir/credentials

source passwords.sh

echo connecting to web$webid

# set the password for the server in question
if test "$webid" = "1"; then
 pass=$password9
 echo "set password for web1"
elif test "$webid" = "2"; then
 pass=$password11
 echo "set password for web2"
elif test "$webid" = "3"; then
 pass=$password13
 echo "set password for web3"
elif test "$webid" = "4"; then
 pass=$password15
 echo "set password for web4"
elif test "$webid" = "5"; then
 pass=$password17
 echo "set password for web5"
elif test "$webid" = "6"; then
 pass=$password19
 echo "set password for web6"
else
 echo "password for $1 not found - exiting"
 exit
fi

myip=$(curl http://checkip.amazonaws.com/)
echo myip=$myip

# get ip of server
ip_address=$(aws ec2 describe-instances --filters Name=key-name,Values=web$webid --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ip_address=$ip_address

# get sg of server
serversg=web$webid
serversg+=sg
echo serversg=$serversg

# allow ssh in sg
vpcwebsg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=$serversg --output text --query 'SecurityGroups[*].GroupId')
echo vpcwebsg_id=$vpcwebsg_id
aws ec2 authorize-security-group-ingress --group-id $vpcwebsg_id --protocol tcp --port 38142 --cidr $myip/32

cd $basedir

# wait for ssh
echo -n "waiting for ssh"
while ! ssh -i credentials/web$webid.pem -p 38142 -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no ec2-user@$ip_address > /dev/null 2>&1 true; do
 echo -n . ; sleep 3;
done; echo " ssh ok"

# upload files
ssh -i credentials/web$webid.pem -p 38142 -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no ec2-user@$ip_address exit
echo "transferring files"
scp -i credentials/web$webid.pem -P 38142 data/website/phpinclude/phpinclude.zip ec2-user@$ip_address:
scp -i credentials/web$webid.pem -P 38142 data/website/htdocs/htdocs.zip ec2-user@$ip_address:
scp -i credentials/web$webid.pem -P 38142 upload/website/install.sh ec2-user@$ip_address:
echo "transferred files"

cd $basedir/credentials

# make and run expect script
echo "#!/usr/bin/expect -f" > expect.sh
echo "set timeout -1" >> expect.sh
echo "spawn ssh -i web$webid.pem -p 38142 -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no ec2-user@$ip_address" >> expect.sh
echo "sleep 3" >> expect.sh
echo "send \"sudo su\n\"" >> expect.sh
echo "expect \"password for ec2-user:\"" >> expect.sh
echo "send \"$pass\n\"" >> expect.sh
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
aws ec2 revoke-security-group-ingress --group-id $vpcwebsg_id --protocol tcp --port 38142 --cidr $myip/32
echo "revoked sg access"

cd $basedir
