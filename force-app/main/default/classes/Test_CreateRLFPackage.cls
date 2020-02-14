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
@isTest 
private class Test_CreateRLFPackage {

    static testMethod void myUnitTest() {
        CCRT__c testCCRT = TestUtility.sampleCCRT();
        //testCCRT.Client_Site_Number__c = '12456';
        insert testCCRT;
        
        Account testAcc = TestUtility.sampleAccount();
        testAcc.CCRT_entry__c = testCCRT.Id;
        testAcc.NS_Cash_Accounting__c = true;
        insert testAcc;
        
        list<Bill_To_Ship_To__c> btstList = new list<Bill_To_Ship_To__c>();
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 1', Default_Billing__c = true, Account__c = testAcc.Id);
        btstList.add(btst);
        Bill_To_Ship_To__c btst2 = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 2', Default_Billing__c = false, Account__c = testAcc.Id);
        btstList.add(btst2);
        insert btstList;
        
        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '11111111111');
        insert misysEntity;
        
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id, NS_Internal_Id__c = '123');
        insert accBySub;
        
        list<NS_Customer_Address__c> custAddList = [select id from NS_Customer_Address__c where Acct_By_Sub__c = :accBySub.Id];

        Opportunity opp = TestUtility.sampleOpportunity();
        opp.CurrencyISOCode = 'USD';
        insert opp;
        
        list<Product2> prodList = new list<Product2>();
        Product2 prod = new Product2(Name = 'testProd', SO_Grouping__c = 'RLF-RLF', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561');
        prodList.add(prod);
        
        insert prodList;
        
        Contract contract = new Contract(Misys_Opportunity__c = opp.Id, StartDate = Date.today(), AccountId = testAcc.Id, Sales_Order_Type__c = 'RLF-RLF');
        insert contract;

        Product_Set__c ps = TestUtility.sampleProductSet(testAcc.Id);
        insert ps;
            
        System__c sys = TestUtility.sampleSystem(testAcc.Id);
        sys.Licence_Group__c = 'licGrp';
        insert sys;
        
        Client_Asset__c cla = TestUtility.sampleClientAsset(ps.Id);
        insert cla;

        list<NS_Subscription_Term__c> nstList = new list<NS_Subscription_Term__c>();
        NS_Subscription_Term__c nst = new NS_Subscription_Term__c(Name = '120 months', Months__c = 120, NS_Subscription_Term_Internal_Id__c = '14');
        NS_Subscription_Term__c nst1 = new NS_Subscription_Term__c(Name = '36 months', Months__c = 36, NS_Subscription_Term_Internal_Id__c = '7');

        nstList.add(nst);
        nstList.add(nst1);
        insert nstList;
        
        NS_Billing_Frequency__c nbf = new NS_Billing_Frequency__c(Name = 'Yearly', Months_Per_Period__c = 12, NS_Billing_Frequency_Internal_Id__c = '8');
        insert nbf;
        
        NS_Currency__c nc = new NS_Currency__c(Name = 'USD', NS_Currency_Internal_Id__c = '1');
        insert nc;
        
        NS_Revenue_Recognition_Template__c nrrt = new NS_Revenue_Recognition_Template__c(Name = 'POC');
        insert nrrt;
        
        Billing_Group__c billingGroup = new Billing_Group__c();
        billingGroup.Account_by_Sub__c = accBySub.Id;
        billingGroup.BG_Billing_Group_Active__c = true;
        billingGroup.Initial_RLF_Package_Created__c = false;
        billingGroup.Original_Opportunity__c = opp.Id;
        billingGroup.Original_Contract__c = contract.Id;
        billingGroup.BG_Client_Bill_To__c = btstList[0].Id;
        billingGroup.BG_Client_Ship_To__c = btstList[0].Id;
        billingGroup.NS_Customer_Ship_To_Address__c = custAddList[0].Id;
        billingGroup.NS_Subscription_Term__c = nst.Id;
        billingGroup.NS_Rating_Frequency_Billing_Period__c = nbf.Id;
        billingGroup.NS_Billing_Frequency__c = nbf.Id;
        billingGroup.NS_Subscription_Billing_Method__c = 'Advance';
        billingGroup.NS_Subscription_Option__c = 'New Subscription';
        billingGroup.NS_Billing_Mode__c = 'Fixed Date';
        billingGroup.NS_Subscription_Start_Type__c = 'On start date';
        billingGroup.NS_Termination_Method__c = 'Upon Cancellation';
        billingGroup.NS_Subscription_Notice_Period__c = '1';
        billingGroup.NS_Subscription_Minimum_Term__c = nst1.Id;
        billingGroup.BG_Misys_Billing_Entity__c = misysEntity.Id;
        billingGroup.RLF_Batch_Create__c = true;
        
        insert billingGroup;

        Contract_Asset__c ca = TestUtility.sampleContractAsset(cla.Id, sys.Id, testAcc.Id);
        ca.OpportunityLineItem__c = null;
        ca.Product__c = prodList[0].Id;
        ca.Contract__c = contract.Id;
        ca.CA_Billing_Status__c = 'Active billing';
        ca.CA_Billing_Group__c = billingGroup.Id;
        insert ca;
        
        Test.startTest();
        CreateRLFPackage.createSalesOrder(billingGroup.Id, 'Initial');
        CreateRLFPackage.checkPlanAvailability(billingGroup.Id);
        CreateRLFPackage.callCreateRLFPackageBatch();
        CreateRLFPackage.checkZeroDecimalCurrency(billingGroup.Id);
        Test.stopTest();

        billingGroup.BG_Client_Bill_To__c = null;
        billingGroup.BG_Client_Ship_To__c = null;
        
        update billingGroup;
    }

    //This is for testing the validation when there are no contrac assets associated with the billing group
    static testMethod void myUnitTest2() {
        CCRT__c testCCRT = TestUtility.sampleCCRT();
        //testCCRT.Client_Site_Number__c = '12456';
        insert testCCRT;
        
        Account testAcc = TestUtility.sampleAccount();
        testAcc.CCRT_entry__c = testCCRT.Id;
        testAcc.NS_Cash_Accounting__c = true;
        insert testAcc;
        
        list<Bill_To_Ship_To__c> btstList = new list<Bill_To_Ship_To__c>();
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 1', Default_Billing__c = true, Account__c = testAcc.Id);
        btstList.add(btst);
        Bill_To_Ship_To__c btst2 = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 2', Default_Billing__c = false, Account__c = testAcc.Id);
        btstList.add(btst2);
        insert btstList;
        
        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '11111111111');
        insert misysEntity;
        
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id, NS_Internal_Id__c = '123');
        insert accBySub;
        
        list<NS_Customer_Address__c> custAddList = [select id from NS_Customer_Address__c where Acct_By_Sub__c = :accBySub.Id];

        Opportunity opp = TestUtility.sampleOpportunity();
        opp.CurrencyISOCode = 'USD';
        insert opp;
        
        list<Product2> prodList = new list<Product2>();
        Product2 prod = new Product2(Name = 'testProd', SO_Grouping__c = 'RLF-RLF', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561');
        prodList.add(prod);
        
        insert prodList;
        
        Contract contract = new Contract(Misys_Opportunity__c = opp.Id, StartDate = Date.today(), AccountId = testAcc.Id, Sales_Order_Type__c = 'RLF-RLF');
        insert contract;

        Product_Set__c ps = TestUtility.sampleProductSet(testAcc.Id);
        insert ps;
            
        System__c sys = TestUtility.sampleSystem(testAcc.Id);
        sys.Licence_Group__c = 'licGrp';
        insert sys;
        
        Client_Asset__c cla = TestUtility.sampleClientAsset(ps.Id);
        insert cla;

        list<NS_Subscription_Term__c> nstList = new list<NS_Subscription_Term__c>();
        NS_Subscription_Term__c nst = new NS_Subscription_Term__c(Name = '120 months', Months__c = 120, NS_Subscription_Term_Internal_Id__c = '14');
        NS_Subscription_Term__c nst1 = new NS_Subscription_Term__c(Name = '36 months', Months__c = 36, NS_Subscription_Term_Internal_Id__c = '7');

        nstList.add(nst);
        nstList.add(nst1);
        insert nstList;
        
        NS_Billing_Frequency__c nbf = new NS_Billing_Frequency__c(Name = 'Yearly', Months_Per_Period__c = 12, NS_Billing_Frequency_Internal_Id__c = '8');
        insert nbf;
        
        NS_Currency__c nc = new NS_Currency__c(Name = 'USD', NS_Currency_Internal_Id__c = '1');
        insert nc;
        
        NS_Revenue_Recognition_Template__c nrrt = new NS_Revenue_Recognition_Template__c(Name = 'POC');
        insert nrrt;
        
        Billing_Group__c billingGroup = new Billing_Group__c();
        billingGroup.Account_by_Sub__c = accBySub.Id;
        billingGroup.BG_Billing_Group_Active__c = true;
        billingGroup.Initial_RLF_Package_Created__c = false;
        billingGroup.Original_Opportunity__c = opp.Id;
        billingGroup.Original_Contract__c = contract.Id;
        billingGroup.BG_Client_Bill_To__c = btstList[0].Id;
        billingGroup.BG_Client_Ship_To__c = btstList[0].Id;
        billingGroup.NS_Customer_Ship_To_Address__c = custAddList[0].Id;
        billingGroup.NS_Subscription_Term__c = nst.Id;
        billingGroup.NS_Rating_Frequency_Billing_Period__c = nbf.Id;
        billingGroup.NS_Billing_Frequency__c = nbf.Id;
        billingGroup.NS_Subscription_Billing_Method__c = 'Advance';
        billingGroup.NS_Subscription_Option__c = 'New Subscription';
        billingGroup.NS_Billing_Mode__c = 'Fixed Date';
        billingGroup.NS_Subscription_Start_Type__c = 'On start date';
        billingGroup.NS_Termination_Method__c = 'Upon Cancellation';
        billingGroup.NS_Subscription_Notice_Period__c = '1';
        billingGroup.NS_Subscription_Minimum_Term__c = nst1.Id;
        billingGroup.BG_Misys_Billing_Entity__c = misysEntity.Id;
        billingGroup.RLF_Batch_Create__c = true;
        
        insert billingGroup;

        Test.startTest();
        CreateRLFPackage.createSalesOrder(billingGroup.Id, 'Initial');
        CreateRLFPackage.checkPlanAvailability(billingGroup.Id);
        CreateRLFPackage.callCreateRLFPackageBatch();
        Test.stopTest();

        billingGroup.BG_Client_Bill_To__c = null;
        billingGroup.BG_Client_Ship_To__c = null;
        
        update billingGroup;
    }

    //This is for testing the validation when the currency ISO code of contract asset is different to currency ISO code of billing group.
    static testMethod void myUnitTest3() {
        CCRT__c testCCRT = TestUtility.sampleCCRT();
        //testCCRT.Client_Site_Number__c = '12456';
        insert testCCRT;
        
        Account testAcc = TestUtility.sampleAccount();
        testAcc.CCRT_entry__c = testCCRT.Id;
        testAcc.NS_Cash_Accounting__c = true;
        insert testAcc;
        
        list<Bill_To_Ship_To__c> btstList = new list<Bill_To_Ship_To__c>();
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 1', Default_Billing__c = true, Account__c = testAcc.Id);
        btstList.add(btst);
        Bill_To_Ship_To__c btst2 = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 2', Default_Billing__c = false, Account__c = testAcc.Id);
        btstList.add(btst2);
        insert btstList;
        
        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '11111111111');
        insert misysEntity;
        
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id, NS_Internal_Id__c = '123');
        insert accBySub;
        
        list<NS_Customer_Address__c> custAddList = [select id from NS_Customer_Address__c where Acct_By_Sub__c = :accBySub.Id];

        Opportunity opp = TestUtility.sampleOpportunity();
        opp.CurrencyISOCode = 'USD';
        insert opp;
        
        list<Product2> prodList = new list<Product2>();
        Product2 prod = new Product2(Name = 'testProd', SO_Grouping__c = 'RLF-RLF', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561');
        prodList.add(prod);
        
        insert prodList;
        
        Contract contract = new Contract(Misys_Opportunity__c = opp.Id, StartDate = Date.today(), AccountId = testAcc.Id, Sales_Order_Type__c = 'RLF-RLF');
        insert contract;

        Product_Set__c ps = TestUtility.sampleProductSet(testAcc.Id);
        insert ps;
            
        System__c sys = TestUtility.sampleSystem(testAcc.Id);
        sys.Licence_Group__c = 'licGrp';
        insert sys;
        
        Client_Asset__c cla = TestUtility.sampleClientAsset(ps.Id);
        insert cla;

        list<NS_Subscription_Term__c> nstList = new list<NS_Subscription_Term__c>();
        NS_Subscription_Term__c nst = new NS_Subscription_Term__c(Name = '120 months', Months__c = 120, NS_Subscription_Term_Internal_Id__c = '14');
        NS_Subscription_Term__c nst1 = new NS_Subscription_Term__c(Name = '36 months', Months__c = 36, NS_Subscription_Term_Internal_Id__c = '7');

        nstList.add(nst);
        nstList.add(nst1);
        insert nstList;
        
        NS_Billing_Frequency__c nbf = new NS_Billing_Frequency__c(Name = 'Yearly', Months_Per_Period__c = 12, NS_Billing_Frequency_Internal_Id__c = '8');
        insert nbf;
        
        NS_Currency__c nc = new NS_Currency__c(Name = 'USD', NS_Currency_Internal_Id__c = '1');
        insert nc;
        
        NS_Revenue_Recognition_Template__c nrrt = new NS_Revenue_Recognition_Template__c(Name = 'POC');
        insert nrrt;
        
        Billing_Group__c billingGroup = new Billing_Group__c();
        billingGroup.Account_by_Sub__c = accBySub.Id;
        billingGroup.BG_Billing_Group_Active__c = true;
        billingGroup.Initial_RLF_Package_Created__c = false;
        billingGroup.Original_Opportunity__c = opp.Id;
        billingGroup.Original_Contract__c = contract.Id;
        billingGroup.BG_Client_Bill_To__c = btstList[0].Id;
        billingGroup.BG_Client_Ship_To__c = btstList[0].Id;
        billingGroup.NS_Customer_Ship_To_Address__c = custAddList[0].Id;
        billingGroup.NS_Subscription_Term__c = nst.Id;
        billingGroup.NS_Rating_Frequency_Billing_Period__c = nbf.Id;
        billingGroup.NS_Billing_Frequency__c = nbf.Id;
        billingGroup.NS_Subscription_Billing_Method__c = 'Advance';
        billingGroup.NS_Subscription_Option__c = 'New Subscription';
        billingGroup.NS_Billing_Mode__c = 'Fixed Date';
        billingGroup.NS_Subscription_Start_Type__c = 'On start date';
        billingGroup.NS_Termination_Method__c = 'Upon Cancellation';
        billingGroup.NS_Subscription_Notice_Period__c = '1';
        billingGroup.NS_Subscription_Minimum_Term__c = nst1.Id;
        billingGroup.BG_Misys_Billing_Entity__c = misysEntity.Id;
        billingGroup.CurrencyIsoCode = 'USD';
        billingGroup.RLF_Batch_Create__c = true;
        
        insert billingGroup;

        Contract_Asset__c ca = TestUtility.sampleContractAsset(cla.Id, sys.Id, testAcc.Id);
        ca.OpportunityLineItem__c = null;
        ca.Product__c = prodList[0].Id;
        ca.Contract__c = contract.Id;
        ca.CA_Billing_Status__c = 'Active billing';
        ca.CA_Billing_Group__c = billingGroup.Id;
        ca.CurrencyIsoCode = 'GBP';
        insert ca;
        
        Test.startTest();
        CreateRLFPackage.createSalesOrder(billingGroup.Id, 'Initial');
        CreateRLFPackage.checkPlanAvailability(billingGroup.Id);
        CreateRLFPackage.callCreateRLFPackageBatch();
        Test.stopTest();

        billingGroup.BG_Client_Bill_To__c = null;
        billingGroup.BG_Client_Ship_To__c = null;
        
        update billingGroup;
    } 

    //for testing the zero currency
    static testMethod void myUnitTest4() {
        CCRT__c testCCRT = TestUtility.sampleCCRT();
        //testCCRT.Client_Site_Number__c = '12456';
        insert testCCRT;
        
        Account testAcc = TestUtility.sampleAccount();
        testAcc.CCRT_entry__c = testCCRT.Id;
        testAcc.NS_Cash_Accounting__c = true;
        insert testAcc;
        
        list<Bill_To_Ship_To__c> btstList = new list<Bill_To_Ship_To__c>();
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 1', Default_Billing__c = true, Account__c = testAcc.Id);
        btstList.add(btst);
        Bill_To_Ship_To__c btst2 = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 2', Default_Billing__c = false, Account__c = testAcc.Id);
        btstList.add(btst2);
        insert btstList;
        
        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '11111111111');
        insert misysEntity;
        
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id, NS_Internal_Id__c = '123');
        insert accBySub;
        
        list<NS_Customer_Address__c> custAddList = [select id from NS_Customer_Address__c where Acct_By_Sub__c = :accBySub.Id];

        Opportunity opp = TestUtility.sampleOpportunity();
        opp.CurrencyISOCode = 'USD';
        insert opp;
        
        list<Product2> prodList = new list<Product2>();
        Product2 prod = new Product2(Name = 'testProd', SO_Grouping__c = 'RLF-RLF', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561');
        prodList.add(prod);
        
        insert prodList;
        
        Contract contract = new Contract(Misys_Opportunity__c = opp.Id, StartDate = Date.today(), AccountId = testAcc.Id, Sales_Order_Type__c = 'RLF-RLF');
        insert contract;

        Product_Set__c ps = TestUtility.sampleProductSet(testAcc.Id);
        insert ps;
            
        System__c sys = TestUtility.sampleSystem(testAcc.Id);
        sys.Licence_Group__c = 'licGrp';
        insert sys;
        
        Client_Asset__c cla = TestUtility.sampleClientAsset(ps.Id);
        insert cla;

        list<NS_Subscription_Term__c> nstList = new list<NS_Subscription_Term__c>();
        NS_Subscription_Term__c nst = new NS_Subscription_Term__c(Name = '120 months', Months__c = 120, NS_Subscription_Term_Internal_Id__c = '14');
        NS_Subscription_Term__c nst1 = new NS_Subscription_Term__c(Name = '36 months', Months__c = 36, NS_Subscription_Term_Internal_Id__c = '7');

        nstList.add(nst);
        nstList.add(nst1);
        insert nstList;
        
        NS_Billing_Frequency__c nbf = new NS_Billing_Frequency__c(Name = 'Yearly', Months_Per_Period__c = 12, NS_Billing_Frequency_Internal_Id__c = '8', Invoices_per_year__c = 4);
        insert nbf;
        
        NS_Currency__c nc = new NS_Currency__c(Name = 'USD', NS_Currency_Internal_Id__c = '1', IsZeroDecimal__c = true);
        insert nc;
        
        NS_Revenue_Recognition_Template__c nrrt = new NS_Revenue_Recognition_Template__c(Name = 'POC');
        insert nrrt;
        
        Billing_Group__c billingGroup = new Billing_Group__c();
        billingGroup.Account_by_Sub__c = accBySub.Id;
        billingGroup.BG_Billing_Group_Active__c = true;
        billingGroup.Initial_RLF_Package_Created__c = false;
        billingGroup.Original_Opportunity__c = opp.Id;
        billingGroup.Original_Contract__c = contract.Id;
        billingGroup.BG_Client_Bill_To__c = btstList[0].Id;
        billingGroup.BG_Client_Ship_To__c = btstList[0].Id;
        billingGroup.NS_Customer_Ship_To_Address__c = custAddList[0].Id;
        billingGroup.NS_Subscription_Term__c = nst.Id;
        billingGroup.NS_Rating_Frequency_Billing_Period__c = nbf.Id;
        billingGroup.NS_Billing_Frequency__c = nbf.Id;
        billingGroup.NS_Subscription_Billing_Method__c = 'Advance';
        billingGroup.NS_Subscription_Option__c = 'New Subscription';
        billingGroup.NS_Billing_Mode__c = 'Fixed Date';
        billingGroup.NS_Subscription_Start_Type__c = 'On start date';
        billingGroup.NS_Termination_Method__c = 'Upon Cancellation';
        billingGroup.NS_Subscription_Notice_Period__c = '1';
        billingGroup.NS_Subscription_Minimum_Term__c = nst1.Id;
        billingGroup.BG_Misys_Billing_Entity__c = misysEntity.Id;
        billingGroup.RLF_Batch_Create__c = true;
        
        insert billingGroup;

        Contract_Asset__c ca = TestUtility.sampleContractAsset(cla.Id, sys.Id, testAcc.Id);
        ca.OpportunityLineItem__c = null;
        ca.Product__c = prodList[0].Id;
        ca.Contract__c = contract.Id;
        ca.CA_Billing_Status__c = 'Active billing';
        ca.CA_Billing_Group__c = billingGroup.Id;
        ca.Annual_RLF_Maint_Override__c = 567.89;
        ca.Annual_Maintenance__c = 567.89;
        insert ca;
        
        Test.startTest();
        CreateRLFPackage.createSalesOrder(billingGroup.Id, 'Initial');
        CreateRLFPackage.checkZeroDecimalCurrency(billingGroup.Id);
        Test.stopTest();
    }

    //for testing the zero currency where the amount is not fully divisible
    static testMethod void myUnitTest5() {
        CCRT__c testCCRT = TestUtility.sampleCCRT();
        //testCCRT.Client_Site_Number__c = '12456';
        insert testCCRT;
        
        Account testAcc = TestUtility.sampleAccount();
        testAcc.CCRT_entry__c = testCCRT.Id;
        testAcc.NS_Cash_Accounting__c = true;
        insert testAcc;
        
        list<Bill_To_Ship_To__c> btstList = new list<Bill_To_Ship_To__c>();
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 1', Default_Billing__c = true, Account__c = testAcc.Id);
        btstList.add(btst);
        Bill_To_Ship_To__c btst2 = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 2', Default_Billing__c = false, Account__c = testAcc.Id);
        btstList.add(btst2);
        insert btstList;
        
        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '11111111111');
        insert misysEntity;
        
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id, NS_Internal_Id__c = '123');
        insert accBySub;
        
        list<NS_Customer_Address__c> custAddList = [select id from NS_Customer_Address__c where Acct_By_Sub__c = :accBySub.Id];

        Opportunity opp = TestUtility.sampleOpportunity();
        opp.CurrencyISOCode = 'USD';
        insert opp;
        
        list<Product2> prodList = new list<Product2>();
        Product2 prod = new Product2(Name = 'testProd', SO_Grouping__c = 'RLF-RLF', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561');
        prodList.add(prod);
        
        insert prodList;
        
        Contract contract = new Contract(Misys_Opportunity__c = opp.Id, StartDate = Date.today(), AccountId = testAcc.Id, Sales_Order_Type__c = 'RLF-RLF');
        insert contract;

        Product_Set__c ps = TestUtility.sampleProductSet(testAcc.Id);
        insert ps;
            
        System__c sys = TestUtility.sampleSystem(testAcc.Id);
        sys.Licence_Group__c = 'licGrp';
        insert sys;
        
        Client_Asset__c cla = TestUtility.sampleClientAsset(ps.Id);
        insert cla;

        list<NS_Subscription_Term__c> nstList = new list<NS_Subscription_Term__c>();
        NS_Subscription_Term__c nst = new NS_Subscription_Term__c(Name = '120 months', Months__c = 120, NS_Subscription_Term_Internal_Id__c = '14');
        NS_Subscription_Term__c nst1 = new NS_Subscription_Term__c(Name = '36 months', Months__c = 36, NS_Subscription_Term_Internal_Id__c = '7');

        nstList.add(nst);
        nstList.add(nst1);
        insert nstList;
        
        NS_Billing_Frequency__c nbf = new NS_Billing_Frequency__c(Name = 'Yearly', Months_Per_Period__c = 12, NS_Billing_Frequency_Internal_Id__c = '8', Invoices_per_year__c = 4);
        insert nbf;
        
        NS_Currency__c nc = new NS_Currency__c(Name = 'USD', NS_Currency_Internal_Id__c = '1', IsZeroDecimal__c = true);
        insert nc;
        
        NS_Revenue_Recognition_Template__c nrrt = new NS_Revenue_Recognition_Template__c(Name = 'POC');
        insert nrrt;
        
        Billing_Group__c billingGroup = new Billing_Group__c();
        billingGroup.Account_by_Sub__c = accBySub.Id;
        billingGroup.BG_Billing_Group_Active__c = true;
        billingGroup.Initial_RLF_Package_Created__c = false;
        billingGroup.Original_Opportunity__c = opp.Id;
        billingGroup.Original_Contract__c = contract.Id;
        billingGroup.BG_Client_Bill_To__c = btstList[0].Id;
        billingGroup.BG_Client_Ship_To__c = btstList[0].Id;
        billingGroup.NS_Customer_Ship_To_Address__c = custAddList[0].Id;
        billingGroup.NS_Subscription_Term__c = nst.Id;
        billingGroup.NS_Rating_Frequency_Billing_Period__c = nbf.Id;
        billingGroup.NS_Billing_Frequency__c = nbf.Id;
        billingGroup.NS_Subscription_Billing_Method__c = 'Advance';
        billingGroup.NS_Subscription_Option__c = 'New Subscription';
        billingGroup.NS_Billing_Mode__c = 'Fixed Date';
        billingGroup.NS_Subscription_Start_Type__c = 'On start date';
        billingGroup.NS_Termination_Method__c = 'Upon Cancellation';
        billingGroup.NS_Subscription_Notice_Period__c = '1';
        billingGroup.NS_Subscription_Minimum_Term__c = nst1.Id;
        billingGroup.BG_Misys_Billing_Entity__c = misysEntity.Id;
        billingGroup.RLF_Batch_Create__c = true;
        
        insert billingGroup;

        Contract_Asset__c ca = TestUtility.sampleContractAsset(cla.Id, sys.Id, testAcc.Id);
        ca.OpportunityLineItem__c = null;
        ca.Product__c = prodList[0].Id;
        ca.Contract__c = contract.Id;
        ca.CA_Billing_Status__c = 'Active billing';
        ca.CA_Billing_Group__c = billingGroup.Id;
        ca.Annual_RLF_Maint_Override__c = 567.00;
        ca.Annual_Maintenance__c = 567.00;
        insert ca;
        
        Test.startTest();
        CreateRLFPackage.createSalesOrder(billingGroup.Id, 'Initial');
        CreateRLFPackage.checkZeroDecimalCurrency(billingGroup.Id);
        Test.stopTest();
    }
}