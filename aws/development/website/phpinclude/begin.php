<!DOCTYPE HTML>

<html>
<head>
	<meta charset="utf-8">	<title>Secure PHP Site Demo</title>	<meta name="description" content="Secure PHP Site Demo" />	<meta name="keywords" content="Secure PHP Site Demo" />
	<meta name="viewport" content="width=device-height" />
	<link rel="shortcut icon" href="/favicon.ico">
	
	<?php if ($global_minifyjscss==0) { ?>

		<link rel="stylesheet" type="text/css" href="/jscss/dev/css/style.css" />

		<script type="text/javascript" src="/jscss/dev/js/jq/jquery.js"></script>
		<script type="text/javascript" src="/jscss/dev/js/jq/jquery.base64.min.js"></script>
		<script type="text/javascript" src="/jscss/dev/js/site/signup.js"></script>
	
	<?php } else { ?>

		<link rel="stylesheet" type="text/css" href="/jscss/prod/style.css" />

		<script type="text/javascript" src="/jscss/prod/jquery.min.js"></script>
		<script type="text/javascript" src="/jscss/prod/general.min.js"></script>

	<?php } ?>

</head>
<body>

<!--- If using Google Analytics, paste code here --->

<div align="center"><br>

<?php if (!isset($S['email'])) { ?>

	<map name="navbar">
		<area shape="rect" coords="140,0,250,40" href="/public/" alt="Home">
		<area shape="rect" coords="251,0,380,40" href="/public/signin.php" alt="Sign In">
		<area shape="rect" coords="381,0,500,40" href="/public/signup.php" alt="Sign Up">
	</map>
	<img src="/img/navbar.png" height="40" width="640" border="0" usemap="#navbar"/>

<?php } else { ?>

	<map name="navbar2">
		<area shape="rect" coords="140,0,250,40" href="/public/" alt="Home">
		<area shape="rect" coords="251,0,380,40" href="/account/" alt="Account">
		<area shape="rect" coords="381,0,500,40" href="/public/signout.php" alt="Sign Out">
	</map>
	<img src="/img/navbar2.png" height="40" width="640" border="0" usemap="#navbar2"/>

<?php } ?>

<br><br>
