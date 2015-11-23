<?php require "init.php";?>

<html>
<head>
	<link href="admstyle.css" type="text/css" rel="stylesheet">
</head>
<body>

<center>

<br><h2>All Logs</h2>
<table border=1 cellspacing=0 cellpadding=5>
	<tr bgcolor='cccccc'><td>log</td><td colspan="5">Action</td></tr>
<?php

	$logdir="/var/log/";
	$logs=array("messages", "maillog", "adminhttpderr.log", "webhttpderr.log", "javamail.log", "adminhttpd.log", "webhttpd.log", "ataglance.log");

	$oscil=0;
	// show a listing of the logs
	foreach ($logs as $log) {
		$output = shell_exec('ls -lart '.$logdir.$log.' 2>&1');
		echo "<tr bgcolor='#".(($oscil==0)?'ffffff':'eeeeee')."'>";
		echo "<td><pre>".$output."</pre></td>";
		echo "<td><a href='alllogsview.php?t=all&log=".$log."'>View All</a></td>";
		echo "<td><a href='alllogsview.php?t=100&log=".$log."'>Tail 100</a></td>";
		echo "<td><a href='alllogsview.php?t=500&log=".$log."'>Tail 500</a></td>";
		echo "</tr>";
		$oscil=($oscil==0)?1:0;
		}
?>
</table>

<br><br>

</center>

</body>
</html>
