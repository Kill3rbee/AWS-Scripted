#!/bin/bash

# copies web, admin, database and java data files to data/website/ data/admin/ data/database/ data/java/ respectively

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./data/makedata.sh"
 exit
fi

# include global variables
. ./master/vars.sh

cd $basedir

# minify js and css in the development directory
# this is so you can test minified code by overriding $global_minifyjscss in globalvariables.php
. ./minify/make.sh

# clear any existing data
rm -f -r data/website
rm -f -r data/admin
rm -f -r data/database
rm -f -r data/java

# remake the data directories
mkdir -p data/website
mkdir -p data/admin
mkdir -p data/database
mkdir -p data/java
mkdir -p data/java/javaMail

# prepare the website
cp -R $webdir/htdocs data/website/htdocs
rm -f -r data/website/htdocs/admin
rm -f -r data/website/htdocs/jscss/dev

# prepare php include files
cp -R $webdir/phpinclude data/website/phpinclude

# tell the website it's running on aws
# insert the email to send from
sed -e "s/SEDis_devSED/0/g" -e "s/SEDsendemailfromSED/$emailsendfrom/g" data/website/phpinclude/globalvariables.php > data/website/phpinclude/globalvariables2.php
rm -f data/website/phpinclude/globalvariables.php
mv data/website/phpinclude/globalvariables2.php data/website/phpinclude/globalvariables.php

# prepare database files
cp -R $databasedir/* data/database

# prepare admin files
cp -R $admindir/* data/admin

# tell the admin website it's running on aws
# insert the email to send from
sed -e "s/SEDis_devSED/0/g" -e "s/SEDsendemailfromSED/$emailsendfrom/g" data/admin/init.php > data/admin/init2.php
rm -f data/admin/init.php
mv data/admin/init2.php data/admin/init.php

# prepare javaMail files
cp $javadir/javaMail/javaMail.jar data/java/javaMail
cp $javadir/javaMail/config_template.properties data/java/javaMail

cd $basedir

echo "done"
