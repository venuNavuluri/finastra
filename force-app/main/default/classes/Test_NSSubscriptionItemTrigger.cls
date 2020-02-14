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
 	Created Date: 29/10/2014
 	Description: This is the test class for testing NSSubscriptionItemTrigger trigger and NSSubscriptionItemTriggerMethods class.
 */
@isTest
private class Test_NSSubscriptionItemTrigger {

    static testMethod void myUnitTest() {
    	list<NS_List_Table__c> nsList = new list<NS_List_Table__c>();
    	
        NS_List_Table__c nsListTable1 = new NS_List_Table__c(Name = 'Arrears', NS_Internal_Id__c = '2', NS_List_Name__c = 'BillingMethod');
        NS_List_Table__c nsListTable2 = new NS_List_Table__c(Name = 'Add new item but no co-term alignment', NS_Internal_Id__c = '2', NS_List_Name__c = 'CoTerm');
        NS_List_Table__c nsListTable3 = new NS_List_Table__c(Name = 'Open', NS_Internal_Id__c = '2', NS_List_Name__c = 'SubscriptionStatus');
        NS_List_Table__c nsListTable4 = new NS_List_Table__c(Name = 'Upon cancellation', NS_Internal_Id__c = '2', NS_List_Name__c = 'TerminationMethod');
        NS_List_Table__c nsListTable5 = new NS_List_Table__c(Name = 'Fixed Date', NS_List_Name__c = 'BillingMode', NS_Internal_Id__c = '1');
        NS_List_Table__c nsListTable6 = new NS_List_Table__c(Name = 'RLF', NS_List_Name__c = 'TransactionCategory', NS_Internal_Id__c = '1');
        NS_List_Table__c nsListTable7 = new NS_List_Table__c(Name = 'Invoice', NS_List_Name__c = 'BillingTransaction', NS_Internal_Id__c = '1');
        
        nsList.add(nsListTable1);
        nsList.add(nsListTable2);
        nsList.add(nsListTable3);
        nsList.add(nsListTable4);
        nsList.add(nsListTable5);
        nsList.add(nsListTable6);
        nsList.add(nsListTable7);
        
        insert nsList;

        NS_Subscriptions__c sub = new NS_Subscriptions__c(Name = 'Test', Billing_Mode_Internal_Id__c = '1', Billing_Transaction_Internal_Id__c = '1', 
        							Status_Internal_Id__c = '2', Termination_Method_Internal_Id__c = '2', SB_Transaction_Category_Internal_Id__c = '1');
        insert sub;
        
        NS_Subscription_Item__c subItem1 = new NS_Subscription_Item__c(Subscription__c = sub.Id, Billing_Method_Internal_Id__c = '2', Co_Term_Internal_Id__c = '2', 
        							Status_Internal_Id__c = '2', Termination_Method_Internal_Id__c = '2', Update_From_NS__c = true);
        insert subItem1;
        							
        NS_Subscription_Item__c subItem2 = new NS_Subscription_Item__c(Subscription__c = sub.Id, Billing_Method__c = 'Arrears', Co_Term__c = 'Add new item but no co-term alignment', 
        							Status__c = 'Open', Termination_Method__c = 'Upon cancellation', Update_From_NS__c = false);
        insert subItem2;

        subItem1 = [select Billing_Method__c from NS_Subscription_Item__c where id = :subItem1.Id];
        system.assertEquals('Arrears', subItem1.Billing_Method__c);

        subItem2 = [select Billing_Method__c, Billing_Method_Internal_Id__c from NS_Subscription_Item__c where id = :subItem2.Id];
        system.assertEquals('2', subItem2.Billing_Method_Internal_Id__c);
        
        subItem1.Billing_Method_Internal_Id__c = '';
        subItem1.Co_Term_Internal_Id__c = '';
        subItem1.Status_Internal_Id__c = '';
        subItem1.Termination_Method_Internal_Id__c = '';
        subItem1.Update_From_NS__c = true;
        update subItem1;

        subItem2.Billing_Method__c = '';
        subItem2.Co_Term__c = '';
        subItem2.Status__c = '';
        subItem2.Termination_Method__c = '';
        subItem2.Update_From_NS__c = false;
        update subItem2;
    }
}