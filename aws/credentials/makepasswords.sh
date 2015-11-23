#!/bin/bash

# create password file

# passwords are used like this
# password1=rds mainuser password
# password2=admin server root user
# password3=admin server ec2-user
# password4=adminrw sql user password
# password5=webphprw sql user password
# password6=javamail sql user password
# password7=sns sql user password
# password8=web1 root user
# password9=web1 ec2-user
# password10=web2 root user
# password11=web2 ec2-user
# password12=web3 root user
# password13=web3 ec2-user
# password14=web4 root user
# password15=web4 ec2-user
# password16=web5 root user
# password17=web5 ec2-user
# password18=web6 root user
# password19=web6 ec2-user
# password20=aeskey for php sessions

# check dir
where=$(pwd)
where="${where: -3}"
if test "$where" = "aws"; then
 echo "running from correct directory"
else
 echo "must be run from aws directory with ./credentials/makepasswords.sh"
 exit
fi

# include global variables
. ./master/vars.sh

cd $basedir/credentials

# save old passwords just in case
now=$(date +"%m_%d_%Y")
mv passwords.sh oldpasswords/passwords_$now.sh

# start the passwords script
echo "#!/bin/bash" > passwords.sh

echo "rds mainuser password (max 16)"
newpassword=$(openssl rand -base64 10)
newpassword=$(echo $newpassword | tr '/' '0')
echo "password1=$newpassword" >> passwords.sh

for (( i=2; i<=20; i++ ))
do
	# randomly discard some passwords
	randdiscard=$[1+$[RANDOM%10]]
	echo "next password $randdiscard"
	for (( j=1; j<=$randdiscard; j++ ))
	do
		newpassword=$(openssl rand -base64 33)
		echo "discarded 1"
	done
	newpassword=$(openssl rand -base64 33)
	newpassword=$(echo $newpassword | tr '/' '0')
	echo "password$i=$newpassword" >> passwords.sh
done

# make the generated script executable
chmod +x passwords.sh

cd $basedir
