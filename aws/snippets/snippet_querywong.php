// simple wrong way to do a query
dbconnect(0);
$somevar="data from a GET or POST variable - potential sql injection";
$query="select * from users where email='".$somevar."';";
$result=$db->query($query);

// what if $somevar="' or '1'='1"?
// then your query becomes:
// select * from users where email='' or '1'='1';
// and all records will be returned
