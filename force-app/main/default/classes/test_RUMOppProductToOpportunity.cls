/**
 * Created by ngronows on 05/09/2017.
 */

@IsTest
private class test_RUMOppProductToOpportunity {

    /*
        maintenance sweep

        rec.TotalPrice = (totalLIPrice*reviewCycleLength*inRate)/100;
        totalLIPrice = ca.Annual_Maintenance_2017_Base__c;
        Decimal reviewCycleLength = getReviewCycleLength(ca);
        Decimal inRate = getVariableRate(ca,CA_RF_Standard_Increase_to_be_applied);

        RollUpManager
        RUMOppProductToOpportunity

        The field that is set on opportunity is chosen based on product family: TheOLI.PricebookEntry.Product2.Family;
        The amount is summed only from Fair_Value__c or TotalPrice on OLI. getAmount()
        Total price is based on Account.Contract Asset related list with CA Billing Status = 'Active billing'

        prod family: RLF (CM) (i == 27)  TheOppty.RSF_RLF_CM_TP__c;
    */

    static testMethod void shouldRollUp_RSF_RLF_CM_TP() {


        list<Product2> prodList = new list<Product2>();
        Product2 prod = new Product2(Name = 'testProd', Family = 'RLF (CM)', SO_Grouping__c = 'RLF-RLF',
                CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561',
                CanUseRevenueSchedule = true);
        prodList.add(prod);

        insert prodList;

        Id pricebookId = Test.getStandardPricebookId();


        list<PricebookEntry> pbeList = new list<PricebookEntry>();
        PricebookEntry pbItem = new PricebookEntry(Product2Id = prod.Id, UnitPrice = 10.00, PriceBook2Id = pricebookId,
                UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'GBP');
        pbeList.add(pbItem);

        insert pbeList;

        Opportunity testOpp1 = TestUtility.sampleOpportunity();
        testOpp1.CloseDate = system.today();
        //testOpp1.OLIs_Pushed_To_Parent__c = true; Victor: the field was retired in PROD and is causing an error here
        insert testOpp1;

        OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem(testOpp1, 'RLF (CM)');
        insert oli;



        List<Opportunity> result = [select id, RSF_RLF_CM_TP__c from Opportunity where id = :testOpp1.id];

        // it's a 100 because Quantity = 1 and TotalPrice = 100 on oli
        //system.assertEquals(100,Integer.valueOf(result.get(0).RSF_RLF_CM_TP__c), 'RSF_RLF_CM_TP__c on opportunity should be updated');

    }

    static testMethod void shouldRollUp_RSF_RLF_ER() {


        list<Product2> prodList = new list<Product2>();
        Product2 prod = new Product2(Name = 'testProd', Family = 'RLF (ER)', SO_Grouping__c = 'RLF-RLF',
                CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561',
                CanUseRevenueSchedule = true);
        prodList.add(prod);

        insert prodList;

        Id pricebookId = Test.getStandardPricebookId();


        list<PricebookEntry> pbeList = new list<PricebookEntry>();
        PricebookEntry pbItem = new PricebookEntry(Product2Id = prod.Id, UnitPrice = 10.00, PriceBook2Id = pricebookId,
                UseStandardPrice = false, IsActive = true, CurrencyISOCode = 'GBP');
        pbeList.add(pbItem);

        insert pbeList;

        Opportunity testOpp1 = TestUtility.sampleOpportunity();
        testOpp1.CloseDate = system.today();
        //testOpp1.OLIs_Pushed_To_Parent__c = true; //Victor: the field was retired in PROD and is causing an error here
        insert testOpp1;

        OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem(testOpp1, 'RLF (ER)');
        oli.Fair_Value__c = 15;
        insert oli;



        List<Opportunity> result = [select id, RSF_RLF_ER__c from Opportunity where id = :testOpp1.id];
        // it's a 100 because Quantity = 1 and TotalPrice = 100 on oli
        // also why RSF_RLF_ER__c == 14.999999999999999999999999999999986 ?
        system.assertEquals(15,result.get(0).RSF_RLF_ER__c.round(), 'RSF_RLF_ER__c on opportunity should be updated');

    }
}