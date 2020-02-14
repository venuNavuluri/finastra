@isTest
private class test_CaseServices {

	static testmethod void testGetPriorityFromSeverity()
	{
		//Create values for the Case_Severity_Defaults__c custom setting
		List<Case_Severity_Defaults__c> lCSD = new List<Case_Severity_Defaults__c>();
		Case_Severity_Defaults__c csd1 = new Case_Severity_Defaults__c();
		csd1.ExternalId__c = csd1.Name = '1 - Critical';
		csd1.Priority__c = 'Critical';
		lCSD.add(csd1);
		Case_Severity_Defaults__c csd2 = new Case_Severity_Defaults__c();
		csd2.ExternalId__c = csd2.Name = '3 - Medium';
		csd2.Priority__c = 'Medium';
		lCSD.add(csd2);
		insert lCSD;
		
		String severity1 = '1 - Critical';		//to test valid value returned
		String severity2 = '2 - Weird';			//to test when value not in custom setting
		
		String result1 = null;
		String result2 = null;
		
		//Run the test
		Test.startTest();
			result1 = CaseServices.getPriorityFromSeverity(severity1);
			
			result2 = CaseServices.getPriorityFromSeverity(severity2);
		Test.stopTest();
		
		//Verify the results
		system.assertEquals('Critical',result1);
		system.assertEquals('2 - Weird',result2);
	}

	static testmethod void testGetSystemStatusFromEnvironment()
	{
		//Set up the test data
		String env1 = 'Production';
		String env2 = 'Altanta';
		String env3 = null;
		String env4 = 'Test';
		String env5 = 'Implementation';
		String env6 = 'Disaster Recovery';
		
		String result1 = null;
		String result2 = null;
		String result3 = null;
		String result4 = null;
		String result5 = null;
		String result6 = null;
		
		//Run the test
		Test.startTest();
			result1 = CaseServices.getSystemStatusFromEnvironment(env1);
			result2 = CaseServices.getSystemStatusFromEnvironment(env2);
			result3 = CaseServices.getSystemStatusFromEnvironment(env3);
			result4 = CaseServices.getSystemStatusFromEnvironment(env4);
			result5 = CaseServices.getSystemStatusFromEnvironment(env5);
			result6 = CaseServices.getSystemStatusFromEnvironment(env6);	
		Test.stopTest();
		
		//Verify the results
		system.assertEquals('Live',result1);
		system.assertEquals('Altanta',result2);
		system.assertEquals(null,result3);
		system.assertEquals('Test',result4);
		system.assertEquals('Implementation',result5);
		system.assertEquals('Disaster Recovery (DR)',result6);
	}

	static testmethod void testGetSeverityForPriority()
	{	
		//Set up test data
		String priority1 = 'Critical';
		String priority2 = 'High';
		String priority3 = 'Medium';
		String priority4 = 'Low';
		String priority5 = 'Steve';
		
		String result1 = null;
		String result2 = null;
		String result3 = null;
		String result4 = null;
		String result5 = null;
		
		//Run the test
		Test.startTest();
			result1 = CaseServices.getSeverityForPriority(priority1);
			result2 = CaseServices.getSeverityForPriority(priority2);
			result3 = CaseServices.getSeverityForPriority(priority3);
			result4 = CaseServices.getSeverityForPriority(priority4);
			result5 = CaseServices.getSeverityForPriority(priority5);
		Test.stopTest();
		
		//Verify the results
		system.assertEquals('1 - Critical',result1);
		system.assertEquals('2 - High',result2);
		system.assertEquals('3 - Medium',result3);
		system.assertEquals('4 - Low',result4);
		system.assertEquals('Steve',result5);
	}
	
