#!/bin/bash
ORAVERSION=`ls -1 /u01/app/oracle/product/`;
ORACLE_HOME=/u01/app/oracle/product/${ORAVERSION}/db1
ORACLE_HOSTNAME=`curl -s http://169.254.169.254/latest/meta-data/local-hostname/`
DBF_MOUNT=/u01/app/oracle/
FRA_MOUNT=/u01/app/oracle/

function lockinstall() {
  if [ -f ~/.lockinst12c ]; then
    echo "Another installation is taking place.  Aborting";
    exit 1
  else
    touch ~/.lockinst12c || exit 1
  fi
}

function unlockinstall() {
  rm -f ~/.lockinst12c
}

die() {
  unlockinstall;
  exit 1;
}

function abortscript() {
  echo "received sigint, aborting installation";
  die
}

lockinstall
if [ -f /home/oracle/hosts_add.sh ]; then
  sudo su -c "/bin/bash /home/oracle/hosts_add.sh"
  sudo su -c "rm -f /home/oracle/hosts_add.sh"
fi
trap abortscript SIGINT

echo
echo "The Oracle Database Software (ORACLE_HOME) has been installed at "
echo "${ORACLE_HOME}."
echo "Before you can use the Oracle Software, you will need to create a database."

echo
echo -n "Would you like to create a database now [y|n]:  "
read LINE
RESP="`echo -n ${LINE} | tr 'A-Z' 'a-z' `"

if [ "${RESP}" = "y" ] || [ "${RESP}" = "yes" ]
then
  echo
else
  echo
  echo "You chose not to continue. If you would like to create a database"
  echo "at a later time,  simply log out and then log in again as the ec2-user."
  echo
  unlockinstall
  exit
fi

mkdir -p ${DBF_MOUNT}/oradata
mkdir -p ${DBF_MOUNT}/admin
mkdir -p ${FRA_MOUNT}/flash_recovery_area
chown -R oracle:oinstall ${DBF_MOUNT}/oradata
chown -R oracle:oinstall ${DBF_MOUNT}/admin
chown -R oracle:oinstall ${FRA_MOUNT}/flash_recovery_area

## START ORACLE USER OUI INSTALL
export DBF_MOUNT FRA_MOUNT ORACLE_HOME

DBCA_TEMPLATE_DIR=${ORACLE_HOME}/assistants/dbca/templates
DBCA_TEMPLATE_NAME=${DBCA_TEMPLATE_DIR}/General_Purpose.dbc
ORACLE_OWNER=oracle
DBCA=${ORACLE_HOME}/bin/dbca
SQLPLUS=${ORACLE_HOME}/bin/sqlplus
EMCTL=${ORACLE_HOME}/bin/emctl
DB_FILE_DIR=${DBF_MOUNT}/oradata
RECO_AREA=${FRA_MOUNT}/flash_recovery_area

