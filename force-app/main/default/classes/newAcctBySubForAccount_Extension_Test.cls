@IsTest
private class newAcctBySubForAccount_Extension_Test {

    @IsTest
    static void testConstructor() {
        // GIVEN an account
        Account testAccount = TestUtility.createAccount('Test Account');
        
        // AND the Id is on the Querystring
        ApexPages.currentPage().getParameters().put('id',testAccount.Id);
        
        // WHEN the extension class is instantiated
        Test.startTest();
            List<Acct_By_Sub__c> emptyList = new List<Acct_By_Sub__c>{ };
            ApexPages.StandardSetController setController = new ApexPages.StandardSetController(emptyList);
            newAcctBySubForAccount_Extension extensionController = new newAcctBySubForAccount_Extension(setController);
        Test.stopTest();
        
        // THEN the accountRecord property is populated
        System.assertEquals('Test Account', extensionController.accountRecord.Name);
    }
    
    @IsTest
    static void testCheckCCRT_withError() {
        // GIVEN an account
        Account testAccount = TestUtility.createAccount('Test Account');
        
        // AND the Id is on the Querystring
        ApexPages.currentPage().getParameters().put('id',testAccount.Id);
        
        // WHEN the extension class is instantiated
        Test.startTest();
            List<Acct_By_Sub__c> emptyList = new List<Acct_By_Sub__c>{ };
            ApexPages.StandardSetController setController = new ApexPages.StandardSetController(emptyList);
            newAcctBySubForAccount_Extension extensionController = new newAcctBySubForAccount_Extension(setController);
            
            // AND CheckCCRT() is called with no CCRT entry
            PageReference pageRedirect = extensionController.checkCCRT();
        Test.stopTest();
        
        // THEN the errorMessage property is populated
        System.assertEquals(label.NewAcctBySubMustHaveCCRTAttached_Error, extensionController.errorMessage);
        
        // AND page redirect is null
        System.assertEquals(null, pageRedirect);
    }
    
    @IsTest
    static void testCheckCCRT_withoutError() {
        // GIVEN an account
        Account testAccount = TestUtility.createAccount('Test Account');
        
        // AND a CCRT
        insert new CCRT__c(Account__c = testAccount.Id, Name = 'Test CCRT', Client_Site_Number__c = '123xx45');
        
        // AND the Id is on the Querystring
        ApexPages.currentPage().getParameters().put('id',testAccount.Id);
        
        // WHEN the extension class is instantiated
        Test.startTest();
            List<Acct_By_Sub__c> emptyList = new List<Acct_By_Sub__c>{ };
            ApexPages.StandardSetController setController = new ApexPages.StandardSetController(emptyList);
            newAcctBySubForAccount_Extension extensionController = new newAcctBySubForAccount_Extension(setController);
            
            // AND CheckCCRT() is called with no CCRT entry
            PageReference pageRedirect = extensionController.checkCCRT();
        Test.stopTest();
        
        // THEN the errorMessage property is null
        System.assertEquals(null, extensionController.errorMessage);
        
        // AND page redirect is populated
        System.assertEquals(true, pageRedirect.getUrl().contains(extensionController.accountRecord.Id));
    }
    
}