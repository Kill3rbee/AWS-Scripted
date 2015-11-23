package com.aws.mail;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Properties;

public class config {

	public Properties prop;
	
	public void getconfig() {
		
		prop = new Properties();
		InputStream input = null;
 
		try {
 
			input = new FileInputStream("config.properties");
 
			// load a properties file
			prop.load(input);
 
			// get the property value and print it out
//			System.out.println(prop.getProperty("dbhost"));
 
			input.close();
			
			}
		catch (Exception e) {
			e.printStackTrace();
			}
		}
	
	}
