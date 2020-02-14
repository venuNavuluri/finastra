@isTest
private class test_Attributes {

	static testmethod void test_InlineAccountAttributesController()
	{
		//Set up the test data
        Account testAcc = TestUtility.sampleAccount();
        testAcc.Account_Watch__c = true;
        testAcc.Tier__c = 'Global';
        testAcc.ReferenceSite__c = 'Yes';
        testAcc.Type = 'Customer';
        insert testAcc;

		//Run the test
		Test.startTest(); 
        PageReference pageRef = new PageReference('/' + testAcc.Id);
        Test.setCurrentPage(pageRef);
        InlineAccountAttributesController iaac = new InlineAccountAttributesController(new ApexPages.StandardController(testAcc));

        //Update values and refresh page
		testAcc.Type = 'Ex-Customer';
		update testAcc;
        pageRef = new PageReference('/' + testAcc.Id);
        Test.setCurrentPage(pageRef);
        iaac = new InlineAccountAttributesController(new ApexPages.StandardController(testAcc));
        
        //Update values and refresh page
        testAcc.Special_Support__c = true;
        update testAcc;
        pageRef = new PageReference('/' + testAcc.Id);
        Test.setCurrentPage(pageRef);
        iaac = new InlineAccountAttributesController(new ApexPages.StandardController(testAcc));
        
        //Update values and refresh page
        testAcc.Tier__c = 'Strategic';
        testAcc.Debtor_Account__c = true;
		testAcc.Type = 'Obsolete';
        update testAcc;
        pageRef = new PageReference('/' + testAcc.Id);
        Test.setCurrentPage(pageRef);
        iaac = new InlineAccountAttributesController(new ApexPages.StandardController(testAcc));
        	
        Test.stopTest();	
		
		//Verify results
		System.assertEquals(iaac.ShowAccountAtRisk,true);
		System.assertEquals(iaac.ShowStrategicAccount,true);
		System.assertEquals(iaac.ShowEndOfLife,true);
		System.assertEquals(iaac.ShowObsoleteCustomer,true);
	}

	static testmethod void test_InlineCaseAttributesController()
	{
		//Set up the test data
        Account testAcc = TestUtility.sampleAccount();
        testAcc.Account_Watch__c = true;
        testAcc.Tier__c = 'Global';
        testAcc.ReferenceSite__c = 'Yes';
        testAcc.Type = 'Customer';
        insert testAcc;
        Case testCase = TestUtility.sampleCase();
        testCase.AccountId = testAcc.Id;
        insert testCase;		
		
		//Run the test
		Test.startTest(); 
        PageReference pageRef = new PageReference('/' + testCase.Id);
        Test.setCurrentPage(pageRef);
        InlineCaseAttributesController icac = new InlineCaseAttributesController(new ApexPages.StandardController(testCase));

        //Update values and refresh page
		testAcc.Type = 'Ex-Customer';
		update testAcc;
        pageRef = new PageReference('/' + testCase.Id);
        Test.setCurrentPage(pageRef);
        icac = new InlineCaseAttributesController(new ApexPages.StandardController(testCase));
                
        //Update values and refresh page
        testAcc.Special_Support__c = true;
        update testAcc;
        pageRef = new PageReference('/' + testCase.Id);
        Test.setCurrentPage(pageRef);
        icac = new InlineCaseAttributesController(new ApexPages.StandardController(testCase));
                
        //Update values and refresh page
        testAcc.Tier__c = 'Strategic';
        testAcc.Debtor_Account__c = true;
		testAcc.Type = 'Obsolete';
        update testAcc;
        pageRef = new PageReference('/' + testCase.Id);
        Test.setCurrentPage(pageRef);
        icac = new InlineCaseAttributesController(new ApexPages.StandardController(testCase));
                	
        Test.stopTest();		
		
		//Verify results
		System.assertEquals(icac.ShowAccountAtRisk,true);
		System.assertEquals(icac.ShowStrategicAccount,true);
		System.assertEquals(icac.ShowEndOfLife,true);
		System.assertEquals(icac.ShowObsoleteCustomer,true);		
	}

}