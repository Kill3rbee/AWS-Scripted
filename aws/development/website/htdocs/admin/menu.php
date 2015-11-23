<?php require "init.php";?>

<html>
<head>
	<link href="admstyle.css" type="text/css" rel="stylesheet">
</head>
<body bgcolor="#EBEDFF" style="padding:5px 5px 5px 5px;">

<h1>ADMIN</h1>

<br><a href="ataglance.php" target="page">At A Glance</a><br>

<br><a href="alllogs.php" target="page">All Logs</a><br>

<br><a href="email.php" target="page">Test Email</a><br>

<br><a href="slowqueries.php" target="page">Slow Queries</a><br>

<br><a href="phpinfo.php" target="page">PHP Info</a><br>

<br><a href="https://<?php echo $_SERVER['SERVER_NAME'];?>:8443/" target="page">M/Monit</a>
<br><a href="/loganalyzer/" target="page">LogAnalyzer</a>
<br><a href="/phpmyadmin/" target="page">PHPMyAdmin</a>

</body>
</html>
