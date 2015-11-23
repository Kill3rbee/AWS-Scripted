#!/bin/sh

# interactive script to set up SES user and smtp credentials
# ses regions are limited
# creates file credentials/smtp.sh
# which is needed by upload/java/upload.sh

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./ami/email/make.sh"
 exit
fi

# include global variables
. ./master/vars.sh

cd $basedir

# this function allows us to extract data from a json string
function jsonval {
	temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop | cut -d":" -f2| sed -e 's/^ *//g' -e 's/ *$//g'`
    echo ${temp##*|}
	}

# make ses user
echo creating aws ses user
aws iam create-user --user-name sesuser
# the ses user can send raw email
policy={\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":\"ses:SendRawEmail\",\"Resource\":\"*\"}]}
echo policy=$policy
echo $policy > temppolicy
# attach the policy to the user
aws iam put-user-policy --user-name sesuser --policy-name SESAccess --policy-document file://temppolicy
rm -f temppolicy

# we need to get 2 values from this returned data but can only call the function once
# hence the laborious jsonval method
json=$(aws iam create-access-key --user-name sesuser)

# get key id
prop='AccessKeyId'
AccessKeyId=`jsonval`

# get secret key
prop='SecretAccessKey'
SecretAccessKey=`jsonval`

# save these values as they can't be redownloaded
cd $basedir
echo $AccessKeyId > credentials/sesuser_AccessKeyId
echo $SecretAccessKey > credentials/sesuser_SecretAccessKey

# the smtp password needs to be generated from the secret access key
# we need java to do this
echo making smtp password with java
cd $basedir/ami/email/pgen
smtppass=$(java -cp . SesSmtpCredentialGenerator $SecretAccessKey)

# write smtp credentials to a file we can use later
echo writing smtp.sh
cd $basedir/credentials
rm -f smtp.sh
# not all regions support SES, check http://docs.aws.amazon.com/ses/latest/DeveloperGuide/regions.html
echo "#!/bin/bash" > smtp.sh
echo "smtp_server=email-smtp.$deplyregion.amazonaws.com" >> smtp.sh
echo "smtp_port=25" >> smtp.sh
echo "smtp_user=$AccessKeyId" >> smtp.sh
echo "smtp_pass=$smtppass" >> smtp.sh
echo "" >> smtp.sh
chmod +x smtp.sh

# we need to verify the email identity of the sending email so we can attach the sns feeds to the ses notifications
# you will receive an email, do what it says
aws ses verify-email-identity --email-address $emailsendfrom --region $deployregion
echo email to verify identity sent to $emailsendfrom please click link in email

cd $basedir
