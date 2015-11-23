<?php include '../../phpinclude/init.php';?>
<?php include '../../phpinclude/begin.php';?>

<div class="titletext">Test Curl</div>

<br><br>

<?php

// do a curl GET operation
// don't do ssl verification
function docurlgetnv($nrequest) {
	echo "do curl GET NOVERIFY(".$nrequest.")<br>";
	$curlOptions = array (
		CURLOPT_URL => $nrequest,
		CURLOPT_VERBOSE => 1,
		CURLOPT_RETURNTRANSFER => 1,
		CURLOPT_SSL_VERIFYPEER => FALSE
	  	);
	$ch = curl_init();
	curl_setopt_array($ch, $curlOptions);
	$response = curl_exec($ch);
	$err=curl_errno($ch);
	if ($err) {
		$errors = curl_error($ch);
		curl_close($ch);
		echo "error ".$err."<br>";
		echo $errors."<br><br>";
		}
	else  {
		curl_close($ch);
		echo "success [ ".$response." ]<br><br>";
   		}
	}

// do a curl GET operation
// do ssl verification
function docurlgetv($nrequest) {
	echo "do curl GET VERIFY(".$nrequest.")<br>";
	$curlOptions = array (
		CURLOPT_URL => $nrequest,
		CURLOPT_VERBOSE => 1,
		CURLOPT_RETURNTRANSFER => 1,
		CURLOPT_SSL_VERIFYPEER => TRUE,
		CURLOPT_SSL_VERIFYHOST => 2
	  	);
	$ch = curl_init();
	curl_setopt_array($ch, $curlOptions);
	$response = curl_exec($ch);
	$err=curl_errno($ch);
	if ($err) {
		$errors = curl_error($ch);
		curl_close($ch);
		echo "error ".$err."<br>";
		echo $errors."<br><br>";
		}
	else  {
		curl_close($ch);
		echo "success [ ".$response." ]<br><br>";
   		}
	}

// test some addresses
// should return 302 Document has moved
// if you get the dreaded 77 error, something is wrong
docurlgetnv("http://www.google.com");
docurlgetnv("https://www.google.com");
docurlgetv("https://www.google.com");

?>

<?php include '../../phpinclude/end.php';?>
