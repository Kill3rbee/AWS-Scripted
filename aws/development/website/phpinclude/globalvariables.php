<?php

	// when we upload to Production Environment, this is replaced with 0
	$global_is_dev="SEDis_devSED";
	
	// when we upload to Production Environment,
	// this is replaced with emailsendfrom from aws/master/vars.sh
	// which must be a verified SES email
	$global_sendemailfrom="SEDsendemailfromSED";

	// whether to use development or minified js and css	
	$global_minifyjscss=0;
	if (strlen($global_is_dev)==1)
		// minify if in an AWS environment
		$global_minifyjscss=1;
	// you can override $global_minifyjscss (set to 1)
	// to test minified code on the dev system
	
	// set UTC as the default time zone
	date_default_timezone_set('UTC');
	
	// the address of the standard error page
	$stderr="/public/error.php?err";
	
	// these usernames are denied for signing up
	$global_reserved_usernames=array("administrator", "support", "admin", "security", "website", "site", "company", "error", "warning", "moderator", "moderate", "staff", "employee");

	// 0=don't require ssl 1=require ssl
	// if required, non-ssl requests will be redirected to ssl in init.php
	$global_require_ssl=1;
	
	// session times out after x seconds, eg 30 minutes = 1800 seconds
	$global_sessionexpiry=1800;
	
	// session can at most last x seconds, eg 1 week = 604800 seconds
	$global_sessionmaxtime=604800;
	
	// set variables based on environment
	if (strlen($global_is_dev)==1) {
		// we are on aws, get from httpd.conf
		// the id of this server
		$global_serverid=$_SERVER['SERVERID'];
		// the aeskey for session cookie encryption
		$global_aeskey=$_SERVER['AESKEY'];
		// the recaptcha private key (from aws/credentials/recaptcha.sh)
		$global_recaptcha_privatekey=$_SERVER['RECAPTCHA_PRIVATEKEY'];
		// the recaptcha public key (from aws/credentials/recaptcha.sh)
		$global_recaptcha_publickey=$_SERVER['RECAPTCHA_PUBLICKEY'];
		}
	else {
		// we are on our in-house development environment
		// we assume only one server
		$global_serverid=1;
		// a dummy key
		$global_aeskey="bcb04b7e103a0cd8b54763051cef08bc55abe029fdebae5e1d417e2ffb2a00a3";
		// a recaptcha private key (see Chapter 10 - Google Recaptcha)
		$global_recaptcha_privatekey="<your development recaptcha private key>";
		// a recaptcha public key (see Chapter 10 - Google Recaptcha)
		$global_recaptcha_publickey="<your development recaptcha public key>";
		}
	
?>