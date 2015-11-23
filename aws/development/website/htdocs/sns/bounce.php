<?php

	// called by aws sns with json payload for subscribe sns or bounced email
	// can't be called on the dev environment

	if($_SERVER['REQUEST_METHOD'] != 'POST')
		exit;

	$post = file_get_contents('php://input');

	require_once('../../phpinclude/snsverify.php');
	if(!verify_sns($post, $_SERVER['AWS_DEPLOYREGION'], $_SERVER['AWS_ACCOUNT'], array('EmailBounce')))
		exit;

	$msg = json_decode($post, true);

	if ($msg['Type'] == 'SubscriptionConfirmation') {
		// need to visit SubscribeURL
		$surl=$msg['SubscribeURL'];
		$curlOptions = array (
			CURLOPT_URL => $surl,
			CURLOPT_VERBOSE => 1,
			CURLOPT_RETURNTRANSFER => 1,
			CURLOPT_SSL_VERIFYPEER => TRUE,
			CURLOPT_SSL_VERIFYHOST => 2
	  		);
		$ch = curl_init();
		curl_setopt_array($ch, $curlOptions);
		$response = curl_exec($ch);
		if (curl_errno($ch)) {
			$errors = curl_error($ch);
			curl_close($ch);
			echo $errors;
			}
		else  {
			curl_close($ch);
			echo $response;
	  		}
		exit;
		}

	elseif ($msg['Type'] == 'Notification') {
		// init db
		$global_is_dev="0";
		include '../../phpinclude/db.php';
		// check if resend and data already stored
		dbconnect(0);
		$messageid=$msg['MessageId'];
		$sql=doSQL("select count(*) as tot from snsnotifications where messageid=?", $messageid) or die ("error1");
		$tot=0;
		if (!is_array($sql))
			$tot=0;
		else {
			$tot=$sql[0]['tot'];
			$tot=($tot=="")?0:$tot;
			}
		if ($tot>0)
			exit;
		// new message
		$subject="";
		if (isset($msg['Subject']))
			$subject=$msg['Subject'];
		$message="";
		if (isset($msg['Message']))
			$message=$msg['Message'];
	
		$result = json_decode($message, true);
		if ($result['notificationType']=="Bounce") {
			if ($result['bounce']['bounceType']=="Permanent") {
				$emailaddr=$result['bounce']['bouncedRecipients'][0]['emailAddress'];
				doSQL("insert into snsnotifications (messageid, subject, message, email) values (?, ?, ?, ?);", $messageid, $subject, $message, $emailaddr) or die ("error2");
				$nid=$db->insert_id;
				doSQL("update users set emailbounce=? where email=?;", $nid, $emailaddr) or die ("error3");
				exit;
				}
			}
			
		// if we get here nothing has been inserted to snsnotifications, insert for posterity
		doSQL("insert into snsnotifications (messageid, subject, message, email) values (?, ?, ?, ?);", $messageid, $subject, $message, "") or die ("error4");

		}
?>