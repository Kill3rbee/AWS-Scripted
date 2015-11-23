// extract from aws/development/website/htdocs/public/signup2.php

// hash password
// create a random salt
$salt = "$2y$10$".bin2hex(openssl_random_pseudo_bytes(22));
// Hash the password with the salt
$hash = crypt($password, $salt);
// now insert $hash in the database, not $password
