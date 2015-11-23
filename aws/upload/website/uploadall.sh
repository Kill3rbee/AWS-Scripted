#!/bin/bash

# uploads the website to all web instances
# then runs the install script on each server
# data from aws/data/website dir, run ./data/makedata.sh first

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./upload/website/uploadall.sh"
 exit
fi

# include global variables
. ./master/vars.sh

cd $basedir

echo "uploading to all webs"

# build data

cd $basedir/data/website

rm -f htdocs/htdocs.zip
rm -f phpinclude/phpinclude.zip

cd $basedir/data/website/phpinclude
# only zip php files (leave out the annoying DSStore files...)
zip -R phpinclude '*.php'

cd $basedir/data/website/htdocs
# only zip recognised file types (leave out the annoying DSStore files...)
# if you use different file types add them below
zip -R htdocs '*.php' '*.js' '*.css' '*.jpg' '*.ico' '*.png' '*.gif' '*.htm' '*.txt'
#zip -R htdocs '*.*'

# upload to each existing webN

cd $basedir

exists=$(aws ec2 describe-key-pairs --key-names web1 --output text --query 'KeyPairs[*].KeyName' 2>/dev/null)
if test "$exists" = "web1"; then
 echo "web1 exists"
 . ./upload/website/upload.sh 1
else
 echo "web1 not found"
fi

exists=$(aws ec2 describe-key-pairs --key-names web2 --output text --query 'KeyPairs[*].KeyName' 2>/dev/null)
if test "$exists" = "web2"; then
 echo "web2 exists"
 . ./upload/website/upload.sh 2
else
 echo "web2 not found"
fi

exists=$(aws ec2 describe-key-pairs --key-names web3 --output text --query 'KeyPairs[*].KeyName' 2>/dev/null)
if test "$exists" = "web3"; then
 echo "web3 exists"
 . ./upload/website/upload.sh 3
else
 echo "web3 not found"
fi

exists=$(aws ec2 describe-key-pairs --key-names web4 --output text --query 'KeyPairs[*].KeyName' 2>/dev/null)
if test "$exists" = "web4"; then
 echo "web4 exists"
 . ./upload/website/upload.sh 4
else
 echo "web4 not found"
fi

exists=$(aws ec2 describe-key-pairs --key-names web5 --output text --query 'KeyPairs[*].KeyName' 2>/dev/null)
if test "$exists" = "web5"; then
 echo "web5 exists"
 . ./upload/website/upload.sh 5
else
 echo "web5 not found"
fi

exists=$(aws ec2 describe-key-pairs --key-names web6 --output text --query 'KeyPairs[*].KeyName' 2>/dev/null)
if test "$exists" = "web6"; then
 echo "web6 exists"
 . ./upload/website/upload.sh 6
else
 echo "web6 not found"
fi

# cleanup
cd $basedir/data/website/phpinclude
rm -f phpinclude.zip
cd $basedir/data/website/htdocs
rm -f htdocs.zip

cd $basedir

