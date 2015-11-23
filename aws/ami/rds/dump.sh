#!/bin/bash

# makes a mysql dump command to dump your database
# you can copy and paste it to the admin server
# after ./credentials/connectssh.sh admin

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./ami/rds/dump.sh"
 exit
fi

# include global variables
. ./master/vars.sh

cd $basedir

# include passwords
source credentials/passwords.sh

# this is the address, or endpoint, for the db
dbendpoint=$(aws rds describe-db-instances --db-instance-identifier $dbinstancename --output text --query 'DBInstances[*].Endpoint.Address')
echo dbendpoint=$dbendpoint

echo $'\nthis is the dump command:\n'
echo "mysqldump --host=$dbendpoint --user=mainuser --password=$password1 $dbname > dump.sql"
echo $'\nrun it on the admin server'