	static testmethod void testCaseSurveyContactUpdate()
	{
		//Set up test data
		//List<Contact> testContacts = new Contact[2];
		//List<Case> testCases = new Case[2];
		
		Account Acc = TestUtility.sampleAccount();
		insert Acc;
		
		Product_Set__c testPS1 = TestUtility.sampleProductSet(acc.Id);
		testPS1.Name = 'Product Set 1';
		insert testPS1;
		
		Contact Con1_NoSurveySent = TestUtility.sampleContact();
		Con1_NoSurveySent.AccountId = Acc.Id;
		insert Con1_NoSurveySent;
		//testContacts[1] = Con1_NoSurveySent;
		/*
		Contact Con2_OneSurveySent = TestUtility.sampleContact();
		Con2_OneSurveySent.Account = Acc.Id;
		Con2_OneSurveySent.CaseSurveyDate = Date.today();
		testContacts[2] = Con2_OneSurveySent;
		Contact Con3_MaxSurveysSent = TestUtility.sampleContact();
		Con3_MaxSurveysSent.Account = Acc.Id;
		Con2_OneSurveySent.CaseSurveyDate = Date.today();
		testContacts[3] = Con3_MaxSurveysSent;
		*/
		
		//insert testContacts;
		//Con1_NoSurveySent = testContacts[1];
		/*Con2_OneSurveySent = testContacts[2];
		Con3_MaxSurveysSent = testContacts[3]; */
		
		Case testCase1 = TestUtility.sampleCase();
		testCase1.AccountId = Acc.Id;
		testCase1.ContactId = Con1_NoSurveySent.Id;
		testCase1.Product_Set__c = testPS1.Id;
		//testCases[1] = testCase1;
		insert testCase1;
		/*
		Case testCase2 = TestUtility.sampleCase();
		testCase2.Account = Acc.Id;
		testCase2.Contact = Con2_OneSurveySent.Id;
		testCases[2] = testCase2;
		Case testCase3 = TestUtility.sampleCase();
		testCase3.Account = Acc.Id;
		testCase3.Contact = Con3_MaxSurveysSent.Id;
		testCases[3] = testCase3;  */
		
		//insert testCases;
		//testCase1 = testCases[1];
		//testCase2 = testCases[2];
		//testCase3 = testCases[3];
		
		//Run the test
		Test.startTest();
			//Update Contact3 twice to max out the surveys sent
			//Con3_MaxSurveysSent.CaseSurveyDate = Date.today();
			//update Con3_MaxSurveysSent;
			//Con3_MaxSurveysSent.CaseSurveyDate = Date.today();
			//update Con3_MaxSurveysSent;
			
			//Set the SurveySent flag on the Case for each
			testCase1.CaseSurveySent__c = true;
			//testCases[2].CaseSurveySent = true;
			update testCase1;
		
		Test.stopTest();
		
		//Verify results
		Case resultCase = [select Id, CaseSurveySent__c from Case where Id = :testCase1.Id];
		Contact resultContact = [select Id, CaseSurveyDate__c, CaseSurveyCounter__c, CaseSurveyAllow__c from Contact where Id = :Con1_NoSurveySent.Id];
		
		system.assertEquals(true,resultCase.CaseSurveySent__c);
		system.assertEquals(date.today(),resultContact.CaseSurveyDate__c);
		system.assertEquals('1',resultContact.CaseSurveyCounter__c.right(1));
		system.assertEquals('FALSE',resultContact.CaseSurveyAllow__c);    //This should now be false since the above action mocked an email being sent today
	}
	
