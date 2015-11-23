#!/bin/sh

# aws account number
# available from Aws > Name > My Account
# used by SNS verify message
# create a dummy user, get the Account Identifier from the ARN, delete the user

arn=$(aws iam create-user --user-name getaccount --output text --query 'User.Arn')
aws_account=$(echo $arn | cut -d ":"  -f 5)
echo aws_account=$aws_account
aws iam delete-user --user-name getaccount
