/*
	this file creates the required database users for MYDB
	these are:
	
	adminrw
		full access with grant

	webphprw
		can read, update, insert required tables for website
	
	javamail
		can read, update required tables for sending mail
	

	useful SQL commands	
	GRANT ALL PRIVILEGES  ON MYDB.* TO 'adminrw'@'%' WITH GRANT OPTION;
	GRANT SELECT, INSERT ON MYDB.* TO 'someuser'@'somehost';
	GRANT SELECT (col1), INSERT (col1,col2) ON MYDB.mytable TO 'someuser'@'somehost';
	
*/

/* do admin first so that if there are any errors at least we can connect to admin server */
DROP PROCEDURE IF EXISTS SEDdbnameSED.drop_user_if_exists ;
DELIMITER $$
CREATE PROCEDURE SEDdbnameSED.drop_user_if_exists()
BEGIN
  DECLARE foo BIGINT DEFAULT 0 ;
  SELECT COUNT(*)
  INTO foo
    FROM mysql.user
      WHERE User = 'adminrw' and  Host = '%';
   IF foo > 0 THEN
         DROP USER 'adminrw'@'%' ;
  END IF;
END ;$$
DELIMITER ;
CALL SEDdbnameSED.drop_user_if_exists() ;
DROP PROCEDURE IF EXISTS SEDdbnameSED.drop_users_if_exists ;

CREATE USER 'adminrw'@'%' IDENTIFIED BY 'SEDDBPASS_adminrwSED';
GRANT ALL PRIVILEGES  ON SEDdbnameSED.* TO 'adminrw'@'%' WITH GRANT OPTION;
GRANT SELECT ON mysql.slow_log TO 'adminrw'@'%';


DROP PROCEDURE IF EXISTS SEDdbnameSED.drop_user_if_exists ;
DELIMITER $$
CREATE PROCEDURE SEDdbnameSED.drop_user_if_exists()
BEGIN
  DECLARE foo BIGINT DEFAULT 0 ;
  SELECT COUNT(*)
  INTO foo
    FROM mysql.user
      WHERE User = 'webphprw' and  Host = '%';
   IF foo > 0 THEN
         DROP USER 'webphprw'@'%' ;
  END IF;
END ;$$
DELIMITER ;
CALL SEDdbnameSED.drop_user_if_exists() ;
DROP PROCEDURE IF EXISTS SEDdbnameSED.drop_users_if_exists ;

CREATE USER 'webphprw'@'%' IDENTIFIED BY 'SEDDBPASS_webphprwSED';
GRANT SELECT, INSERT, UPDATE 		 ON SEDdbnameSED.users TO 'webphprw'@'%';
GRANT SELECT, INSERT			 		 ON SEDdbnameSED.sendemails TO 'webphprw'@'%';
GRANT SELECT, INSERT			 		 ON SEDdbnameSED.snsnotifications TO 'webphprw'@'%';


DROP PROCEDURE IF EXISTS SEDdbnameSED.drop_user_if_exists ;
DELIMITER $$
CREATE PROCEDURE SEDdbnameSED.drop_user_if_exists()
BEGIN
  DECLARE foo BIGINT DEFAULT 0 ;
  SELECT COUNT(*)
  INTO foo
    FROM mysql.user
      WHERE User = 'javamail' and  Host = '%';
   IF foo > 0 THEN
         DROP USER 'javamail'@'%' ;
  END IF;
END ;$$
DELIMITER ;
CALL SEDdbnameSED.drop_user_if_exists() ;
DROP PROCEDURE IF EXISTS SEDdbnameSED.drop_users_if_exists ;

CREATE USER 'javamail'@'%' IDENTIFIED BY 'SEDDBPASS_javamailSED';
GRANT SELECT,			UPDATE 		 ON SEDdbnameSED.sendemails TO 'javamail'@'%';
