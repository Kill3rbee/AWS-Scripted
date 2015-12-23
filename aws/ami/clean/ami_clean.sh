#!/bin/bash
/sbin/service rsyslog stop 2>/dev/null
/sbin/service auditd stop 2>/dev/null
/usr/bin/yum clean all
/usr/sbin/logrotate -f /etc/logrotate.conf
find / -name .bash_history -exec shred -zu {} \;
find /etc -name ssh_host\* -exec shred -zu {} \;
find / -name .ssh -print | while read i; do sudo shred -zu ${i}/* 2>/dev/null; done

shred -zu /var/log/* 2>/dev/null
shred -zu /var/log/audit/* 2>/dev/null
/bin/cat /dev/null > /var/log/audit/audit.log
/bin/cat /dev/null > /var/log/wtmp
/bin/cat /dev/null > /var/log/lastlog

shred -zu /etc/udev/rules.d/70*
