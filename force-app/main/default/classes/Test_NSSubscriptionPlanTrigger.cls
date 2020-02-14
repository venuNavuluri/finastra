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

 //This is the test class for testing the triggers NSSubscriptionPlanTrigger and NSSubscriptionPlanItemTrigger and classes NSSubscriptionPlanTriggerMethods and NSSubscriptionPlanItemTriggerMethods
@isTest
private class Test_NSSubscriptionPlanTrigger {

    static testMethod void myUnitTest() {
    	list<NS_List_Table__c> nsList = new list<NS_List_Table__c>();
    	
        NS_List_Table__c nsListTable1 = new NS_List_Table__c(Name = 'Arrears', NS_Internal_Id__c = '2', NS_List_Name__c = 'BillingMethod');
        NS_List_Table__c nsListTable2 = new NS_List_Table__c(Name = 'Anniversary', NS_Internal_Id__c = '1', NS_List_Name__c = 'BillingMode');
        NS_List_Table__c nsListTable3 = new NS_List_Table__c(Name = 'Add new item but no co-term alignment', NS_Internal_Id__c = '2', NS_List_Name__c = 'CoTerm');
        NS_List_Table__c nsListTable4 = new NS_List_Table__c(Name = 'Available', NS_Internal_Id__c = '5', NS_List_Name__c = 'SubscriptionPlanStatus');
        NS_List_Table__c nsListTable5 = new NS_List_Table__c(Name = 'Upon cancellation', NS_Internal_Id__c = '2', NS_List_Name__c = 'TerminationMethod');
        NS_List_Table__c nsListTable6 = new NS_List_Table__c(Name = 'Rating Period', NS_Internal_Id__c = '5', NS_List_Name__c = 'Unit');
        
        nsList.add(nsListTable1);
        nsList.add(nsListTable2);
        nsList.add(nsListTable3);
        nsList.add(nsListTable4);
        nsList.add(nsListTable5);
        nsList.add(nsListTable6);
        
        insert nsList;
        
        NS_Subscription_Plan__c subPlan = new NS_Subscription_Plan__c(Name = 'test', Billing_Method_Internal_Id__c = '2', Billing_Mode_Internal_Id__c = '1', Co_Term_Internal_Id__c = '2', Status_Internal_Id__c = '5', Termination_Method_Internal_Id__c = '2', Update_From_NS__c = true);
        insert subPlan;
        
        subPlan = [select Billing_Method__c from NS_Subscription_Plan__c where Id = :subPlan.Id][0];
        system.assertEquals('Arrears', subPlan.Billing_Method__c);

        NS_Subscription_Plan_Item__c subPlanItem = new NS_Subscription_Plan_Item__c(NS_Billing_Method_Internal_Id__c = '2', NS_Unit_Internal_Id__c = '5', Update_From_NS__c = true, NS_Subscription_Plan__c = subPlan.Id);
        insert subPlanItem;
        
        subPlanItem = [select Billing_Method__c from NS_Subscription_Plan_Item__c where Id = :subPlanItem.Id][0];
        system.assertEquals('Arrears', subPlanItem.Billing_Method__c);

        NS_Subscription_Plan__c subPlan1 = new NS_Subscription_Plan__c(Name = 'test1', Billing_Method__c = 'Arrears', Billing_Mode__c = 'Anniversary', Co_Term__c = 'Add new item but no co-term alignment', Status__c = 'Available', Termination_Method__c = 'Upon cancellation', Update_From_NS__c = false);
        insert subPlan1;

        subPlan1 = [select Billing_Method_Internal_Id__c from NS_Subscription_Plan__c where Id = :subPlan1.Id][0];
        system.assertEquals('2', subPlan1.Billing_Method_Internal_Id__c);

        NS_Subscription_Plan_Item__c subPlanItem1 = new NS_Subscription_Plan_Item__c(Billing_Method__c = 'Arrears', Unit__c = 'Rating Period', Update_From_NS__c = false, NS_Subscription_Plan__c = subPlan1.Id);
        insert subPlanItem1;

        subPlanItem1 = [select NS_Billing_Method_Internal_Id__c from NS_Subscription_Plan_Item__c where Id = :subPlanItem1.Id][0];
        system.assertEquals('2', subPlanItem1.NS_Billing_Method_Internal_Id__c);
        
        subPlan.Billing_Method_Internal_Id__c = '';
        subPlan.Billing_Mode_Internal_Id__c = '';
        subPlan.Co_Term_Internal_Id__c = '';
        subPlan.Status_Internal_Id__c = '';
        subPlan.Termination_Method_Internal_Id__c = '';
        subPlan.Update_From_NS__c = true;
        update subPlan;
        
        subPlan1.Billing_Method__c = '';
        subPlan1.Billing_Mode__c = '';
        subPlan1.Co_Term__c = '';
        subPlan1.Status__c = '';
        subPlan1.Termination_Method__c = '';
        subPlan1.Update_From_NS__c = false;
        update subPlan1;
        
        subPlanItem.NS_Billing_Method_Internal_Id__c = '';
        subPlanItem.NS_Unit_Internal_Id__c = '';
        subPlanItem.Update_From_NS__c = true;
        update subPlanItem;

        subPlanItem1.Billing_Method__c = '';
        subPlanItem1.Unit__c = '';
        subPlanItem1.Update_From_NS__c = false;
        update subPlanItem1;
    }
}