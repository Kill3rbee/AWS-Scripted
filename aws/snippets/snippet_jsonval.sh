# extract from aws/ami/email/make.sh
# this function allows us to extract data from a json string
function jsonval {
	temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop | cut -d":" -f2| sed -e 's/^ *//g' -e 's/ *$//g'`
	echo ${temp##*|}
	}

# make ses user
aws iam create-user --user-name sesuser

# we need to get 2 values from this returned data but can only call the function once
# hence the laborious jsonval method
json=$(aws iam create-access-key --user-name sesuser)

# get key id
prop='AccessKeyId'
AccessKeyId=`jsonval`

# get secret key
prop='SecretAccessKey'
SecretAccessKey=`jsonval`
