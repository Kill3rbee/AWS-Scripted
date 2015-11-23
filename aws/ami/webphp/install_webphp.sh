#!/bin/bash

# install packages
yum -y install php php-bcmath php-mysql php-mbstring php-mcrypt openssl httpd
yum -y install mod_security mod_security_crs.noarch
yum --disablerepo="*" --enablerepo="epel" -y install php-suhosin

# install mod_rpaf
rpm -ivh mod_rpaf-0.6-0.7.x86_64.rpm

# copy conf files
cp -f httpd.conf /etc/httpd/conf/httpd.conf
cp -f php.ini /etc/php.ini
cp -f mod_evasive.conf /etc/httpd/conf.d/mod_evasive.conf
cp -f modsecurity_overrides /etc/httpd/modsecurity.d/modsecurity_overrides

# set permissions on conf files
chown root:root /etc/httpd/conf/httpd.conf
chmod 400 /etc/httpd/conf/httpd.conf
chown root:root /etc/php.ini
chmod 400 /etc/php.ini
chown root:root /etc/httpd/modsecurity.d/modsecurity_overrides
chmod 400 /etc/httpd/modsecurity.d/modsecurity_overrides

# clear current webroot
rm -f -R /var/www/cgi-bin
rm -f -R /var/www/error
rm -f -R /var/www/icons
rm -f -R /var/www/html/*
rm -f -R /jail

# make the jailed webroot
mkdir -p /jail/var/www/html
mkdir -p /jail/var/www/phpinclude

# install monit
yum install -y monit
# configure monit
cd /home/ec2-user
cp -f monit.conf /etc/monit.conf
# start at boot
chkconfig --levels 2345 monit on

# turn off autostart services (monit handles them)
chkconfig --levels 2345 ntpd off
chkconfig --levels 2345 sshd off
chkconfig --levels 2345 httpd off

# configure rsyslog
cd /home/ec2-user
cp -f rsyslog.conf /etc/rsyslog.conf
chown root:root /etc/rsyslog.conf
chmod 400 /etc/rsyslog.conf

# remove ec2-user no password from sshed with key feature
echo "ec2-user ALL = ALL" > /etc/sudoers.d/cloud-init

# install expect
yum install -y expect

# update root and ec2-user passwords
cd /home/ec2-user
./chp_ec2-user.sh
./chp_root.sh

# remove expect
yum erase -y expect

# clear any files
rm -f -R /home/ec2-user/*

# further configuration is done in /aws/upload/website/uploadall.sh
reboot
