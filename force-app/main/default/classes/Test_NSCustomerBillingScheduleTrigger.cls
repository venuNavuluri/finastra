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
 	Created Date: 07/04/2014
 	Description: This is the test class for testing NSCustomerBillingScheduleTrigger trigger and NSCustomerBillingScheduleTriggerMethods class.
 */
@isTest
private class Test_NSCustomerBillingScheduleTrigger {

    static testMethod void myUnitTest() {
        NS_Customer_Billing_Schedule__c cbs = new NS_Customer_Billing_Schedule__c(Name = 'TestName', Public__c = false, Synced_To_NS__c = true);
        insert cbs;
        
        cbs = [select Public__c, Synced_To_NS__c from NS_Customer_Billing_Schedule__c where id = :cbs.Id];
        system.assertEquals(false, cbs.Public__c);
        system.assertEquals(true, cbs.Synced_To_NS__c);
        
        cbs.Public__c = true;
        update cbs;
        
        cbs = [select Public__c, Synced_To_NS__c from NS_Customer_Billing_Schedule__c where id = :cbs.Id];
        system.assertEquals(true, cbs.Public__c);
        system.assertEquals(false, cbs.Synced_To_NS__c);
    }
}