<?php
	$signin=1;
	require "init.php";
	if ($_POST['password']=="admin") {
		// set cookie (expiry on close browser)
		setcookie("ADMIN", "ok");
		}
	else
		header("Location: signin.php");
?>
<!DOCTYPE HTML>
<html>
<head>
	<script>window.onload=function(){
		location.href='<?php echo $global_webprefix;?>';
		};
	</script>
</head>
</html>
