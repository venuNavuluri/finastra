/**
* @File Name          : PreviewApprovalsOverrideController_Test.cls
* @Description        : Test class for PreviewApprovalsOverrideController.cls
* @Author             : Dan Meseroll
* @Group              : ATG
* @Last Modified By   : Dan Meseroll
* @Last Modified On   : 1/22/2020, 12:00:00 PM
* @Modification Log   : 
* Ver       Date            Author      		    Modification        JIRA Ticket
* 1.0       1/22/2020       Dan Meseroll            Initial Version     RUBX-107
**/@isTest
private class PreviewApprovalsOverrideController_Test {
    @TestSetup
    static void setup(){
        Opportunity[] opps = TestDataFactory.createOpportunities(1, 1, true);
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Opportunity2__c = opps[0].Id;
        quote.SBQQ__Primary__c = true;
        insert quote;
    }

    /**
    * @description :  Test method to test the Submit button. Makes sure Quote is Approved after submitted.
    * @Rule Name: 
    * @Rule Definition: 
    * @author : Dan Meseroll
    * @param : None
    * @return : None
    **/
    testMethod static void test_Submit_PositveTest() {
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c LIMIT 1];
        
        Test.startTest();
        PreviewApprovalsOverrideController con = new PreviewApprovalsOverrideController(new ApexPages.StandardController(quote));
        con.onSubmit();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Approved', quote.ApprovalStatus__c);
    }
    
    /**
    * @description :  Test method to test the Submit button. Makes sure the Error message appears
    *                 when the quote is not the Primary, and the page does not redirect.
    * @Rule Name: 
    * @Rule Definition: 
    * @author : Dan Meseroll
    * @param : None
    * @return : None
    **/    
    testMethod static void test_SubmitNotPrimary_NegativeTest() {
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c LIMIT 1];
        quote.SBQQ__Primary__c = false;
        update quote;
        
        Test.startTest();
        PreviewApprovalsOverrideController con = new PreviewApprovalsOverrideController(new ApexPages.StandardController(quote));
        PageReference pr = con.onSubmit();
        Test.stopTest();
        //If it is not a primary quote, then Page reference will be null.
        System.assertEquals(null, pr);
        //Assert the error message
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());
        // Check that the error message you are expecting is in pageMessages
        Boolean messageFound = false;

        for(ApexPages.Message message : pageMessages) {
            if((message.getSummary() == System.Label.Only_Primary_Quotes) && (message.getSeverity() == ApexPages.Severity.WARNING)) {
                messageFound = true;       
            }
        }
        System.assert(messageFound);

    }

    /**
    * @description :  Test method to test the Cancel button. Make sure the Page redirects back to the quote.
    * @Rule Name: 
    * @Rule Definition: 
    * @author : Dan Meseroll
    * @param : None
    * @return : None
    **/    
    testMethod static void test_Cancel_PositiveTest() {
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c LIMIT 1];
        final String expectedURL = '/' + quote.Id;

        Test.startTest();
        PreviewApprovalsOverrideController con = new PreviewApprovalsOverrideController(new ApexPages.StandardController(quote));
        PageReference pr = con.onCancel();
        List<SBAA__Approval__c> approvalList = con.approvals;
        Test.stopTest();
        
        System.assertEquals(expectedURL, pr.getUrl());
    }
}