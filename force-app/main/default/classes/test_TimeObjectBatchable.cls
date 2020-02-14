@isTest
private class test_TimeObjectBatchable 
{
	public static testmethod void testTimeObjectBatchable_new2()
   	{
		//Set up the test data
        Account acc = TestUtility.sampleAccount();
        insert acc;
        SLA__c testSLA = TestUtility.sampleSLA();
		insert testSLA;
		Business_Hours_In_Use__c testBHIU = TestUtility.sampleBHIU(testSLA.Id);
		testBHIU.Account__c = acc.Id;
		insert testBHIU;
		Contact con = TestUtility.sampleContact();
		con.AccountId = acc.Id;
		insert con;
        RecordType rt = [select Id, Name from RecordType where sObjectType = 'Case' LIMIT 1];
        List<Case> tCases = new List<Case>();
        Case testCase;
        for(Integer i=0; i<30; i++)
        {
        	testCase = TestUtility.sampleCase();
        	testCase.Subject = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        	testCase.AccountId = acc.Id;
        	//testCase.AccountId = '001P000000HNRA2';
        	testCase.ContactId = con.Id;
        	//testCase.ContactId = '003P000000DvPzh';
        	testCase.RecordTypeId = rt.Id;
        	//testCase.Priority = 'Medium';
        	testCase.Severity__c = '2 - Medium';
        	tCases.add(testCase);     	
        }
		insert tCases;
		Set<Id> tCaseIds = new Set<Id>();
		for(Case c : tCases)
		{
			tCaseIds.add(c.Id);
		}
		List<Time_Object__c> tTimeObjects = [select Id, Process_Closed_Case__c, Case__c from Time_Object__c where Case__c in :tCaseIds];
		for(Time_Object__c tTO : tTimeObjects)
		{
			tTO.Process_Closed_Case__c = true;
		}
		update tTimeObjects;
		
		//Run the tests
		Test.startTest();
        //String str = 'where Subject = \'ABCDEFGHIJKLMNOPQRSTUVWXYZ\'';
        String strQuery = 'Select Id, Process_Me__c, AccountId, CreatedDate, ClosedDate, Time_Object__c, SLA__c, IsClosed, '
			+ 'Priority, Severity__c, Case_Category__c, Status, Category__c, Sub_status__c, Business_Hours_in_Use__c, '
			+ 'Business_Hours_in_Use__r.Business_Hours__c, Business_Hours_in_Use__r.Normal_Working_Day_Length__c, ' 
			+ 'Original_Priority__c, Original_SLA__c, Original_Business_Hours_in_Use__c, Workaround_Time_Stamp__c, '
			+ 'Original_Business_Hours_in_Use__r.Business_Hours__c, Original_Business_Hours_in_Use__r.Normal_Working_Day_Length__c '
			+ 'from Case where Time_Object__c != null and Subject = \'ABCDEFGHIJKLMNOPQRSTUVWXYZ\'';
        TimeObjectBatchable b = new TimeObjectBatchable(strQuery);
        Id testProcessId = database.executeBatch(b);
		Test.stopTest();
		
		//Verify the results
		AsyncApexJob testJob = [select Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors from AsyncApexJob where Id = :testProcessId];
		system.debug('testJob results: '+testJob);
		system.assertEquals(testJob.Status,'Completed');		
   	}
   	
