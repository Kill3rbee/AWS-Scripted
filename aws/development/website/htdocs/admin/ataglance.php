<?php require "init.php";?>

<html>
<head>
	<link href="admstyle.css" type="text/css" rel="stylesheet">
</head>
<body>

<center>

<br><h2>At A Glance</h2>

<table border=1 cellspacing=0 cellpadding=5>
<?php
	
	$logdir="/var/log/";
	$logs=array("messages", "maillog", "adminhttpderr.log", "webhttpderr.log", "javamail.log", "adminhttpd.log", "webhttpd.log", "ataglance.log");

	$oscil=0;
	// show details about each log file
	foreach ($logs as $log) {
		$output = shell_exec('ls -lart '.$logdir.$log.' 2>&1');
		echo "<tr bgcolor='#".(($oscil==0)?'ffffff':'eeeeee')."'>";
		echo "<td><pre>".$output."</pre></td>";
		echo "</tr>";
		$oscil=($oscil==0)?1:0;
		$output = shell_exec('tail -n 5 '.$logdir.$log.' 2>&1');
		echo "<tr bgcolor='#".(($oscil==0)?'ffffff':'eeeeee')."'>";
		echo "<td><pre>".$output."</pre></td>";
		echo "</tr>";
		$oscil=($oscil==0)?1:0;
		}
?>
</table>

<br><br>

</center>

</body>
</html>
