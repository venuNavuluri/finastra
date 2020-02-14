@isTest
private class test_Attachment {
 	
    private static testmethod void testAttachment_Viewer()
    {
    	//Set up test data
    	Account testAccount = TestUtility.sampleAccount();
       	insert testAccount;
        //Contact testContact = TestUtility.sampleContact();
       	//testContact.AccountId = testAccount.Id;
       	//insert testContact;
       	Case testCase = TestUtility.sampleCase();
        testCase.AccountId = testAccount.Id;
        insert testCase;
        
        List<Attachment> lAttachments = new List<Attachment>();
        for(Integer x = 1; x <= 5; x++)
        {
        	Attachment a = new Attachment();
        	a.ParentId = testCase.Id;
        	a.ContentType = 'txt';
        	a.Name = 'test'+x+'.txt';
        	a.Body = Blob.valueOf('test');
        	lAttachments.add(a);
        }
        system.debug('JRB: lAttachments: '+lAttachments);
        insert lAttachments;
    	
    	//Run the test (instantiate the VF page controller)
    	Test.startTest();
    	PageReference p = Page.Attachment_Viewer;
    	Test.setCurrentPage(p);
    	ApexPages.currentPage().getParameters().put('ParentId',testCase.Id);
    	AttachmentViewerController AVC = new AttachmentViewerController();
    	List<Attachment> listAttached = AVC.getListAttachments();
    	List<SelectOption> fileTypes = AVC.getFileTypes();
    	List<SelectOption> dateRanges = AVC.getDateRangeOptions();
    	String selectedFileType = AVC.getselFileType();
    	String selectedDateRange = AVC.getselDateRange();
    	AVC.toggleSort();
    	AVC.setselFileType('Word');
    	AVC.setselDateRange('Last7Days');
    	AVC.findAttachments();    	
    	AVC.setselFileType('Excel');
    	AVC.setselDateRange('Last30Days');
    	AVC.findAttachments();
    	AVC.setselFileType('PowerPoint');
    	AVC.setselDateRange('Over30Days');
    	AVC.findAttachments();
    	AVC.setselFileType('Image');
    	AVC.setselDateRange('Over90Days');
    	AVC.findAttachments();
    	AVC.setselFileType('PDF');
    	AVC.setselDateRange('Over6Months');
    	AVC.findAttachments();
    	AVC.setselFileType('Text');
    	AVC.setselDateRange('Over12Months');
    	AVC.findAttachments();
    	AVC.setselFileType('Zip');
    	AVC.findAttachments();
    	AVC.setselFileType('Other');
    	AVC.findAttachments();
    	AVC.setselFileType('All');
    	AVC.setselDateRange('All');
    	AVC.findAttachments();
    	Test.stopTest();
    	
    	
    	//Verify the results
    	system.assertEquals(listAttached.size(),5);
    	system.assert(fileTypes.size()>0);
    	system.assert(dateRanges.size()>0);
    	system.assertEquals(selectedFileType,'All');
    	system.assertEquals(selectedDateRange,'All');
    } 
    
    private static testmethod void test_AttachmentLogFromPortal()
    {
    	//Set up the test data
    	User runUser = [select Id from User where Id = :userInfo.getUserId() and isActive = true LIMIT 1];
        Account testAcc;
        Contact testCont;
        User testCPuser,testInternalUser;
        System.runAs(runUser){
            testAcc = TestUtility.sampleAccount();
            insert testAcc;
            testCont = TestUtility.sampleContact();
            testCont.AccountId = testAcc.Id;
            testCont.FirstName = 'First';
            testCont.email = 'testtest@foo.bar.co';
            insert testCont;
            testCPuser = TestUtility.sampleCustPortalUser(testCont);
            testInternalUser = TestUtility.sampleUser();
			insert new List<User>{testCPuser, testInternaluser};
        }
        Case testCase = TestUtility.sampleCase();
    	testCase.OwnerId = testInternalUser.Id;
    	testCase.AccountId = testAcc.Id;
    	testCase.ContactId = testCont.Id;
    	insert testCase;
    	Attachment attach1;
    	Attachment attach2;
    	Attachment attach3;
    	
    	//Initialize variables to capture results
    	List<Process_Log__c> plAttach_BeforeProcess = new List<Process_Log__c>();
    	List<Process_Log__c> plAttach_AfterProcess = new List<Process_Log__c>();
    	List<Process_Log__c> plAttach_AfterProcessNotFound = new List<Process_Log__c>();
    	
    	//Run the tests
    	Test.startTest();
	    	system.RunAs(runUser)
	    	{
	    		attach1 = TestUtility.sampleAttachment(testCase.Id);
	    		attach2 = TestUtility.sampleAttachment(testCase.Id);
	    		attach3 = TestUtility.sampleAttachment(testCase.Id);
	    		insert attach1;
	    		insert attach2;
	    		insert attach3;
	    	}
	    	Set<Id> testAttachIds = new Set<Id>();
	    	testAttachIds.add(attach1.Id);
	    	testAttachIds.add(attach2.Id);
	    	testAttachIds.add(attach3.Id);
	    	delete attach3;
	    	
	    	//Check for the Process Logs for the two new attachments
	    	plAttach_BeforeProcess = [select Id, RecordId__c from Process_Log__c where RecordId__c in :testAttachIds and Status__c = 'Unprocessed'];
	    	
	    	//Run the process to send notification of the new attachments - this would normally by called by the scheduled Apex process
	    	AttachmentNotifyScheduler.AttachmentNotification();
	    	
	    	//Get ProcessLogs after processing
	    	plAttach_AfterProcess = [select Id, RecordId__c from Process_Log__c where RecordId__c in :testAttachIds and Status__c = 'Processed'];
	    	plAttach_AfterProcessNotFound = [select Id, RecordId__c from Process_Log__c where RecordId__c in :testAttachIds and Status__c = 'Attachment Not Found'];
    	Test.stopTest();
    	
    	//Verify the results
    	
    	//Check for ProcessLogs before processing occurs 
    	//system.assertEquals(3,plAttach_BeforeProcess.size()); 
    	//Check status of ProcessLogs after processing occurs
    	//system.assertEquals(2,plAttach_AfterProcess.size());
    	//Check status of ProcessLogs after processing occurs for the missing attachment
    	//system.assertEquals(1,plAttach_AfterProcessNotFound.size());
    }
    
