@isTest
private class test_CaseMetrics {

	static testmethod void testNewCase()
	{
		//Set up test data
		Account testAcct = TestUtility.sampleAccount();
		insert testAcct;
        SLA__c testSLA = TestUtility.sampleSLA();
		insert testSLA;
		Business_Hours_In_Use__c testBHIU = TestUtility.sampleBHIU(testSLA.Id);
		testBHIU.Account__c = testAcct.Id;
		insert testBHIU;		
		Contact testContact = TestUtility.sampleContact();
		testContact.AccountId = testAcct.Id;
		insert testContact;
		Case testCase1 = TestUtility.sampleCase();
		testCase1.AccountId = testAcct.Id;
		testCase1.ContactId = testContact.Id;
		testCase1.Status = Constants__c.getInstance('STATUS_NEW').Value__c;
		testCase1.RecordTypeId = Constants__c.getInstance('DEFAULT_CASE_RECORDTYPE_ID').Value__c;
		testCase1.Severity__c = Constants__c.getInstance('DEFAULT_SEVERITY').Value__c;
		testCase1.Urgency__c = Constants__c.getInstance('DEFAULT_URGENCY').Value__c;
		
		//Run the tests
		Test.startTest();
			insert testCase1; 
		Test.stopTest();
				
		//Verify the results
		Case resultCase1 = [select id, Status, Severity__c, Priority, Urgency__c, SLA__c, Time_Object__c, PSP2_Calculations_Last_Updated__c,
							Time_in_L1_hrs__c, Time_in_L2_hrs__c, Time_in_L3_hrs__c, Misys_Resolution_Time_PSP2__c, Misys_Solution_Time_PSP2__c
							from Case where Id = :testCase1.Id];
		system.assertNotEquals(null,resultCase1.PSP2_Calculations_Last_Updated__c);
	} 

	static testmethod void testL1Case()
	{
		//Set up test data
		Account testAcct = TestUtility.sampleAccount();
		insert testAcct;
        SLA__c testSLA = TestUtility.sampleSLA();
		insert testSLA;
		Business_Hours_In_Use__c testBHIU = TestUtility.sampleBHIU(testSLA.Id);
		testBHIU.Account__c = testAcct.Id;
		insert testBHIU;		
		Contact testContact = TestUtility.sampleContact();
		testContact.AccountId = testAcct.Id;
		insert testContact;
		Case testCase1 = TestUtility.sampleCase();
		testCase1.AccountId = testAcct.Id;
		testCase1.ContactId = testContact.Id;
		testCase1.Status = Constants__c.getInstance('STATUS_NEW').Value__c;
		testCase1.RecordTypeId = Constants__c.getInstance('DEFAULT_CASE_RECORDTYPE_ID').Value__c;
		testCase1.Severity__c = Constants__c.getInstance('DEFAULT_SEVERITY').Value__c;
		testCase1.Urgency__c = Constants__c.getInstance('DEFAULT_URGENCY').Value__c;
		
		//Run the tests
		Test.startTest();
			insert testCase1; 
			testCase1.Status = 'Assigned';
			update testCase1;		
		Test.stopTest();
		
		//Verify the results
		Case resultCase2 = [select id, Status, Severity__c, Priority, Urgency__c, SLA__c, Time_Object__c, PSP2_Calculations_Last_Updated__c, SLA2_Solution_Target_Time__c,
							Time_in_L1_hrs__c, Time_in_L2_hrs__c, Time_in_L3_hrs__c, Misys_Resolution_Time_PSP2__c, Misys_Solution_Time_PSP2__c
							from Case where Id = :testCase1.Id];
		system.assertNotEquals(null,resultCase2.SLA2_Solution_Target_Time__c);
	} 	
	
	static testmethod void testL2Case()
	{
		//Set up test data
		Account testAcct = TestUtility.sampleAccount();
		insert testAcct;
        SLA__c testSLA = TestUtility.sampleSLA();
		insert testSLA;
		Business_Hours_In_Use__c testBHIU = TestUtility.sampleBHIU(testSLA.Id);
		testBHIU.Account__c = testAcct.Id;
		insert testBHIU;		
		Contact testContact = TestUtility.sampleContact();
		testContact.AccountId = testAcct.Id;
		insert testContact;
		Case testCase1 = TestUtility.sampleCase();
		testCase1.AccountId = testAcct.Id;
		testCase1.ContactId = testContact.Id;
		testCase1.Status = Constants__c.getInstance('STATUS_NEW').Value__c;
		testCase1.RecordTypeId = Constants__c.getInstance('DEFAULT_CASE_RECORDTYPE_ID').Value__c;
		testCase1.Severity__c = Constants__c.getInstance('DEFAULT_SEVERITY').Value__c;
		testCase1.Urgency__c = Constants__c.getInstance('DEFAULT_URGENCY').Value__c;
		
		//Run the tests
		Test.startTest();
			insert testCase1; 	
			testCase1.Status = 'In Progress';
			testCase1.Sub_Status__c = 'CS';
			update testCase1;
		Test.stopTest();
		
		//Verify the results
		Case resultCase3 = [select id, Status, Severity__c, Priority, Urgency__c, SLA__c, Time_Object__c, PSP2_Calculations_Last_Updated__c,
								Time_in_L1_hrs__c, Time_in_L2_hrs__c, Time_in_L3_hrs__c, Misys_Resolution_Time_PSP2__c, Misys_Solution_Time_PSP2__c
								from Case where Id = :testCase1.Id];
		system.assertNotEquals(null,resultCase3.Time_in_L2_hrs__c);
	}

