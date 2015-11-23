<?php
	require '../../phpinclude/init.php';

	// get, check and clean inputs
	$email=check_text_input($_POST['email'], 1, 255, "Email", "/public/signin.php?err");
	$password=check_text_input($_POST['password'], 1, 32, "Password", "/public/signin.php?err");
	
	dbconnect(0);
	
	// email exists?
	$result=doSQL("select userID, password from users where email=?;", $email) or die("ERR");
	if (!is_array($result)) {
		// error, email inexistent
		header("Location: /public/signin.php?err=1");
		exit;
		}
	// get password
	$row=$result[0];
	
	// check hash
	$passwordok=0;
	if (crypt($password, $row['password']) === $row['password'])
		$passwordok=1;

	if ($passwordok==0) {
		// error, password wrong
		header("Location: /public/signin.php?err=1");
		exit;
		}
	
	// sign in
	sessionstart($row['userID']);
	header("Location: /account/index.php?signin=1");

?>