while :
do
  ## ORACLE_SID ##
  echo
  echo "Please enter the name for your Oracle Database. "
  echo "This name will be used as your "
  echo -n "ORACLE SID (System Identifier):  "
  read LINE
  while [ -z "$LINE" ]
  do
   echo -n "ORACLE SID can not be null, please try again:  "
   read LINE
  done

  NDB_LENGTH="`echo ${LINE} | wc -L`"

  while [ ${NDB_LENGTH} -gt 8 ]
  do
   echo "The new database name: ${LINE} is too long.  The database name must be 8 bytes or less, please try again:  "
   read LINE
  NDB_LENGTH="`echo ${LINE} | wc -L`"
  done

  SID=$LINE
  GLOBAL_NAME=$SID

  ## PASSWORDS ##
  echo
  echo "Please specify the passwords for the database administrative accounts."
  echo "All passwords must be a minimum of 6 characters in length and must"
  echo "contain a combination of letters and numbers."
  echo

  for dbuser in SYS SYSTEM DBSNMP
  do
    echo
    if [ "${dbuser}" = "SYS" ] || [ "${dbuser}" = "SYSTEM" ]
    then
     display_user="${dbuser} (Database Administrative Account)"
    elif [ "${dbuser}" = "DBSNMP" ] || [ "${dbuser}" = "SYSMAN" ]
    then
     display_user="${dbuser} (Enterprise Manager Administrative Account)"
    else
     display_user=${dbuser}
    fi
     echo -n "${display_user} Password:  "
    while [ 1 ]
    do
      /bin/stty -echo > /dev/null 2>&1
      temp=`echo $IFS`
      export IFS="\n"
      while [ 1 ]
      do
      read LINE

      while [ -z "$LINE" ]
      do
       echo
       echo -n "Password can not be null, please try again:  "
       read LINE
      done

      result=`expr index "$LINE" [\'\"]`
      if [ $result != 0 ];
      then
       echo
       echo -n "The password you entered contains invalid characters. Please try again:  "
       continue
      fi

      if [[ ${#LINE} -ge 6 && "$LINE" == *[a-z]* && "$LINE" == *[0-9]* ]]; then
        # password match criteria
        break
      else
        echo
        echo "The password does not meet the minimum requirements. Please try another password.  "
        echo -n "${display_user} Password:  "
        continue
      fi
    done
    echo
    echo -n "Confirm ${dbuser} password:  "
    read LINE1
    echo
    if [ "$LINE" != "$LINE1" ];
    then
      echo
     echo -n "Passwords do not match.  Please enter the password again:  "
    else
     break
    fi
   done

   if [ ${dbuser} = "SYS" ]
   then
    SYS_PWD=$LINE
   elif [ ${dbuser} = "SYSTEM" ]
   then
    SYSTEM_PWD=$LINE
   elif [ ${dbuser} = "DBSNMP" ]
   then
    DBSNMP_PWD=$LINE
   elif [ ${dbuser} = "SYSMAN" ]
   then
    SYSMAN_PWD=$LINE
   elif [ ${dbuser} = "ADMIN" ]
   then
    APEX_PWD=$LINE
   else
    echo "Invalid database user: ${dbuser}"
    echo
    echo "The above error must be fixed before we can proceed."
    echo "After you fix the problem, you can create a database"
    echo "by running the following program:"
    echo "$0"
    echo
    die
   fi

   /bin/stty echo > /dev/null 2>&1
   export IFS=$temp
 done
 break;
done

export ORACLE_SID=${SID}

echo
echo "Please wait while your database is created, it may take up to 15 minutes."
echo

${DBCA} -silent -createDatabase -templateName ${DBCA_TEMPLATE_NAME} -gdbName ${GLOBAL_NAME} -sid ${SID} -sysPassword ${SYS_PWD} -systemPassword ${SYSTEM_PWD} -dbsnmpPassword ${DBSNMP_PWD} -emConfiguration LOCAL -storageType FS -datafileJarLocation ${DBCA_TEMPLATE_DIR} -sampleSchema true -datafileDestination ${DB_FILE_DIR} -recoveryAreaDestination ${RECO_AREA} -characterSet AL32UTF8
RV=$?
if [ $RV -ne 0 ]; then
  echo
  echo "database installation FAILED.";
  die
fi

# create basrc file containing required env vars
cat > ~/.bashrc << EOT
ORACLE_HOME=${ORACLE_HOME}
ORACLE_SID=${SID}
ORACLE=oracle
ORACLE_UNQNAME=${SID}

PATH=${PATH}:$ORACLE_HOME/bin

export ORACLE_HOME ORACLE_SID PATH

export PS1="\u@\h \w> "
EOT

# include just created env variables
. ~/.bashrc

echo "please wait while configuring Enterprise Manager Database Console."

${ORACLE_HOME}/bin/lsnrctl start > /dev/null
echo -e "exec DBMS_XDB_CONFIG.SETHTTPSPORT(1158);\nquit" | ${ORACLE_HOME}/bin/sqlplus / as sysdba > /dev/null
# restart required for EM console to work;
sudo su -c "sed -i 's/:N$/:Y/' /etc/oratab";
sudo su -c "/etc/init.d/oracle stop"
sudo su -c "/etc/init.d/oracle start"

RV=$?
if [ $RV -ne 0 ]; then
  echo
  echo "Failed to update /etc/oratab.";
  die
fi

EX_NAME=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`;
echo
echo "The database and config was created successfully."
echo
echo "To use the database web console, navigate to https://${EX_NAME}:1158/em "
echo "and login with the username SYS and the password you created earlier for the SYS account. "
echo "Note that you must have properly configured your security groups "
echo "to allow the IP you are browsing from to connect to port 1158 on the database instance."
echo
echo "To connect to the database from the command line, type 'sudo su - oracle' to change to the oracle user. "
echo "To start working with the database instance type 'sqlplus / as sysdba' "
echo
echo "Thank You for choosing Oracle Database on EC2!"
echo

rm -f /home/oracle/DBinstaller.sh

# enable startup scripts for swap on instant storage and for oracle start/stop
sudo su -c '/sbin/chkconfig --add oracle'
sudo su -c '/sbin/chkconfig oracle on'

# cleanup user bash_profile
sudo su -c 'mv -f ~ec2-user/.bash_profile.empty ~ec2-user/.bash_profile'

unlockinstall

exit 0;

