#!/bin/bash

# delete old java files
rm -f /java/javamail/javaMail.jar
rm -f /java/javamail/config.properties

# move new ones
mv /home/ec2-user/javaMail.jar /java/javamail/javaMail.jar
mv /home/ec2-user/config_javaMail.properties /java/javamail/config.properties

# set permissions on the java folder
chown root:root /java
chmod 700 /java
find /java -type d -exec chown root:root {} +
find /java -type d -exec chmod 700 {} +
find /java -type f -exec chown root:root {} +
find /java -type f -exec chmod 700 {} +

# cleanup
rm -f -R /home/ec2-user/*
echo "deleted files from /home/ec2-user"

# tell expect in calling script we are finished
echo "install.sh finished"
