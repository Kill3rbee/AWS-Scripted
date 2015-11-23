#!/bin/bash

# waits for completion of rds database

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./ami/rds/make2.sh"
 exit
fi

# include global variables
. ./master/vars.sh

cd $basedir

# wait for the db state to be available
echo -n "waiting for db"
while state=$(aws rds describe-db-instances --db-instance-identifier $dbinstancename --output text --query 'DBInstances[*].DBInstanceStatus'); test "$state" != "available"; do
 echo -n . ; sleep 3;
done; echo " $state"

# this is the address, or endpoint, for the db
dbendpoint=$(aws rds describe-db-instances --db-instance-identifier $dbinstancename --output text --query 'DBInstances[*].Endpoint.Address')
echo dbendpoint=$dbendpoint

cd $basedir

echo "database ALIVE"
