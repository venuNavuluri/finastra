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
 	Created By : Abhinit Kohar
 	Created Date: 30-09-2014
 	Description: This is the test class for testing NSRlfChangeOrderTrigger and NSRlfChangeOrderMethods.
 */
@isTest
private class Test_NSRlfChangeOrderTrigger {

    static testMethod void myUnitTest1() {
        NS_RLF_Change_Order__c co1 = new NS_RLF_Change_Order__c(Pushed_to_NS__c = false);
        insert co1;
        
        co1.Ready_For_Export_To_NS__c = true;
        update co1;
        
        co1 = [select NS_Push_Token__c from NS_RLF_Change_Order__c where id = :co1.Id];
        system.assertEquals(true, co1.NS_Push_Token__c);

        NS_RLF_Change_Order__c co2 = new NS_RLF_Change_Order__c(Pushed_to_NS__c = false);
        insert co2;
        
        co2.Ready_For_Export_To_NS__c = true;
        update co2;

        co2 = [select NS_Push_Token__c from NS_RLF_Change_Order__c where id = :co2.Id];
        system.assertEquals(false, co2.NS_Push_Token__c);

        co1.Pushed_to_NS__c = true;
        co1.NS_Push_Token__c = false;
        update co1;

        co2 = [select NS_Push_Token__c from NS_RLF_Change_Order__c where id = :co2.Id];
        system.assertEquals(true, co2.NS_Push_Token__c);
    }
}