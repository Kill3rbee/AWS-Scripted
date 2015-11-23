<?php include '../../phpinclude/init.php';?>

<?php
	// cancel session
	if (isset($S['userID']))
		$S=sessionend($S['userID']);
?>

<?php include '../../phpinclude/begin.php';?>

<div class="titletext">Signed Out</div>

<?php include '../../phpinclude/end.php';?>
