<?php

	// an example of how to do a scheduled page
	// this page is 'cron'ed in aws/ami/admin/install_admin_template.php
	// output is piped to a log file (/var/log/ataglance.log)
	// with /usr/bin/logger
	
	// can be called without signing in
	$signin=1;
	require "../init.php";
	
	// these will be sent to the log file
	ini_set("show_errors", 1);
	
	// do a listing of log files
	$logdir="/var/log/";
	$logs=array("adminhttpderr.log", "webhttpderr.log", "javamail.log", "adminhttpd.log", "webhttpd.log", "ataglance.log");
	foreach ($logs as $log) {
		$output = shell_exec('ls -lart '.$logdir.$log.' 2>&1');
		$msg.=$output."\n";
		$output = shell_exec('tail -n 3 '.$logdir.$log.' 2>&1');
		$msg.=$output."\n\n";
		}
	
	// send them in an email
	$result=doSQL("insert into sendemails (userID, sendto, sendfrom, sendsubject, sendmessage) values (?, ?, ?, ?, ?)", 1, $global_sendemailfrom, $global_sendemailfrom, "At A Glance", $msg) or die("Error");
	
	// send a message to the logfile
	echo "At a glance done";
?>
