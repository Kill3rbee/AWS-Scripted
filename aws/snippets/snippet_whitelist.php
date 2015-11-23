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
