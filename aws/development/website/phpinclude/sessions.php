<?php

	// to get mcrypt to work on osx installations of apache, look at:
	// http://topicdesk.com/downloads/mcrypt/mcrypt-download
	// or use macports

	// setup a session just after signin
	// we use our own session system, not php sessions
	// you can call this function to reset the session credentials if necessary
	// eg if you get a security context change
	function sessionstart($nuserID) {
	
		// session times out after x seconds, eg 30 minutes = 1800 seconds
		global $global_sessionexpiry;
		// session can at most last x seconds, eg 1 week = 604800 seconds
		global $global_sessionmaxtime;
		
		// create 2 16 digit random tokens
		$sessiontoken1=makepassword(16);
		$sessiontoken2=makepassword(16);
		
		// get ip address and user agent
		$ipaddress=$_SERVER['REMOTE_ADDR'];
		$useragent=substr($_SERVER['HTTP_USER_AGENT'], 0, 64);
		
		// cookie 1 holds ipaddress, sessiontoken1 and userid
		$cookie1=$ipaddress."|||".$sessiontoken1."|||".$nuserID;
		
		// cookie 2 holds sessiontoken2 and useragent
		$cookie2=$sessiontoken2."&&&".$useragent;
		
		// encrypt the cookies
		$cookie1=aes_encrypt($cookie1);
		$cookie2=aes_encrypt($cookie2);
		
		// send 2 cookies
		setcookie("TOKEN1", $cookie1, time()+$global_sessionmaxtime, "/");
		setcookie("TOKEN2", $cookie2, time()+$global_sessionmaxtime, "/");
		
		// update COOKIE globals
		$_COOKIE['TOKEN1']=$cookie1;
		$_COOKIE['TOKEN2']=$cookie2;
		
		// save data to the database
		$result=doSQL("update users set sessiontoken1=?, sessiontoken2=?, sessionipaddress=?, sessionuseragent=?, sessionlastdateSQL=now() where userID=?;", $sessiontoken1, $sessiontoken2, $ipaddress, $useragent, $nuserID) or die("ERR");
			
		}
	
	// call on any page which needs to access session data
	// returns the $S session array, call with $S=sessionuse();
	// for demonstration, the $S array holds userID and email
	// you should add whatever session variables you need
	function sessionuse() {
	
		global $global_sessionexpiry;
		
		// check cookies exist and are not void
		if (!isset($_COOKIE['TOKEN1']))
			return;
		if (!isset($_COOKIE['TOKEN2']))
			return;
		if ($_COOKIE['TOKEN1']=="0")
			return;
		if ($_COOKIE['TOKEN2']=="0")
			return;
		
		// decrypt the cookies
		$cookie1=aes_decrypt($_COOKIE['TOKEN1']);
		$cookie2=aes_decrypt($_COOKIE['TOKEN2']);
		
		// break up the cookies
		$bits=explode("|||", $cookie1);
		$ipaddress=$bits[0];
		$sessiontoken1=$bits[1];
		$userID=$bits[2];
		$bits=explode("&&&", $cookie2);
		$sessiontoken2=$bits[0];
		$useragent=$bits[1];
		
		// check cookie values match current http values
		if (!($ipaddress==$_SERVER['REMOTE_ADDR'])) {
			header("Location: /public/expired.php");
			return;
			}
		if (!($useragent=substr($_SERVER['HTTP_USER_AGENT'], 0, 64))) {
			header("Location: /public/expired.php");
			return;
			}
		
		// get database values and check they match
		$result=doSQL("select userID, email, sessiontoken1, sessiontoken2, sessionipaddress, sessionuseragent, timestampdiff(second, sessionlastdateSQL, now()) as inactivetime from users where userID=?;", $userID) or die("ERR");
		
		// userID found?
		if (!is_array($result)) {
			header("Location: /public/expired.php");
			return;
			}
		
		// check fields are populated
		if (($result[0]['sessionipaddress']=='')||($result[0]['sessionuseragent']=='')||($result[0]['sessiontoken1']=='')||($result[0]['sessiontoken2']=='')) {
			header("Location: /public/expired.php");
			return;
			}
		
		
		// has session expired?
		if ($result[0]['inactivetime']>$global_sessionexpiry) {
			header("Location: /public/expired.php");
			return;
			}

		// values match?
		if (!($ipaddress==$result[0]['sessionipaddress'])) {
			header("Location: /public/expired.php");
			return;
			}
		if (!($useragent==$result[0]['sessionuseragent'])) {
			header("Location: /public/expired.php");
			return;
			}
		if (!($sessiontoken1==$result[0]['sessiontoken1'])) {
			header("Location: /public/expired.php");
			return;
			}
		if (!($sessiontoken2==$result[0]['sessiontoken2'])) {
			header("Location: /public/expired.php");
			return;
			}
		
		// all ok, set '$S' session array
		$S=array();
		$S['userID']=$result[0]['userID'];
		$S['email']=$result[0]['email'];
		// to add more session variables:
		//  add a column to the users table
		//  select that column in the query above
		//  add it to the $S array
		//  also update the sessionsave() and sessionend() functions

		return $S;

		}

	// if session values change, call this to save the data to the database
	// update the $S variable and pass it to this function
	// we assume the index field (userID) does not change
	function sessionsave($S) {
	
		// save data to the database
		// if you add new fields, update this query
		$result=doSQL("update users set email=? where userID=?;", $S['email'], $S['userID']) or die("ERR");
			
		}

	// call to end a session
	// sends dud cookies to the client
	// and wipes the database
	function sessionend($nuserID) {

		// session can at most last x seconds, eg 1 week = 604800 seconds
		global $global_sessionmaxtime;

		// send 2 dud cookies
		setcookie("TOKEN1", "0", time()+$global_sessionmaxtime, "/");
		setcookie("TOKEN2", "0", time()+$global_sessionmaxtime, "/");

		// wipe data in the database
		$result=doSQL("update users set sessiontoken1='', sessiontoken2='', sessionipaddress='', sessionuseragent='', sessionlastdateSQL=now() where userID=?;", $nuserID) or die("ERR");
		
		return array();
		}
	
?>