<?php

	$db=null;
	
	// open a connection to the database
	// $npriv determines which mysql user to use
	function dbconnect($npriv) {
	
		global $global_is_dev, $db;
		
		$dbhost="";
		$dbname="";
		$dbuser="";
		$dbpass="";
		
		if (strlen($global_is_dev)>1) {
			// development
			$dbhost="127.0.0.1";
			$dbname="SEDdbnameSED";
			if ($npriv==0) {
				$dbuser="webphprw";
				$dbpass="SEDDBPASS_webphprwSED";
				}
			else if ($npriv==1) {
				$dbuser="a different user";
				$dbpass="a different password";
				}
			}
		else {
			// aws
			$dbhost=$_SERVER['DBHOST'];
			$dbname=$_SERVER['DBNAME'];
			if ($npriv==0) {
				$dbuser=$_SERVER['DBUSER_webphprw'];
				$dbpass=$_SERVER['DBPASS_webphprw'];
				}
			}
		$db = new mysqli($dbhost, $dbuser, $dbpass, $dbname);
		if (mysqli_connect_errno()) {
			trigger_error("Unable to connect to database.");
			exit;
			}
		$db->set_charset('UTF-8');
		}

	// runs a parametrised sql query
	// if query has no parameters:
	//  if query returns no data, return 1 (success) 0 (error)
	//  if query returns data, return data array (success) or 0 (error)
	// if query has parameters:
	//  if query returns no data, return 1 (success) 0 (error)
	//  if query returns data, return data array (success) or 0 (error)
	function doSQL($nquery) {
		global $db;
		$args = func_get_args();
		if (count($args) == 1) {
			$result = $db->query($nquery);
			if (is_bool($result)) {
				if ($result==1)
					return 1;
				return 0;
				}
			if ($result->num_rows) {
				$out = array();
				while (null != ($r = $result->fetch_array(MYSQLI_ASSOC)))
					$out [] = $r;
				return $out;
				}
			return 1;
			}
		else {
			if (!$stmt = $db->prepare($nquery))
				//trigger_error("Unable to prepare statement: {$nquery}, reason: " . $db->error . "");
				return 0;
			array_shift($args); //remove $nquery from args
			//the following three lines are the only way to copy an array values in PHP
			$a = array();
			foreach ($args as $k => &$v)
				$a[$k] = &$v;
			$types = str_repeat("s", count($args)); //all params are strings, works well on MySQL and SQLite
			array_unshift($a, $types);
			call_user_func_array(array($stmt, 'bind_param'), $a);
			$stmt->execute();
			//fetching all results in a 2D array
			$metadata = $stmt->result_metadata();
			$out = array();
			$fields = array();
			if (!$metadata)
				return 1;
			$length = 0;
			while (null != ($field = mysqli_fetch_field($metadata))) {
				$fields [] = &$out [$field->name];
				$length+=$field->length;
				}
			call_user_func_array(array($stmt, "bind_result"), $fields);
			$output = array();
			$count = 0;
			while ($stmt->fetch()) {
				foreach ($out as $k => $v)
					$output [$count] [$k] = $v;
				$count++;
				}
			$stmt->free_result();
			return ($count == 0) ? 1 : $output;
			}
		}
		
?>