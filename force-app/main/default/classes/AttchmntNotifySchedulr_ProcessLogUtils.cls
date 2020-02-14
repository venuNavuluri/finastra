public class AttchmntNotifySchedulr_ProcessLogUtils
{
	public static void queryUnprocessedLogsAndBuildMaps(
		Map<Id,Process_Log__c> unProcessedLogs,
		List<String> attachmentIds,
		Map<Id,Process_Log__c> mapAttachmentToLog)
	{
		//Get any records in the Process Log for attachment notifications that have not been processed
		for(Process_Log__c pl : [select Id, RecordId__c, Status__c from Process_Log__c where Process__c = 'Portal Attachment Notification' and Status__c = 'Unprocessed'])
		{
			unProcessedLogs.put(pl.Id, pl);
			attachmentIds.add(pl.RecordId__c);
			mapAttachmentToLog.put(pl.RecordId__c,pl);
		}
	}
	
	public static Integer markLogsProcessed(Map<Id,Process_Log__c> mapLogsToBeProcessed)
	{
		List<Process_Log__c> processedLogs = new List<Process_Log__c>();
		//if processed successfully, update the process log to 'Processed'
		//for(Process_Log__c p : unProcessedLogs.values())
		for(Process_Log__c p : mapLogsToBeProcessed.values())
		{
			if(!p.Status__c.contains('Failed') && !p.Status__c.contains('Unprocessed'))
			{
				Process_Log__c log = p;
				//log.Id = p.Id;
				log.Status__c = 'Processed';
				processedLogs.add(log);
			}
		}
		update processedLogs;
		return processedLogs.size();
	}
	
	public static void markLogsWithInvalidAttachmentIds(
		List<String> attachmentIds,
		List<Attachment> addedAttachments,
		Map<Id,Process_Log__c> mapAttachmentToLog)
	{
		//If there are any Ids from the Process Log that are not valid Ids in the Attachment object, set the status on the Process Log to 'Attachment Not Found'
		List<Process_Log__c> missingAttachmentLogs = new List<Process_Log__c>();
		//Create a set of attachment Ids for a quick search
		Set<Id> existingAttachmentIds = new Set<Id>();
		for(Attachment existingAttachment : addedAttachments)	{
			existingAttachmentIds.add(existingAttachment.Id);
		}
		system.debug('existingAttachmentIds: ' + existingAttachmentIds);
		
		for(String logAttachId : attachmentIds)	{
			if(!existingAttachmentIds.contains(logAttachId)) {
				Process_Log__c m = mapAttachmentToLog.get(logAttachId);
				m.Status__c = 'Attachment Not Found';
				missingAttachmentLogs.add(m);
			}
		}
		update missingAttachmentLogs;
	}
	
	public static Map<Id, List<Attachment>> buildCaseToAttachmentListMap(
		List<Attachment> addedAttachments,
		Map<Id,Process_Log__c> mapAttachmentToLog,
		Map<Id,Process_Log__c> mapLogsToBeProcessed)
	{
		Map<Id, List<Attachment>> mapParentToAttachments = new Map<Id, List<Attachment>>();
		
		//Loop through attachments and group them by ParentId - Only process attachments for a certain number of cases at a time, to be on the safe side 
		//for(Attachment a1: addedAttachments)
		if(addedAttachments.size() == 0) {
			return mapParentToAttachments;
		}
		Integer att = 0;
		Boolean bProcessIt;
		do
		{	
			bProcessIt = false;
			Attachment a1 = addedAttachments[att];
			
			//Add to the list if the map already contains the key, otherwise create the list and add the map key
			if(mapParentToAttachments.containsKey(a1.ParentId))
			{
				mapParentToAttachments.get(a1.ParentId).add(a1);
				bProcessIt = true;
			}
			else if(mapParentToAttachments.keySet().size() < integer.valueOf(Label.Case_Attachment_Notice_Batch_Size))
			{
				List<Attachment> listA = new List<Attachment>();
				listA.add(a1);
				mapParentToAttachments.put(a1.ParentId,listA);
				bProcessIt = true;
			}
			
			//If this one was added to a ParentId list, add the related Process Log to the list of ones to be processed
			if(bProcessIt == true)
			{
				mapLogsToBeProcessed.put(mapAttachmentToLog.get(a1.Id).Id,mapAttachmentToLog.get(a1.Id));
			}
		
			//Increment the attachment position
			att++;
			system.debug('mapParentToAttachments.size:'+mapParentToAttachments.keySet().size()+'; att:'+att);
			
			///
			// jump out of loop when mapParentToAttachments has 250 keys (250 related cases)
			///
			/// when getting Process Logs, build a map of attachment id to log, such as mapAttachmentToLog
			/// then when looping through attachments, add log to a list of ones to be processed, such as mapLogsToProcess
			/// then use mapLogsToProcess in the rest of the code so only these are updated.
			
			//If the most recent CreateDate on the attachment is over 2 minutes old, add the Case to the list to be included in the notificaiton
			//  This provides a window of time where the user may not have finished uploading their attachment files
			//if(a1.CreatedDate < System.now().addMinutes(-2))
			//	includedCaseIds.add(a1.ParentId);
		}
		while (mapParentToAttachments.keySet().size() <= integer.valueOf(Label.Case_Attachment_Notice_Batch_Size) && att < addedAttachments.size());
		system.debug('AttachmentNotification: mapParentToAttachments: '+mapParentToAttachments);
		return mapParentToAttachments;
	}
	

}