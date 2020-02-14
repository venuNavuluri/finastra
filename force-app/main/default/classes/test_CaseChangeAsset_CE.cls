@isTest
private class test_CaseChangeAsset_CE {

	static testmethod void test_CaseChangeAsset_Simple()
	{
		//Set up test data
		Account mainAccount = TestUtility.sampleAccount();
		mainAccount.Name = 'Main Account';
		mainAccount.Type = 'Customer';
		insert mainAccount;

		Contact supportContact = TestUtility.sampleContact();
		supportContact.AccountId = mainAccount.Id;
		supportContact.Inactive_Contact__c = false;
		insert supportContact;
		
		Case testCase = TestUtility.sampleCase();
		testCase.AccountId = mainAccount.Id;
		testCase.ContactId = supportContact.Id;
		insert testCase;
		
		System__c testSystem1 = new System__c();
		testSystem1.Account__c = mainAccount.Id;
		testSystem1.Environment2__c = 'PROD';
		testSystem1.Name = 'TS1';
		insert testSystem1;
		
		//CCRT__c mainCCRT = new CCRT__c();
		//mainCCRT.Account__c = mainAccount.Id;
		//insert mainCCRT;
		
		//CCRT__c supportCCRT = new CCRT__c();
		//supportCCRT.Account__c = supportAccount.Id;
		//insert supportCCRT;
		
		Product_Set__c testPS1 = new Product_Set__c();
		testPS1.Account__c = mainAccount.Id;
		testPS1.Business_Group__c = 'BG1';
		testPS1.Production__c = true;
		insert testPS1;
		
		Entitlement__c testEnt1 = new Entitlement__c();
		testEnt1.Account__c = mainAccount.Id;
		testEnt1.Product_Set__c = testPS1.Id;
		testEnt1.System__c = testSystem1.Id;
		testEnt1.Status__c = 'Active';
		insert testEnt1;
		
		Client_Asset__c testCA1 = new Client_Asset__c();
		testCA1.Product_Set__c = testPS1.Id;
		testCA1.Account__c = mainAccount.Id;
		insert testCA1;
		
		Contract_Asset__c testTA1 = new Contract_Asset__c();
		testTA1.Client_Asset__c = testCA1.Id;
		testTA1.System__c = testSystem1.Id;
		testTA1.Account__c = mainAccount.Id;
		insert testTA1;
		
		//Location_of_Use__c testLOU1 = new Location_of_Use__c();
		//testLOU1.CCRT__c = supportCCRT.Id;
		//testLOU1.System__c = testSystem1.Id;
		//testLOU1.Contract_Asset__c = testTA1.Id;
		//insert testLOU1;		

		List<Constants__c> custSettings = TestUtility.loadConstants();
		insert custSettings;
		
		string resultProductSetChosen;
		string resultSystemChosen;
		string resultEntitlementChosen;
		string resultClientAssetChosen;
						
		//Run the tests
		Test.startTest();
			PageReference testPR1 = Page.CaseChangeAsset;
			testPR1.getParameters().put('id',testCase.Id);
			Test.setCurrentPage(testPR1);
			
			//Instantiate the controller and capture the account and contact selected to verify later.
			ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(testCase);
			CaseChangeAsset_CE cont = new CaseChangeAsset_CE(std);
			resultProductSetChosen = cont.productSetChosen;
			cont.productSetSelected();
			cont.saveChange();
			resultSystemChosen = testCase.System__c;
			resultEntitlementChosen = testCase.Support_Entitlement__c;
		Test.stopTest();
		
		//Verify the results
		system.assertEquals(testPS1.Id,resultProductSetChosen);
		system.assertEquals(testSystem1.Id,resultSystemChosen);
		system.assertEquals(testEnt1.Id,resultEntitlementChosen);
	}

	static testmethod void test_CaseChangeAsset_LocationOfUse()
	{
		//Set up test data
		Account mainAccount = TestUtility.sampleAccount();
		mainAccount.Name = 'Main Account';
		mainAccount.Type = 'Customer';
		insert mainAccount;
		
		Account supportAccount = TestUtility.sampleAccount();
		supportAccount.Name = 'Support Account';
		supportAccount.Type = 'Customer';
		insert supportAccount;

		Contact supportContact = TestUtility.sampleContact();
		supportContact.AccountId = supportAccount.Id;
		supportContact.Inactive_Contact__c = false;
		insert supportContact;
		
		Case testCase = TestUtility.sampleCase();
		testCase.AccountId = supportAccount.Id;
		testCase.ContactId = supportContact.Id;
		insert testCase;
		
		System__c testSystem1 = new System__c();
		testSystem1.Account__c = mainAccount.Id;
		testSystem1.Environment2__c = 'PROD';
		testSystem1.Name = 'TS1';
		insert testSystem1;
		
		CCRT__c mainCCRT = new CCRT__c();
		mainCCRT.Account__c = mainAccount.Id;
		mainCCRT.Client_Site_Number__c = '1234567';
		insert mainCCRT;
		
		CCRT__c supportCCRT = new CCRT__c();
		supportCCRT.Account__c = supportAccount.Id;
		supportCCRT.Client_Site_Number__c = '7654321';
		insert supportCCRT;
		
		Product_Set__c testPS1 = new Product_Set__c();
		testPS1.Account__c = mainAccount.Id;
		testPS1.Business_Group__c = 'BG1';
		testPS1.Production__c = true;
		insert testPS1;
		
		Entitlement__c testEnt1 = new Entitlement__c();
		testEnt1.Account__c = mainAccount.Id;
		testEnt1.Product_Set__c = testPS1.Id;
		testEnt1.System__c = testSystem1.Id;
		testEnt1.Status__c = 'Active';
		insert testEnt1;
		
		Client_Asset__c testCA1 = new Client_Asset__c();
		testCA1.Product_Set__c = testPS1.Id;
		testCA1.Account__c = mainAccount.Id;
		insert testCA1;
		
		Contract_Asset__c testTA1 = new Contract_Asset__c();
		testTA1.Client_Asset__c = testCA1.Id;
		testTA1.System__c = testSystem1.Id;
		testTA1.Account__c = mainAccount.Id;
		insert testTA1;
		
		Location_of_Use__c testLOU1 = new Location_of_Use__c();
		testLOU1.CCRT__c = supportCCRT.Id;
		testLOU1.Contract_Asset__c = testTA1.Id;
		insert testLOU1;		

		List<Constants__c> custSettings = TestUtility.loadConstants();
		insert custSettings;
		
		string resultProductSetChosen;
		string resultSystemChosen;
		string resultEntitlementChosen;
		string resultClientAssetChosen;
						
		//Run the tests
		Test.startTest();
			PageReference testPR1 = Page.CaseChangeAsset;
			testPR1.getParameters().put('id',testCase.Id);
			Test.setCurrentPage(testPR1);
			
			//Instantiate the controller and capture the account and contact selected to verify later.
			ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(testCase);
			CaseChangeAsset_CE cont = new CaseChangeAsset_CE(std);
			resultProductSetChosen = cont.productSetChosen;
			cont.productSetSelected();
			cont.saveChange();
			resultSystemChosen = cont.customerCase.System__c;
			resultEntitlementChosen = cont.customerCase.Support_Entitlement__c;
		Test.stopTest();
		
		//Verify the results
		system.assertEquals(testPS1.Id,resultProductSetChosen);
		system.assertEquals(testSystem1.Id,resultSystemChosen);
		system.assertEquals(testEnt1.Id,resultEntitlementChosen);
	}

}