<?php include '../../phpinclude/init.php'; ?>

<?php
	if (isset($S)) {
		echo "<script>location.href='/account/profile.php?signin=1';</script>";
		exit;
		}
?>

<?php
	// called for new sign in

	$erraddr1='signup.php?msg1';
	$erraddr2='signup.php?msg2';
	$erraddr3='signup.php?msg3';
	$erraddrrc='signup.php?msgrc';
		
	// check and clean inputs
	$username=check_text_input($_POST['usernamesu'], 1, 16, 'Username', $erraddr1);
	$password=check_text_input($_POST['passwordsu'], 6, 32, 'First Password', $erraddr2);
	$password2=check_text_input($_POST['passwordsu2'], 6, 32, 'Confirm Password', $erraddr2);
	$email=check_text_input($_POST['emailsu'], 1, 255, 'First Email', $erraddr3);
	$email2=check_text_input($_POST['emailsu2'], 1, 255, 'Confirm Email', $erraddr3);
	
	if (!(check_legal_chars($username)==$username))
		do_err($erraddr1, 'Illegal characters in Username');
	if (!($password==$password2))
		do_err($erraddr2, 'Passwords do not match');
	if (!($email==$email2))
		do_err($erraddr3, 'Emails do not match');

	dbconnect(0);

	// check email still available
	$result=doSQL("select * from users where email=?;", $email) or do_err($erraddr3, "Database Error");
	if (is_array($result))
		// no, exists, quit
		do_err($erraddr3, "Email in use");
	
	// check username still available
	$result=doSQL("select * from users where username=?;", $username) or do_err($erraddr1, "Database Error");
	if (is_array($result))
		// no, exists, quit
		do_err($erraddr1, "Username in use");
	
	// check recaptcha
	$rcc=$_POST["rcc"];
	$rcr=$_POST["rcr"];
	$rch=base64_decode($_POST["rch"]);
	$rcstr=$_SERVER["REMOTE_ADDR"]."836429".$rcc."7364528".$rcr;
	if (!(crypt($rcstr, $rch) === $rch))
		do_err($erraddrrc, "The reCAPTCHA was wrong ".$rcerr);
	
	// hash password
	// create a random salt
	$salt = "$2y$10$".bin2hex(openssl_random_pseudo_bytes(22));

	// Hash the password with the salt
	$hash = crypt($password, $salt);

	// insert user
	$result=doSQL("insert into users (username, password, email) values (?, ?, ?);", $username, $hash, $email) or do_err($erraddr3, "Database Error");
	$nid=$db->insert_id;
	
	// signin
	sessionstart($nid);
	
	// jump
	header('Location: ../account/index.php?signup=1');

?>

