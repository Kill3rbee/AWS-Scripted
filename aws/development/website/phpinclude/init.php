<?php

	// global variables
	include 'globalvariables.php';

	// redirect to ssl if:
	//  global_require_ssl is set
	//  we are on an aws environment
	if (	(strlen($global_is_dev)==1)&&($global_require_ssl==1)) {
		if ($_SERVER['HTTP_X_FORWARDED_PROTO']!="https") {
			$redirect= "https://".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];
			header("Location:$redirect");
			exit;
			}
		}

	// include database functionality
	include 'db.php';
	
	// include shared functions
	include 'globalfunctions.php';
	
	// include session functions
	include 'sessions.php';
	
	// connect to the database
	// this can be called again with a different user as required
	// eg dbconnect(1)
	dbconnect(0);
	
	// set up the session (if it exists)
	$S=sessionuse();
	
?>