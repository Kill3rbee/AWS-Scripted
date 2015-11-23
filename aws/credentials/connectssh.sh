#!/bin/bash

# open an ssh session to a server and auto sudo su with password
# can be admin, web1, web2 ... etc as long as ssh key exists
# do a double exit from ssh to exit, removes the sg ingress rule

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./credentials/connectssh.sh ..."
 exit
fi

# include global variables
. ./master/vars.sh

cd $basedir/credentials

source passwords.sh

sshport=38142
sshuser=ec2-user

echo "connecting to $1 on $sshport with user $sshuser"

# get sg of server
serversg=$1
serversg+=sg
echo serversg=$serversg

if test "$1" = "web1"; then
 pass=$password9
 echo "set password for web1"
elif test "$1" = "web2"; then
 pass=$password11
 echo "set password for web2"
elif test "$1" = "web3"; then
 pass=$password13
 echo "set password for web3"
elif test "$1" = "web4"; then
 pass=$password15
 echo "set password for web4"
elif test "$1" = "web5"; then
 pass=$password17
 echo "set password for web5"
elif test "$1" = "web6"; then
 pass=$password19
 echo "set password for web6"
elif test "$1" = "admin"; then
 pass=$password3
 echo "set password for admin"
else
 echo "password for $1 not found - exiting"
 exit
fi

myip=$(curl http://checkip.amazonaws.com/)
echo myip=$myip

# get ip of server
ip_address=$(aws ec2 describe-instances --filters Name=key-name,Values=$1 --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo ip_address=$ip_address

# allow ssh in sg
vpcsg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=$serversg --output text --query 'SecurityGroups[*].GroupId')
echo vpcsg_id=$vpcsg_id
aws ec2 authorize-security-group-ingress --group-id $vpcsg_id --protocol tcp --port 38142 --cidr $myip/32

echo ssh -i $1.pem -p $sshport -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no $sshuser@$ip_address
# wait for ssh
echo -n "waiting for ssh"
while ! ssh -i $1.pem -p $sshport -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no $sshuser@$ip_address > /dev/null 2>&1 true; do
 echo -n . ; sleep 3;
done; echo " ssh ok"

# make and run expect script
# use timeout -1 for no timeout
echo "#!/usr/bin/expect -f" > expect.sh
echo "set timeout -1" >> expect.sh
echo "spawn ssh -i $1.pem -p $sshport -o ConnectTimeout=60 -o BatchMode=yes -o StrictHostKeyChecking=no $sshuser@$ip_address" >> expect.sh
echo "send \"sudo su\n\"" >> expect.sh
echo "expect \"password for $sshuser:\"" >> expect.sh
echo "send \"$pass\n\"" >> expect.sh
echo "interact" >> expect.sh
chmod +x expect.sh
./expect.sh
rm expect.sh

# script now waits for double 'exit'

# remove ssh in sg
aws ec2 revoke-security-group-ingress --group-id $vpcsg_id --protocol tcp --port $sshport --cidr $myip/32
echo "revoked sg access"

exit
