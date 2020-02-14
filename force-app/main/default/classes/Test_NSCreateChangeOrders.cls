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
    Created Date: 04/11/2014
    Description: This is the test class for testing NSCreateChangeOrders class.
 */
@isTest
private class Test_NSCreateChangeOrders {
    private static Account acct;
    private static Product_Set__c ps;
    private static System__c sys;
    private static Client_Asset__c cla;
    private static NS_Subscriptions__c sub;

    private static void setupContractAssetPrerequisites()
    {
        acct = TestUtility.sampleAccount();
        insert acct;
        
        ps = TestUtility.sampleProductSet(acct.Id);
        insert ps;
            
        sys = TestUtility.sampleSystem(acct.Id);
        sys.Licence_Group__c = 'licGrp';
        insert sys;
        
        cla = TestUtility.sampleClientAsset(ps.Id);
        insert cla;

        list<NS_List_Table__c> nsList = new list<NS_List_Table__c>();
        
        NS_List_Table__c nsListTable1 = new NS_List_Table__c(Name = 'Arrears', NS_Internal_Id__c = '2', NS_List_Name__c = 'BillingMethod');
        NS_List_Table__c nsListTable2 = new NS_List_Table__c(Name = 'Add new item but no co-term alignment', NS_Internal_Id__c = '2', NS_List_Name__c = 'CoTerm');
        NS_List_Table__c nsListTable3 = new NS_List_Table__c(Name = 'Open', NS_Internal_Id__c = '2', NS_List_Name__c = 'SubscriptionStatus');
        NS_List_Table__c nsListTable4 = new NS_List_Table__c(Name = 'Upon cancellation', NS_Internal_Id__c = '2', NS_List_Name__c = 'TerminationMethod');
        NS_List_Table__c nsListTable5 = new NS_List_Table__c(Name = 'Fixed Date', NS_List_Name__c = 'BillingMode', NS_Internal_Id__c = '1');
        NS_List_Table__c nsListTable6 = new NS_List_Table__c(Name = 'RLF', NS_List_Name__c = 'TransactionCategory', NS_Internal_Id__c = '1');
        NS_List_Table__c nsListTable7 = new NS_List_Table__c(Name = 'Invoice', NS_List_Name__c = 'BillingTransaction', NS_Internal_Id__c = '1');
        NS_List_Table__c nsListTable8 = new NS_List_Table__c(Name = 'Pending', NS_Internal_Id__c = '1', NS_List_Name__c = 'SubscriptionStatus');
        
        nsList.add(nsListTable1);
        nsList.add(nsListTable2);
        nsList.add(nsListTable3);
        nsList.add(nsListTable4);
        nsList.add(nsListTable5);
        nsList.add(nsListTable6);
        nsList.add(nsListTable7);
        nsList.add(nsListTable8);
        insert nsList;

        sub = new NS_Subscriptions__c(Name = 'Test', Billing_Mode_Internal_Id__c = '1', Billing_Transaction_Internal_Id__c = '1', NS_Subscription_Internal_Id__c = '1234561', 
                                    Status_Internal_Id__c = '2', Termination_Method_Internal_Id__c = '2', SB_Transaction_Category_Internal_Id__c = '1');
        insert sub;
    }

    public static testmethod void myUnitTest1()
    {
        setupContractAssetPrerequisites();
        
        Contract_Asset__c ca = TestUtility.sampleContractAsset(cla.Id, sys.Id, acct.Id);
        ca.OpportunityLineItem__c = null;
        ca.NS_Subscription__c = sub.Id;
        ca.NS_Uplift_Start_Date__c = Date.today();
        ca.NS_Uplift_Override__c = 3.0;
        ca.Apply_2015_Uplift__c = true;
        ca.CO_Batch_Create__c = true;
        ca.CO_Batch_Create_Complete__c = false;
        
        insert ca;
        
        system.assertEquals('Change Order created successfully', NSCreateChangeOrders.createSingleChangeOrder(sub.Id));
        system.assertEquals('There are no associated Contract Assets for creating the uplift Change Order', NSCreateChangeOrders.createSingleChangeOrder(sub.Id));
    }

