<?php require "init.php";?>

<html>
<head>
	<link href="admstyle.css" type="text/css" rel="stylesheet">
</head>
<body>

<center>

<br><h2>Slow Queries</h2>

<?php

	// generic function to print a table (very handy)
	function printtable($nresult, $ntablename) {
		if (is_array($nresult)) {
			echo "<table border=1 cellspacing=0 cellpadding=5>";
			$keys=array_keys($nresult[0]);
			echo "<tr bgcolor='cccccc'>";
			foreach ($keys as $key)
				echo "<td>".$key."</td>";
			echo "</tr>";
			foreach ($nresult as $row) {
				echo "<tr>";
				foreach ($row as $value)
					echo "<td>".$value."</td>";
				echo "</tr>";
				}
			echo "</table><br>";
			}
		else
			echo "<table border=1 cellspacing=0 cellpadding=5><tr bgcolor='cccccc'><td>{$ntablename} No Data</td></tr></table><br>";
		}
	
	// read the slow queries table
	$result=doSQL("select * from mysql.slow_log order by start_time asc;") or die("Query failed : " . mysql_error());
	printtable($result, "slow_log");
?>

</center>

</body>
</html>
