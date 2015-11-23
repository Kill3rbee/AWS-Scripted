#!/bin/bash

# check aws for regions, zones and pricing
deployregion=eu-west-1
deployzone=eu-west-1a
deployzone2=eu-west-1b

# the fully qualified path to the aws directory
basedir=/Users/ccerri/Desktop/aws

# these directories point to your development environment
# currently they point to the aws/development folder
# you should change them to your specific dev folders
# webdir would refer to your apache2 directory (ie contains htdocs and phpinclude)
# you might share the apache folder on a server and use /Volumes/apache2
webdir=$basedir/development/website
admindir=$basedir/development/website/htdocs/admin
javadir=$basedir/development/java
databasedir=$basedir/development/database

# location of the sshknowhosts file for your user account
sshknownhosts=/Users/ccerri/.ssh/known_hosts

# database config
# the instance type to use (different from ec2 instance types)
rdsinstancetype=db.m3.medium
# in GB
rdsvolumesize=40
# 1=use multi-az, 0=don't
rdsusemultiaz=0
# name for your db subnet group
dbsubnetgroupname=MYDBSUBNETGROUP
# description for said db subnet group
dbsubnetgroupdesc=MYDBSUBNETGROUPDESC
# name for your db parameter group
dbpgname=MYDBPG
# description for said parameter group
dbpgdesc=MYDBPGDESC
# name of the rds instance
dbinstancename=MYDBINSTANCE
# name for your db
dbname=MYDB

# this may change so find the latest from the aws console
# Amazon Linux AMI, HVM
baseami=ami-aa8f28dd
# use this instance type for the temporary shared image server
sharedinstancetype=m1.small
# in GB, subsequent servers can be larger, but not smaller
sharedebsvolumesize=20

# the instance type for the admin server
admininstancetype=m1.small

# the instance type for each webphp server
webphpinstancetype=m1.small

# size of admin server ebs volume in GB
adminebsvolumesize=100

# size of webphp server ebs volume in GB
webphpebsvolumesize=20

# name for your vpc
vpcname=MYVPC

# name for your elb
elbname=MYELB

# 1=use self-signed ELB SSL cert 0=use valid cert
elbselfsigned=1

# ELB SSL Certificate name (for both self-signed and valid)
elbcertname=MYELBCERT

# valid certificate for ELB (production)
# these files need to be put in aws/ami/elb/validssl
# filename of your .key file as provided by your Certificate Authority
elbvalidcertkeyfile=www_yourdomain_com.key
# filename of your .crt file as provided by your Certificate Authority
elbvalidcertcertfile=www_yourdomain_com.crt
# filename of your intermediate .crt file as provided by your Certificate Authority, eg DigiCert
elbvalidcertinterfile=DigiCertCA.crt

# number of webphp servers to make
numwebs=2

# your domain name
webdomain=www.yourdomain.com

# email address to send from
# must be valid as needs to be verified
emailsendfrom=donotreply@yourdomain.com
