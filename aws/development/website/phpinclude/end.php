<br><br>

<?php if (!isset($S['userID'])) { ?>
	Not signed in
	&nbsp;&nbsp;&nbsp;
	<a href="/public/signin.php">Sign In</a>
	&nbsp;&nbsp;&nbsp;
	<a href="/public/signup.php">Sign Up</a>
<?php } else { ?>
	Signed in as <?php echo $S['email'];?>&nbsp;&nbsp;&nbsp;<a href="/public/signout.php">Sign Out</a>
<?php } ?>

&nbsp;&nbsp;&nbsp;
&copy; 2014 C S Cerri
&nbsp;&nbsp;&nbsp;
<a href="/public/terms.php">Terms</a>
&nbsp;&nbsp;&nbsp;
Server: <?php echo $global_serverid;?>
&nbsp;&nbsp;&nbsp;
<?php echo date('D jS M Y H:i:s e');?>

</div>

</body>
</html>
