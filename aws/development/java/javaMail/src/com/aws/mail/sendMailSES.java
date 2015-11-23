package com.aws.mail;

import java.util.Properties;

import javax.mail.*;
import javax.mail.internet.*;

public class sendMailSES {

	private String host;
	private String port;
	private String username;
	private String password;
	
	public sendMailSES(String nhost, String nport, String nusername, String npassword) {
		host=nhost;
		port=nport;
		username=nusername;
		password=npassword;
		}

	public boolean send(String nto, String nfrom, String nsubject, String nbody) {    
	    
		// Create a Properties object to contain connection configuration information.
		Properties props = System.getProperties();
		props.put("mail.transport.protocol", "smtp");
		props.put("mail.smtp.port", port); 
    	
		// Set properties indicating that we want to use STARTTLS to encrypt the connection.
		// The SMTP session will begin on an unencrypted connection, and then the client
		// will issue a STARTTLS command to upgrade to an encrypted connection.
		props.put("mail.smtp.auth", "true");
		props.put("mail.smtp.starttls.enable", "true");
		props.put("mail.smtp.starttls.required", "true");

		// Create a Session object to represent a mail session with the specified properties. 
		Session session = Session.getDefaultInstance(props);

		// Create a message with the specified information.
		MimeMessage msg = new MimeMessage(session);
		try {
			msg.setFrom(new InternetAddress(nfrom));
			msg.setRecipient(Message.RecipientType.TO, new InternetAddress(nto));
			msg.setSubject(nsubject);
			msg.setContent(nbody,"text/plain");
			}
		catch (Exception e) {
			System.out.println("Error creating message");
			e.printStackTrace();
			return false;
			}
            
		// Create a transport.        
		Transport transport=null;

		// Send the message.
		boolean success=false;
		try {
			transport = session.getTransport();
 			System.out.println("Attempting to send an email through the Amazon SES SMTP interface...");
            
			// Connect to Amazon SES using the SMTP username and password you specified above.
			transport.connect(host, username, password);

			// Send the email.
			transport.sendMessage(msg, msg.getAllRecipients());
			System.out.println("Email sent!");
			success=true;
			}
		catch (Exception ex) {
			System.out.println("The email was not sent.");
			System.out.println("Error message: " + ex.getMessage());
			}
        
		try {
			// Close and terminate the connection.
			transport.close();        	
			}
		catch (Exception e) {
			System.out.println("Could not close transport");
			e.printStackTrace();
			}

		return success;
		}
	
	}