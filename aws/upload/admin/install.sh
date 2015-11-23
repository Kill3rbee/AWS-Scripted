#!/bin/bash

# remove admin website, but not phpmyadmin or loganalyzer
rm -f /var/www/html/*.php
rm -f /var/www/html/*.css
rm -f -r /var/www/html/sched

# copy the admin zip, unpack and delete it
cp admin.zip /var/www/html/admin.zip
cd /var/www/html
unzip admin.zip
rm -f admin.zip

# set permissions on the webroot
find /var/www/html -type d -exec chown root:apache {} +
find /var/www/html -type d -exec chmod 550 {} +
find /var/www/html -type f -exec chown root:apache {} +
find /var/www/html -type f -exec chmod 440 {} +

# cleanup any uploaded files
rm -f -R /home/ec2-user/*
echo "deleted files from /home/ec2-user"

# needed for expect to finish
echo "install.sh finished"
