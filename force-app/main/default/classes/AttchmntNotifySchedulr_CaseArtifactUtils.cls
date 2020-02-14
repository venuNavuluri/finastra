public class AttchmntNotifySchedulr_CaseArtifactUtils
{
	public static void processCaseArtifacts(
		List<CaseComment> caseComments,
		List<FeedItem> caseFeedItems,
		List<Messaging.SingleEmailMessage> emailsToSend,
		Map<Id,Process_Log__c> mapLogsToBeProcessed)
	{
		//insertCaseComments(caseComments, mapLogsToBeProcessed);//AK - Commented this as the comments are created as soon as the attachments are attached.
		//insertChatterPosts(caseFeedItems, mapLogsToBeProcessed);
		for(Process_Log__c pLog : mapLogsToBeProcessed.values())
		{
			if(pLog.Status__c == 'Unprocessed')
				pLog.Status__c = 'Processed';
		}
		sendEmails(emailsToSend);
	}
	
	private static void insertCaseComments(List<CaseComment> caseComments, Map<Id,Process_Log__c> mapLogsToBeProcessed)
	{
		//Insert the Case Comments
		try{
			//insert caseComments;
			Database.SaveResult[] results = Database.insert(caseComments,false);
			//updateSaveResults(results,caseComments,unProcessedLogs);
			updateSaveResults(results,caseComments,mapLogsToBeProcessed);
		}catch(Exception e){
			System.debug('Error inserting Case Comments: '+e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
		}	
	}
	
	private static void insertChatterPosts(List<FeedItem> caseFeedItems, Map<Id,Process_Log__c> mapLogsToBeProcessed)
	{
		//Insert the Chatter alerts
		if(Label.Case_Attachment_Notice_Disable_Chatter.toUpperCase() != 'TRUE')
		{
			try{
				//insert caseFeedItems;
				Database.SaveResult[] results = Database.insert(caseFeedItems,false);
				//updateSaveResults(results,caseFeedItems,unProcessedLogs);
				updateSaveResults(results,caseFeedItems,mapLogsToBeProcessed);
			}catch(Exception e){
				System.debug('Error inserting Chatter Feed Itemss: '+e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
			}
		}
	}
	
	private static void sendEmails(List<Messaging.SingleEmailMessage> emailsToSend)
	{
		//Send the email notice (Standard email notice does not occur when the case comment is added through Apex)
	 	try {
    		Messaging.sendEmail(emailsToSend,false);
    	}
    	catch(Exception e) {
    		system.debug('Error sending email: '+e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
    	}
	}

	public static void createCaseArtifacts(
		Map<Id, List<Attachment>> mapParentToAttachments,
		List<CaseComment> caseComments,
		List<Messaging.SingleEmailMessage> emailsToSend,
		List<FeedItem> caseFeedItems)
	{
		//Now with the list of CaseIds that require notification, we need to create and add the comment, email, and Chatter post.
		if(mapParentToAttachments.keySet().size() > 0)
		{
			//Get the list of Case Comments to be added
			caseComments.addAll(createAttachNotice_CaseComments(mapParentToAttachments));
			
			//Get the list email notices to be sent 
			emailsToSend.addAll(createAttachNotice_Emails(mapParentToAttachments));
			
			/*
			//Get the list of Chatter notices to insert
			caseFeedItems.addAll(createAttachNotice_FeedItems(mapParentToAttachments));
			*/
		}
		system.debug('AttachmentNotification: caseComments: '+caseComments);
		system.debug('AttachmentNotification: emailsToSend: '+emailsToSend);
		system.debug('AttachmentNotification: caseFeedItems: '+caseFeedItems);
	}
	
	private static List<CaseComment> createAttachNotice_CaseComments(Map<Id,List<Attachment>> mapCaseIdToAttachments)
	{
		List<CaseComment> comments = new List<CaseComment>();
		
		//For each case Id in the map,
		system.debug('mapCaseIdToAttachments key count = '+mapCaseIdToAttachments.keySet().size());
		for(Id CaseId : mapCaseIdToAttachments.keySet())
		{
			String attachments = '';
			DateTime maxCreateDate = null;
			for(Attachment a : mapCaseIdToAttachments.get(CaseId))
			{
				system.debug('createAttachNotice_CaseComments - Attachment name: '+a.Name);
				//attachments += a.Name + ' (' + a.CreatedDate.format('yyyy-MM-dd') + ')' + '\r\n';
				attachments += a.Name + '\r\n';
				if(maxCreateDate == null || a.CreatedDate > maxCreateDate)
				{
					maxCreateDate = a.CreatedDate;
				}
			}
			attachments += '';
			
			//Create the Case Comment
			CaseComment noticeComment = new CaseComment();
			noticeComment.ParentId = CaseId;
			noticeComment.IsPublished = true;
			noticeComment.CreatedById = Label.MBS_Admin_Integration_UserId;
			//noticeComment.CreatedDate = maxCreateDate;			//Used to recover backlog in case of a failure
			//String listOfAttachments;
			noticeComment.CommentBody = Label.Case_Attachment_Notice_Comment + '\r\n' + attachments + '';
			comments.add(noticeComment);
			system.debug('Case Comment Added: '+noticeComment);
		}
		return comments;
	}

	//Update the processing results to the Process Log records
	private static void updateSaveResults(Database.SaveResult[] results, List<sObject> updatedRecs, map<Id,Process_Log__c> mapRecToLog)
	{
		if(results != null)
		{
			system.debug('results list: '+results);
			system.debug('updatedRecs: '+updatedRecs);
			system.debug('mapRecToLog: '+mapRecToLog);
			for(Integer x = 0; x <= updatedRecs.size()-1; x++)
			{
				system.debug('updatedRecs['+x+']: '+updatedRecs[x]);
				system.debug('results['+x+']: '+results[x]);
				
				for(Process_Log__c pLog : mapRecToLog.values())
				{
					if(pLog.Status__c == 'Unprocessed')
						pLog.Status__c = '';
					if(results[x].isSuccess())
					{
						pLog.Status__c = pLog.Status__c + 'Processed. ';
					}
					else
					{
						pLog.Status__c = 'Failed - ' + results[x].getErrors()[0].getStatusCode()+' - '+results[x].getErrors()[0].getFields()+' - '+results[x].getErrors()[0].getMessage();
					}
				}
			}
		}		
	}
	
	private static List<Messaging.SingleEmailMessage> createAttachNotice_Emails(Map<Id,List<Attachment>> mapCasesToAttachments)
	{
		//Reserve email capacity for the current Apex transaction to ensure that we won't exceed our daily email limits when sending email after the current transaction is committed.
		Boolean bNoEmail = false;
		try	{
			Messaging.reserveSingleEmailCapacity(mapCasesToAttachments.keySet().size());
		}
		catch(Exception e) {
			System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
			bNoEmail = true;
		}
		List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
		system.debug('EmailsToSend count: '+ emailsToSend.size());
		
		//Check the flag that turns off case attachment emails
		if(Label.Case_Attachment_Notice_Disable_Email.toUpperCase() == 'TRUE')
		{
			bNoEmail = true;
		}
		
		//Get the information for the related cases
		Map<Id,Case> mapCases = new Map<Id,Case>([select Id, OwnerId, Casenumber, Subject from Case where Id in :mapCasesToAttachments.keySet()]);
		
		//Get the owner of each case
		List<Id> caseOwnerIds = new List<Id>();
		for(Case thisCase : mapCases.values())
			caseOwnerIds.add(thisCase.OwnerId);
		system.debug('JRB     caseOwnerIds:'+caseOwnerIds);
		
		//Get the email addresses for the Case owners, including user and queue emails
		Map<Id,List<String>> mapCaseOwnerToEmail = ScheduledCommonFunctions.getEmailsForOwners(CaseOwnerIds);
		system.debug('JRB     mapCaseOwnerToEmail:'+mapcaseOwnerToEmail);
		
		//For each case Id in mapParentToAttachments,
		for(Id CaseId : mapCasesToAttachments.keySet())
		{
			//Create the Email
			if(bNoEmail == false)
			{
				Case c = mapCases.get(CaseId);
				system.debug('JRB - Create Case Notice - Case:'+c);
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setToAddresses(mapCaseOwnerToEmail.get(c.OwnerId));
				mail.setSubject('Attachment Notification - Case Number '+c.Casenumber);
				mail.setReplyTo('noreply@misys.com');
				mail.setSenderDisplayName('MBS Admin');
				String sHTML = '';
				sHTML = '<br /><b>Case ' + c.casenumber + ' : "'+ c.Subject + '"</b>';
				sHTML += '<br /><br />New file attachment(s) have been added to this case in the customer portal.';
				sHTML += 'Click the link below to view the case and attachment details.';
				//if(attName != '')
				//{
				//	sHTML += '<br /><br />Attachment:  '+attName;
				//}
				sHTML += '<br /><br /><a href=' + Label.Domain_URL + '/' + c.Id + '>' + Label.Domain_URL + '/' + c.Id + '</a>';
				sHTML += '<br /><br /><br />This is an automatically generated email. Please do not reply to it.';
				mail.setHtmlBody(sHTML);
				emailsToSend.add(mail);
			}
		}
		return emailsToSend;
	}
	
	/*
	public static List<FeedItem> createAttachNotice_FeedItems(Map<Id,List<Attachment>> mapCasesToAttachments)
	{
		List<FeedItem> fItems = new List<FeedItem>();
		
		for(Id CaseId : mapCasesToAttachments.keySet())
		{
			//Create the Feed Item
			FeedItem fItem = new FeedItem();
			fItem.Type = 'TextPost';
			fItem.ParentId = CaseId;
			try{
				fItem.CreatedById = Label.MBS_Admin_Integration_UserId;
			}
			catch(Exception e)
			{
				String errMessage = 'Portal Attachment Notification - CaseId '+CaseId+': Unable to set CreatedById for FeedPost on  - '+e;
				String errSubject = 'Error - FeedItem update - Portal Attachment Notification';
				String errLocation = 'AttachmentTriggerMethods.createAttachNotice_FeedItems';
				CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),errSubject,errLocation,new CommonFunctions.CustomException(errMessage));
			}
			//fItem.CreatedDate = mapCasesToAttachments.get(CaseId)[0].CreatedDate;		//Used to recover backlog in case of a failure
			fItem.Body = Label.Case_Attachment_Notice_Chatter;
			fItems.add(fItem);
		}
		return fItems;
	}
	*/
	
}