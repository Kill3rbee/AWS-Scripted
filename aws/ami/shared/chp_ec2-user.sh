#!/usr/bin/expect
# used when we set up boxes to change the password for ec2-user
spawn passwd ec2-user
expect "New password:"
send "SED-EC2-USER-PASS-SED\n";
expect "new password:"
send "SED-EC2-USER-PASS-SED\n";
interact
