@isTest
private class test_AddChangeRequestToParent {
/*
	class Test_Exception extends Exception {}
	static testmethod void test_CopyOLIs()
	{
		//Set up test data
		Opportunity testParentOpp = TestUtility.sampleOpportunity();
		testParentOpp.Approval_Status__c = 'APPROVED';
		testParentOpp.StageName = 'Suspect';
		testParentOpp.Client_Signed_contract_attached__c = true;
		testParentOpp.Is_PearlMastered__c = true;
		testParentOpp.Contractual_Billing_Address__c = 'blah';
		testParentOpp.Contractual_Shipping_Address__c = 'more blah';
		insert testParentOpp;
		
		Opportunity testCRopp = TestUtility.sampleOpportunity();
		testCRopp.RecordTypeId = Label.RecType_Opportunity_ChangeReq;
		testCRopp.StageName = 'Suspect';
		testCRopp.Approval_Status__c = 'APPROVED';
		testCRopp.Client_Signed_contract_attached__c =  true;
		testCRopp.Is_PearlMastered__c = true;
		//testCRopp.OLIs_Pushed_To_Parent__c = true;
		testCRopp.OLIs_Pushed_To_Parent__c = false;
		testCRopp.Original_Opportunity__c = testParentOpp.Id;
		testCRopp.Contractual_Billing_Address__c = 'blah';
		testCRopp.Contractual_Shipping_Address__c = 'more blah';
		insert testCRopp;
		
		Product2 testProd = TestUtility.sampleProduct();
		testProd.Family = 'PS';
		testProd.Type__c = 'PS Product';
		insert testProd;
		
		Pricebook2 Pricebook = [select id from pricebook2 where IsStandard =: true];
    	
    	PricebookEntry pbe = new PricebookEntry(UnitPrice=1000.00,CurrencyIsoCode='GBP',Pricebook2Id=Pricebook.Id,Product2Id=testProd.Id,IsActive=true);
    	insert pbe;    	
		
		integer numOLIs = 5;
		list<OpportunityLineItem> listCRproducts = new OpportunityLineItem[numOLIs];
		for(integer x=0;x<numOLIs;x++)
		{
			//OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem(testCRopp,'PS (B)');
			OpportunityLineItem oli = new OpportunityLineItem();
			oli.OpportunityId = testCRopp.Id;
			oli.PricebookEntryId = pbe.Id;
			oli.UnitPrice = pbe.UnitPrice;
			oli.Quantity = 1;
			//oli.TotalPrice = 10;
			listCRproducts[x] = oli;
		}
		insert listCRproducts;
		
		PageReference prResult1;
		
		//Run the test
		Test.startTest();
			//Set the current page to the CR Opp
			//PageReference p1 = Page.AddChangeRequestToParent;
			//p1.getParameters().put('id',testCRopp.Id);
			//Test.setCurrentPage(p1);
			
			//Instantiate the controller and run through the scenario
			ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(testCROpp);
			AddChangeRequestToParent_CE acr = new AddChangeRequestToParent_CE(std);
			prResult1 = acr.CopyOLIs();
			testCRopp.Original_Opportunity__c = testParentOpp.Id;
			update testCRopp;
			acr = new AddChangeRequestToParent_CE( new ApexPages.Standardcontroller(testCROpp));
			prResult1 = acr.CopyOLIs();
			testCRopp.OLIs_Pushed_To_Parent__c = false;
			testCRopp.StageName = 'Closed Won';
			testParentOpp.StageName = 'Closed Won';
			update testCRopp;
			update testParentOpp;
			acr = new AddChangeRequestToParent_CE( new ApexPages.Standardcontroller(testCROpp));
			prResult1 = acr.CopyOLIs();
			List<OpportunityLineItem> parentOppLineItems = [SELECT Id FROM OpportunityLineItem
																	  WHERE OpportunityId=:testParentOpp.Id];
			system.assert(!parentOppLineItems.IsEmpty());														  	
			
			
			Win_Loss_Form__c winLoss = new Win_Loss_Form__c(Opportunity__c =testCRopp.Id,
															Lost_To__c = 'ACI',
															Reason_Won_Lost__c = 'Lost',
															Level_Group_Caused_Us_to_Lose_the_Deal__c = 'Deal was thwarted by legal' );
			insert winLoss;
			//delete listCRproducts[0];
			delete testCRopp; 
			OpportunityServices.sendMassErrorsEmailFriendly(new List<String>{'dev@appirio.com'} , 'Test Methods', 'test_AddChangeRequestToParent', new List<Exception> {new Test_Exception('Code Failure')});
		Test.stopTest();
		
		//Verify the results
		system.debug('test_AddChangeRequestToParent.test_CopyOLIs - prResult1:'+prResult1);
		system.assert(prResult1.getURL().contains(testCRopp.Id));
		system.assert(prResult1.getURL().contains(acr.returnToOpp().getUrl()) );
		system.assert(!acr.getIsError());
		parentOppLineItems = [SELECT Id FROM OpportunityLineItem
										WHERE OpportunityId=:testParentOpp.Id];
		system.assert(parentOppLineItems.IsEmpty());
	}
*/
static testmethod void test_Opportunity_AfterDelete()
	{
		//Set up test data
		Opportunity testParentOpp = TestUtility.sampleOpportunity();
		testParentOpp.OLIs_Pushed_To_Parent__c = false;
		insert testParentOpp;
		delete testParentOpp;
	}
}