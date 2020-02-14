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
private class Test_ce4sfStep_CreateILFPackage {

    private static Id pbId;
    static {
        pbId = TestUtils.getStandardPriceBookId();
    }
    
    static testMethod void myUnitTest1() {
        Opportunity opp = TestUtility.sampleOpportunity();
        opp.CurrencyISOCode = 'USD';
        insert opp;
        
        list<Product2> prodList = new list<Product2>();
        Product2 prod = new Product2(Name = 'testProd', SO_Grouping__c = 'ILF-ILF', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561');
        prodList.add(prod);
        Product2 prod1 = new Product2(Name = 'testProd1', SO_Grouping__c = 'ILF-RA', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234562', X3rd_Party_Product__c = true, NS_3PP_Vendor_ID__c = '123456');
        prodList.add(prod1);
        Product2 prod2 = new Product2(Name = 'testProd2', SO_Grouping__c = 'PS-PSS', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, ProductCode = 'SVFP', UPID__c = '1234563');
        prodList.add(prod2);
        Product2 prod3 = new Product2(Name = 'testProd3', SO_Grouping__c = 'PS-PSS', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, ProductCode = 'SVTM', UPID__c = '1234564');
        prodList.add(prod3);
        
        insert prodList;
        
        //pricebook2 standardpb = [select id from pricebook2 where isstandard = true];
        
       
        list<PricebookEntry> pbeList = new list<PricebookEntry>();
        PricebookEntry pbItem = new PricebookEntry(Product2Id = prod.Id, UnitPrice = 10.00, PriceBook2Id = pbId, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem);
        PricebookEntry pbItem1 = new PricebookEntry(Product2Id = prod1.Id, UnitPrice = 10.00, PriceBook2Id = pbId, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem1);
        PricebookEntry pbItem2 = new PricebookEntry(Product2Id = prod2.Id, UnitPrice = 10.00, PriceBook2Id = pbId, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem2);
        PricebookEntry pbItem3 = new PricebookEntry(Product2Id = prod3.Id, UnitPrice = 10.00, PriceBook2Id = pbId, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem3);
        
        insert pbeList;

       Test.startTest();

        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
        OpportunityLineItem oli1 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbItem.Id;
        oli1.NS_Order_Form_Type__c = 'ILF-ILF';
        oli1.Pearl_Item__c = true;
        oli1.Fair_Value__c = 10.00;
        oliList.add(oli1);
        
        OpportunityLineItem oli2 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbItem.Id;
        oli2.NS_Order_Form_Type__c = 'ILF-ILF';
        oli2.Pearl_Item__c = false;
        oli2.Fair_Value__c = 10.00;
        oliList.add(oli2);
        
        OpportunityLineItem oli3 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli3.OpportunityId = opp.Id;
        oli3.PricebookEntryId = pbItem1.Id;
        oli3.NS_Order_Form_Type__c = 'ILF-RA';
        oli3.Pearl_Item__c = true;
        oli3.Fair_Value__c = 10.00;
        oli3.ThirdParty_Costs_PO_Ccy__c = 100;
        oliList.add(oli3);
/*
        OpportunityLineItem oli4 = TestUtility.sampleOpportunityLineItem(opp, 'PS (B)');
        oli4.OpportunityId = opp.Id;
        oli4.PricebookEntryId = pbItem2.Id;
        oli4.NS_Order_Form_Type__c = 'PS-PSS';
        oli4.Pearl_Item__c = true;
        oli4.Fair_Value__c = 10.00;
        oliList.add(oli4);

        OpportunityLineItem oli5 = TestUtility.sampleOpportunityLineItem(opp, 'PS (B)');
        oli5.OpportunityId = opp.Id;
        oli5.PricebookEntryId = pbItem3.Id;
        oli5.NS_Order_Form_Type__c = 'PS-PSS';
        oli5.Pearl_Item__c = true;
        oli5.Fair_Value__c = 10.00;
        oliList.add(oli5);
*/
        insert oliList;

        Opportunity_Billing_Schedule__c obs = new Opportunity_Billing_Schedule__c(Opportunity__c = opp.Id, Processing_Type__c = 'ILF');
        insert obs;
        
        Opportunity_Billing_Schedule_Item__c obsItem = new Opportunity_Billing_Schedule_Item__c(Name = 'M1 - 20% Start of UAT', Narrative__c = '20% Start of UAT', Opportunity_Billing_Schedule__c = obs.Id, Line__c = 30);
        insert obsItem;
       /* 
        Opportunity_Billing_Schedule__c obs1 = new Opportunity_Billing_Schedule__c(Opportunity__c = opp.Id, Processing_Type__c = 'PS');
        insert obs1;
        
        Opportunity_Billing_Schedule_Item__c obsItem1 = new Opportunity_Billing_Schedule_Item__c(Name = 'M1 - 20% Start of UAT', Narrative__c = '20% Start of UAT', Opportunity_Billing_Schedule__c = obs1.Id, Line__c = 30);
        insert obsItem1;
        */
        list<OpportunityLineItem> oliListUpdate = new list<OpportunityLineItem>();
        oli1.Opportunity_Billing_Schedule__c = obs.Id;
        oli2.Opportunity_Billing_Schedule__c = obs.Id;
        oli3.Opportunity_Billing_Schedule__c = obs.Id;
        //oli4.Opportunity_Billing_Schedule__c = obs1.Id;
        oliListUpdate.add(oli1);
        oliListUpdate.add(oli2);
        oliListUpdate.add(oli3);
        //oliListUpdate.add(oli4);
        update oliListUpdate;
        system.debug('oliList = ' + oliList);
        system.debug('oliListUpdate = ' + oliListUpdate);

        CCRT__c testCCRT = TestUtility.sampleCCRT();
        testCCRT.Client_Site_Number__c = '12456';
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
        
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id);
        insert accBySub;
        
        list<NS_Customer_Address__c> custAddList = [select id from NS_Customer_Address__c where Acct_By_Sub__c = :accBySub.Id];

        Contract contract = new Contract(Misys_Opportunity__c = opp.Id, StartDate = Date.today(), AccountId = testAcc.Id, Sales_Order_Type__c = 'ILF-ILF;ILF-RA');
        insert contract;

       ce4sf20_001.AeServiceRequest request = new ce4sf20_001.AeServiceRequest();
       request.objectId = '123456789';
       request.objectType = 'TestObject';
       request.addParameter('opportunityId', opp.Id);
       request.addParameter('acctBySubId', accBySub.Id);
       request.addParameter('contractId', contract.Id);
       request.addParameter('billToId', custAddList[0].Id);
       request.addParameter('shipToId', custAddList[1].Id);
    
       // invoke the service
       // Test.startTest();
       ce4sf20_001.IAeAutomatedStepService service = new ce4sfStep_CreateILFPackage();
       ce4sf20_001.AeServiceResponse response = service.invoke(request);
        system.debug('response = ' + response);
        
        //This is for testing the DeleteSalesOrderPackage class which gets invoked from Delete Sales Orders button on Contract
        DeleteSalesOrderPackage.deletePackage(contract.id);
       Test.stopTest(); 
    }


    static testMethod void myUnitTest2() {
        CCRT__c testCCRT = TestUtility.sampleCCRT();
        testCCRT.Client_Site_Number__c = '12456';
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
        
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id);
        insert accBySub;
        
        list<NS_Customer_Address__c> custAddList = [select id from NS_Customer_Address__c where Acct_By_Sub__c = :accBySub.Id];

        Opportunity opp = TestUtility.sampleOpportunity();
        opp.CurrencyISOCode = 'USD';
        opp.StageName = 'Closed Won';
        opp.CloseDate = Date.today();
        opp.Approval_Status__c = 'APPROVED';
        insert opp;
        
        list<Product2> prodList = new list<Product2>();
        Product2 prod = new Product2(Name = 'testProd', SO_Grouping__c = 'ILF-ILF', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561');
        prodList.add(prod);
        Product2 prod1 = new Product2(Name = 'testProd1', SO_Grouping__c = 'ILF-RA', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234562');
        prodList.add(prod1);
        Product2 prod2 = new Product2(Name = 'testProd2', SO_Grouping__c = 'PS-PS', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, ProductCode = 'SVFP', UPID__c = '1234563');
        prodList.add(prod2);
        Product2 prod3 = new Product2(Name = 'testProd3', SO_Grouping__c = 'PS-PSS', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, ProductCode = 'SVTM', UPID__c = '1234564');
        prodList.add(prod3);
        
        Product2 prod4 = new Product2(Name = 'Test-FED: Reimbursable Expenses', SO_Grouping__c = 'PS-FED', UPID__c = '5909901', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, ProductCode = 'SVTM');
        prodList.add(prod4);
        Product2 prod5 = new Product2(Name = 'Test-PSS: Reimbursable Expenses', SO_Grouping__c = 'PS-PSS', UPID__c = '5909902', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, ProductCode = 'SVTM');
        prodList.add(prod5);
        Product2 prod6 = new Product2(Name = 'Test-PS: Expense Markup', SO_Grouping__c = 'PS-PS', UPID__c = '5909904', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, ProductCode = 'SVTM');
        prodList.add(prod6);
        Product2 prod7 = new Product2(Name = 'Test-PS: Reimbursable Expenses', SO_Grouping__c = 'PS-PS', UPID__c = '5909903', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, ProductCode = 'SVTM');
        prodList.add(prod7);
        insert prodList;
        
        list<T_And_E_Items__c> teItemList = new list<T_And_E_Items__c>();
        T_And_E_Items__c te1 = new T_And_E_Items__c(Name = 'Test-FED: Reimbursable Expenses', Sales_Order_Type__c = 'FED', UPID__c = '5909901', Quantity__c = 1000, Rate__c = 0.1, OA_Billing_Rule_Internal_Id__c = '1');
        teItemList.add(te1);
        //T_And_E_Items__c te2 = new T_And_E_Items__c(Name = 'Test-PS: Expense Markup', Sales_Order_Type__c = 'PS', UPID__c = '5909904', Quantity__c = 10000, Rate__c = 0.1, OA_Billing_Rule_Internal_Id__c = '1', Rev_Rec_Schedule_Internal_Id__c = '37', OA_Rev_Rec_Rule_Internal_Id__c = '2');
        //teItemList.add(te2);
        T_And_E_Items__c te3 = new T_And_E_Items__c(Name = 'Test-PS: Reimbursable Expenses', Sales_Order_Type__c = 'PS', UPID__c = '5909903', Quantity__c = 10000, Rate__c = 0.1, OA_Billing_Rule_Internal_Id__c = '1', Rev_Rec_Schedule_Internal_Id__c = '37', OA_Rev_Rec_Rule_Internal_Id__c = '2');
        teItemList.add(te3);
        T_And_E_Items__c te4 = new T_And_E_Items__c(Name = 'Test-PSS: Reimbursable Expenses', Sales_Order_Type__c = 'PSS', UPID__c = '5909902', Quantity__c = 1000, Rate__c = 0.1, OA_Billing_Rule_Internal_Id__c = '1');
        teItemList.add(te4);
        insert teItemList;
        
        
        list<PricebookEntry> pbeList = new list<PricebookEntry>();
        PricebookEntry pbItem = new PricebookEntry(Product2Id = prod.Id, UnitPrice = 10.00, PriceBook2Id = pbId, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem);
        PricebookEntry pbItem1 = new PricebookEntry(Product2Id = prod1.Id, UnitPrice = 10.00, PriceBook2Id = pbId, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem1);
        PricebookEntry pbItem2 = new PricebookEntry(Product2Id = prod2.Id, UnitPrice = 10.00, PriceBook2Id = pbId, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem2);
        PricebookEntry pbItem3 = new PricebookEntry(Product2Id = prod3.Id, UnitPrice = 10.00, PriceBook2Id = pbId, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem3);
        
        insert pbeList;

       Test.startTest();

        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
      
        OpportunityLineItem oli1 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli1.PricebookEntryId = pbItem.Id;
        oli1.NS_Order_Form_Type__c = 'ILF-ILF';
        oli1.Pearl_Item__c = true;
        oli1.Fair_Value__c = 10.00;
        oliList.add(oli1);
        
        OpportunityLineItem oli2 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli2.PricebookEntryId = pbItem.Id;
        oli2.NS_Order_Form_Type__c = 'ILF-ILF';
        oli2.Pearl_Item__c = false;
        oli2.Fair_Value__c = 10.00;
        oliList.add(oli2);
        
        OpportunityLineItem oli3 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli3.PricebookEntryId = pbItem1.Id;
        oli3.NS_Order_Form_Type__c = 'ILF-RA';
        oli3.Pearl_Item__c = true;
        oli3.Fair_Value__c = 10.00;
        oliList.add(oli3);

        OpportunityLineItem oli4 = TestUtility.sampleOpportunityLineItem(opp, 'PS (B)');
        oli4.PricebookEntryId = pbItem2.Id;
        oli4.NS_Order_Form_Type__c = 'PS-PS';
        oli4.Pearl_Item__c = true;
        oli4.Fair_Value__c = 10.00;
        oliList.add(oli4);

        OpportunityLineItem oli5 = TestUtility.sampleOpportunityLineItem(opp, 'PS (B)');
        oli5.PricebookEntryId = pbItem3.Id;
        oli5.NS_Order_Form_Type__c = 'PS-PSS';
        oli5.Pearl_Item__c = true;
        oli5.Fair_Value__c = 10.00;
        oliList.add(oli5);

        insert oliList;

        //Opportunity_Billing_Schedule__c obs = new Opportunity_Billing_Schedule__c(Opportunity__c = opp.Id, Processing_Type__c = 'ILF');
        //insert obs;
        
        //Opportunity_Billing_Schedule_Item__c obsItem = new Opportunity_Billing_Schedule_Item__c(Name = 'M1 - 20% Start of UAT', Narrative__c = '20% Start of UAT', Opportunity_Billing_Schedule__c = obs.Id, Line__c = 30);
        //insert obsItem;
        
        Opportunity_Billing_Schedule__c obs1 = new Opportunity_Billing_Schedule__c(Opportunity__c = opp.Id, Processing_Type__c = 'PS');
        insert obs1;
        
        Opportunity_Billing_Schedule_Item__c obsItem1 = new Opportunity_Billing_Schedule_Item__c(Name = 'M1 - 20% Start of UAT', Narrative__c = '20% Start of UAT', Opportunity_Billing_Schedule__c = obs1.Id, Line__c = 30);
        insert obsItem1;
        
        list<OpportunityLineItem> oliListUpdate = new list<OpportunityLineItem>();
        //oli1.Opportunity_Billing_Schedule__c = obs.Id;
        //oli2.Opportunity_Billing_Schedule__c = obs.Id;
        //oli3.Opportunity_Billing_Schedule__c = obs.Id;
        oli4.Opportunity_Billing_Schedule__c = obs1.Id;
        //oliListUpdate.add(oli1);
        //oliListUpdate.add(oli2);
        //oliListUpdate.add(oli3);
        oliListUpdate.add(oli4);
        update oliListUpdate;

        Contract contract = new Contract(Misys_Opportunity__c = opp.Id, StartDate = Date.today(), AccountId = testAcc.Id, Sales_Order_Type__c = 'PS-PS;PS-PSS');
        insert contract;

       ce4sf20_001.AeServiceRequest request = new ce4sf20_001.AeServiceRequest();
       request.objectId = '123456789';
       request.objectType = 'TestObject';
       request.addParameter('opportunityId', opp.Id);
       request.addParameter('acctBySubId', accBySub.Id);
       request.addParameter('contractId', contract.Id);
       request.addParameter('billToId', custAddList[0].Id);
       request.addParameter('shipToId', custAddList[1].Id);
    
       // invoke the service
       //Test.startTest();
       ce4sf20_001.IAeAutomatedStepService service = new ce4sfStep_CreateILFPackage();
       ce4sf20_001.AeServiceResponse response = service.invoke(request);
       system.debug('response = ' + response);
       Test.stopTest();
        
    }

    

    static testMethod void myUnitTest3() {
        CCRT__c testCCRT = TestUtility.sampleCCRT();
        testCCRT.Client_Site_Number__c = '12456';
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
        
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id);
        insert accBySub;
        
        list<NS_Customer_Address__c> custAddList = [select id from NS_Customer_Address__c where Acct_By_Sub__c = :accBySub.Id];

        Opportunity opp = TestUtility.sampleOpportunity();
        opp.CurrencyISOCode = 'USD';
        insert opp;
        
        list<Product2> prodList = new list<Product2>();
        Product2 prod = new Product2(Name = 'testProd', SO_Grouping__c = 'RLF-RLF', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561');
        prodList.add(prod);
        
        insert prodList;
        
        list<PricebookEntry> pbeList = new list<PricebookEntry>();
        PricebookEntry pbItem = new PricebookEntry(Product2Id = prod.Id, UnitPrice = 10.00, PriceBook2Id = pbId, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem);
        
        insert pbeList;

       Test.startTest();

        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
        OpportunityLineItem oli1 = TestUtility.sampleOpportunityLineItem(opp, 'RLF (B)');
        oli1.PricebookEntryId = pbItem.Id;
        oli1.NS_Order_Form_Type__c = 'RLF-RLF';
        oli1.Pearl_Item__c = true;
        oli1.Fair_Value__c = 10.00;
        oliList.add(oli1);
        
        insert oliList;
        
        //Opportunity_Billing_Schedule__c obs = new Opportunity_Billing_Schedule__c(Opportunity__c = opp.Id, Processing_Type__c = 'RLF', RF_Review_Month__c = 'Dec');
        Opportunity_Billing_Schedule__c obs = new Opportunity_Billing_Schedule__c(Opportunity__c = opp.Id, Processing_Type__c = 'RLF');
        insert obs;
        
        Opportunity_Billing_Schedule_Item__c obsItem = new Opportunity_Billing_Schedule_Item__c(Name = 'M1 - 20% Start of UAT', Narrative__c = '20% Start of UAT', Opportunity_Billing_Schedule__c = obs.Id, Line__c = 30);
        insert obsItem;
        
        
        list<OpportunityLineItem> oliListUpdate = new list<OpportunityLineItem>();
        oli1.Opportunity_Billing_Schedule__c = obs.Id;
        oliListUpdate.add(oli1);
        update oliListUpdate;

        Contract contract = new Contract(Misys_Opportunity__c = opp.Id, StartDate = Date.today(), AccountId = testAcc.Id, Sales_Order_Type__c = 'RLF-RLF');
        insert contract;

       ce4sf20_001.AeServiceRequest request = new ce4sf20_001.AeServiceRequest();
       request.objectId = '123456789';
       request.objectType = 'TestObject';
       request.addParameter('opportunityId', opp.Id);
       request.addParameter('acctBySubId', accBySub.Id);
       request.addParameter('contractId', contract.Id);
       request.addParameter('billToId', custAddList[0].Id);
       request.addParameter('shipToId', custAddList[1].Id);
    
       // invoke the service
       //Test.startTest();
       ce4sf20_001.IAeAutomatedStepService service = new ce4sfStep_CreateILFPackage();
       ce4sf20_001.AeServiceResponse response = service.invoke(request);
       system.debug('response = ' + response);
       CreateRLFPackage.checkPlanAvailabilityFromOBS(obs.Id);
       Test.stopTest(); 
    }
    
    //Test for third party when vendor id is not there
    static testMethod void myUnitTest4() {

        Opportunity opp = TestUtility.sampleOpportunity();
        opp.CurrencyISOCode = 'USD';
        insert opp;
        
        list<Product2> prodList = new list<Product2>();
        Product2 prod = new Product2(Name = 'testProd', SO_Grouping__c = 'ILF-ILF', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561');
        prodList.add(prod);
        Product2 prod1 = new Product2(Name = 'testProd1', SO_Grouping__c = 'ILF-RA', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234562', X3rd_Party_Product__c = true);
        prodList.add(prod1);
        Product2 prod2 = new Product2(Name = 'testProd2', SO_Grouping__c = 'PS-PSS', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, ProductCode = 'SVFP', UPID__c = '1234563');
        prodList.add(prod2);
        Product2 prod3 = new Product2(Name = 'testProd3', SO_Grouping__c = 'PS-PSS', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, ProductCode = 'SVTM', UPID__c = '1234564');
        prodList.add(prod3);
        
        insert prodList;
        
        list<PricebookEntry> pbeList = new list<PricebookEntry>();
        PricebookEntry pbItem = new PricebookEntry(Product2Id = prod.Id, UnitPrice = 10.00, PriceBook2Id = pbId, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem);
        PricebookEntry pbItem1 = new PricebookEntry(Product2Id = prod1.Id, UnitPrice = 10.00, PriceBook2Id = pbId, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem1);
        PricebookEntry pbItem2 = new PricebookEntry(Product2Id = prod2.Id, UnitPrice = 10.00, PriceBook2Id = pbId, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem2);
        PricebookEntry pbItem3 = new PricebookEntry(Product2Id = prod3.Id, UnitPrice = 10.00, PriceBook2Id = pbId, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem3);
        
        insert pbeList;

       Test.startTest();

        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
        OpportunityLineItem oli1 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbItem.Id;
        oli1.NS_Order_Form_Type__c = 'ILF-ILF';
        oli1.Pearl_Item__c = true;
        oli1.Fair_Value__c = 10.00;
        oliList.add(oli1);
        
        OpportunityLineItem oli2 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbItem.Id;
        oli2.NS_Order_Form_Type__c = 'ILF-ILF';
        oli2.Pearl_Item__c = false;
        oli2.Fair_Value__c = 10.00;
        oliList.add(oli2);
        
        OpportunityLineItem oli3 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli3.OpportunityId = opp.Id;
        oli3.PricebookEntryId = pbItem1.Id;
        oli3.NS_Order_Form_Type__c = 'ILF-RA';
        oli3.Pearl_Item__c = true;
        oli3.Fair_Value__c = 10.00;
        oli3.ThirdParty_Costs_PO_Ccy__c = 100;
        oliList.add(oli3);

        OpportunityLineItem oli4 = TestUtility.sampleOpportunityLineItem(opp, 'PS (B)');
        oli4.OpportunityId = opp.Id;
        oli4.PricebookEntryId = pbItem2.Id;
        oli4.NS_Order_Form_Type__c = 'PS-PSS';
        oli4.Pearl_Item__c = true;
        oli4.Fair_Value__c = 10.00;
        oliList.add(oli4);

        OpportunityLineItem oli5 = TestUtility.sampleOpportunityLineItem(opp, 'PS (B)');
        oli5.OpportunityId = opp.Id;
        oli5.PricebookEntryId = pbItem3.Id;
        oli5.NS_Order_Form_Type__c = 'PS-PSS';
        oli5.Pearl_Item__c = true;
        oli5.Fair_Value__c = 10.00;
        oliList.add(oli5);
        insert oliList;

        Opportunity_Billing_Schedule__c obs = new Opportunity_Billing_Schedule__c(Opportunity__c = opp.Id, Processing_Type__c = 'ILF');
        insert obs;
        
        Opportunity_Billing_Schedule_Item__c obsItem = new Opportunity_Billing_Schedule_Item__c(Name = 'M1 - 20% Start of UAT', Narrative__c = '20% Start of UAT', Opportunity_Billing_Schedule__c = obs.Id, Line__c = 30);
        insert obsItem;
        
        Opportunity_Billing_Schedule__c obs1 = new Opportunity_Billing_Schedule__c(Opportunity__c = opp.Id, Processing_Type__c = 'PS');
        insert obs1;
        
        Opportunity_Billing_Schedule_Item__c obsItem1 = new Opportunity_Billing_Schedule_Item__c(Name = 'M1 - 20% Start of UAT', Narrative__c = '20% Start of UAT', Opportunity_Billing_Schedule__c = obs1.Id, Line__c = 30);
        insert obsItem1;
        
        list<OpportunityLineItem> oliListUpdate = new list<OpportunityLineItem>();
        oli1.Opportunity_Billing_Schedule__c = obs.Id;
        oli2.Opportunity_Billing_Schedule__c = obs.Id;
        oli3.Opportunity_Billing_Schedule__c = obs.Id;
        oli4.Opportunity_Billing_Schedule__c = obs1.Id;
        oliListUpdate.add(oli1);
        oliListUpdate.add(oli2);
        oliListUpdate.add(oli3);
        oliListUpdate.add(oli4);
        update oliListUpdate;
        system.debug('oliList = ' + oliList);
        system.debug('oliListUpdate = ' + oliListUpdate);

        CCRT__c testCCRT = TestUtility.sampleCCRT();
        testCCRT.Client_Site_Number__c = '12456';
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
        
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id);
        insert accBySub;
        
        list<NS_Customer_Address__c> custAddList = [select id from NS_Customer_Address__c where Acct_By_Sub__c = :accBySub.Id];

        Contract contract = new Contract(Misys_Opportunity__c = opp.Id, StartDate = Date.today(), AccountId = testAcc.Id, Sales_Order_Type__c = 'ILF-ILF;ILF-RA');
        insert contract;

       ce4sf20_001.AeServiceRequest request = new ce4sf20_001.AeServiceRequest();
       request.objectId = '123456789';
       request.objectType = 'TestObject';
       request.addParameter('opportunityId', opp.Id);
       request.addParameter('acctBySubId', accBySub.Id);
       request.addParameter('contractId', contract.Id);
       request.addParameter('billToId', custAddList[0].Id);
       request.addParameter('shipToId', custAddList[1].Id);
    
       // invoke the service
       //Test.startTest();
       ce4sf20_001.IAeAutomatedStepService service = new ce4sfStep_CreateILFPackage();
       ce4sf20_001.AeServiceResponse response = service.invoke(request);
        system.debug('response = ' + response);
        
        //This is for testing the DeleteSalesOrderPackage class which gets invoked from Delete Sales Orders button on Contract
        DeleteSalesOrderPackage.deletePackage(contract.id);
       Test.stopTest();

    }
    
}