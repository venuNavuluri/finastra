@isTest
private class test_CaseTriggerMethods {

	static testMethod void test_ChangedIssueCase()
	{
		//Set up test data with initial values
		User testUser = TestUtility.sampleUser();
		insert testUser;
		
		Case testCase = TestUtility.sampleCase();
		Case oldCase = TestUtility.sampleCase();
		testCase.RecordTypeId = Label.issue_case_id;
		oldCase.RecordTypeId = Label.issue_case_id;
		testCase.OwnerId = testUser.Id;
		oldCase.OwnerId = testUser.Id;
		testCase.CSFE_Parent_Status__c = 'Need Info';
		oldCase.CSFE_Parent_Status__c = 'Need Info';
		testCase.Case_Category__c = 'Support Request';
		oldCase.Case_Category__c = 'Support Request';
		testCase.SFDC_CSFE_Commentary__c = 'Place comments here';
		oldCase.SFDC_CSFE_Commentary__c = 'Place comments here';
		testCase.Replication_Steps__c = 'Error when I click Button 2';
		oldCase.Replication_Steps__c = 'Error when I click Button 2';
		testCase.Self_Service_Product__c = 'ALM Banking Test A';
		oldCase.Self_Service_Product__c = 'ALM Banking Test A';
		testCase.Product_Module__c = 'Almonde ALM';
		oldCase.Product_Module__c = 'Almonde ALM';
		testCase.Priority = 'Low';
		oldCase.Priority = 'Low';
		testCase.Product_Version__c = 'ALM 1.0';
		oldCase.Product_Version__c = 'ALM 1.0';
		testCase.Description = 'Longwinded description';
		oldCase.Description = 'Longwinded description';
		testCase.Subject = 'error ABC';
		oldCase.Subject = 'error ABC';
		testCase.Resolution_Type__c = 'Patch';
		oldCase.Resolution_Type__c = 'Patch';
		testCase.Resolution_Details__c = 'Please list details here';
		oldCase.Resolution_Details__c = 'Please list details here';
		insert testCase;
		insert oldCase;
		
		//Update the values for the test
		testCase.CSFE_Parent_Status__c = 'Confirmed';
		testCase.Case_Category__c = 'Defect';
		testCase.SFDC_CSFE_Commentary__c = 'Comments have been updated.';
		testCase.Replication_Steps__c = 'Stay away from Button 2!';
		testCase.Self_Service_Product__c = 'ALM Banking Test B';
		testCase.Product_Module__c = 'Almone B2';
		testCase.Priority = 'Medium';
		testCase.Product_Version__c = 'ALM 2.0';
		testCase.Description = 'concise description';
		testCase.Subject = 'Error ABC123';
		testCase.Resolution_Type__c = 'Service pack';
		testCase.Resolution_Details__c = 'Here are the resolution details';
		update testCase;
		
		//Initialize variable to capture results
		
		
		//Run the tests
		Test.startTest();
			system.debug('TEST STARTING');
			CaseTriggerMethods.ChangedIssueCase(oldCase,testCase);
			//update testCase;
			system.debug('TEST ENDING');
		Test.stopTest();
		
		//Verify the results
		
	}
	
	
	static testMethod void test_createTimeObjectForNewCase()
	{
		//include SetTimeObjectOnCase
		//run where no Time Object should be created (see exclusion list)
		
		//Set up test data
		Case testCustCase = TestUtility.sampleCase();
		testCustCase.RecordTypeId = Label.RecTypeId_Case_Sophis;
		Case testIssueCase = TestUtility.sampleIssueCase();
		
		//Initialize variable to capture results
		Map<Id,Case> caseResults;
		List<Id> caseIds = new List<Id>();
		
		//Run the tests
		Test.startTest();
			insert testCustCase;
			insert testIssueCase;
			caseIds.add(testCustCase.Id);
			caseIds.add(testIssueCase.Id);
			CaseTriggerMethods.CallWebServiceMethod(caseIds);
		Test.stopTest();
		
		//Verify the results
		caseResults = new Map<Id,Case>([select Id, Time_Object__c from Case where Id = :testCustCase.Id or Id = :testIssueCase.Id]);
		system.assertNotEquals(null,caseResults.get(testCustCase.Id).Time_Object__c);
		system.assertEquals(null,caseResults.get(testIssueCase.Id).Time_Object__c);
	}
	
	//Note that these may not ever be called if there is no Time Object....  Check code before writing test code
	
	static testMethod void test_TimeObjectUpdates()
	{
		//Check that the SOQL on line 1037 returns records
		//should be covered in test_TimeCalculator.  Its not... but it should be.
		
		//Set up test data
		Case testCustCase = TestUtility.sampleCase();
		testCustCase.RecordTypeId = Label.RecTypeId_Case_Sophis;
		testCustCase.Priority = 'Low';
		Case testIssueCase = TestUtility.sampleIssueCase();
		
		//Initialize variable to capture results
		Map<Id,Case> caseResults;
		List<Id> custCaseIds = new List<Id>();
		List<Id> issueCaseIds = new List<Id>();
		
		//Run the tests
		Test.startTest();
			insert testCustCase;
			custCaseIds.add(testCustCase.Id);
			CaseTriggerMethods.CallWebServiceMethod(custCaseIds);
			insert testIssueCase;
			issueCaseIds.add(testIssueCase.Id);
			CaseTriggerMethods.CallWebServiceMethod(issueCaseIds);
			testCustCase.Date_Time_Responded__c = system.now();
			testCustCase.Priority = 'High';
			update testCustCase;
		Test.stopTest();
		
		//Verify the results
		caseResults = new Map<Id,Case>([select Id, Time_Object__c from Case where Id = :testCustCase.Id or Id = :testIssueCase.Id]);
		
	}
	
	static testMethod void test_SetCaseOriginalOnPriorityChange()
	{
		//Not run because updatedCases sent to this seems to be empty?? (line 1061)
	}
	
	static testMethod void test_SetCaseWorkaroundTime()
	{
		//Not called in above test methods
	}
	
	static testMethod void test_SetCaseSolutionBreachTime()
	{
		//not covered starting line 1376 - pspHelper.getMapSLA != null
	}
	
		//Set up test data
		
		
		//Initialize variable to capture results
		
		
		//Run the tests
		
		
		//Verify the results
		
	
}