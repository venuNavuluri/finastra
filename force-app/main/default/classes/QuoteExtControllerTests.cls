//Updated by Robert Howell 12/6/2019. Updated test methods to support validation rule from RUBX-91
@isTest
private class QuoteExtControllerTests {
    
    testMethod static void testSubmit() {
        Opportunity[] opps = TestDataFactory.createOpportunities(1, 1, true);
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Opportunity2__c = opps[0].Id;
        insert quote;
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Approved', quote.ApprovalStatus__c);
    }
    
    testMethod static void testRecall() {
        Opportunity[] opps = TestDataFactory.createOpportunities(1, 1, true);
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Opportunity2__c = opps[0].Id;
        insert quote;
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onRecall();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Recalled', quote.ApprovalStatus__c);
    }
}