    public static testmethod void test_TimeObjectSchedulerNotCritical()
    {
    	CronTrigger ctResult;
    	
    	Test.startTest();
        	//Schedule the test job
        	String times = '0 0 0 3 9 ? 2022';
        	String jobId = System.schedule('testJob1forNotCritical',times, new TimeObjectSchedulerNotCritical());
        	
        	//Get information from the CronTrigger API object
        	ctResult = [select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
        Test.stopTest();
    	
    	//Verify the results
    	
    		//Verify the expressions are the same
    		system.assertEquals(times, ctResult.CronExpression);
    		//Verify the job has not run
    		system.assertEquals(0,ctResult.TimesTriggered);
    		//Verify the next time the job will run
    		system.assertEquals('2022-09-03 00:00:00',String.valueOf(ctResult.NextFireTime));
    }    	
   	
    public static testmethod void test_TimeObjectSchedulerCritical()
    {
    	CronTrigger ctResult;
    	
    	Test.startTest();
        	//Schedule the test job
        	String times = '0 0 0 3 9 ? 2022';
        	String jobId = System.schedule('testJob1forCritical',times, new TimeObjectSchedulerCritical());
        	
        	//Get information from the CronTrigger API object
        	ctResult = [select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
        Test.stopTest();
    	
    	//Verify the results
    	
    		//Verify the expressions are the same
    		system.assertEquals(times, ctResult.CronExpression);
    		//Verify the job has not run
    		system.assertEquals(0,ctResult.TimesTriggered);
    		//Verify the next time the job will run
    		system.assertEquals('2022-09-03 00:00:00',String.valueOf(ctResult.NextFireTime));
    }      	
   	
   	/*
   	    public static testmethod void testTimeObjectSchedulerNotCritical()
    {
    	//Stop the currently scheduled jobs
		for(CronTrigger ct : [SELECT Id from CronTrigger where State != 'DELETED']){
			try{
				System.abortJob(ct.Id);
			}catch (Exception e){
        		System.debug('Caught error: '+e);
			}
        }
        Test.startTest();
        String times = '0 20 * * * ? *';
        String jobId = System.schedule('Run Job 1 for Critical',times, new TimeObjectSchedulerNotCritical());
        Test.stopTest();
        
        List<CronTrigger> resultCT = [select Id, State from CronTrigger where Id = :jobId];
        system.debug('testTimeObjectSchedulerNotCritical - result: '+resultCT);
        system.assertEquals(resultCT.size(),1);
    }   	
    */
   	
   	
   	/**********************************************************************************************************************************************
	//Run the test using existing data.  
	//This can be uncommented and used to troubleshoot the batch process without filling up the debug log by inserting new data
	
	public static testmethod void testTimeObjectBatchable_existingData()
   	{		
		//Run the tests
		Test.startTest();
        String strQuery = 'Select Id, Process_Me__c, AccountId, CreatedDate, ClosedDate, Time_Object__c, SLA__c, IsClosed, '
			+ 'Priority, Case_Category__c, Status, Category__c, Sub_status__c, Business_Hours_in_Use__c, '
			+ 'Business_Hours_in_Use__r.Business_Hours__c, Business_Hours_in_Use__r.Normal_Working_Day_Length__c, ' 
			+ 'Original_Priority__c, Original_SLA__c, Original_Business_Hours_in_Use__c, Workaround_Time_Stamp__c, '
			+ 'Original_Business_Hours_in_Use__r.Business_Hours__c, Original_Business_Hours_in_Use__r.Normal_Working_Day_Length__c '
			+ 'from Case where Time_Object__c != null and Process_Me__c = \'True\' and Priority != \'Critical\' Limit 150';
        TimeObjectBatchable b = new TimeObjectBatchable(str);
        Id testProcessId = database.executeBatch(b);
		Test.stopTest();
		
		//Verify the results
		AsyncApexJob testJob = [select Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors from AsyncApexJob where Id = :testProcessId];
		system.debug('testJob results: '+testJob);
		system.assertEquals(testJob.Status,'Completed');	
   	}   	
   	**********************************************************************************************************************************************/
/*

 	

    public static testmethod void testCallScheduler()
    {
    	//Stop the currently scheduled jobs
		for(CronTrigger ct : [SELECT Id from CronTrigger where State != 'DELETED']){
			try{
				System.abortJob(ct.Id);
			}catch (Exception e){
        		System.debug('Caught error: '+e);
			}
        }
    	
    	//Test running the jobs
    	CallScheduler.RunJob();
    	
        List<CronTrigger> resultCT = [select Id, State from CronTrigger where State != 'DELETED'];
        system.debug('testCallScheduler - result: '+resultCT);
        system.assert(resultCT.size()>1);    	
    }
  */  
}