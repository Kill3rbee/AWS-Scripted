<?php include '../../phpinclude/init.php'; ?>

<?php

	// called via AJAX when checking new username available on web

	$submit=0;
	if (isset($_POST['s'])) {
		if ($_POST['s']=="1")
			$submit=1;
		}

	if (!isset($_POST['u'])) {
		echo "ERR";
		exit;
		}
	
	$username=$_POST['u'];
	if (strlen($username)==0) {
		echo "EMPTY";
		exit;
		}

	if (strlen($username)>16) {
		echo "LONG";
		exit;
		}

	$illegal=check_legal_chars($username);
	if ($illegal=="Illegal Input") {
		echo ("ILL");
		exit;
		}
	
	// check any reserved words
	if (in_array(strtolower($username), $global_reserved_usernames)) {
		echo "TAKEN";
		exit;
		}

	// username exists?
	dbconnect(0);
	$result=doSQL("select * from users where username=?;", $username) or die("ERR");
	if (is_array($result))
		// exists
		echo "TAKEN";
	else {
		// available
		if ($submit==1)
			echo "SUB";
		else
			echo "AVAIL";
		}
?>
