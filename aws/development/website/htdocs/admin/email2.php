<?php require "init.php";?>

<html>
<head>
	<link href="admstyle.css" type="text/css" rel="stylesheet">
</head>
<body>

<center>

<br><h2>Sending Email...</h2>

<?php

	// send test email
	$to=$_GET['predef'];
	if (isset($_GET['dyn'])) {
		if (!($_GET['dyn']==""))
			$to=$_GET['dyn'];
		}
	$result=doSQL("insert into sendemails (userID, sendto, sendfrom, sendsubject, sendmessage) values (?, ?, ?, ?, ?)", 1, $to, $global_sendemailfrom, "Admin Email Test", "Testing 123...") or die("Error");
?>

Sent to <?php echo $to;?>

<br><br>

Check the sendemails database table.

<br><br>

</center>


</body>
</html>
