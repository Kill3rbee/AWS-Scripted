#!/bin/bash

# make everything in /jscss/prod folder

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./minify/make.sh"
 exit
fi

# include global variables
. ./master/vars.sh

minifydir=$basedir
minifydir+=/minify
jscssdir=$webdir
jscssdir+=/htdocs/jscss

echo "minifying js and css"

cd $minifydir

# clear current files
rm -f -R $jscssdir/prod/*

# copy the style sheet
cp $jscssdir/dev/css/style.css $jscssdir/prod/style.css

# copy minified jquery
cp $jscssdir/dev/js/jq/jquery.min.js $jscssdir/prod/jquery.min.js

# create a concatenation of all other javascript files
cat $jscssdir/dev/js/site/signup.js > $jscssdir/prod/general.js
cat $jscssdir/dev/js/jq/jquery.base64.min.js >> $jscssdir/prod/general.js

# minify this file
java -jar yuicompressor-2.4.8.jar $jscssdir/prod/general.js -o $jscssdir/prod/general.min.js

# remove the unminified file
rm -f $jscssdir/prod/general.js

cd $basedir
