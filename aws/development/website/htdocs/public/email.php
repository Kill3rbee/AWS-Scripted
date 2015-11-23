<?php include '../../phpinclude/init.php';?>
<?php include '../../phpinclude/begin.php';?>

<div class="titletext">Test Email</div>

<?php if (!isset($S['userID'])) { ?>
	You must be Signed In to Test Email<br><br>
<?php } ?>

<form action="email2.php" method="get">

	Sending from <?php echo $global_sendemailfrom;?>

	<br><br>

	To:
	<select name="predef">
		<option value="success@simulator.amazonses.com">success@simulator.amazonses.com
		<option value="bounce@simulator.amazonses.com">bounce@simulator.amazonses.com
		<option value="complaint@simulator.amazonses.com">complaint@simulator.amazonses.com
		<option value="suppressionlist@simulator.amazonses.com">suppressionlist@simulator.amazonses.com
	</select>
	
	<br><br>
	
	or: <input type="text" name="dyn" size="50"><br>
	[must be verified in SES if SES Production Access is not enabled]

	<br><br>
	
	<input type="Submit" value="Send">
	
</form>

<br><br>

<?php include '../../phpinclude/end.php';?>