	static testmethod void testCSCaseManager()
	{
		//Set up test data
		//----------------
		Account acc = TestUtility.sampleAccount();
		insert acc;
		
		User testUser1 = TestUtility.sampleUser();
		testUser1.LastName = 'User1';
		testUser1.FirstName = 'Test';
		insert testUser1;
		
		User testUser2 = TestUtility.sampleUser();
		testUser2.LastName = 'User2';
		testUser2.FirstName = 'Test';
		insert testUser2;
		
		Product_Set__c testPS1 = TestUtility.sampleProductSet(acc.Id);
		testPS1.Name = 'Product Set 1';
		testPS1.Customer_Advocate__c = testUser1.Id;
		insert testPS1;
		
		Product_Set__c testPS2 = TestUtility.sampleProductSet(acc.Id);
		testPS2.Name = 'Product Set 2';
		testPS2.Customer_Advocate__c = testUser2.Id;
		insert testPS2;
		
		Product_Set__c testPS3 = TestUtility.sampleProductSet(acc.Id);
		testPS3.Name = 'Product Set 3';
		insert testPS3;		
		
		//scenario 1: New case entered
		Case case1 = TestUtility.sampleCase();
		case1.AccountId = acc.Id;
		case1.recordtypeid = '0122000000000wNAAQ';
		case1.Product_Set__c = testPS1.Id;
		
		//scenario 2: case Product Set changed
		Case case2 = TestUtility.sampleCase();
		case2.AccountId = acc.Id;
		case2.recordtypeid = '0122000000000wNAAQ';
		case2.Product_Set__c = testPS1.Id;
		insert case2;
		
		//scenario 3: CS Case Manager manually changed, then Product Set changed
		Case case3 = TestUtility.sampleCase();
		case3.AccountId = acc.Id;
		case3.recordtypeid = '0122000000000wNAAQ';
		case3.Product_Set__c = testPS1.Id;
		insert case3;
		case3.CS_Case_Manager__c = UserInfo.getUserName();
		update case3;
		
		//scenario 4: Case with no Product Set defined
		Case case4 = TestUtility.sampleCase();
		case4.AccountId = acc.Id;
		case4.recordtypeid = '0122000000000wNAAQ';
		
		//scenario 5: Case with Product Set with no Customer Advocate defined
		Case case5 = TestUtility.sampleCase();
		case5.AccountId = acc.Id;
		case5.recordtypeid = '0122000000000wNAAQ';
		insert case5;
		
		//Set up the structures to capture results
		Case resultCase1;
		Case resultCase2;
		Case resultCase3;
		Case resultCase4;
		Case resultCase5;
		 
		//Run the test
		Test.startTest();
			//scenario 1: New case entered
			insert case1;
			resultCase1 = [select Id, CS_Case_Manager__c from Case where Id = :case1.Id];
		
			//scenario 2: Case Product Set changed
			case2.Product_Set__c = testPS2.Id;
			update case2;
			resultCase2 = [select Id, CS_Case_Manager__c from Case where Id = :case2.Id];
		
			//scenario 3: CS Case Manager manually changed, then Product Set changed
			case3.Product_Set__c = testPS2.Id;
			update case3;
			resultCase3 = [select Id, CS_Case_Manager__c from Case where Id = :case3.Id];
			
			//scenario 4: Case with no Product Set defined
			insert case4;
			resultCase4 = [select Id, CS_Case_Manager__c from Case where Id = :case4.Id];
			
			//scenario 5: Case with Product Set with no Customer Advocate defined
			case5.Product_Set__c = testPS3.Id;
			update case5;
			resultCase5 = [select Id, CS_Case_Manager__c from Case where Id = :case5.Id];
			
		Test.stopTest();
		
		//Verify the results
		//------------------
		
		//scenario 1: New case entered
		system.assertEquals('Test User1',resultCase1.CS_Case_Manager__c);
		
		//scenario 2: Case Product Set changed
		system.assertEquals('Test User2',resultCase2.CS_Case_Manager__c);
		
		//scenario 3: CS Case Manager manually changed, then Product Set changed
		system.assertEquals(UserInfo.getUserName(),resultCase3.CS_Case_Manager__c);
		
		//scenario 4: case type which always uses a default CS Case Manager value
		system.assertEquals(Label.CaseManager_NoProductSet,resultCase4.CS_Case_Manager__c);
		
		//scenario 5: Case with Product Set with no Customer Advocate defined
		system.assertEquals(Label.CaseManager_NoCustomerAdvocate,resultCase5.CS_Case_Manager__c);
	}
	
}