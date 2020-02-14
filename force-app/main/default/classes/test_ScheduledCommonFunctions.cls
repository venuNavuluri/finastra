@isTest
private class test_ScheduledCommonFunctions {

	static testmethod void test_addProcessLog()
	{
		//set up test data
		//CommonFunctions.ProcessLog testLog = new CommonFunctions.ProcessLog();
		//testLog.ObjectName = 'Case';
		//testLog.Process = 'Test';
		//testLog.TypeCode = 'Apex Trigger';
		//testLog.UserId = UserInfo.getUserId();
		
		//Run the test
		//ScheduledCommonFunctions.addProcessLog(new CommonFunctions.ProcessLog[]{testLog});
		ScheduledCommonFunctions.addProcessLog('Case','Test','Apex Trigger');
		
		//Verify the results
		List<Process_Log__c> logs = [select Id, Name, Object__c from Process_Log__c where Object__c = 'Case' and Process__c = 'Test'];
		system.AssertEquals(logs.size(),1);
	}
	
	static testmethod void test_sendEmailErrorNotice()
	{
		//set up test data
		List<String> toAddr = new String[]{'test.user@foo.bar'};
		String testSubject = 'This is a test';
		String testMethodName = 'test_ScheduledCommonFunctions.test_sendEmailErrorNotice';
		
		
		//Run the test
		//Test.startTest();
			//generate an exception
			try{
				Integer i = 1/0;
			}catch(Exception e){
				System.debug('An error has occurred: '+e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
    			ScheduledCommonFunctions.sendEmailErrorNotice(toAddr,testSubject,testMethodName,e);
			}

	}
	
}