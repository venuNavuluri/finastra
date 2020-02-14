public class AttachmentTriggerMethods {
	
	//When an attachment is added or removed from a Case and the Case has a recordtype of Issue, update 
	//	an indicator field that is sent to the ALM system via OBM
	public static void IssueCaseAttachmentIndicator(List<Attachment> lAttachments, String fileAction)
	{
		Set<Id> CaseIds = new Set<Id>();
		Set<Id> AttachmentIds = new Set<Id>();
		List<Case> casesToUpdate = new List<Case>();
		
		//loop through the attachments to determine if attached to a Case
		for(Attachment a : lAttachments)
		{
			//If the ParentId starts with '500' then it is a case, so add it to the set of case Ids'
			system.debug('IssueCaseAttachmentIndicator:  Attachment ParentId = '+a.ParentId);
			CaseIds.add(a.ParentId);
			AttachmentIds.add(a.Id);
		}
		system.debug('CaseIds: '+CaseIds);
		system.debug('AttachmentIds: '+AttachmentIds);
		
		//Now check to see if any are Issue Cases in the list and check for other Attachments on each
		List<Case> casesRelated = [select id, recordtypeid, casenumber, has_attachments__c from Case where Id in :CaseIds and recordtypeid = :Label.issue_case_id];
		system.debug('casesRelated: '+casesRelated);
		
		//create map of attachments for those issue cases
		Map<String,Integer> caseCurrentAttachments = new Map<String,Integer>();
		AggregateResult[] groupedCount = [select parentid, count(id)NumAttachments from attachment where parentid in :CaseIds and Id not in :AttachmentIds group by parentid];
		system.debug('groupedCount (Attachments per case): '+groupedCount);
		for(AggregateResult ar : groupedCount)
		{
			caseCurrentAttachments.put(string.valueOf(ar.get('parentid')), integer.valueOf(ar.get('NumAttachments')));
			//  --->>>  Need to re-do logic here?  Maybe loop through all attachments, and update map counts manually?
		}
		system.debug('caseCurrentAttachments: '+caseCurrentAttachments);
		
		//For each case related to the current attachment(s), determine how to update the Has Attachments field
		for(Case c : casesRelated)
		{
			if(fileAction == 'Insert')
			{
				c.Has_Attachments__c = Label.ALM_Issue_Case_Has_Attachment;
			}
			else if(fileAction == 'Delete')
			{
				if(!caseCurrentAttachments.keySet().contains(string.valueOf(c.Id)))
				{
					c.Has_Attachments__c = Label.ALM_Issue_Case_Has_No_Attachment;
				}
			}
		}
		system.debug('casesRelated (Before Update of indicator): '+casesRelated);
		
		try
		{
			update casesRelated;
		}catch(Exception e){
			system.debug('Error updating Has Attachments on Case: '+e);
			String errMessage = 'Unable to update Has Attachments indicator on Case ('+CaseIds+') - '+e;
			String errSubject = 'Error - Has Attachments update';
			String errLocation = 'AttachmentTriggerMethods.IssueCaseAttachmentIndicator';
			CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),errSubject,errLocation,new CommonFunctions.CustomException(errMessage));
		}
	}
	
	//On insert of a new attachment, determine if attachment should be logged to be processed later
	//If so, add Process Log record, including Attachment Id and Status = 'Unprocessed'
	//Originally written to provide notification of new attachments on Cases added by Customer Portal users
	public static void addAttachmentNotifyLog(List<Attachment> newAttachments)
	{
		List<Process_Log__c> newLogs = new List<Process_Log__c>();
		List<CaseComment> comments = new List<CaseComment>();
		
		//loop through attachments to find ones that require notification
		for(Attachment a : newAttachments)
		{
			//Find Attachments added to Cases ('500..') by customer portal users
			system.debug('addAttachmentNotifyLog:  Attachment ParentId = '+a.ParentId);
			if(String.valueOf(a.ParentId).startswith('500'))
			{
				//If the current user is a customer portal user
				system.debug('JRB:   Current user type = '+UserInfo.getUserType());
				if(UserInfo.getUserType() == 'PowerCustomerSuccess' || Test.IsRunningTest())
				{
	       	   		//Add the attachment Id to the Process Log list for later processing
	       	   		Process_Log__c p = new Process_Log__c();
	       	   		p.Object__c = 'Attachment';
	       	   		p.Process__c = 'Portal Attachment Notification';
	       	   		p.RecordId__c = String.valueOf(a.Id);
	       	   		p.Status__c = 'Unprocessed';
	 				p.Type__c = 'Apex Trigger';
	 				newLogs.add(p);

					//Create the Case Comment
					CaseComment noticeComment = new CaseComment();
					noticeComment.ParentId = a.ParentId;
					noticeComment.IsPublished = true;
					noticeComment.CommentBody = Label.Case_Attachment_Notice_Comment + '\r\n' + a.Name + '' ;
					comments.add(noticeComment);
					system.debug('addAttachmentNotifyLog - Case Comment Added: '+noticeComment);
				}
			}
 		}
		system.debug('JRB   newLogs:'+newLogs);
		insert newLogs;
		
		if(comments != null && comments.size() > 0){
			insert comments;
		}
		
	}
	
	
	public static String attachAsPDF (PageReference vfPage, Id pageId, Id parentId, String attachmentName)
	{
		String fileExt = '.pdf';
		String attName = attachmentName+fileExt;
		
		//Create the new attachment object
		Attachment attachPDF = new Attachment();
		
		//Create the page reference with the given Id
		//PageReference vfPageRef = new PageReference(vfPage);
		
		vfPage.getParameters().put('id',pageId);
		
		//Contents of the attachment as a PDF
		Blob body;
		//try
		//{
			//Render the page as a PDF and return the contents
			system.debug('VFPage parameters: '+vfPage.getParameters());
			if (Test.IsRunningTest()) {
				body = Blob.toPdf('UNIT TEST');
			}
			else {
				body = vfPage.getContentAsPDF();
			}
		//}
		//catch(Exception e)
		//{
		//	system.debug('Failed to create attachment as PDF - '+e);
		//	return;
		//}
		
		//Add the body and other properties of the attachment
		attachPDF.body = body;
		attachPDF.Name = attName;
		attachPDF.ParentId = parentId;
		system.debug('Attachment properties before insert: Name='+attachPDF.Name+', ParentId='+attachPDF.ParentId+', vfPage='+vfPage+', body='+body+'');
		//Insert the attachment
		//try
		//{
			insert attachPDF;
		//}
		//catch (Exception e)
		//{
		//	system.debug('Failed to insert attachment as PDF - '+e);
		//}
		
		//If successful, return the attachment Id
		return attachPDF.Id;
	}
	
	//This method is for creating an attachment to the contract record if the attachment is on DocuSign Status object.
	public static void createContractAttachment(map<Id, Attachment> newAttachmentMap){
		
        list<Attachment> newAttachments = new list<Attachment>();
        set<Id> docuSignIds = new set<Id>();
        map<id, id> parentIdAttachmentIdMap = new map<id, id>();
		system.debug('Attachment = ' + newAttachmentMap);
		
        for(Attachment att : newAttachmentMap.values()){
			Schema.SObjectType token = att.ParentId.getSObjectType();
            if(token.getDescribe().getName() == 'dsfs__DocuSign_Status__c'){
            	docuSignIds.add(att.ParentId);
            	parentIdAttachmentIdMap.put(att.ParentId, att.Id);
            }
        }
        system.debug('docuSignIds = ' + docuSignIds);
        system.debug('parentIdAttachmentIdMap = ' + parentIdAttachmentIdMap);
        if(docuSignIds != null && docuSignIds.size() > 0){
	        for(dsfs__DocuSign_Status__c ds : [select id, dsfs__Contract__c, dsfs__Envelope_Status__c from dsfs__DocuSign_Status__c where id in :docuSignIds]){
	        	if(ds.dsfs__Contract__c != null && ds.dsfs__Envelope_Status__c == 'Completed'){
	        		newAttachments.add(new Attachment(parentid = ds.dsfs__Contract__c, Name = newAttachmentMap.get(parentIdAttachmentIdMap.get(ds.Id)).Name, Body = newAttachmentMap.get(parentIdAttachmentIdMap.get(ds.Id)).Body));
	        	}
	        }
        }
        system.debug('newAttachments = ' + newAttachments);
        if(newAttachments != null && newAttachments.size() > 0){
            insert newAttachments; 
        }
	}
}