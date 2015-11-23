#!/usr/bin/expect
spawn openssl rsa -in server.key.org -out server.key
expect ":"
send "somepassword7372638\n"
interact
