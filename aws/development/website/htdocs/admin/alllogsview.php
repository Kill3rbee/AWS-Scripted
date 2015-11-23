<?php require "init.php";?>

<html>
<head>
	<link href="admstyle.css" type="text/css" rel="stylesheet">
</head>
<body>

<center>

<?php
	$logdir="/var/log/";
	$log=$_GET['log'];
	$type=$_GET['t'];
?>

<br><h2>All Logs View</h2>
<table border=1 cellspacing=0 cellpadding=5>
	<tr bgcolor='cccccc'><td>log: <?php echo $logdir.$log;?> <a href="alllogs.php">Back</a></td></tr>

<?php
	// print the log file as requested
	if ($type=="all")
		$output = shell_exec('cat '.$logdir.$log.' 2>&1');
	else if ($type=="100")
		$output = shell_exec('tail -n 100 '.$logdir.$log.' 2>&1');
	else if ($type=="500")
		$output = shell_exec('tail -n 500 '.$logdir.$log.' 2>&1');
	echo "<tr><td><pre>".$output."</pre></td></tr>";
?>
</table>

<br><br>

</center>

</body>
</html>
