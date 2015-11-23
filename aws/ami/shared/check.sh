#!/bin/bash

# script to check some linux security issues

echo "some linux security checks"

echo "You should only see one line as follows: root:x:0:0:root:/root:/bin/bash"
awk -F: '($3 == "0") {print}' /etc/passwd

#echo "press a key"
#read -n 1 -s

# check network listeners
echo "net listeners"
netstat -tulpn

#echo "press a key"
#read -n 1 -s

# Disable Unwanted SUID and SGID Binaries
# All SUID/SGID bits enabled file can be misused when the SUID/SGID executable has a security problem or bug
# All local or remote user can use such file. It is a good idea to find all such files. Use the find command as follows:
# See all set user id files:
echo "Disable Unwanted SUID and SGID Binaries"
find / -perm +4000

#echo "press a key"
#read -n 1 -s

echo "See all group id files"
find / -perm +2000

#echo "press a key"
#read -n 1 -s

echo "World-Writable Files"
# Anyone can modify world-writable file resulting into a security issue
# Use the following command to find all world writable and sticky bits set files:
find / -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -print

#echo "press a key"
#read -n 1 -s

echo "Noowner Files"
# Files not owned by any user or group can pose a security problem
# Just find them with the following command which do not belong to a valid user and a valid group
find / -xdev \( -nouser -o -nogroup \) -print

#echo "press a key"
#read -n 1 -s

echo "deleting ec2-user files"

rm -f /home/ec2-user/*
ls