    private static testmethod void test_AttachmentLogFromPortal_LoadTest()
    {
    	//Set up the test data
    	Account testAcc = TestUtility.sampleAccount();
    	insert testAcc;
    	Contact testCont = TestUtility.sampleContact();
    	testCont.AccountId = testAcc.Id;
    	insert testCont;
        
        User runUser = [select Id from User where Id = :userInfo.getUserId() and isActive = true LIMIT 1];
        User testCPuser,testInternalUser;
        System.runAs(runUser){
            testCPuser = TestUtility.sampleCustPortalUser(testCont);
            insert testCPuser;
            testInternalUser = TestUtility.sampleUser();
            insert testInternalUser;
        }
        
    	//add a mass of cases for the attachment test
    	List<Case> testCases = new List<Case>();
    	integer BatchSize = 10;//integer.valueOf(Label.Case_Attachment_Notice_Batch_Size);
    	for(Integer x=0;x < BatchSize; x++)
    	{
    		Case testCase = TestUtility.sampleCase();
    		testCase.OwnerId = testInternalUser.Id;
    		testCase.AccountId = testAcc.Id;
    		testCase.ContactId = testCont.Id;
    		testCases.add(testCase);
    	}
    	insert testCases;
    	
    	//Initialize variables to capture results
    	List<Attachment> listAttachments = new List<Attachment>();
    	Set<Id> idsAttachments = new Set<Id>();
    	List<Process_Log__c> plAttach_BeforeProcess = new List<Process_Log__c>();
    	List<Process_Log__c> plAttach_AfterProcess = new List<Process_Log__c>();
    	
    	//Run the tests
    	Test.startTest();
	    	system.RunAs(runUser)
	    	{
	    		//add the mass of attachment records
		    	for(Integer x=0;x < BatchSize; x++)
		    	{
		    		Attachment attach1 = TestUtility.sampleAttachment(testCases[x].Id);
		    		listAttachments.add(attach1);
		    	}
		    	insert listAttachments;
	    	}
	    	//Get the Ids of the new Attachments
	    	for(Attachment a : listAttachments)
	    	{
	    		idsAttachments.add(a.Id);
	    	}
	    	
	    	//Check for the Process Logs for the new attachments
	    	plAttach_BeforeProcess = [select Id, RecordId__c, Status__c from Process_Log__c where RecordId__c in :idsAttachments and Status__c = 'Unprocessed'];
	    	
	    	//Run the process to send notification of the new attachments - this would normally by called by the scheduled Apex process
	    	AttachmentNotifyScheduler.AttachmentNotification();
	    	
	    	//Get ProcessLogs after processing
	    	plAttach_AfterProcess = [select Id, RecordId__c, Status__c from Process_Log__c where RecordId__c in :idsAttachments];
    	Test.stopTest();
    	
    	//Verify the results
    	Integer iProcessed = 0;
    	Integer iUnprocessed = 0; 
    	for(Process_Log__c pl : plAttach_AfterProcess)
    	{
    		if(pl.Status__c == 'Processed')
    		{
    			iProcessed++;
    		}
    		else if(pl.Status__c == 'Unprocessed')
    		{
    			iUnprocessed++;
    		}
    	}
    	
    	//Check for ProcessLogs before processing occurs 
    	//system.assertEquals(idsAttachments.size(),plAttach_BeforeProcess.size()); 
    	
    	//Check status of ProcessLogs after processing occurs
    	//system.assertEquals(integer.valueOf(Label.Case_Attachment_Notice_Batch_Size),iProcessed);
    	//system.assertEquals(10,iUnprocessed);
    }
    
