#!/bin/bash

case $1 in
 start)
  cd /java/javamail
  echo $$ > javaMail.pid;
  exec 2>&1 java -jar javaMail.jar |/usr/bin/logger -t javamail -p local3.info
  ;;
 stop)
  pid1=$(ps axf | grep "java -jar javaMail.jar" | grep -v grep | awk '{print $1}')
  pid2=$(ps axf | grep "/usr/bin/logger -t javamail -p local3.info" | grep -v grep | awk '{print $1}')
  pid3=$(ps axf | grep "/bin/bash /java/javamail/launch_javaMail.sh start" | grep -v grep | awk '{print $1}')
  kill $pid1
  sleep 2
  kill $pid2
  kill $pid3
  ;;
 *)  
  echo "usage: launch_javaMail.sh {start|stop}" ;;
esac
exit 0
