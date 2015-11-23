#!/bin/bash

yum -y install mysql php php-soap php-bcmath php-mysql php-mbstring php-imap php-mcrypt openssl mod_ssl httpd

cd /home/ec2-user

# install httpd.conf
cp -f httpd.conf /etc/httpd/conf/httpd.conf
chown root:root /etc/httpd/conf/httpd.conf
chmod 400 /etc/httpd/conf/httpd.conf

# setup admin site
rm -f -R /var/www/cgi-bin
rm -f -R /var/www/error
rm -f -R /var/www/icons
rm -f -R /var/www/html/*

# install phpMyAdmin
yum --enablerepo=epel install -y phpmyadmin
cp -r /usr/share/phpMyAdmin /var/www/html/phpmyadmin
rm -f /etc/httpd/conf.d/phpMyAdmin.conf
cd /home/ec2-user
cp -f config.inc.php /etc/phpMyAdmin/config.inc.php
chown root:apache /etc/phpMyAdmin
chmod 750 /etc/phpMyAdmin
chown root:apache /etc/phpMyAdmin/config.inc.php
chmod 750 /etc/phpMyAdmin/config.inc.php

# install loganalyser
cd /home/ec2-user
#wget http://download.adiscon.com/loganalyzer/loganalyzer-3.6.5.tar.gz
tar -xvf loganalyzer-3.6.5.tar.gz
cd loganalyzer-3.6.5
cp -r src /var/www/html/loganalyzer
cd /home/ec2-user
cp config.php /var/www/html/loganalyzer/config.php

# grant read access to log files
chmod 604 /var/log/messages
chmod 604 /var/log/maillog

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

# install mmonit
mkdir /mmonit
cd /home/ec2-user
cp mmonit-3.2.1-linux-x64.tar.gz /mmonit
cd /mmonit
#wget http://mmonit.com/dist/mmonit-3.2-linux-x64.tar.gz
tar -xvf mmonit-3.2.1-linux-x64.tar.gz
rm -f mmonit-3.2.1-linux-x64.tar.gz
cd /home/ec2-user
rm -f /mmonit/mmonit-3.2.1/conf/server.xml
mv server.xml /mmonit/mmonit-3.2.1/conf/server.xml
# to start (but handled by monit)
#cd mmonit-3.2
#./bin/mmonit

# configure rsyslog
cd /home/ec2-user
cp -f rsyslog.conf /etc/rsyslog.conf
chown root:root /etc/rsyslog.conf
chmod 400 /etc/rsyslog.conf

# set webroot permissions
find /var/www/html -type d -exec chown apache:apache {} +
find /var/www/html -type d -exec chmod 500 {} +
find /var/www/html -type f -exec chown apache:apache {} +
find /var/www/html -type f -exec chmod 400 {} +

# remove ec2-user no password from sshed with key feature
echo "ec2-user ALL = ALL" > /etc/sudoers.d/cloud-init

# install expect
yum install -y expect

# update root and ec2-user passwords
cd /home/ec2-user
./chp_ec2-user.sh
./chp_root.sh

# make ssl

cd /home/ec2-user

echo "#!/usr/bin/expect -f" > expect.sh
echo "set timeout -1" >> expect.sh
echo "spawn openssl genrsa -des3 -out server.key 1024" >> expect.sh
echo "expect \":\"" >> expect.sh
echo "send \"somepasswordssl382594\n\"" >> expect.sh
echo "expect \":\"" >> expect.sh
echo "send \"somepasswordssl382594\n\"" >> expect.sh
echo "interact" >> expect.sh
chmod +x expect.sh
./expect.sh
rm expect.sh

echo "#!/usr/bin/expect -f" > expect.sh
echo "set timeout -1" >> expect.sh
echo "spawn openssl req -new -key server.key -out server.csr" >> expect.sh
echo "expect \":\"" >> expect.sh
echo "send \"somepasswordssl382594\n\"" >> expect.sh
echo "expect \":\"" >> expect.sh
echo "send \"GB\n\"" >> expect.sh
echo "expect \":\"" >> expect.sh
echo "send \"London\n\"" >> expect.sh
echo "expect \":\"" >> expect.sh
echo "send \"London\n\"" >> expect.sh
echo "expect \":\"" >> expect.sh
echo "send \"YOURCOMPANY\n\"" >> expect.sh
echo "expect \":\"" >> expect.sh
echo "send \"YOURCOMPANY Admin\n\"" >> expect.sh
echo "expect \":\"" >> expect.sh
echo "send \"SEDadminpublicipSED\n\"" >> expect.sh
echo "expect \":\"" >> expect.sh
echo "send \"youremail@yourdomain.com\n\"" >> expect.sh
echo "expect \":\"" >> expect.sh
echo "send \"\n\"" >> expect.sh
echo "expect \":\"" >> expect.sh
echo "send \"\n\"" >> expect.sh
echo "interact" >> expect.sh
chmod +x expect.sh
./expect.sh
rm expect.sh

cp server.key server.key.org

echo "#!/usr/bin/expect -f" > expect.sh
echo "set timeout -1" >> expect.sh
echo "spawn openssl rsa -in server.key.org -out server.key" >> expect.sh
echo "expect \":\"" >> expect.sh
echo "send \"somepasswordssl382594\n\"" >> expect.sh
echo "interact" >> expect.sh
chmod +x expect.sh
./expect.sh
rm expect.sh

openssl x509 -req -days 3650 -in server.csr -signkey server.key -out server.crt

mkdir -p /etc/httpd/ssl
cp server.crt /etc/httpd/ssl/ssl.crt
cp server.key /etc/httpd/ssl/ssl.key
rm -f /etc/httpd/conf.d/ssl.conf

yum erase -y expect

# do ssl for mmonit
cat server.key > /mmonit/mmonit-3.2.1/conf/mmonit.pem
cat server.crt >> /mmonit/mmonit-3.2.1/conf/mmonit.pem

# add php sched files
line="1 0,6,12,18 * * * wget --no-check-certificate -O - -q https://localhost/sched/ataglance.php | /usr/bin/logger -t ataglance -p local6.info"
(crontab -u root -l; echo "$line" ) | crontab -u root -
echo php scheduled files crontabbed

# logrotate
cd /home/ec2-user
mv logrotatehttp /etc/logrotate.d/logrotatehttp
chown root:root /etc/logrotate.d/logrotatehttp
chmod 644 /etc/logrotate.d/logrotatehttp
mkdir -p /var/log/old
chown root:root /var/log/old
chmod 700 /var/log/old

# javaMail - make new dirs for java files and logs, copy launch files there and set permissions

mkdir /java

mkdir /java/javamail
mv /home/ec2-user/launch_javaMail.sh /java/javamail/launch_javaMail.sh

chown root:root /java
chmod 700 /java
find /java -type d -exec chown root:root {} +
find /java -type d -exec chmod 700 {} +
find /java -type f -exec chown root:root {} +
find /java -type f -exec chmod 700 {} +

rm -f -R /home/ec2-user/*

echo "deleted files from /home/ec2-user"

reboot