    public static testmethod void myUnitTest2()
    {
        setupContractAssetPrerequisites();
        
        Contract_Asset__c ca = TestUtility.sampleContractAsset(cla.Id, sys.Id, acct.Id);
        ca.OpportunityLineItem__c = null;
        ca.NS_Subscription__c = sub.Id;
        ca.NS_Uplift_Start_Date__c = Date.today();
        ca.NS_Uplift_Override__c = 3.0;
        ca.Apply_2015_Uplift__c = true;
        ca.CO_Batch_Create__c = true;
        
        insert ca;
        
        sub.Status_Internal_Id__c = '1';
        update sub;
        
        system.assertEquals('Change Order can not be created for this Subscription. \n\n Please check that the Status of Subscription should be Open and Subscription should not be inactive.', NSCreateChangeOrders.createSingleChangeOrder(sub.Id));
       // system.assertEquals('Change Order can not be created for this Subscription. \n\n Please check that the Status of Subscription should be Open and Subscription should not be inactive.', NSCreateChangeOrders.createSingleChangeOrderNew(sub.Id, '2015'));

    }

    public static testmethod void myUnitTest3()
    {
        setupContractAssetPrerequisites();
        
        Contract_Asset__c ca = TestUtility.sampleContractAsset(cla.Id, sys.Id, acct.Id);
        ca.OpportunityLineItem__c = null;
        ca.NS_Subscription__c = sub.Id;
        ca.NS_Uplift_Start_Date__c = Date.today();
        ca.NS_Uplift_Override__c = 3.0;
        ca.Apply_2015_Uplift__c = true;
        ca.CO_Batch_Create__c = true;
        
        insert ca;
        
        Contract_Asset__c ca1 = TestUtility.sampleContractAsset(cla.Id, sys.Id, acct.Id);
        ca1.OpportunityLineItem__c = null;
        ca1.NS_Subscription__c = sub.Id;
        ca1.NS_Uplift_Start_Date__c = Date.today();
        ca1.NS_Uplift_Override__c = 4.0;
        ca1.Apply_2015_Uplift__c = true;
        ca.CO_Batch_Create__c = true;
        
        insert ca1;

        system.assertEquals('Change Orders created successfully', NSCreateChangeOrders.createChangeOrders());
    }

    public static testmethod void myUnitTest4()
    {
        setupContractAssetPrerequisites();
        
        Contract_Asset__c ca = TestUtility.sampleContractAsset(cla.Id, sys.Id, acct.Id);
        ca.OpportunityLineItem__c = null;
        ca.NS_Subscription__c = sub.Id;
        ca.NS_Uplift_Effective_Date__c = Date.today().addDays(-1);
        ca.NS_Uplift_Start_Date__c = Date.today();
        ca.NS_Uplift_Override__c = 3.0;
        ca.Apply_2015_Uplift__c = true;
        ca.CO_Batch_Create__c = true;
        ca.CO_Batch_Create_Complete__c = false;
        
        insert ca;
        
        system.assertEquals('Change Order not created: If the Contract Asset NS Uplift Effective Date is OLDER than TODAY, the NS Uplift Start Date MUST be the same date', NSCreateChangeOrders.createSingleChangeOrder(sub.Id));
    }

    public static testmethod void myUnitTest5()
    {
        setupContractAssetPrerequisites();
        
        Contract_Asset__c ca = TestUtility.sampleContractAsset(cla.Id, sys.Id, acct.Id);
        ca.OpportunityLineItem__c = null;
        ca.NS_Subscription__c = sub.Id;
        ca.NS_Uplift_Effective_Date__c = Date.today().addDays(1);
        ca.NS_Uplift_Start_Date__c = Date.today();
        ca.NS_Uplift_Override__c = 3.0;
        ca.Apply_2015_Uplift__c = true;
        ca.CO_Batch_Create__c = true;
        ca.CO_Batch_Create_Complete__c = false;
        
        insert ca;
        
        system.assertEquals('Change Order not created: If the Contract Asset NS Uplift Effective Date is TODAY or LATER than TODAY, the NS Uplift Start Date MUST be the same date or LATER', NSCreateChangeOrders.createSingleChangeOrder(sub.Id));
    }

    public static testmethod void myUnitTest6()
    {
        setupContractAssetPrerequisites();
        
        Contract_Asset__c ca = TestUtility.sampleContractAsset(cla.Id, sys.Id, acct.Id);
        ca.OpportunityLineItem__c = null;
        ca.NS_Subscription__c = sub.Id;
        ca.NS_Uplift_Effective_Date__c = Date.today();
        ca.NS_Uplift_Start_Date__c = Date.today().addDays(-1);
        ca.NS_Uplift_Override__c = 3.0;
        ca.Apply_2015_Uplift__c = true;
        ca.CO_Batch_Create__c = true;
        ca.CO_Batch_Create_Complete__c = false;
        
        insert ca;
        
        system.assertEquals('Change Order not created: If the Contract Asset NS Uplift Effective Date is TODAY or LATER than TODAY, the NS Uplift Start Date MUST be the same date or LATER', NSCreateChangeOrders.createSingleChangeOrder(sub.Id));
    }

