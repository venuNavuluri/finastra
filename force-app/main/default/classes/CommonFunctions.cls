public class CommonFunctions {
	
	public class CustomException extends Exception{}
	
	public class chatterFeedItem 
	{
		public Id parentId;
		public String feedType;
		public String feedTitle;
		public String feedBody;
		public String feedURL;
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
	
	public static void sendErrorEmailFriendly(List<String> toAddresses, String mailSubject, String methodName, Exception excp, String actionMessage)
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
			system.debug('JRB:  sendErrorEmailFriendly function');
			system.debug('JRB:  toAddresses = '+toAddresses);
			system.debug('JRB:  mailSubject = '+mailSubject);
			system.debug('JRB:  methodName = '+methodName);
			system.debug('JRB:  Exception details = '+excp.getTypeName() + ' - ' + excp.getCause() + ': ' + excp.getMessage());
			system.debug('JRB:  actionMessage = '+actionMessage);

	     	//Create the email to send
	     	List<Messaging.SingleEmailMessage> mailToSend = new List<Messaging.SingleEmailMessage>();
	     	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	     	mail.setToAddresses(toAddresses);
	     	mail.setSubject(mailSubject);
	     	String sHTML = '';
	     	sHTML += actionMessage;
	     	sHTML += '<br /><br />';
	     	sHTML += 'Technical Details:<br />';
	     	sHTML += 'An error has occurred in <b>'+methodName+'</b>.  See error details below.'; 
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
	
	public static void sendEmailNoticeBasic(List<String> toAddresses, String mailSubject, String processName, String actionMessage, String RecordId)
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
			system.debug('JRB:  sendEmailNoticeBasic function');
			system.debug('JRB:  toAddresses = '+toAddresses);
			system.debug('JRB:  mailSubject = '+mailSubject);
			system.debug('JRB:  processName = '+processName);
			system.debug('JRB:  actionMessage = '+actionMessage);
			system.debug('JRB:  RecordId = '+RecordId);

	     	//Create the email to send
	     	List<Messaging.SingleEmailMessage> mailToSend = new List<Messaging.SingleEmailMessage>();
	     	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	     	mail.setToAddresses(toAddresses);
	     	mail.setSubject(mailSubject);
	     	String sHTML = '';
	     	sHTML += 'Process Name: '+processName;
	     	sHTML += '<br /><br />'; 
	     	sHTML += actionMessage;
	     	sHTML += '<br /><br />'; 
	     	sHTML += '<a href=/'+RecordId+'>Related Record Link</a>';
	     	sHTML += '<br /><br />';
	     	sHTML += '<br /><br />';
	     	sHTML += 'Sent by an automated process in Apex class CommonFunctions.sendEmailNoticeBasic()';
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
	
	@future public static void future_addProcessLog(String strObject, String strProcess, String strTypeCode)
	{
		CommonFunctions.addProcessLog(strObject, strProcess, strTypeCode);
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
	
	/*
	//////// NOTE - this doesn't work well because of how the '\' character is handled in Apex strings - need to re-write...
	public static String getFileNameFromPath(String sFilePath)
	{
		//Given a string like either \\server\share\filename.ext or c:\dir\filename.ext, this function will return the filename and extenstion
		
		String sFileName = '';
		system.debug('Incoming File Path = '+sFilePath);
		if(sFilePath != '' && sFilePath != null)
		{
			Integer iPos;
			iPos = sFilePath.lastIndexOf('\\');
			sFilename = sFilePath.subString(iPos+1);
		}
		system.debug('Final File Name = '+sFileName);
		return sFileName;
	}
	*/

	public static Map<Id,List<Attachment>> getAttachmentsMap(Set<Id> sParentIds)
	{
		//Given a set of parent record Ids, get all related attachments and return in a map
		//  Note that if a parent record has no attachments, it will not be included in the map as a key
		Map<Id,List<Attachment>> mapRecToAttachments = new map<Id,List<Attachment>>();
		for(Attachment a : [select Id, Name, ParentId from Attachment where ParentId in :sParentIds])
		{
			if(!mapRecToAttachments.keySet().contains(a.ParentId))
			{
				mapRecToAttachments.put(a.ParentId,new Attachment[]{a});
			}
			else
			{
				mapRecToAttachments.get(a.ParentId).add(a);
			}
		}
		return mapRecToAttachments;
	}
	
	public static String getMonthName(Integer monthNum, String formatString)
	{
		String monthName = '';
		
		if(formatString != 'MMM' && formatString != 'MMMMM'){
			formatString = 'MMM';
		}
		
		DateTime dt = datetime.newInstance(date.today().year(),monthNum,1,12,0,0);
		monthName = dt.format(formatString);
		system.debug('CommonFunctions.getMonthName - monthName to return: '+monthName);
		
		return monthName;
	}
	
	    /* Utility function to get all the users that belong to a group.
     *
     * @param groupId the Id of the public group to unwind
     * @return a Set<Id> containing the User Ids from the given group
     */
    public static Set<Id> getUsersFromGroup(Id groupId) {
        Set<Id> memberGroupIds = null;
        Set<Id> memberRoleIds = null;
        Set<Id> userIds = null;

        if (groupId != null) {
            Set<Id> memberIds = new Set<Id>();
            memberGroupIds = new Set<Id>();
            for (GroupMember member : [select UserOrGroupId
                                       from GroupMember
                                       where GroupId = :groupId]) {
                if(string.valueOf(member.UserOrGroupId).startsWith('00G')){
                	memberGroupIds.add(member.UserorGroupId);
                }else if(string.valueOf(member.UserOrGroupId).startsWith('005')){
                	memberIds.add(member.UserOrGroupId);
                }
            }
			
			//If the member of the group is a group, need to determine if it is an actual group or a group representing a role
			memberRoleIds = new Set<Id>();
			for(Group g : [select Id, RelatedId from Group where Id in :memberGroupIds]){
				//If the RelatedId  represents a Role ('00E'), then add the Role Id to a set and remove the Group Id from the set of groups
				if(g.RelatedId != null && string.valueOf(g.RelatedId).startsWith('00E')){
					memberRoleIds.add(g.RelatedId);
					memberGroupIds.remove(g.Id);
				}
			}
			
			//Get the members of the roles
			for(User u : [select Id from User where isActive = true and UserRoleId in : memberRoleIds]){
				memberIds.add(u.Id);
			}
			
			//Get the members of the group
			for(Id i : memberGroupIds){
				memberIds.addAll(getUsersFromGroup(i));
			}
			
			//Add the users that are direct members of the group
			if (memberIds.size() > 0) {
				userIds = new Set<Id>();
				userIds.addAll(memberIds);
			} 
			
			
            //if (memberIds.size() > 0) {
            //    userIds = new Set<Id>();
			//
            //    for (User u : [select Id
            //                   from User
            //                   where Id in :memberIds]) {
            //        userIds.add(u.Id);
            //    }
            //}
        }

        return userIds;
    }
    
    //public static List<String> RegionList {get; set;}
    
    public static List<String> getRegionList()
    {
    	List<String> regions = new String[7];
    	regions[0] = 'APAC';
		regions[1] = 'NEUR';
		regions[2] = 'SEUR';
		regions[3] = 'SSA';
		regions[4] = 'LAM';
		regions[5] = 'NAM';
		regions[6] = 'ME';
		return regions;
    }
    
    public static void postFeedItems(List<chatterFeedItem> fiPosts)
	{
		String defaultPostType = 'TextPost';
		List<FeedItem> fItems = new List<FeedItem>();
		for(chatterFeedItem post : fiPosts)
		{
			if(post.parentId != null && 
			   post.feedBody != '' && post.feedBody != null && 
			   post.feedType != '' && post.feedType != null &&
			   !(post.feedType == 'LinkPost' && (post.feedURL == '' || post.feedURL == null))){
				FeedItem fItem = new FeedItem();
				if(post.feedType == 'LinkPost'){
					fItem.Type = post.feedType;
					fItem.ParentId = post.parentId;
					fItem.Title = post.feedTitle;
					fItem.Body = post.feedBody;
					fItem.LinkUrl = post.feedURL;
				}else if(post.feedType == 'TextPost'){
					fItem.Type = post.feedType;
					fItem.ParentId = post.parentId;
					fItem.Title = post.feedTitle;
					fItem.Body = post.feedBody;
				}else{
					system.debug('Unknown feedType - ' + post.feedType + ' - requested.  Defaulting to TextPost.');
					fItem.Type = defaultPostType;
					fItem.ParentId = post.parentId;
					fItem.Body = post.feedBody;
				}
				fItems.add(fItem);
			}
		}
		try{
			insert fItems;
		}catch(Exception e){
			system.debug('CommonFunctions.postFeedItems EXCEPTION - '+e);
		}
	}
	    
}