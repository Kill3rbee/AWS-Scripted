#!/usr/bin/expect
# used when we set up boxes to change the password for root
spawn passwd root
expect "New password:"
send "SED-ROOT-PASS-SED\n";
expect "new password:"
send "SED-ROOT-PASS-SED\n";
interact
