/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
/*
	Created By: Abhinit Kohar
	Created Date: 12/12/2013
	Description: This is the test class for testing ContractTrigger trigger and ContractTriggerMethods class. 
*/
@isTest (SeeAllData = true)
private class Test_ContractTrigger {

    static testMethod void myUnitTest() {
	    Opportunity testOpp1 = TestUtility.sampleOpportunity();
	    testOpp1.CloseDate = system.today();
	    insert testOpp1;
	    OpportunityLineItem testProduct = TestUtility.sampleOpportunityLineItem(testOpp1, 'PS (T)');
	    insert testProduct;
	    
	    Opportunity opp = [select AccountId from Opportunity where id = :testOpp1.Id limit 1];
	    
	    //Run the actions to test the update
	    test.startTest();
	    Contract contract = new Contract(Name = 'TestContract', Misys_Opportunity__c = testOpp1.Id, CurrencyIsoCode = 'IDR', Contract_Type__c = 'Escrow', Contract_Document_Services_Amount__c = 14545.25, AccountId = opp.AccountId);
	    insert contract;
	    test.stopTest();
    }
}