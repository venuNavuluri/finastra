@isTest
private class test_OppContractCreateAttach_CE {

	public static testmethod void testAttachNewContract()
	{
		//Set up test data
		Account testAcc = TestUtility.sampleAccount();
		insert testAcc;
		Opportunity testOpp = TestUtility.sampleOpportunity(testAcc);
		insert testOpp;
		
		PageReference resultPR1;
		
		
		//Run the test
		Test.startTest();
			ApexPages.Standardcontroller std = new ApexPages.StandardController(testOpp);
			OppContractCreateAttach_CE myOpp = new OppContractCreateAttach_CE(std);
			
			resultPR1 = myOpp.CreateAttachContract();
			system.debug('test_OppContractCreateAttach.testAttachNewContract resultPR1:'+resultPR1);
		
			Contract tmpContract = [select Id, RecordTypeId from Contract where Misys_Opportunity__c = :testOpp.Id];
		Test.stopTest();
		
		//Verify the results
		system.debug('new COntract rec type:'+tmpContract.RecordTypeId);
		system.assert(resultPR1.getURL().contains('attach/NoteAttach'));
		
	}

	public static testmethod void testAttachExistingContract()
	{
		//Set up test data
		Account testAcc = TestUtility.sampleAccount();
		insert testAcc;
		Opportunity testOpp = TestUtility.sampleOpportunity(testAcc);
		insert testOpp;
		Contract testCont = TestUtility.sampleContract(testAcc.Id);
		testCont.Misys_Opportunity__c = testOpp.Id;
		insert testCont;
		
		PageReference resultPR1;
		
		
		//Run the test
		Test.startTest();
			ApexPages.Standardcontroller std = new ApexPages.StandardController(testOpp);
			OppContractCreateAttach_CE myOpp = new OppContractCreateAttach_CE(std);
			
			resultPR1 = myOpp.CreateAttachContract();
			system.debug('test_OppContractCreateAttach.testAttachNewContract resultPR1:'+resultPR1);
		
		Test.stopTest();
		
		//Verify the results
		system.assert(resultPR1.getURL().contains('attach/NoteAttach'));
		//Verify the URL contains the pre-existing contract, so we are sure it is attaching the file to the correct contract
		system.assert(resultPR1.getURL().contains(testCont.Id));
	}

	public static testmethod void testAttachMultipleContracts()
	{
		//Set up test data
		Account testAcc = TestUtility.sampleAccount();
		insert testAcc;
		Opportunity testOpp = TestUtility.sampleOpportunity(testAcc);
		insert testOpp;
		Contract testCont = TestUtility.sampleContract(testAcc.Id);
		testCont.Misys_Opportunity__c = testOpp.Id;
		insert testCont;
		Contract testCont2 = TestUtility.sampleContract(testAcc.Id);
		testCont2.Misys_Opportunity__c = testOpp.Id;
		insert testCont2;
		
		PageReference resultPR1;
		
		//Run the test
		Test.startTest();
			
			ApexPages.Standardcontroller std = new ApexPages.StandardController(testOpp);
			OppContractCreateAttach_CE myOpp = new OppContractCreateAttach_CE(std);
			
			resultPR1 = myOpp.CreateAttachContract();
			system.debug('test_OppContractCreateAttach.testAttachNewContract resultPR1:'+resultPR1);
		
		Test.stopTest();
		
		//Verify the results
		//Verify the page reference returned is null, meaning there was an error becuase more than 1 contract was found.
		system.assertEquals(null,resultPR1);
		
	}

}