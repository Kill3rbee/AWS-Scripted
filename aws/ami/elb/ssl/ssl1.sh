#!/usr/bin/expect
spawn openssl genrsa -des3 -out server.key 1024
expect "Enter pass phrase for server.key:"
send "somepassword7372638\n";
expect "Enter pass phrase for server.key:"
send "somepassword7372638\n";
interact
