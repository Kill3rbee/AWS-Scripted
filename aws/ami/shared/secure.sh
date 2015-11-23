#!/bin/bash

# script to make linux more secure

# daily yum update
cp yumupdate.sh /etc/cron.daily/yumupdate.sh
chmod +x /etc/cron.daily/yumupdate.sh

#other yum details
yum -y erase inetd xinetd ypserv tftp-server telnet-server rsh-serve
yum -y update

#turn of unwanted services
chkconfig ip6tables off

# new sshd config
cp sshd_config /etc/ssh/sshd_config
chown root:root /etc/ssh/sshd_config
chmod 400 /etc/ssh/sshd_config

# disable ipv6
echo "install ipv6 /bin/true" > /etc/modprobe.d/disable-ipv6.conf
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf

echo "config kernel"

# harden kernel /etc/sysctl.conf
echo "kernel.exec-shield=1" >> /etc/sysctl.conf
echo "kernel.randomize_va_space=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.rp_filter=1" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.accept_source_route=0" >> /etc/sysctl.conf
echo "net.ipv4.icmp_echo_ignore_broadcasts=1" >> /etc/sysctl.conf
echo "net.ipv4.icmp_ignore_bogus_error_messages=1" >> /etc/sysctl.conf

echo "reboot"

# needs reboot
reboot

# don't forget you need to ssh -p 38142 ... and open aws security rule
exit
