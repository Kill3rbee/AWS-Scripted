#!/bin/bash

# install database from admin server

echo "installing db"
mysql --host=SEDdbhostSED --user=mainuser --password=SEDdbmainuserpasswordSED --database=SEDdbnameSED --execute="SOURCE dbs.sql"
echo "db installed"

echo "installing users"
mysql --host=SEDdbhostSED --user=mainuser --password=SEDdbmainuserpasswordSED --database=SEDdbnameSED --execute="SOURCE dbusers.sql"
echo "users installed"

echo "testing db"
mysql --host=SEDdbhostSED --user=mainuser --password=SEDdbmainuserpasswordSED --database=SEDdbnameSED --execute="show tables;"
echo "db tested"

rm -f -R /home/ec2-user/*
echo "deleted files from /home/ec2-user"

echo install.sh finished
