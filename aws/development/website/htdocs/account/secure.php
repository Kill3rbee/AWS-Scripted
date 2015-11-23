<?php
	if (!isset($S['userID'])) {
		header('Location: ../public/signin.php');
		exit;
		}
	if ($S['userID']==0) {
		header('Location: ../public/signin.php');
		exit;
		}
?>
