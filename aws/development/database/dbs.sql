DROP DATABASE IF EXISTS `SEDdbnameSED`;
CREATE DATABASE `SEDdbnameSED`;

DROP TABLE IF EXISTS `SEDdbnameSED`.`users`;
CREATE TABLE  `SEDdbnameSED`.`users` (
  `userID` int(11) unsigned NOT NULL auto_increment,
  `dateSQL` timestamp(3) NOT NULL default CURRENT_TIMESTAMP(3),
  `username` varchar(16) NOT NULL UNIQUE,
  `password` varchar(128) NOT NULL,
  `email` varchar(255) default NULL UNIQUE,
  `emailbounce` int(11) unsigned NOT NULL default 0 comment '0=ok >0=bounced holds snsnotifiationID',
  `emailcomplaint` int(11) unsigned NOT NULL default 0 comment '0=ok >0=complained holds snsnotifiationID',
  `sessiontoken1` varchar(16) default NULL,
  `sessiontoken2` varchar(16) default NULL,
  `sessionipaddress` varchar(64) default NULL,
  `sessionuseragent` varchar(64) default NULL,
  `sessionlastdateSQL` datetime,
  PRIMARY KEY (`userID`)
) ENGINE=InnoDB AUTO_INCREMENT=12973 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `SEDdbnameSED`.`sendemails`;
CREATE TABLE  `SEDdbnameSED`.`sendemails` (
  `sendemailID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `dateSQL` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `userID` int(11) unsigned NOT NULL,
  `sendto` varchar(255) NOT NULL DEFAULT '',
  `sendfrom` varchar(255) NOT NULL DEFAULT '',
  `sendsubject` varchar(255) NOT NULL DEFAULT '',
  `sendmessage` varchar(8192) NOT NULL DEFAULT '',
  `sendfailures` tinyint unsigned NOT NULL DEFAULT '0',
  `sent` tinyint unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`sendemailID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `SEDdbnameSED`.`snsnotifications`;
CREATE TABLE `SEDdbnameSED`.`snsnotifications` (
  `snsnotificationID` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `dateSQL` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `messageid` varchar(255) DEFAULT '',
  `subject` varchar(255) DEFAULT '',
  `message` varchar(2048) DEFAULT '',
  `email` varchar(255) DEFAULT '',
  PRIMARY KEY (`snsnotificationID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
