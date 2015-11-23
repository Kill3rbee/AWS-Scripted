<?php include '../../phpinclude/init.php';?>
<?php include 'secure.php';?>
<?php include '../../phpinclude/begin.php';?>

<?php
	if (isset($_GET['signup']))
		echo "<h2>Thankyou You Signed Up Successfully</h2>";
	else if (isset($_GET['signin']))
		echo "<h2>Signed In Successfully</h2>";
	else
		echo "<h2>Your Account</h2>";
?>

This page is secure and only accessible if Signed In.

<br><br><br><br><br><br><br><br>

<?php include '../../phpinclude/end.php';?>
