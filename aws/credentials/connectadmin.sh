#!/bin/bash

# open up required sg inbounds and connect to admin server via Chrome
# when Quit Chrome, close up security

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./credentials/connectadmin.sh"
 exit
fi

# include global variables
. ./master/vars.sh

myip=$(curl -s http://checkip.amazonaws.com/)
echo myip=$myip

# get ip of server
ip_address=$(aws ec2 describe-instances --filters Name=key-name,Values=admin --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo admin_ip_address=$ip_address

echo "PRECONNECT: perhaps 38142 should be open to the world but nothing else except security groups"
aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=adminsg --output text

vpcadminsg_id=$(aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=adminsg --output text --query 'SecurityGroups[*].GroupId')
echo vpcadminsg_id=$vpcadminsg_id

# allow 443 and 8443 in sg
echo -n authorising :443 
result=$(aws ec2 authorize-security-group-ingress --group-id $vpcadminsg_id --protocol tcp --port 443 --cidr $myip/32 --output text)
if test "$result" = "true"; then
	echo " ok"
else
	echo " ERROR"
#	exit;
fi

echo -n authorising :8443 
result=$(aws ec2 authorize-security-group-ingress --group-id $vpcadminsg_id --protocol tcp --port 8443 --cidr $myip/32 --output text)
if test "$result" = "true"; then
	echo " ok"
else
	echo " ERROR"
#	exit;
fi

echo "YOU MUST QUIT CHROME WITH command-Q"
echo connecting to https://$ip_address

open -a "Google Chrome" --args --homepage https://$ip_address
open -a "Google Chrome" https://$ip_address:8443
open -a "Google Chrome" https://$ip_address/phpmyadmin
open -a "Google Chrome" -W https://$ip_address/loganalyzer

# remove 443 and 8443 in sg
echo -n revoking :443 
result=$(aws ec2 revoke-security-group-ingress --group-id $vpcadminsg_id --protocol tcp --port 443 --cidr $myip/32 --output text)
if test "$result" = "true"; then
	echo " ok"
else
	echo " ERROR"
fi

echo -n revoking :8443 
result=$(aws ec2 revoke-security-group-ingress --group-id $vpcadminsg_id --protocol tcp --port 8443 --cidr $myip/32 --output text)
if test "$result" = "true"; then
	echo " ok"
else
	echo " ERROR"
fi

echo "POSTCONNECT: perhaps 38142 should be open to the world but nothing else except security groups"
aws ec2 describe-security-groups --filters Name=tag-key,Values=sgname --filters Name=tag-value,Values=adminsg --output text

echo done
