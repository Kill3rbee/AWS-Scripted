pvresize /dev/xvdb
lvresize -rl +100%FREE /dev/mapper/u01-u01