	static testmethod void testL3Case()
	{
		//Set up test data
		Account testAcct = TestUtility.sampleAccount();
		insert testAcct;
        SLA__c testSLA = TestUtility.sampleSLA();
		insert testSLA;
		Business_Hours_In_Use__c testBHIU = TestUtility.sampleBHIU(testSLA.Id);
		testBHIU.Account__c = testAcct.Id;
		insert testBHIU;		
		Contact testContact = TestUtility.sampleContact();
		testContact.AccountId = testAcct.Id;
		insert testContact;
		Case testCase1 = TestUtility.sampleCase();
		testCase1.AccountId = testAcct.Id;
		testCase1.ContactId = testContact.Id;
		testCase1.Status = Constants__c.getInstance('STATUS_NEW').Value__c;
		testCase1.RecordTypeId = Constants__c.getInstance('DEFAULT_CASE_RECORDTYPE_ID').Value__c;
		testCase1.Severity__c = Constants__c.getInstance('DEFAULT_SEVERITY').Value__c;
		testCase1.Urgency__c = Constants__c.getInstance('DEFAULT_URGENCY').Value__c;
		
		//Run the tests
		Test.startTest();
			insert testCase1; 								
			testCase1.Status = 'In Progress';
			testCase1.Sub_Status__c = 'Development';
			update testCase1;
		Test.stopTest();
		
		//Verify the results
		Case resultCase4 = [select id, Status, Severity__c, Priority, Urgency__c, SLA__c, Time_Object__c, PSP2_Calculations_Last_Updated__c,
							Time_in_L1_hrs__c, Time_in_L2_hrs__c, Time_in_L3_hrs__c, Misys_Resolution_Time_PSP2__c, Misys_Solution_Time_PSP2__c
							from Case where Id = :testCase1.Id];

		system.assert(resultCase4.Time_in_L2_hrs__c >= 0);
	} 	
	
	static testmethod void testClosedCase()
	{
		//Set up test data
		Account testAcct = TestUtility.sampleAccount();
		insert testAcct;
        SLA__c testSLA = TestUtility.sampleSLA();
		insert testSLA;
		Business_Hours_In_Use__c testBHIU = TestUtility.sampleBHIU(testSLA.Id);
		testBHIU.Account__c = testAcct.Id;
		insert testBHIU;		
		Contact testContact = TestUtility.sampleContact();
		testContact.AccountId = testAcct.Id;
		insert testContact;
		Case testCase1 = TestUtility.sampleCase();
		testCase1.AccountId = testAcct.Id;
		testCase1.ContactId = testContact.Id;
		testCase1.Status = Constants__c.getInstance('STATUS_NEW').Value__c;
		testCase1.RecordTypeId = Constants__c.getInstance('DEFAULT_CASE_RECORDTYPE_ID').Value__c;
		testCase1.Severity__c = Constants__c.getInstance('DEFAULT_SEVERITY').Value__c;
		testCase1.Urgency__c = Constants__c.getInstance('DEFAULT_URGENCY').Value__c;
		
		//Run the tests
		Test.startTest();
			insert testCase1; 
			testCase1.Status = 'Closed';
			testCase1.Sub_Status__c = 'Client Confirmed';
			update testCase1;		
		Test.stopTest();
		
		//Verify the results
		Case resultCase5 = [select id, Status, Severity__c, Priority, Urgency__c, SLA__c, Time_Object__c, PSP2_Calculations_Last_Updated__c,
							Time_in_L1_hrs__c, Time_in_L2_hrs__c, Time_in_L3_hrs__c, Misys_Resolution_Time_PSP2__c, Misys_Solution_Time_PSP2__c
							from Case where Id = :testCase1.Id];
		system.assertNotEquals(null,resultCase5.Misys_Resolution_Time_PSP2__c);
	} 	 	
	
	static testmethod void testCase_InvalidStatus()
	{
		//Set up test data
		Account testAcct = TestUtility.sampleAccount();
		insert testAcct;
        SLA__c testSLA = TestUtility.sampleSLA();
		insert testSLA;
		Business_Hours_In_Use__c testBHIU = TestUtility.sampleBHIU(testSLA.Id);
		testBHIU.Account__c = testAcct.Id;
		insert testBHIU;		
		Contact testContact = TestUtility.sampleContact();
		testContact.AccountId = testAcct.Id;
		insert testContact;
		Case testCase1 = TestUtility.sampleCase();
		testCase1.AccountId = testAcct.Id;
		testCase1.ContactId = testContact.Id;
		testCase1.Status = Constants__c.getInstance('STATUS_NEW').Value__c;
		testCase1.RecordTypeId = Constants__c.getInstance('DEFAULT_CASE_RECORDTYPE_ID').Value__c;
		testCase1.Severity__c = Constants__c.getInstance('DEFAULT_SEVERITY').Value__c;
		testCase1.Urgency__c = Constants__c.getInstance('DEFAULT_URGENCY').Value__c;
		
		//Run the tests
		Test.startTest();
			insert testCase1; 								
			testCase1.Status = 'In Prog';
			testCase1.Sub_Status__c = 'Crazy';
			update testCase1;
		Test.stopTest();
		
		//Verify the results
		Case resultCase4 = [select id, Status, Severity__c, Priority, Urgency__c, SLA__c, Time_Object__c, PSP2_Calculations_Last_Updated__c,
							Time_in_L1_hrs__c, Time_in_L2_hrs__c, Time_in_L3_hrs__c, Misys_Resolution_Time_PSP2__c, Misys_Solution_Time_PSP2__c
							from Case where Id = :testCase1.Id];

		system.assert(resultCase4.Time_in_L2_hrs__c >= 0);
	}	
	 	
}