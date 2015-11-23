#!/bin/bash

# stop apache
service httpd stop

# delete and recreate the jail
rm -f -R /jail
mkdir -p /jail/var/www/html
mkdir -p /jail/var/www/phpinclude

# copy and unpack assets
cp phpinclude.zip /jail/var/www/phpinclude/phpinclude.zip
cp htdocs.zip /jail/var/www/html/htdocs.zip
cd /jail/var/www/phpinclude
unzip phpinclude.zip
rm -f phpinclude.zip
cd /jail/var/www/html
unzip htdocs.zip
rm -f htdocs.zip

# if you were to use php sessions, you would need this
#mkdir -p /jail/var/lib/php/session

# this is so UTC can work
mkdir -p /jail/usr/share/zoneinfo
cp /usr/share/zoneinfo/UTC /jail/usr/share/zoneinfo

# modsecurity needs a writable folder
mkdir -p /jail/var/lib/mod_security

# allow dns to work
mkdir -p /jail/etc
cp /etc/resolv.conf /jail/etc/resolv.conf

# allow curl ssl and verify to work
mkdir -p /jail/etc
cp /etc/nsswitch.conf /jail/etc/nsswitch.conf
cp -r /etc/pki /jail/etc
cp -r /etc/ssl /jail/etc
mkdir -p /jail/usr/lib64
cp /usr/lib64/libnsspem.so /jail/usr/lib64/libnsspem.so
cp /usr/lib64/libsoftokn3.so /jail/usr/lib64/libsoftokn3.so
cp /usr/lib64/libnsssysinit.so /jail/usr/lib64/libnsssysinit.so
cp /usr/lib64/libfreebl3.so /jail/usr/lib64/libfreebl3.so
cp /usr/lib64/libnssdbm3.so /jail/usr/lib64/libnssdbm3.so

# set the default certificate bundle
echo curl.cainfo=/etc/ssl/certs/ca-bundle.crt >> /etc/php.d/curl.ini

# set permissions on the jail
find /jail -type d -exec chown root:apache {} +
find /jail -type d -exec chmod 550 {} +
find /jail -type f -exec chown root:apache {} +
find /jail -type f -exec chmod 440 {} +

# for php sessions, apache needs write access
#chmod 660 /jail/var/lib/php/session

# mod_security needs write/traverse access
chown root:apache /jail/var/lib/mod_security
chmod 770 /jail/var/lib/mod_security

# cleanup
rm -f -R /home/ec2-user/*
echo "deleted files from /home/ec2-user"

# start apache
service httpd start

# needed for expect in calling script
echo "install.sh finished"
