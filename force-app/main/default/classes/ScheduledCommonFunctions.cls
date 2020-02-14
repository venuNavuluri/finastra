public class ScheduledCommonFunctions
{
	public class CustomException extends Exception{}

	public static void ScheduleJob(Schedulable job, string jobName, integer intMinutes)
	{
		//Schedule the next run of the job for the interval specified
		
		//Build the system time of now + the specified interval
		Datetime systime = System.now();
		sysTime = sysTime.addMinutes(intMinutes);
		
		//Build the scheduling string
		String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
		system.debug('chron_exp: ' + chron_exp);
		
		//Schedule the next job and include the time so the name is unique
		system.schedule(jobName+sysTime.getTime(), chron_exp, job);
	}

	public static void sendEmailErrorNotice(List<String> toAddresses, String mailSubject, String methodName, Exception excp)
	{
		//Use format below to populate the list of toAddresses
		//List<String> toAddr = Label.Apex_Error_Emails.split(';');
		
		//Verify there is available email capacity for the current Apex transaction to ensure that we won't exceed our daily email limits when sending this email
		Boolean bNoEmail = false;
		try{
			Messaging.reserveSingleEmailCapacity(1);
		}catch(Exception e1){
			System.debug('In sendEmailErrorNotice, Error='+e1.getTypeName() + ' - ' + e1.getCause() + ': ' + e1.getMessage());
			bNoEmail = true;
		}

		if(!bNoEmail)
		{
			system.debug('JRB:  sendEmailErrorNotice function');
			system.debug('JRB:  toAddresses = '+toAddresses);
			system.debug('JRB:  mailSubject = '+mailSubject);
			system.debug('JRB:  methodName = '+methodName);
			system.debug('JRB:  Exception details = '+excp.getTypeName() + ' - ' + excp.getCause() + ': ' + excp.getMessage());

	     	//Create the email to send
	     	List<Messaging.SingleEmailMessage> mailToSend = new List<Messaging.SingleEmailMessage>();
	     	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	     	mail.setToAddresses(toAddresses);
	     	mail.setSubject(mailSubject);
	     	String sHTML = '';
	     	sHTML = 'An error has occurred in <b>'+methodName+'</b>.  See error details below.'; 
	     	//with record Id <b>'+recordId+'</b>
	     	sHTML += '<br /><br />';
	     	sHTML += excp.getTypeName() + ' - ' + excp.getCause() + ': ' + excp.getMessage();
	     	sHTML += '<br /><br />';
	     	sHTML += 'Sent by an automated process in Apex class CommonFunctions.sendEmailErrorNotice()';
	     	mail.setHtmlBody(sHTML);
	     	mailToSend.add(mail);
	     	
	     	//Send the email
		 	try{
        		Messaging.sendEmail(mailToSend,false);
        	}catch(Exception e2){
        		system.debug('Error sending email: '+e2.getTypeName() + ' - ' + e2.getCause() + ': ' + e2.getMessage());
        	}			
		}				
	}
	
	public static void addProcessLog(String strObject, String strProcess, String strTypeCode)
	{
		//Be sure to call this method outside any loops to avoid problems with DML limits!
		Process_Log__c log = new Process_Log__c();
		log.Object__c = strObject;
		log.Process__c = strProcess;
		log.Type__c = strTypeCode;
		insert log;
	}
	
	public static Map<Id,List<String>> getEmailsForOwners(List<Id> ownerIds)
	{
		Map<Id,List<String>> mapOwnerIdToEmail = new Map<Id,List<String>>();
		Set<Id> userIds = new Set<Id>();
		Set<Id> queueIds = new Set<Id>();
		Map<Id,User> mapIdToUser = new Map<Id,User>();
		Map<Id,Group> mapIdToQueue = new Map<Id,Group>();
		
		//Loop through list of Id's to separate user and queue owners
		for(Id i : ownerIds)
		{
			if(String.ValueOf(i).startsWith('005'))
			{
				userIds.add(i);
			}else{
				queueIds.add(i);
			}
		}
		
		//Get data for the list of queues
		if(queueIds.size() > 0)
		{
			mapIdToQueue = new Map<Id,Group>([select Id, Email from Group where Id in :queueIds]);
			
			//Loop through the queue data and add to the final map
			for(Id q : queueIds)
			{
				if(mapIdToQueue.containskey(q))
				{
					List<String> lQueueEmails = new List<String>();
					if(mapIdToQueue.get(q).Email != null)
					{
						lQueueEmails.add(mapIdToQueue.get(q).Email);
					}else{
	            		lQueueEmails.add(Label.Case_Update_Default_Email);
					}
					mapOwnerIdToEmail.put(q,lQueueEmails);
				}
			}
		}
		
		//Get data for the list of users
		if(userIds.size() > 0)
		{
			mapIdToUser = new Map<Id,User>([select Id, Email from User where Id in :userIds]);
			
			//Loop through the user data and add to the final map
			for(Id u : userIds)
			{
				if(mapIdToUser.containsKey(u))
				{
					List<String> lUserEmails = new List<String>();
					lUserEmails.add(mapIdToUser.get(u).Email);
					mapOwnerIdToEmail.put(u,lUserEmails);
				}
			}
		}
	
		return mapOwnerIdToEmail;	
	}
	
}