<?php include '../../phpinclude/init.php'; ?>

<?php
	// called when checking recaptcha for signin
	$res=checkrecaptcha($_SERVER["REMOTE_ADDR"], base64_decode($_POST["recaptcha_challenge_field"]), base64_decode($_POST["recaptcha_response_field"]));
	if ($res=="") {
		$salt = "$2y$10$".bin2hex(openssl_random_pseudo_bytes(22));
		$hash = crypt($_SERVER["REMOTE_ADDR"]."836429".$_POST["recaptcha_challenge_field"]."7364528".$_POST["recaptcha_response_field"], $salt);
		echo base64_encode($hash);
		exit;
		}
	echo "ERR";
?>
