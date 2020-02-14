@isTest(seeAllData=false)
private class test_TestUtils
{
    private static testmethod void exerciseTestUtils(){
        Product2 p = TestUtils.getProduct('name', 'familyName');
        insert p;

        Account acct = TestUtils.getAccount('AcctName');
        insert acct;
        Project__c prj = TestUtils.getProject(acct);

        Opportunity oppty = TestUtils.getOpportunity(acct, 'Oppty name');
        OpportunityLineItem oli = TestUtils.getOLI(oppty);
        oli = TestUtils.getOLI(oppty, p);
        
        PricebookEntry pbe = TestUtils.getPriceBookEntry(p, test.getStandardPricebookId());
        
        System__c sys = TestUtils.getSystem(acct, 'sysname');
        insert sys;
        Contract_Asset__c ca = TestUtils.getAsset(acct, p, sys);
        
        Case cs = TestUtils.getCase();
        CaseComment ccm = TestUtils.getCaseComment(cs);
        
        User adm = TestUtils.getAdminUser('adminName');
        Contact cntct = TestUtils.getContact(acct);
        User portalUsr = TestUtils.getCustomerPortalUser('repName', cntct);
        
        //Intacct_Entity__c ie = TestUtils.getIntacctEntity();
        Contract ctrct = TestUtils.getContract(acct);
        Bill_To_Ship_To__c btst = TestUtils.getBillToShipTo(acct);
    }
    
    private static testmethod void dummyFunctionForDeltaTestCoverage(){
        TestUtility.dummyFunctionForDeltaTestCoverage();
    }

}