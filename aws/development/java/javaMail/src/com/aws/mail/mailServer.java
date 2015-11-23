package com.aws.mail;

public class mailServer {

		// no args
		public static void main(String[] args) {

			System.out.println("Started");

			config c=new config();
			c.getconfig();
		
			dbManager dbm=new dbManager(c.prop.getProperty("dbhost"), c.prop.getProperty("dbport"), c.prop.getProperty("dbname"), c.prop.getProperty("dbuser"), c.prop.getProperty("dbpassword"));

			pollMail pm=new pollMail(dbm, c.prop.getProperty("smtphost"), c.prop.getProperty("smtpport"), c.prop.getProperty("smtpuser"), c.prop.getProperty("smtppass"));
			pm.start();
	
			}

		}
