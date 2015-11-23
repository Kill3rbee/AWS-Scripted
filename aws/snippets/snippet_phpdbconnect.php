// excerpt from aws/development/website/phpinclude/db.sql

	$db=null;
	
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
