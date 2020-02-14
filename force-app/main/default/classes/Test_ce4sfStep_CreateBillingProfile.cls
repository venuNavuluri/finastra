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
@isTest(seeAllData=true)
private class Test_ce4sfStep_CreateBillingProfile {

    static testMethod void myUnitTest() {
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
        
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id, NS_Internal_Id__c = '124565222');
        insert accBySub;
        
        list<NS_Customer_Address__c> custAddList = [select id from NS_Customer_Address__c where Acct_By_Sub__c = :accBySub.Id];

        Opportunity opp = TestUtility.sampleOpportunity();
        opp.CurrencyISOCode = 'USD';
        insert opp;
        
        list<Product2> prodList = new list<Product2>();
        Product2 prod = new Product2(Name = 'testProd', SO_Grouping__c = 'RLF-RLF', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561');
        prodList.add(prod);
        
        insert prodList;
        
        //pricebook2 standardpb = [select id from pricebook2 where isstandard = true];
        
        PriceBook2 pb = [select id from pricebook2 where isstandard = true];
        
        list<PricebookEntry> pbeList = new list<PricebookEntry>();
        PricebookEntry pbItem = new PricebookEntry(Product2Id = prod.Id, UnitPrice = 10.00, PriceBook2Id = pb.Id, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
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

		Product_Set__c ps = TestUtility.sampleProductSet(testAcc.Id);
		insert ps;

		System__c sys = TestUtility.sampleSystem(testAcc.Id);
		sys.Licence_Group__c = 'licGrp';
		insert sys;
		
		Client_Asset__c cla = TestUtility.sampleClientAsset(ps.Id);
		insert cla;

		Contract_Asset__c ca = TestUtility.sampleContractAsset(cla.Id, sys.Id, testAcc.Id);
		ca.Product__c = prodList[0].Id;
		ca.Contract__c = contract.Id;
		ca.CA_Billing_Status__c = 'Active billing';
		insert ca;

       Test.stopTest();

       ce4sf20_001.AeServiceRequest request = new ce4sf20_001.AeServiceRequest();
       request.objectId = '123456789';
       request.objectType = 'TestObject';
       request.addParameter('opportunityId', opp.Id);
       request.addParameter('acctBySubId', accBySub.Id);
       request.addParameter('contractId', contract.Id);
       request.addParameter('billToId', custAddList[0].Id);
       request.addParameter('shipToId', custAddList[1].Id);
       request.addParameter('obsId', obs.Id);
    
       // invoke the service
       ce4sf20_001.IAeAutomatedStepService service = new ce4sfStep_CreateBillingProfile();
       ce4sf20_001.AeServiceResponse response = service.invoke(request);
       system.debug('response = ' + response);
    }
}