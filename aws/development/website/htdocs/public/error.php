<?php include '../../phpinclude/init.php';?>
<?php include '../../phpinclude/begin.php';?>

<?php
	$message="unspecified";
	if (isset($_GET['err']))
		$message=check_legal_chars(urldecode($_GET['err']));
?>

<div class="titletext">An error occurred: <?php echo $message;?></div>

<br><br><br><br><br><br><br><br><br><br><br><br>

<?php include '../../phpinclude/end.php';?>