    private static testmethod void test_IssueCaseAttachmentIndicator()
    {
    	//Set up test data
    	Case testCase1 = TestUtility.sampleCase();
    	testCase1.recordTypeId = Label.issue_case_id;
    	//Case1 has no attachment to start with
    	insert testCase1;
    	Case testCase2 = TestUtility.sampleCase();
    	testCase2.recordTypeId = Label.issue_case_id;
    	//Case2 has an attachment to start with
    	insert testCase2;
	   	Attachment existingAttachment2 = TestUtility.sampleAttachment(testCase2.Id);
    	insert existingAttachment2;
    	Attachment newAttachment1 = TestUtility.sampleAttachment(testCase1.Id);
    	Attachment newAttachment2 = TestUtility.sampleAttachment(testCase2.Id);
    	
    	//Initialize variables to capture data
    	String hasAttachBeforeInsert1;
    	String hasAttachAfterInsert1;
    	String hasAttachAfterDelete1;
    	String hasAttachBeforeInsert2;
    	String hasAttachAfterInsert2;
    	String hasAttachAfterDelete2;
    	
    	//Run the tests
    	Test.startTest();
			//Check the Has Attachments value before inserting a new attachment - value should be 0
				//For Case1, value should be 0
    		Case caseAttachBeforeInsert1 = [select Id, Has_Attachments__c from Case where Id = :testCase1.Id];
    		system.debug('test_IssueCaseAttachmentIndicator - caseAttachBeforeInsert1: '+caseAttachBeforeInsert1);
    		hasAttachBeforeInsert1 = caseAttachBeforeInsert1.Has_Attachments__c;
    			//For Case2, value should be 1, since there are other attachments on the Case
    		Case caseAttachBeforeInsert2 = [select Id, Has_Attachments__c from Case where Id = :testCase2.Id];
    		system.debug('test_IssueCaseAttachmentIndicator - caseAttachBeforeInsert2: '+caseAttachBeforeInsert2);
    		hasAttachBeforeInsert2 = caseAttachBeforeInsert2.Has_Attachments__c;
    		
    		//Insert an attachment on the case
    		insert newAttachment1;
    		insert newAttachment2;
    		
    		//Check the Has Attachments value after inserting a new attachment - value should be 1
    			//For Case1, value should be 1
    		Case caseAttachAfterInsert1 = [select Id, Has_Attachments__c from Case where Id = :testCase1.Id];
    		system.debug('test_IssueCaseAttachmentIndicator - caseAttachAfterInsert1: '+caseAttachAfterInsert1);
    		hasAttachAfterInsert1 = caseAttachAfterInsert1.Has_Attachments__c;
    			//For Case2, value should be 1
    		Case caseAttachAfterInsert2 = [select Id, Has_Attachments__c from Case where Id = :testCase2.Id];
    		system.debug('test_IssueCaseAttachmentIndicator - caseAttachAfterInsert2: '+caseAttachAfterInsert2);
    		hasAttachAfterInsert2 = caseAttachAfterInsert2.Has_Attachments__c;
    		
			//Delete the attachment from the case
    		delete newAttachment1;
    		delete newAttachment2;
    		
    		//Check the Has Attachments value after deleting a new attachment
    			//For Case1, value should be 0
    		Case caseAttachAfterDelete1 = [select Id, Has_Attachments__c from Case where Id = :testCase1.Id];
    		system.debug('test_IssueCaseAttachmentIndicator - caseAttachAfterDelete1: '+caseAttachAfterDelete1);
    		hasAttachAfterDelete1 = caseAttachAfterDelete1.Has_Attachments__c;
    			//For Case2, value should be 1, since there are other attachments on the Case
    		Case caseAttachAfterDelete2 = [select Id, Has_Attachments__c from Case where Id = :testCase2.Id];
    		system.debug('test_IssueCaseAttachmentIndicator - caseAttachAfterDelete2: '+caseAttachAfterDelete2);
    		hasAttachAfterDelete2 = caseAttachAfterDelete2.Has_Attachments__c;
    	
    	Test.stopTest();
    	
    	//Verify the results
    		//Case1
    	//system.assertEquals(Label.ALM_Issue_Case_Has_No_Attachment,hasAttachBeforeInsert1);
    	//system.assertEquals(Label.ALM_Issue_Case_Has_Attachment,hasAttachAfterInsert1);
    	//system.assertEquals(Label.ALM_Issue_Case_Has_No_Attachment,hasAttachAfterDelete1);
    		//Case2
    	//system.assertEquals(Label.ALM_Issue_Case_Has_Attachment,hasAttachBeforeInsert2);
    	//system.assertEquals(Label.ALM_Issue_Case_Has_Attachment,hasAttachAfterInsert2);
    	//system.assertEquals(Label.ALM_Issue_Case_Has_Attachment,hasAttachAfterDelete2);
    }
    
