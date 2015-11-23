<?php include '../../phpinclude/init.php';?>
<?php include '../../phpinclude/begin.php';?>

<?php
	if (!isset($S)) { ?>

	<form id="signinform" action="signin2.php" method="post" enctype="application/x-www-form-urlencoded">
		<div class="titletext">Sign In to your account</div>
		<table cellpadding="5">
			<?php if (isset($_GET['err'])) { ?>
				<tr><td colspan="2" align="center"><div class="errmessage">Email/Password not recognised</div></td></tr>
			<?php } ?>
			<tr>
				<td><b>Email:</b></td>
				<td><input value="" type="text" name="email"></td>
			</tr>
			<tr>
				<td><b>Password:</b></td>
				<td><input value="" type="password" name="password" onkeydown="if (event.keyCode == 13) submit();"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td><br><input value="SIGN IN" type="submit"></td>
			</tr>
		</table>

	</form>

<?php } else { ?>

	<div class="titletext">Signed In as <?php echo $S['email'];?></div>
	<input value="SIGN OUT" type="button" onclick="location.href='/public/signout.php';">

<?php } ?>

<br><br>

<?php include '../../phpinclude/end.php';?>
