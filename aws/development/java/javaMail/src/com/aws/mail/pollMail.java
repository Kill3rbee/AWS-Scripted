package com.aws.mail;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class pollMail implements Runnable {

	private static dbManager dbm;
	private Thread runner;
	private sendMailSES sm;
	
	private int maxattempts=3;
	
	SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy HH:mm:ss");

	public pollMail(dbManager ndbm, String nsmtphost, String nsmtpport, String nsmtpuser, String nsmtppass) {
		dbm=ndbm;
		runner = new Thread(this, "pollMail");
		System.out.println(getdate()+" Created Thread "+runner.getName());
		sm=new sendMailSES(nsmtphost, nsmtpport, nsmtpuser, nsmtppass);
		}

	public void start() {
		runner.start();
		System.out.println(getdate()+" Started Thread "+runner.getName());
		}
	
	public void run() {
		
		
		Runtime.getRuntime().addShutdownHook(new Thread() {
		    public void run() {
				System.out.println(getdate()+" STOPPED");
		    		}
			});
		
		while (true) {
			
			Connection c=dbm.getConnection();
			
			try {
				Statement statement = c.createStatement();
				ResultSet res = statement.executeQuery("select sendemailID, sendto, sendfrom, sendsubject, sendmessage, sendfailures from sendemails where sent=0 and sendfailures<"+maxattempts+" order by sendemailID asc limit 1;");

				long sendemailID;
				String sendto;
				String sendfrom;
				String sendsubject;
				String sendmessage;
				int sendfailures;
				if (res.next()) {
					sendemailID=res.getLong("sendemailID");
					sendto=res.getString("sendto");
					sendfrom=res.getString("sendfrom");
					sendsubject=res.getString("sendsubject");
					sendmessage=res.getString("sendmessage");
					sendfailures=res.getInt("sendfailures");
					boolean isvalid=isValidEmailAddress(sendto);
					boolean result=false;
					if (isvalid)
						result=sm.send(sendto, sendfrom, sendsubject, sendmessage);
					if (result==true) {
						PreparedStatement pstatement=c.prepareStatement("update sendemails set sent=1 where sendemailID="+sendemailID+";");
						pstatement.executeUpdate();
						pstatement.close();
						System.out.println(getdate()+" sent email ok "+sendto+" ID: "+sendemailID);
						}
					else {
						PreparedStatement pstatement=c.prepareStatement("update sendemails set sendfailures=sendfailures+1 where sendemailID="+sendemailID+";");
						pstatement.executeUpdate();
						pstatement.close();
						System.out.println(getdate()+" sent email err '"+sendto+"' "+sendemailID+" failures "+(sendfailures+1)+" EMAIL"+((isvalid)?" VALID":" INVALID"));
						}
					res.close();
					statement.close();
					}
				else {
					res.close();
					statement.close();
					Thread.sleep(1000L);
					System.gc();
					}
				}
			catch (Exception e) {
				e.printStackTrace();
				System.out.println(getdate()+" Error getting next email");
				try {Thread.sleep(2000L);} catch (Exception e2) {}
				}

			}
		}

	public boolean isValidEmailAddress(String email) {
		Pattern p = Pattern.compile("^.+@.+\\..+$");
		Matcher m = p.matcher(email);
		return m.matches();
		}
	
	private String getdate() {
		return sdf.format(new Date());
		}
	
	}
