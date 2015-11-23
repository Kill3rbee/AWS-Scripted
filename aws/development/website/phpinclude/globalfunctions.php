<?php

	// an error occurred
	function do_err($naddr, $nmsg) {
		if ($naddr=="")
			exit();
		header('Location: '.$naddr.'='.$nmsg);
		exit();
		}

	// a standard error occurred
	function do_std_err($nmsg) {
		header('Location: /public/error.php?err='.$nmsg);
		exit();
		}

	// check a text input is the correct length
	// min, max -1 to ignore
	function check_text_input($var, $min, $max, $errname, $erraddr) {
		$ret=$var;
		if ( (!($min==-1)) && (strlen($ret)<$min) )
			do_err($erraddr, $errname." too short");
		if ( (!($max==-1)) && (strlen($ret)>$max) )
			do_err($erraddr, $errname." too long");
		return $ret;
		}

	// check a numeric value lies within a range
	// min, max -1 to ignore
	function check_num_input($var, $min, $max, $errname, $erraddr) {
		$ret=$var;
		if (!is_numeric($ret))
			do_err($erraddr, $errname." not a number");
		if ( (!($min==-1)) && ($ret<$min) )
			do_err($erraddr, $errname." min is ".$min);
		if ( (!($max==-1)) && ($ret>$max) )
			do_err($erraddr, $errname." max is ".$max);
		return $ret;
		}

	// ajax version of text size checker
	// min, max -1 to ignore
	function check_text_input_ajax($var, $min, $max, $errname, $erraddr) {
		$ret=$var;
		if ( (!($min==-1)) && (strlen($ret)<$min) )
			return false;
		if ( (!($max==-1)) && (strlen($ret)>$max) )
			return false;
		return $ret;
		}
	
	// ajax version of numeric range checker
	// min, max -1 to ignore
	function check_num_input_ajax($var, $min, $max) {
		$ret=$var;
		if (!is_numeric($ret))
			return false;
		if ( (!($min==-1)) && ($ret<$min) )
			return false;
		if ( (!($max==-1)) && ($ret>$max) )
			return false;
		return $ret;
		}
	
	// check a string exists in a string array
	function check_text_input_in_array($var, $arr, $errname, $erraddr) {
		$ret=$var;
		if (!(in_array($ret, $arr)))
			do_err($erraddr, $errname." not found");
		return $ret;
		}

	// checks a string only contains chars from the array within
	// returns original string if legal, or "Illegal Input" if not
	function check_legal_chars($ns) {
		$legal=array("q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m",
					 "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M",
					 " ", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0",
					 "!", "@", "$", "*", "(", ")", ":", ";", "+", "-", "?" );
		$s=$ns;
		for ($i=0; $i<count($legal); $i++)
			$s=str_replace($legal[$i], "", $s);
		if ($s=="")
			return $ns;
		return "Illegal Input";
		}

	// seed the generator
	function makerandseed() {
		list($usec, $sec) = explode(' ', microtime());
  		return (float) $sec + ((float) $usec * 100000);
		}

	// return a password of length $nlength from the $legal array
	function makepassword($nlength) {
		$legal=array("q", "w", "e", "r", "t", "y", "u", "i", "o", "p", "a", "s", "d", "f", "g", "h", "j", "k", "l", "z", "x", "c", "v", "b", "n", "m",
					 "Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "Z", "X", "C", "V", "B", "N", "M",
					 "1", "2", "3", "4", "5", "6", "7", "8", "9", "0");
		$ret="";
		srand(makerandseed());
		for ($i=0; $i<$nlength; $i++) {
			$rnd=rand(0, 61);
			$ret.=$legal[$rnd];
			}
		return $ret;
		}

	// encrypt a string with aes	
	function aes_encrypt($ntext) {
		global $global_aeskey;
		$key = pack('H*', $global_aeskey);
		$iv_size = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_128, MCRYPT_MODE_CBC);
		$iv = mcrypt_create_iv($iv_size, MCRYPT_RAND);
		$ciphertext = mcrypt_encrypt(MCRYPT_RIJNDAEL_128, $key, $ntext, MCRYPT_MODE_CBC, $iv);
		$ciphertext = $iv . $ciphertext;
		$ciphertext_base64 = base64_encode($ciphertext);
		return $ciphertext_base64;
		}

	// decrypt an aes encrypted string	    
	function aes_decrypt($ntext) {
		global $global_aeskey;
		$key = pack('H*', $global_aeskey);
		$iv_size = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_128, MCRYPT_MODE_CBC);
		$ciphertext_dec = base64_decode($ntext);
		$iv_dec = substr($ciphertext_dec, 0, $iv_size);
		$ciphertext_dec = substr($ciphertext_dec, $iv_size);
		$plaintext = mcrypt_decrypt(MCRYPT_RIJNDAEL_128, $key, $ciphertext_dec, MCRYPT_MODE_CBC, $iv_dec);
		return $plaintext;
		}

	// example function to send mail
	// by inserting into the sendemails table	
	function sendemail($nuserID, $nto, $nsubject, $nmessage) {
		global $global_sendemailfrom;
		// check not bouncer or complainer
		$result=doSQL("select emailbounce, emailcomplaint from users where userID=?;", $nuserID) or do_std_err("Error getting mail details");
		if (!is_array($result))
			do_std_err("Error getting mail details");
		if ($result[0]['emailbounce']>0)
			do_std_err("Email has Bounced previous emails");
		if ($result[0]['emailcomplaint']>0)
			do_std_err("Email has Complained about previous emails");
		// send
		$emsg=$nmessage."\n\nThanks\n";
		$result=doSQL("insert into sendemails (userID, sendto, sendfrom, sendsubject, sendmessage) values (?, ?, ?, ?, ?)", $nuserID, $nto, $global_sendemailfrom, $nsubject, $emsg) or do_std_err("Error sending mail");
		}

	// use the Google lib to check a recaptcha	
	function checkrecaptcha($naddr, $nchallenge, $nresponse) {
		global $global_recaptcha_privatekey;
		require_once('recaptchalib.php');
		$privatekey = $global_recaptcha_privatekey;
		$resp = recaptcha_check_answer ($privatekey, $naddr, $nchallenge, $nresponse);
		if (!$resp->is_valid)
			// What happens when the CAPTCHA was entered incorrectly
   			return $resp->error;
		return "";
		}
		
?>