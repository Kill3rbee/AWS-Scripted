<?php include '../../phpinclude/init.php';?>
<?php include '../../phpinclude/begin.php';?>

<div class="titletext">Test Email</div>

<h2>Sending Email...</h2>

<?php

	// send test email
	$to=$_GET['predef'];
	if (isset($_GET['dyn'])) {
		if (!($_GET['dyn']==""))
			$to=$_GET['dyn'];
		}
	sendemail($S['userID'], $to, "Test Email", "Testing 123...");
?>

Sent to <?php echo $to;?>

<br><br>

Check the sendemails database table.

<br><br>

<?php include '../../phpinclude/end.php';?>