    private static testmethod void test_attachAsPDF()
    {
    	//Set up test data
    	Case testCase = TestUtility.sampleCase();
    	insert testCase;
    	
    	//Initialize variables to capture data
    	PageReference p = null;
    	String returnId = null;
    	List<Attachment> resultAtts = new List<Attachment>();
    	
    	//Run the tests
    	Test.startTest();
    		p = Page.Attachment_Viewer;
    		returnId = AttachmentTriggerMethods.attachAsPDF(p, testCase.Id, testCase.Id, 'testAttachment');
    		resultAtts = [select Id, ParentId, Name from Attachment where ParentId = :testCase.Id];
    	Test.stopTest();
    	
    	//Verify the results
    	system.assertEquals(resultAtts.size(),1);
    	system.assertEquals(resultAtts[0].Name,'testAttachment.pdf');
    }
  	
  	private static void setupUnprocessedLogs()
  	{
  		Case c1 = TestUtility.sampleCase();
  		insert c1;
  		Attachment att1 = TestUtility.sampleAttachment(c1.Id);
  		insert att1;
  		Process_Log__c pl = new Process_Log__c(
  			RecordId__c = att1.Id,
  			Status__c = 'Unprocessed',
  			Process__c = 'Portal Attachment Notification'
  		);
  		insert pl;
  	}
  	
  	private static testmethod void test_AttachmentNotifyScheduler_TestUnprocessedLogs()
  	{
  		setupUnprocessedLogs();
  		Test.startTest();
	        Map<Id,Process_Log__c> unProcessedLogs = new Map<Id,Process_Log__c>();
	        List<String> attachmentIds = new List<String>();
	        Map<Id,Process_Log__c> mapAttachmentToLog = new Map<Id,Process_Log__c>();
	        
	        AttchmntNotifySchedulr_ProcessLogUtils.queryUnprocessedLogsAndBuildMaps(unProcessedLogs, attachmentIds, mapAttachmentToLog);
	        
	        if (unProcessedLogs.keySet().size() > 0) {
	            AttachmentNotifyScheduler.doUnprocessedLogs(unProcessedLogs, attachmentIds, mapAttachmentToLog);
	        }
		Test.stopTest();
  	}
  	
  	private static testmethod void test_AttachmentNotifyScheduler()
  	{
  		
  		CronTrigger ctResult;
  		
  		Test.startTest();
  		
	  		//Schedule the test job
	  		String CRON_EXP = '0 0 0 3 9 ? 2022';
	  		String jobId = system.schedule('testScheduledApex', CRON_EXP, new AttachmentNotifyScheduler());
	  		
	  		//Get information from the CronTrigger API object
	  		ctResult = [select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
	  		
	  	Test.stopTest();
	  	
	  	//Verify the results
	  	//
	  	//Verify the expressions are the same
	  	system.assertEquals(CRON_EXP, ctResult.CronExpression);
	  	//Verify the job has not run
	  	system.assertEquals(0,ctResult.TimesTriggered);
	  	//Verify the next time the job will run	 	
	  	system.assertEquals('2022-09-03 00:00:00',String.valueOf(ctResult.NextFireTime));
	  	//system.assertNotEquals
  	}
  
  /*
     static testmethod void test() {
   Test.startTest();

      Account a = new Account();
      a.Name = 'testScheduledApexFromTestMethod';
      insert a;

   // Schedule the test job 
    

      String jobId = System.schedule('testBasicScheduledApex',
      TestScheduledApexFromTestMethod.CRON_EXP, 
         new TestScheduledApexFromTestMethod());
   // Get the information from the CronTrigger API object 
    

      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

   // Verify the expressions are the same 
    
      System.assertEquals(TestScheduledApexFromTestMethod.CRON_EXP, 
         ct.CronExpression);

   // Verify the job has not run 
    
      System.assertEquals(0, ct.TimesTriggered);

   // Verify the next time the job will run 
    
      System.assertEquals('2022-09-03 00:00:00', 
         String.valueOf(ct.NextFireTime));
      System.assertNotEquals('testScheduledApexFromTestMethodUpdated',
         [SELECT id, name FROM account WHERE id = :a.id].name);

   Test.stopTest();

   System.assertEquals('testScheduledApexFromTestMethodUpdated',
   [SELECT Id, Name FROM Account WHERE Id = :a.Id].Name);

   }
  */
  
  
}