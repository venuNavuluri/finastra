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
 	Created Date: 11/09/2014
 	Description: This is the test class for testing NSSubscriptionTrigger trigger and NSSubscriptionTriggerMethods class.
 */
@isTest
private class Test_NSSubscriptionTrigger {

    static testMethod void myUnitTest() {
    	list<NS_List_Table__c> ltList = new list<NS_List_Table__c>();
        NS_List_Table__c lt1 = new NS_List_Table__c(Name = 'Fixed Date', NS_List_Name__c = 'BillingMode', NS_Internal_Id__c = '1');
        NS_List_Table__c lt2 = new NS_List_Table__c(Name = 'RLF', NS_List_Name__c = 'TransactionCategory', NS_Internal_Id__c = '1');
        NS_List_Table__c lt3 = new NS_List_Table__c(Name = 'Invoice', NS_List_Name__c = 'BillingTransaction', NS_Internal_Id__c = '1');
        NS_List_Table__c lt4 = new NS_List_Table__c(Name = 'Upon cancellation', NS_List_Name__c = 'TerminationMethod', NS_Internal_Id__c = '1');
        NS_List_Table__c lt5 = new NS_List_Table__c(Name = 'Open', NS_List_Name__c = 'SubscriptionStatus', NS_Internal_Id__c = '1');
        NS_List_Table__c lt6 = new NS_List_Table__c(Name = 'Uplift Required', NS_List_Name__c = 'HoldBillingReason', NS_Internal_Id__c = '1');
        
        ltList.add(lt1);
        ltList.add(lt2);
        ltList.add(lt3);
        ltList.add(lt4);
        ltList.add(lt5);
        ltList.add(lt6);
        insert ltList;
        
        NS_Subscriptions__c sub = new NS_Subscriptions__c(Name = 'Test', Billing_Mode_Internal_Id__c = '1', Billing_Transaction_Internal_Id__c = '1', 
        							Status_Internal_Id__c = '1', Termination_Method_Internal_Id__c = '1', SB_Transaction_Category_Internal_Id__c = '1', 
        							Hold_Billing_Reason_Internal_Id__c = '1');
        insert sub;
        
        sub = [select id, name, Billing_Mode__c, Hold_Billing_Reason__c from NS_Subscriptions__c where id = :sub.Id];
        system.assertEquals('Fixed Date', sub.Billing_Mode__c);
        system.assertEquals('Uplift Required', sub.Hold_Billing_Reason__c);
        
        sub.Billing_Mode_Internal_Id__c = null;
        sub.Billing_Transaction_Internal_Id__c = null;
        sub.Status_Internal_Id__c = null;
        sub.Termination_Method_Internal_Id__c = null;
        sub.SB_Transaction_Category_Internal_Id__c = null;
        sub.Hold_Billing_Reason_Internal_Id__c = null;
        
        update sub;
    }
}