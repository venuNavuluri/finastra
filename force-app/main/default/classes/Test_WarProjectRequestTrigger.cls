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
//This test class is for testing WarProjectRequestTrigger and WarProjectRequestTriggerMethods
@isTest(seeAllData=true)
private class Test_WarProjectRequestTrigger {

    static testMethod void myUnitTest() {
        NS_Cost_Centre__c costCentre = new NS_Cost_Centre__c();
        insert costCentre;
        Opportunity opp = TestUtility.sampleOpportunity();
        opp.CurrencyISOCode = 'USD';
        opp.PS_Cost_Centre__c = costCentre.id;
        insert opp;

        RecordType rt = [select id, name from RecordType where name = 'WAR Project Request - Initial Days' limit 1];

        WAR_Project__c wp = new WAR_Project__c(Opportunity__c = opp.id, RecordTypeId = rt.id,
                Request_Type__c = 'Initial Days', WAR_days__c = 10, Initial_Finastra_Cost__c = 100.00);
        insert wp;
        
        wp.WAR_Approval_Status__c = 'APPROVED';
        update wp;
        
        Opportunity opp1 = [select id, WAR_Approval_Status__c from Opportunity where id = :opp.id];
        system.assertEquals('APPROVED', opp1.WAR_Approval_Status__c);
        
        wp.WAR_Approval_Status__c = 'REJECTED';
        update wp;

        Opportunity opp2 = [select id, WAR_Approval_Status__c from Opportunity where id = :opp.id];
        system.assertEquals('REJECTED', opp2.WAR_Approval_Status__c);
    }
}