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
 	Created Date: 22/09/2014
 	Description: This is the test class for testing SalesOrderItemTrigger trigger and SalesOrderItemTriggerMethods class.
 */
@isTest
private class Test_SalesOrderItemTrigger {

    static testMethod void myUnitTest() {
    	list<NS_List_Table__c> ltList = new list<NS_List_Table__c>();
        NS_List_Table__c lt1 = new NS_List_Table__c(Name = 'Open', NS_List_Name__c = 'SubscriptionStatus', NS_Internal_Id__c = '1');
        
        ltList.add(lt1);
        insert ltList;

    	NS_Revenue_Recognition_Template__c revRec = new NS_Revenue_Recognition_Template__c(Name = 'POC', NS_Internal_Id__c = '38');
    	insert revRec;
        
		Sales_Order__c salesOrder = new Sales_Order__c(Order_Type__c = 'ILF', Sales_Role__c = 'Sales Rep');
		insert salesOrder;

        Sales_Order_Item__c soItem = new Sales_Order_Item__c(Name = 'Test', Sales_Order__c = salesOrder.Id);
        insert soItem;
        
        soItem.NS_Primary_Sub_Item_Status_Internal_Id__c = '1';
        update soItem;
        
        soItem = [select id, name, NS_Primary_Sub_Item_Status__c from Sales_Order_Item__c where id = :soItem.Id];
        system.assertEquals('Open', soItem.NS_Primary_Sub_Item_Status__c);
    }
}