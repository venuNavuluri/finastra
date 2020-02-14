@IsTest
private class ReferenceView_Extension_Test {

    @IsTest
    static void testRedirectAddSalesWin() {
        // GIVEN an opportunity
        Opportunity opp = TestUtility.sampleOpportunity();
        insert opp;
        
        // AND the Id is on the Querystring
        ApexPages.currentPage().getParameters().put('id',opp.Id);
        
        // WHEN the extension class is instantiated
        Test.startTest();
            List<roi__Sales_Win__c> emptyList = new List<roi__Sales_Win__c>{ };
            ApexPages.StandardSetController setController = new ApexPages.StandardSetController(emptyList);
            ReferenceView_Extension extensionController = new ReferenceView_Extension(setController);
            
            // AND redirectAddSalesWin() is called
            PageReference pageRedirect = extensionController.redirectAddSalesWin();
        Test.stopTest();
        
        // THEN page redirect is populated
        System.assert(pageRedirect.getUrl().contains('page=SalesWinAdd'));
        System.assert(pageRedirect.getUrl().contains('oid='+opp.Id));
    }

    @IsTest
    static void testRedirectRaiseRequest() {
        // GIVEN an opportunity
        Opportunity opp = TestUtility.sampleOpportunity();
        insert opp;
        
        // AND the Id is on the Querystring
        ApexPages.currentPage().getParameters().put('id',opp.Id);
        
        // WHEN the extension class is instantiated
        Test.startTest();
            List<roi__Sales_Win__c> emptyList = new List<roi__Sales_Win__c>{ };
            ApexPages.StandardSetController setController = new ApexPages.StandardSetController(emptyList);
            ReferenceView_Extension extensionController = new ReferenceView_Extension(setController);
            
            // AND redirectRaiseRequest() is called
            PageReference pageRedirect = extensionController.redirectRaiseRequest();
        Test.stopTest();
        
        // THEN page redirect is populated
        System.assert(pageRedirect.getUrl().contains('page=Requests'));
        System.assert(pageRedirect.getUrl().contains('oid='+opp.Id));
    }
}