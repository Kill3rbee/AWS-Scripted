#!/bin/bash

# one script to rule them all...

echo $'\n\n*********************\n SETUP AWS APPLICATION\n*********************\n'

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./master/master.sh"
 exit
fi

# include global variables
. ./master/vars.sh

# make passwords
./credentials/makepasswords.sh

# order below is crucial

echo $'\n\n*********************\n MAKING VPC\n*********************\n\n'
. ./ami/vpc/make.sh
echo $'\n\n*********************\n MADE VPC\n*********************\n\n'

echo $'\n\n*********************\n MAKING RDS DB\n*********************\n\n'
. ./ami/rds/make.sh
echo $'\n\n*********************\n MADE RDS DB\n*********************\n\n'

echo $'\n\n*********************\n MAKING SHARED IMAGE\n*********************\n\n'
. ./ami/shared/make.sh
echo $'\n\n*********************\n MADE SHARED IMAGE\n*********************\n\n'

echo $'\n\n*********************\n MAKING RDS DB 2\n*********************\n\n'
. ./ami/rds/make2.sh
echo $'\n\n*********************\n MADE RDS DB 2\n*********************\n\n'

echo $'\n\n*********************\n MAKING ADMIN\n*********************\n\n'
. ./ami/admin/make.sh
echo $'\n\n*********************\n MADE ADMIN\n*********************\n\n'

echo $'\n\n*********************\n MAKING ELB\n*********************\n\n'
. ./ami/elb/make.sh $elbselfsigned
echo $'\n\n*********************\n MADE ELB\n*********************\n\n'

for (( i=1; i<=$numwebs; i++ )) do
 echo $'\n\n*********************\n MAKING WEB\n*********************\n\n'
 . ./ami/webphp/make.sh $i
 echo $'\n\n*********************\n MADE WEB\n*********************\n\n'
done

echo $'\n\n*********************\n MAKING SES1\n*********************\n\n'
. ./ami/email/make.sh
echo $'\n\n*********************\n MADE SES1\n*********************\n\n'

echo $'\n\n*********************\n MAKING DATA\n*********************\n\n'
. ./data/makedata.sh
echo $'\n\n*********************\n MADE DATA\n*********************\n\n'

echo $'\n\n*********************\n UPLOADING DATABASE\n*********************\n\n'
. ./upload/database/upload.sh
echo $'\n\n*********************\n UPLOADED DATABASE\n*********************\n\n'

echo $'\n\n*********************\n UPLOADING ADMIN\n*********************\n\n'
. ./upload/admin/upload.sh
echo $'\n\n*********************\n UPLOADED ADMIN\n*********************\n\n'

echo $'\n\n*********************\n UPLOADING WEB SERVERS\n*********************\n\n'
. ./upload/website/uploadall.sh
echo $'\n\n*********************\n UPLOADED WEB SERVERS\n*********************\n\n'

echo $'\n\n*********************\n UPLOADING JAVA\n*********************\n\n'
. ./upload/java/upload.sh
echo $'\n\n*********************\n UPLOADED JAVA\n*********************\n\n'

echo $'\n\n*********************\n MAKING SES2\n*********************\n\n'
. ./ami/email/make2.sh
echo $'\n\n*********************\n MADE SES2\n*********************\n\n'

elbdns=$(aws elb describe-load-balancers --load-balancer-names $elbname --output text --query 'LoadBalancerDescriptions[*].DNSName')
echo website=http://$elbdns
echo website=https://$elbdns
echo "domain registry: point a cname record www for your domain to $elbdns"
echo "at your DNS Registrar, add a TXT record to yourdomain.com containing: include:amazonses.com"

echo master script finished