    //for 2015
    public static testmethod void myUnitTest7()
    {
        setupContractAssetPrerequisites();
        
        Contract_Asset__c ca = TestUtility.sampleContractAsset(cla.Id, sys.Id, acct.Id);
        ca.OpportunityLineItem__c = null;
        ca.NS_Subscription__c = sub.Id;
        ca.NS_Uplift_Start_Date__c = Date.today();
        ca.NS_Uplift_Override__c = 3.0;
        ca.Apply_2015_Uplift__c = true;
        ca.CO_Batch_Create__c = true;
        ca.CO_Batch_Create_Complete__c = false;
        ca.CA_Billing_Status__c = 'Active billing';
        
        insert ca;
        
        NS_Subscription_Item__c subItem = new NS_Subscription_Item__c(Subscription__c = sub.Id, Contract_Asset__c = ca.Id);
        insert subItem;
        
      //  system.assertEquals('Change Order created successfully', NSCreateChangeOrders.createSingleChangeOrderNew(sub.Id, '2015'));
     //   system.assertEquals('There are no associated Contract Assets for creating the uplift Change Order', NSCreateChangeOrders.createSingleChangeOrderNew(sub.Id, '2015'));
    }

    //for 2016
    public static testmethod void myUnitTest8()
    {
        setupContractAssetPrerequisites();
        
        Contract_Asset__c ca = TestUtility.sampleContractAsset(cla.Id, sys.Id, acct.Id);
        ca.OpportunityLineItem__c = null;
        ca.NS_Subscription__c = sub.Id;
        ca.NS_Uplift_Start_Date__c = Date.today();
        ca.NS_Uplift_Override__c = 3.0;
        ca.Apply_2016_Uplift__c = true;
        ca.CO_Batch_Create__c = true;
        ca.CO_Batch_Create_Complete__c = false;
        ca.CA_Billing_Status__c = 'Active billing';
        
        insert ca;
        
        NS_Subscription_Item__c subItem = new NS_Subscription_Item__c(Subscription__c = sub.Id, Contract_Asset__c = ca.Id);
        insert subItem;
        
     //   system.assertEquals('Change Order created successfully', NSCreateChangeOrders.createSingleChangeOrderNew(sub.Id, '2016'));
      //  system.assertEquals('There are no associated Contract Assets for creating the uplift Change Order', NSCreateChangeOrders.createSingleChangeOrderNew(sub.Id, '2016'));
    }

    //for ad-hoc
    public static testmethod void myUnitTest9()
    {
        setupContractAssetPrerequisites();
        
        Contract_Asset__c ca = TestUtility.sampleContractAsset(cla.Id, sys.Id, acct.Id);
        ca.OpportunityLineItem__c = null;
        ca.NS_Subscription__c = sub.Id;
        ca.NS_Uplift_Start_Date__c = Date.today();
        ca.NS_Uplift_Override__c = 3.0;
        ca.Apply_Ad_Hoc_Uplift__c = true;
        ca.CO_Batch_Create__c = true;
        ca.CO_Batch_Create_Complete__c = false;
        ca.CA_Billing_Status__c = 'Active billing';
        
        insert ca;
        
        NS_Subscription_Item__c subItem = new NS_Subscription_Item__c(Subscription__c = sub.Id, Contract_Asset__c = ca.Id);
        insert subItem;
        
       //  system.assertEquals('Change Order created successfully', NSCreateChangeOrders.createSingleChangeOrderNew(sub.Id, '2016', '2016', '01/01/2016','01/01/2016'));
        NSCreateChangeOrders.createSingleChangeOrderNew(sub.Id, '2016', '2016', '01/01/2016','01/01/2016');
        NSCreateChangeOrders.createSingleChangeOrderNew(sub.Id, '2015', '2015', '01/01/2016','01/01/2016');
        NSCreateChangeOrders.createSingleChangeOrderNew(sub.Id, '2017', '2017', '01/01/2016','01/01/2016');
        NSCreateChangeOrders.createSingleChangeOrderNew(sub.Id, 'Generic', '2016', '01/01/2016','01/01/2016');
     //   system.assertEquals('Change Order created successfully', NSCreateChangeOrders.createSingleChangeOrderNew(sub.Id, 'ad-hoc'));
     //   system.assertEquals('There are no associated Contract Assets for creating the uplift Change Order', NSCreateChangeOrders.createSingleChangeOrderNew(sub.Id, 'ad-hoc'));
    }
}