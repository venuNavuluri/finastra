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
private class Test_ce4sfStep_GetPendingSalesOrderType {

    static testMethod void myUnitTest() {
        Opportunity opp = TestUtility.sampleOpportunity();
        opp.CurrencyISOCode = 'USD';
        insert opp;
        
        list<Product2> prodList = new list<Product2>();
        Product2 prod = new Product2(Name = 'testProd', SO_Grouping__c = 'ILF-ILF', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00);
        prodList.add(prod);
        Product2 prod1 = new Product2(Name = 'testProd1', SO_Grouping__c = 'ILF-RA', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00);
        prodList.add(prod1);
        Product2 prod2 = new Product2(Name = 'testProd2', SO_Grouping__c = 'PS-PS', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, ProductCode = 'SVFP');
        prodList.add(prod2);
        Product2 prod3 = new Product2(Name = 'testProd3', SO_Grouping__c = 'PS-PSS', CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, ProductCode = 'SVTM');
        prodList.add(prod3);

        insert prodList;
        
        PriceBook2 pb = [select id from pricebook2 where isstandard = true];
        
        list<PricebookEntry> pbeList = new list<PricebookEntry>();
        PricebookEntry pbItem = new PricebookEntry(Product2Id = prod.Id, UnitPrice = 10.00, PriceBook2Id = pb.Id, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem);
        PricebookEntry pbItem1 = new PricebookEntry(Product2Id = prod1.Id, UnitPrice = 10.00, PriceBook2Id = pb.Id, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem1);
        PricebookEntry pbItem2 = new PricebookEntry(Product2Id = prod2.Id, UnitPrice = 10.00, PriceBook2Id = pb.Id, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem2);
        PricebookEntry pbItem3 = new PricebookEntry(Product2Id = prod3.Id, UnitPrice = 10.00, PriceBook2Id = pb.Id, UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'USD');
        pbeList.add(pbItem3);
        
        insert pbeList;
        
        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
        OpportunityLineItem oli1 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli1.PricebookEntryId = pbItem.Id;
        oli1.Pearl_Item__c = true;
        oliList.add(oli1);
        
        OpportunityLineItem oli2 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli2.PricebookEntryId = pbItem.Id;
        oli2.Pearl_Item__c = false;
        oliList.add(oli2);
        
        OpportunityLineItem oli3 = TestUtility.sampleOpportunityLineItem(opp, 'ILF (B)');
        oli3.PricebookEntryId = pbItem1.Id;
        oli3.Pearl_Item__c = true;
        oliList.add(oli3);

        OpportunityLineItem oli4 = TestUtility.sampleOpportunityLineItem(opp, 'PS (B)');
        oli4.PricebookEntryId = pbItem2.Id;
        oli4.Pearl_Item__c = true;
        oliList.add(oli4);

        OpportunityLineItem oli5 = TestUtility.sampleOpportunityLineItem(opp, 'PS (B)');
        oli5.PricebookEntryId = pbItem3.Id;
        oli5.Pearl_Item__c = true;
        oliList.add(oli5);
        insert oliList;
        
        Test.startTest();
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
        oli5.Opportunity_Billing_Schedule__c = obs1.Id;
        oliListUpdate.add(oli1);
        oliListUpdate.add(oli2);
        oliListUpdate.add(oli3);
        oliListUpdate.add(oli4);
        oliListUpdate.add(oli5);
        update oliListUpdate;

        ce4sf20_001.AeServiceRequest request = new ce4sf20_001.AeServiceRequest();
        request.objectId = '123456789';
        request.objectType = 'TestObject';
        request.addParameter('opportunityId', opp.Id);
    
        // invoke the service
        ce4sf20_001.IAeAutomatedStepService service = new ce4sfStep_GetPendingSalesOrderType();
        ce4sf20_001.AeServiceResponse response = service.invoke(request);
        system.debug('response = ' + response);
        Test.stopTest();
    }

	//test coverage when opportunity id is not passed
    static testMethod void myUnitTest2() {
        ce4sf20_001.AeServiceRequest request = new ce4sf20_001.AeServiceRequest();
        request.objectId = '123456789';
        request.objectType = 'TestObject';
        request.addParameter('opportunityId', null);
    
        // invoke the service
        ce4sf20_001.IAeAutomatedStepService service = new ce4sfStep_GetPendingSalesOrderType();
        ce4sf20_001.AeServiceResponse response = service.invoke(request);
        system.debug('response = ' + response);
    }
}