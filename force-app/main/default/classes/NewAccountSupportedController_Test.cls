@isTest private class NewAccountSupportedController_Test {

	static private CCRT__c[] setupCCRTs()
	{
		CCRT__c[] testCCRTs = new CCRT__c[]{}; 
		CCRT__c oneCCRT = TestUtility.sampleCCRT();
		oneCCRT.Client_Site_Number__c = '12345';
		testCCRTs .add(oneCCRT);
		
		oneCCRT = TestUtility.sampleCCRT();
		oneCCRT.Client_Site_Number__c = '123';
		testCCRTs .add(oneCCRT);
		
		oneCCRT = TestUtility.sampleCCRT();
		oneCCRT.Client_Site_Number__c = '1';
		testCCRTs .add(oneCCRT);
		
		return testCCRTs;
	}
		 
	
	static testmethod void testNewAccountSupportedController(){
		
		CCRT__c[] testCCRTs = setupCCRTs();
		insert testCCRTs;
		
		Account testAcc = new Account(Name='test',AccountNumber='1234321',Site='Parent', CCRT_entry__c = testCCRTs[0].Id);
		insert testAcc;
		Contact testCont = new Contact(LastName='test');
		insert testCont;
		Account testChildAcc = new Account(Name='test',AccountNumber='12345',Site='Child', CCRT_entry__c = testCCRTs[1].Id);
		insert testChildAcc;
		
		Account testChildAcc1 = new Account(Name='test',AccountNumber='12345',Site='Child', CCRT_entry__c = testCCRTs[2].Id);
		insert testChildAcc1;
		
		Accounts_Supported__c accsupp = new Accounts_Supported__c();
		PageReference pageRef = Page.New_Account_Supported;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('CF00N200000029p5q_lkid', testCont.Id);
		//ApexPages.currentPage().getParameters().put('CF00NR0000000XiCd_lkid', testCont.Id);
		NewAccountSupportedController cont = new NewAccountSupportedController(new ApexPages.StandardController(accsupp));
		cont.accountSupported.Supported_Account__c = testAcc.Id;
		
		PageReference p = cont.Save();
		String accountSupportedID = p.getURL().substring(1,16);
		System.debug('URL...' + p.getURL() + ' ' + accountSupportedID);
		try {
		  Accounts_Supported__c accsuppreread = [SELECT id, name FROM accounts_supported__c WHERE id = :accountSupportedID];
		  System.assertEquals(accsuppreread.name, '12345');
		} catch(Exception e) {
          System.debug(e.getMessage());
		  System.assert(false); //should never get here	
		}
		
		Accounts_Supported__c accsupp2 = new Accounts_Supported__c();
		cont = new NewAccountSupportedController(new ApexPages.StandardController(accsupp2));
		cont.accountSupported.Supported_Account__c = testChildAcc.Id;
		p = cont.saveAndNew();
		
		Accounts_Supported__c accsupp3 = new Accounts_Supported__c();
		cont = new NewAccountSupportedController(new ApexPages.StandardController(accsupp3));
		cont.accountSupported.Supported_Account__c = testChildAcc1.Id;
		p = cont.saveAndNew();
	
		
		System.assert(p.getURL().indexOf('auto_forward') > -1);		
		System.assert(p.getURL().indexOf(testCont.id) > -1);
		
	}

}