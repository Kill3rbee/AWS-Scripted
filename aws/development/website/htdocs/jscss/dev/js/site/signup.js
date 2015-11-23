function do_check_signup(is_submit) {
	$('#msg').html('Working...');
	$.ajax({
		type: 'POST',
		url: 'checkusername.php',
		data: { s: is_submit, u: $('#usernamesu').val() },
		success: function(ndata) {
			data=ndata.trim();
			if (data=='AVAIL') {
				if (is_submit==0)
					$('#msg').html('This username is available');
				else
					$('#msg').html('');
				}
			else if (data=='TAKEN')
				$('#msg').html('This username is not available');
			else if (data=='EMPTY')
				$('#msg').html('Username is empty');
			else if (data=='LONG')
				$('#msg').html('Username is too long (max 16 chars)');
			else if (data=='ILL')
				$('#msg').html('Illegal characters');
			else if (data=='SUB') {
				$('#msg').html('This username is available');
				do_check_rc();
				}
			else
				$('#msg').html('Sorry, please try again');
			},
		error: function(ndata) {
			$('#msg').html('Sorry, please try again');
			}
		});
	}

function do_check_rc() {
	$('#msgrc').html('Working...');
	var rcc=$.base64.encode(Recaptcha.get_challenge());
	var rcr=$.base64.encode(Recaptcha.get_response());
	$.ajax({
		type: 'POST',
		url: 'checkrecaptcha.php',
		data: { recaptcha_challenge_field: rcc, recaptcha_response_field: rcr },
		success: function(ndata) {
			data=ndata.trim();
			if (data=='ERR')
				$('#msgrc').html('The reCAPTCHA was wrong');
			else {
				$('#msgrc').html('reCAPTCHA confirmed');
				$('#rcc').val(rcc);
				$('#rcr').val(rcr);
				$('#rch').val(data);
				$('#signupform').submit();
				}
			},
		error: function(ndata) {
			$('#msgrc').html('The reCAPTCHA was wrong');
			}
		});
	}

function check_submit() {
	$('#msg1').html('');
	$('#msg2').html('');
	$('#msg3').html('');
	$('#msg4').html('');
	$('#msgrc').html('');
	p=$('#passwordsu').val();
	c=$('#passwordsu2').val();
	e=$('#emailsu').val();
	c2=$('#emailsu2').val();
	t=($('#terms').is(":checked"))?1:0;
	if (e=='')
		$('#msg3').html('Email cannot be blank');
	else if (!(e==c2)) {
		$('#msg3').html('Emails do not match');
		}
	else if (p=='')
		$('#msg2').html('Password cannot be blank');
	else if (p.length<6)
		$('#msg2').html('Password must be at least 6 characters');
	else if (!(p==c))
		$('#msg2').html('Passwords do not match');
	else if (!(t==1))
		$('#msg4').html('You must accept our Terms and Conditions');
	else
		do_check_signup(1);
	}
