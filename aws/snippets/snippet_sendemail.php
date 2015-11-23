function sendemail($nuserID, $nto, $nsubject, $nmessage) {
	// check verified and not bouncer or complainer
	$result=doSQL("select emailbounce, emailcomplaint from users where userID=?;", $nuserID) or do_std_err("Error getting mail details");
	if (!is_array($result))
		do_std_err("Error getting mail details");
	if ($result[0]['emailbounce']>0)
		do_std_err("Email has Bounced previous emails");
	if ($result[0]['emailcomplaint']>0)
		do_std_err("Email has Complained about previous emails");
	// send
	$emsg=$nmessage."\n\nThanks\n";
	$result=doSQL("insert into sendemails (userID, sendto, sendfrom, sendsubject, sendmessage) values (?, ?, ?, ?, ?)", $nuserID, $nto, "donotreply@yourdomain.com", $nsubject, $emsg) or do_std_err("Error sending mail");
	}

// example call
sendemail(1, "recipient@somedomain.com", "this is the subject", "this is the message");
