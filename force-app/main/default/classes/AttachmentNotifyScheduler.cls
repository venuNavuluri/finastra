global class AttachmentNotifyScheduler implements Schedulable
{
    public static void Schedule(string jobName, integer intMinutes)
    {
        ScheduledCommonFunctions.ScheduleJob(new AttachmentNotifyScheduler(), jobName, intMinutes);
    }
    
    global void execute(SchedulableContext SC)
    {
        //Notification of Attachments added by portal users
        System.debug('---------------Schedule Notification of new Attachments from Customer Portal users-----------------');
        try
        {
            //Call process to determine if notification is needed
            attachmentNotification();   
            
            //Generate an exception if this is a test method
            //  (Not the best design to do this, but this will result in a higher test code coverage percent)
            if(Test.isRunningTest()){
                throw new ScheduledCommonFunctions.CustomException('Test Exception');
            }
        }
        catch(Exception e)
        {
            System.debug('------------------Exception in AttachmentNotifyScheduler------------------'+e.getMessage());
            String errMessage = 'Unable to reschedule job for Portal Attachment Notification - '+e;
            String errSubject = 'Error - reschedule Portal Attachment Notification';
            String errLocation = 'AttachmentNotifyScheduler.execute()';
            ScheduledCommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),errSubject,errLocation,new ScheduledCommonFunctions.CustomException(errMessage));
            scheduleNextBatch();
        }
    }
    
    public static void attachmentNotification()
    {
        Map<Id,Process_Log__c> unProcessedLogs = new Map<Id,Process_Log__c>();
        List<String> attachmentIds = new List<String>();
        Map<Id,Process_Log__c> mapAttachmentToLog = new Map<Id,Process_Log__c>();
        
        AttchmntNotifySchedulr_ProcessLogUtils.queryUnprocessedLogsAndBuildMaps(unProcessedLogs, attachmentIds, mapAttachmentToLog);
        
        if (unProcessedLogs.keySet().size() > 0) {
            doUnprocessedLogs(unProcessedLogs, attachmentIds, mapAttachmentToLog);
        }
        
        scheduleNextBatch();
    }
    
    public static void doUnprocessedLogs(
        Map<Id,Process_Log__c> unProcessedLogs,
        List<String> attachmentIds,
        Map<Id,Process_Log__c> mapAttachmentToLog)
    {
        Map<Id,Process_Log__c> mapLogsToBeProcessed = new Map<Id,Process_Log__c>();

        List<Attachment> addedAttachments =
            [select Id, Name, ParentId, CreatedById, CreatedDate from Attachment where Id in :attachmentIds order by ParentId];
        
        // Input: addedAttachments, mapAttachmentToLog
        // Output: mapLogsToBeProcessed
        Map<Id, List<Attachment>> mapParentToAttachments =
            AttchmntNotifySchedulr_ProcessLogUtils.buildCaseToAttachmentListMap(addedAttachments, mapAttachmentToLog, mapLogsToBeProcessed);
        
        // create the case artifact-collections, and then populate them
        List<CaseComment> caseComments = new List<CaseComment>();
        List<FeedItem> caseFeedItems = new List<FeedItem>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        // Input: mapParentToAttachments
        // Output: caseComments, emailsToSend, caseFeedItems
        AttchmntNotifySchedulr_CaseArtifactUtils.createCaseArtifacts(mapParentToAttachments, caseComments, emailsToSend, caseFeedItems);

        // process the collections (ie. insert the CaseComments, insert the chatterPosts, and send the emails)
        // Input: caseComments, caseFeedItems, emailsToSend, mapLogsToBeProcessed
        // Side-effect: update the status on the members in mapLogsToBeProcessed
        AttchmntNotifySchedulr_CaseArtifactUtils.processCaseArtifacts(caseComments, caseFeedItems, emailsToSend, mapLogsToBeProcessed);
        
        // update the status on the processed log records
        Integer processedLogCount = AttchmntNotifySchedulr_ProcessLogUtils.markLogsProcessed(mapLogsToBeProcessed);
        
        // update the status on the failed log records
        AttchmntNotifySchedulr_ProcessLogUtils.markLogsWithInvalidAttachmentIds(attachmentIds, addedAttachments, mapAttachmentToLog);
        
        if (processedLogCount > 0) {
            try{
                ScheduledCommonFunctions.addProcessLog('Case', 'Portal Attachment Notification', 'Apex Scheduled Job');
            }
            catch(Exception e){
                System.debug('Error adding Process Log: '+e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
            }
        }
    }
    
    private static void scheduleNextBatch()
    {
        //Schedule the next run of the job
        try {
            Schedule('Attachment Notification (Portal)',integer.valueOf(Label.Case_Attachment_Notice_Interval));
        }
        catch(Exception e) {
            String errMessage = 'Unable to reschedule job for Portal Attachment Notification - '+e;
            String errSubject = 'Error - reschedule Portal Attachment Notification';
            String errLocation = 'AttachmentTriggerMethods.AttachmentNotification';
            ScheduledCommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),errSubject,errLocation,new ScheduledCommonFunctions.CustomException(errMessage));
        }
        finally {
			//Below code is for deleting the deleted scheduled job for the attachment notification
			try {
					LIST<CronTrigger> ctList = [Select Id, CronJobDetail.Name From CronTrigger where State = 'DELETED'];
			        for(CronTrigger ct : ctList) {
			            system.debug('ct.id = ' + ct.CronJobDetail.Name);
			            if(ct.CronJobDetail.Name != null && (ct.CronJobDetail.Name).contains('Attachment Notification'))
			                System.abortJob(ct.Id);
			        }
			} catch(Exception ex){
				//nothing needs to be done here as the above code is only for deleting the deleted scheduled jobs
			}
        }
    }
    
    
}