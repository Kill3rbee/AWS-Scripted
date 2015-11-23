// extract from aws/development/website/htdocs/public/signin2.php

// check hash
$passwordok=0;
if (crypt($password, $row['password']) === $row['password'])
	$passwordok=1;
if ($passwordok==0) {
	// error, password wrong
	header("Location: /public/signin.php?err=1"); 
	exit;
	}
