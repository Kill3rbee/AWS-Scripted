#!/bin/bash

# interactive script to set up SES and SNS for email sending
# must be run after the website is running
# ses regions are limited
# we link to the elb name and don't use SSL (it needs to be valid)

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

# address of elb
elbdns=$(aws elb describe-load-balancers --load-balancer-names $elbname --output text --query 'LoadBalancerDescriptions[*].DNSName')
echo $elbdns

# where sns looks for your bounce and complaint scripts
# you can change this to your real domain name and https if you have set up your CNAME record and have valid SSL
scriptshost=$elbdns
echo scriptshost=$scriptshost
protocol=http
echo protocol=$protocol

# check the website is running
# elb.htm should return ok
elbokaddr=$protocol://$scriptshost/elb.htm
echo $elbokaddr
echo -n "waiting for website"
while elbok=$(curl $elbokaddr); test "$elbok" != "ok"; do
 echo -n . ; sleep 3;
done; echo " $elbok"

# check email has been verified
# needed to attach ses feeds to sns topics
echo -n "waiting for verification of $emailsendfrom (click link in email)"
while verified=$(aws ses get-identity-verification-attributes --identities "$emailsendfrom" --region $deployregion --output text --query 'VerificationAttributes."'$emailsendfrom'".VerificationStatus'); test "$verified" != "Success"; do
 echo -n . ; sleep 3;
done; echo " $elbok"

echo "creating SNS Topics (Bounce and Complaint)"

# this is the bounced email topic
bouncesnsarn=$(aws sns create-topic --name EmailBounce --output text --query 'TopicArn' --region $deployregion)
echo "bouncesnsarn=$bouncesnsarn"

# subscribe to the script on your webserver
echo "pointing to bounce receiver url"
aws sns subscribe --topic-arn $bouncesnsarn --protocol $protocol --notification-endpoint $protocol://$scriptshost/sns/bounce.php --region $deployregion

# this is the complained email topic
complaintsnsarn=$(aws sns create-topic --name EmailComplaint --output text --query 'TopicArn' --region $deployregion)
echo complaintsnsarn=$complaintsnsarn

# subscribe to the script on your webserver
echo "pointing to complaint receiver url"
aws sns subscribe --topic-arn $complaintsnsarn --protocol $protocol --notification-endpoint $protocol://$scriptshost/sns/complaint.php --region $deployregion

# attach ses feeds to sns topics
echo "attaching sns to ses feeds"
aws ses set-identity-notification-topic --identity $emailsendfrom --notification-type Bounce --sns-topic $bouncesnsarn --region $deployregion
aws ses set-identity-notification-topic --identity $emailsendfrom --notification-type Complaint --sns-topic $complaintsnsarn --region $deployregion

# we don't want an email every time (but you might)
echo "disable feedback forwarding"
aws ses set-identity-feedback-forwarding-enabled --identity $emailsendfrom --no-forwarding-enabled --region $deployregion

echo SES SNS done
echo test by sending to success@simulator.amazonses.com
echo or bounce@simulator.amazonses.com
echo or complaint@simulator.amazonses.com
echo or suppressionlist@simulator.amazonses.com
echo then request production access at http://aws.amazon.com/ses/fullaccessrequest/

echo "if testing, you need to verify those emails (send or receive) until you get production access"

cd $basedir
