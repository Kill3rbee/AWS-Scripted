package com.aws.mail;

import java.sql.Connection;
import java.sql.DriverManager;

public class dbManager {

	private Connection c;
	
	public dbManager(String nipaddress, String nport, String ndb, String nuser, String npassword) {
		try {
			Class.forName("com.mysql.jdbc.Driver");
			String url ="jdbc:mysql://"+nipaddress+":"+nport+"/"+ndb;
			System.out.println("Connect url  "+url);
			c = DriverManager.getConnection(url, nuser, npassword);
			System.out.println("Connected to "+ndb);
			}
		catch (Exception e) {
			System.out.println("Could Not Connect to "+ndb);
			e.printStackTrace();
			}
		}
	
	public Connection getConnection() {
		return c;
		}
	
	public void closeConnection() {
		try {
			c.close();
			}
		catch(Exception e) {
			System.out.println("Close Connection Error");
			e.printStackTrace();
			}
		}

	}
