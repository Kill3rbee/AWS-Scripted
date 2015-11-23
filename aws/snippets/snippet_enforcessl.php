if ($_SERVER['HTTP_X_FORWARDED_PROTO']!="https") {
	$redirect= "https://".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];
	header("Location:$redirect");
	exit;
	}
