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
    Created Date: 28/03/2014
    Description: This is the test class for testing SalesOrderTrigger and SalesOrderTriggerMethods class.
 */
@isTest
private class SalesOrderTriggerMethods_Test {

    static testMethod void myUnitTest() {
        list<NS_List_Table__c> tableList = new list<NS_List_Table__c>();
        NS_List_Table__c listTable1 = new NS_List_Table__c(NS_List_Name__c = 'TransactionCategory', Name = 'ILF', NS_Internal_Id__c = '1');
        tableList.add(listTable1);
        NS_List_Table__c listTable2 = new NS_List_Table__c(NS_List_Name__c = 'SalesRole', Name = 'Sales Rep', NS_Internal_Id__c = '-2');
        tableList.add(listTable2);
        
        insert tableList;
        
        NS_Revenue_Recognition_Template__c revRec = new NS_Revenue_Recognition_Template__c(Name = 'POC', NS_Internal_Id__c = '38');
        insert revRec;
        
        CCRT__c testCCRT = TestUtility.sampleCCRT();
        testCCRT.Client_Site_Number__c = '12456';
        insert testCCRT;
        
        Account testAcc = TestUtility.sampleAccount();
        testAcc.CCRT_entry__c = testCCRT.Id;
        testAcc.NS_Cash_Accounting__c = true;
        insert testAcc;
        
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 1', Default_Billing__c = true, Account__c = testAcc.Id);
        insert btst;
        Bill_To_Ship_To__c btst2 = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 2', Default_Billing__c = false, Account__c = testAcc.Id);
        insert btst2;
        
        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '1');
        insert misysEntity;
        
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id);
        insert accBySub;

        NS_Product__c product = new NS_Product__c(name = 'test_prod');
        insert product;

        NS_Project__c project = new NS_Project__c(Project_Product__c = product.id, Project_Name__c = 'Test Proj', Customer__c = accBySub.Id, OpenAir_Project_Stage__c = 'Pipeline', SFDC_Opportunity_Category__c = 'Omitted', OA_Project_Template__c = 'TEMPLATE - Pre-Sales Project', Project_Category__c = 'Training');
        insert project;
        
        NS_Project_Milestone__c projMilestone = new NS_Project_Milestone__c(Name = 'Test Milestone', NS_Project__c = project.Id, Start_Date__c = Date.today(), Status__c = 'In Progress');
        insert projMilestone;
        
        Sales_Order__c salesOrder = new Sales_Order__c(Order_Type__c = 'ILF', Sales_Role__c = 'Sales Rep', Bill_To_Customer__c = accBySub.Id, NS_Project__c = project.Id);
        insert salesOrder;
        
        Sales_Order__c so = [select Order_Type_Internal_Id__c, Sales_Role_Internal_Id__c from Sales_Order__c where id = :salesOrder.id];
        
        system.assertEquals('1', so.Order_Type_Internal_Id__c);
        system.assertEquals('-2', so.Sales_Role_Internal_Id__c);
    }

    static testMethod void myUnitTest2() {
        CCRT__c testCCRT = TestUtility.sampleCCRT();
        testCCRT.Client_Site_Number__c = '12456';
        insert testCCRT;
        
        Account testAcc = TestUtility.sampleAccount();
        testAcc.CCRT_entry__c = testCCRT.Id;
        testAcc.NS_Cash_Accounting__c = true;
        insert testAcc;

        NS_Revenue_Recognition_Template__c revRec = new NS_Revenue_Recognition_Template__c(Name = 'POC', NS_Internal_Id__c = '38');
        insert revRec;
        
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 1', Default_Billing__c = true, Account__c = testAcc.Id);
        insert btst;
        Bill_To_Ship_To__c btst2 = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 2', Default_Billing__c = false, Account__c = testAcc.Id);
        insert btst2;
        
        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '1');
        insert misysEntity;
        
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id);
        insert accBySub;

        NS_Product__c product = new NS_Product__c(name = 'test_prod');
        insert product;

        NS_Project__c project = new NS_Project__c(Project_Product__c = product.id, Project_Name__c = 'Test Proj', Customer__c = accBySub.Id, OpenAir_Project_Stage__c = 'Pipeline', SFDC_Opportunity_Category__c = 'Omitted', OA_Project_Template__c = 'TEMPLATE - Pre-Sales Project', Project_Category__c = 'Training');
        insert project;
        
        NS_Project_Milestone__c projMilestone = new NS_Project_Milestone__c(Name = 'Test Milestone', NS_Project__c = project.Id, Start_Date__c = Date.today(), Status__c = 'In Progress');
        insert projMilestone;
        
        NS_Account__c nsAccount = new NS_Account__c(Name = 'Deferred revenue - ILF', NS_Account_Internal_Id__c = '129', Is_Inactive__c = false, Account_Type__c = 'DEFERRED_REVENUE');
        insert nsAccount;
        
        NS_Currency__c nsCurrency = new NS_Currency__c(Name = 'GBP', NS_Currency_Internal_Id__c = '13');
        insert nsCurrency;
        
        NS_Cost_Centre__c nsCC = new NS_Cost_Centre__c(Name = 'P110 Business Development', NS_Cost_Centre_Internal_Id__c = '3');
        insert nsCC;
        
        NS_Product__c nsProd = new NS_Product__c(Name = 'Capital Markets Fusion', NS_Product_Internal_Id__c = '2', Product_is_Inactive__c = false);
        insert nsProd;

        Opportunity opp = TestUtility.sampleOpportunity();
        opp.CurrencyISOCode = 'USD';
        insert opp;
        
        Sales_Order__c salesOrder = new Sales_Order__c(Bill_To_Customer__c = accBySub.Id, NS_Project__c = project.Id, 
            Primary_Partner__c = accBySub.Id, NS_Deferred_Rev_Rec_Acc_Internal_Id__c = '129', 
            NS_Currency__c = nsCurrency.Id, NS_Cost_Centre__c = nsCC.Id, NS_Product__c = nsProd.Id, Opportunity__c = opp.Id);
        insert salesOrder;
        
        Sales_Order__c so = [select Order_Type_Internal_Id__c, Sales_Role_Internal_Id__c, NS_Deferred_Rev_Rec_Acc_Internal_Id__c, 
            NS_Currency_Internal_Id__c, NS_Cost_Centre_Internal_Id__c, NS_Product_Analysis_Internal_Id__c from Sales_Order__c where id = :salesOrder.id];
        
        system.assertEquals('129', so.NS_Deferred_Rev_Rec_Acc_Internal_Id__c);
        system.assertEquals('13', so.NS_Currency_Internal_Id__c);
        system.assertEquals('3', so.NS_Cost_Centre_Internal_Id__c);
        system.assertEquals('2', so.NS_Product_Analysis_Internal_Id__c);
        
        delete so;
    }
    
     @IsTest
    static void testNVL() {

        Test.startTest();

        Decimal x = SalesOrderTriggerMethods.nvl(null);
        System.assertEquals(0, x);

        Decimal y = SalesOrderTriggerMethods.nvl(1);
        System.assertEquals(1, y);

        Test.stopTest();
    }

    @IsTest
    static void testApplyNewILFSubsAssetSizeOnSubmit() {

        List<SBQQ__Subscription__c> subscriptions = createSubscriptions();
        insert subscriptions;

        subscriptions = [SELECT Id, Fair_Value__c, SBQQ__NetPrice__c, SBQQ__Contract__r.Asset_Size__c FROM SBQQ__Subscription__c];

        for (SBQQ__Subscription__c sub : subscriptions) {
            System.assertEquals(100, sub.SBQQ__NetPrice__c);
            System.assertEquals(800, sub.SBQQ__Contract__r.Asset_Size__c);
        }

        Test.startTest();

        List<Sales_Order__c> salesOrders = createSalesOrders();
        insert salesOrders;

        List<Sales_Order_Item__c> salesOrderItems = createSalesOrderItem(salesOrders);
        insert salesOrderItems;

        for (Sales_Order__c so : salesOrders) {
            so.Order_Status__c = 'Pending Fulfilment';
            so.Synced_To_NS__c = true;
        }
        update salesOrders;

        Test.stopTest();

        List<SBQQ__Subscription__c> ilfSubscriptions = [SELECT Id, SO_Amount__c, SBQQ__NetPrice__c , SBQQ__Contract__r.Asset_Size__c FROM SBQQ__Subscription__c where Sales_Order_Type__c = 'ILF'];

        for (SBQQ__Subscription__c sub : ilfSubscriptions) {
            //System.assertEquals(null, sub.SO_Amount__c);
            System.assertEquals(100, sub.SBQQ__NetPrice__c);
            System.assertEquals(900, sub.SBQQ__Contract__r.Asset_Size__c);
        }
        
        List<SBQQ__Subscription__c> rlfSubscriptions = [SELECT Id, SO_Amount__c, SBQQ__NetPrice__c , SBQQ__Contract__r.Asset_Size__c FROM SBQQ__Subscription__c where Sales_Order_Type__c = 'RLF'];

        for (SBQQ__Subscription__c sub : rlfSubscriptions) {
            System.assertEquals(110, sub.SO_Amount__c);
            System.assertEquals(100, sub.Fair_Value__c);
            System.assertEquals(100, sub.SBQQ__NetPrice__c);
            System.assertEquals(900, sub.SBQQ__Contract__r.Asset_Size__c);
        }
    }

    private static List<Sales_Order__c> createSalesOrders() {

        CCRT__c testCCRT = TestUtility.sampleCCRT();
        testCCRT.Client_Site_Number__c = '12456';
        insert testCCRT;

        Account testAcc = TestUtility.sampleAccount();
        testAcc.CCRT_entry__c = testCCRT.Id;
        testAcc.NS_Cash_Accounting__c = true;
        insert testAcc;

        NS_Revenue_Recognition_Template__c revRec = new NS_Revenue_Recognition_Template__c(Name = 'POC', NS_Internal_Id__c = '38');
        insert revRec;

        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 1', Default_Billing__c = true, Account__c = testAcc.Id);
        insert btst;
        Bill_To_Ship_To__c btst2 = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 2', Default_Billing__c = false, Account__c = testAcc.Id);
        insert btst2;

        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '1');
        insert misysEntity;

        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id);
        insert accBySub;

        NS_Product__c product = new NS_Product__c(name = 'test_prod');
        insert product;

        NS_Project__c project = new NS_Project__c(Project_Product__c = product.id, Project_Name__c = 'Test Proj', Customer__c = accBySub.Id, OpenAir_Project_Stage__c = 'Pipeline', SFDC_Opportunity_Category__c = 'Omitted', OA_Project_Template__c = 'TEMPLATE - Pre-Sales Project', Project_Category__c = 'Training');
        insert project;

        NS_Project_Milestone__c projMilestone = new NS_Project_Milestone__c(Name = 'Test Milestone', NS_Project__c = project.Id, Start_Date__c = Date.today(), Status__c = 'In Progress');
        insert projMilestone;

        NS_Account__c nsAccount = new NS_Account__c(Name = 'Deferred revenue - ILF', NS_Account_Internal_Id__c = '129', Is_Inactive__c = false, Account_Type__c = 'DEFERRED_REVENUE');
        insert nsAccount;

        NS_Currency__c nsCurrency = new NS_Currency__c(Name = 'GBP', NS_Currency_Internal_Id__c = '13');
        insert nsCurrency;

        NS_Cost_Centre__c nsCC = new NS_Cost_Centre__c(Name = 'P110 Business Development', NS_Cost_Centre_Internal_Id__c = '3');
        insert nsCC;

        NS_Product__c nsProd = new NS_Product__c(Name = 'Capital Markets Fusion', NS_Product_Internal_Id__c = '2', Product_is_Inactive__c = false);
        insert nsProd;

        Opportunity opp = TestUtility.sampleOpportunity();
        opp.CurrencyISOCode = 'USD';
        insert opp;
        
        List<Contract> lContr = [Select Id from Contract Limit 1];

        List<Sales_Order__c> salesOrders = new List<Sales_Order__c>();
        for (Integer i = 0; i < 200; i++) {
            Sales_Order__c so = new Sales_Order__c(Bill_To_Customer__c = accBySub.Id, NS_Project__c = project.Id,
                    Primary_Partner__c = accBySub.Id, NS_Deferred_Rev_Rec_Acc_Internal_Id__c = '100' + i, Contract__c = lContr[0].Id,
                    NS_Currency__c = nsCurrency.Id, NS_Cost_Centre__c = nsCC.Id, NS_Product__c = nsProd.Id, Opportunity__c = opp.Id, Order_Status__c = 'Pending Approval');
            salesOrders.add(so);
        }
        return salesOrders;

    }

    private static List<Sales_Order_Item__c> createSalesOrderItem(List<Sales_Order__c> lso) {

        List<Sales_Order_Item__c> salesOrderItems = new List<Sales_Order_Item__c>();
        List<SBQQ__Subscription__c> subscriptions = [SELECT Id FROM SBQQ__Subscription__c];

        Integer i = 0;
        for (Sales_Order__c so : lso) {
            Sales_Order_Item__c soi = new Sales_Order_Item__c();
            soi.Sales_Order__c = so.Id;
            //soi.ILF_Asset_Uplift_Subscription__C = subscriptions[i].Id;
            //soi.ILF_New_Asset_Size__c = 20;
            salesOrderItems.add(soi);
            i++;
        }

        return salesOrderItems;
    }

    private static List<SBQQ__Subscription__c> createSubscriptions() {
        Account acc = new Account(name = 'uplift test account');
        insert acc;
        
        Opportunity opp = new Opportunity(AccountId = acc.Id, Name = 'uplift test opp', StageName = 'Suspect', CloseDate = Date.today(), Service_Type__c ='Consultancy' );
        insert opp;
        
        Contract contract1 = new Contract(accountId = acc.Id, SBQQ__Opportunity__c = opp.Id,Next_Asset_Uplift_Date__c=Date.today()-300,Asset_Size__c=800,New_Asset_Size__c=900,
                Next_Uplift_Date__c = Date.today(), status = 'Draft', ContractTerm = 12);
        insert contract1;

        Uplift__c uplift1 = new Uplift__c(
                Exclude__c = true,
                Status__c = 'Pro-Rata',
                Billing_Type__c = 'Advance',
                Uplift_Advance__c = 61,
                Billing_Frequency__c = 'Monthly',
                Hold_Billing__c = false,
                Active__c = true,
                Uplift_Application_Date__c = Date.today(),
                Start_Date__c = Date.today(),
                Uplift_Effective_Date__c = Date.today());

        insert uplift1;

        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>();
        for (Integer i = 0; i < 200; i++) {
            SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
                    SBQQ__Quantity__c = 1,
                    Varied_Licence__c = true,
                    CPI_Uplift__c = uplift1.id,
                    Transactions__c = 2,
                    Sold_Value__c = 50,
                    SBQQ__NetPrice__c = 100,
                    SO_Amount__c = 100,
                    Fair_Value__c = 100,
                    Asset_Uplift__c = true,
                    RLF_Uplift_Multiplier_Percent__c=10,
                    Uplift_Multiplier__c = 1,
                    SBQQ__BillingType__c = 'Advance',
                    SBQQ__Contract__c = contract1.Id,
                    ProdType__c = 'ILF'
                    );

            subscriptions.add(sub);
        }
        for (Integer i = 0; i < 200; i++) {
            SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
                    SBQQ__Quantity__c = 1,
                    Varied_Licence__c = true,
                    CPI_Uplift__c = uplift1.id,
                    Transactions__c = 2,
                    Sold_Value__c = 50,
                    Asset_Uplift__c = true,
                    SO_Amount__c = 100,
                    Fair_Value__c = 100,
                	RLF_Uplift_Multiplier_Percent__c=10,
                    Uplift_Multiplier__c = 1,
                    SBQQ__NetPrice__c = 100,
                    SBQQ__BillingType__c = 'Advance',
                    SBQQ__Contract__c = contract1.Id,
                    ProdType__c = 'RLF'
                    );

            subscriptions.add(sub);
        }

        return subscriptions;
    }
}