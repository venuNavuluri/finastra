@isTest
public class test_OpportunityLineItem {

    public static testmethod void test_OLI()
    {

        User testUser = TestUtility.sampleUser();
        insert testUser;

        List<Product2> products = new List<Product2>();
        Product2 testProd = TestUtility.sampleProduct();
        testProd.Family = 'CLD (TB)';
        testProd.CanUseRevenueSchedule= true;
        products.add(testProd);

        Product2 testProd_HOS = TestUtility.sampleProduct();
        testProd_HOS.Family = 'HOS (CB)';
        testProd_HOS.CanUseRevenueSchedule= true;
        products.add(testProd_HOS);

        Product2 testProd_SUB = TestUtility.sampleProduct();
        testProd_SUB.Family = 'SUB (CB)';
        testProd_SUB.CanUseRevenueSchedule= true;
        products.add(testProd_SUB);

        Product2 testProd_HOSTB = TestUtility.sampleProduct();
        testProd_HOSTB.Family = 'HOS (TB)';
        testProd_HOSTB.CanUseRevenueSchedule= true;
        products.add(testProd_HOSTB);

        Product2 testProd_HOSIM = TestUtility.sampleProduct();
        testProd_HOSIM.Family = 'HOS (IM)';
        testProd_HOSIM.CanUseRevenueSchedule= true;
        products.add(testProd_HOSIM);

        Product2 testProd_CLDCB = TestUtility.sampleProduct();
        testProd_CLDCB.Family = 'CLD (CB)';
        testProd_CLDCB.CanUseRevenueSchedule= true;
        products.add(testProd_CLDCB);

        Product2 testProd_CLDCL = TestUtility.sampleProduct();
        testProd_CLDCL.Family = 'CLD (CL)';
        testProd_CLDCL.CanUseRevenueSchedule= true;
        products.add(testProd_CLDCL);

        Product2 testProd_CLDCM = TestUtility.sampleProduct();
        testProd_CLDCM.Family = 'CLD (CM)';
        testProd_CLDCM.CanUseRevenueSchedule= true;
        products.add(testProd_CLDCM);

        insert products;

        
        Id stdPbId = Test.getStandardPricebookId();

        List<PricebookEntry> pbe = new List<PricebookEntry>();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = testProd.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        pbe.add(standardPrice);

        PricebookEntry standardPrice_HOS = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = testProd_HOS.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        pbe.add(standardPrice_HOS);

        PricebookEntry standardPrice_SUB = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = testProd_SUB.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        pbe.add(standardPrice_SUB);

        PricebookEntry standardPrice_HOSTB = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = testProd_HOSTB.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        pbe.add(standardPrice_HOSTB);

        PricebookEntry standardPrice_HOSIM = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = testProd_HOSIM.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        pbe.add(standardPrice_HOSIM);

        PricebookEntry standardPrice_CLDCB = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = testProd_CLDCB.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        pbe.add(standardPrice_CLDCB);

        PricebookEntry standardPrice_CLDCL = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = testProd_CLDCL.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        pbe.add(standardPrice_CLDCL);

        PricebookEntry standardPrice_CLDCM = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = testProd_CLDCM.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        pbe.add(standardPrice_CLDCM);
        insert pbe;

		
        Id MisysPbId = TestIntegrationLogUtils.GetMisysPricebookId();

        insert new PricebookEntry(pricebook2id = MisysPbId,  product2id = testProd.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert new PricebookEntry(pricebook2id = MisysPbId,  product2id = testProd_HOS.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert new PricebookEntry(pricebook2id = MisysPbId,  product2id = testProd_SUB.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert new PricebookEntry(pricebook2id = MisysPbId,  product2id = testProd_HOSTB.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert new PricebookEntry(pricebook2id = MisysPbId,  product2id = testProd_HOSIM.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert new PricebookEntry(pricebook2id = MisysPbId,  product2id = testProd_CLDCB.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert new PricebookEntry(pricebook2id = MisysPbId,  product2id = testProd_CLDCL.id,unitprice=1.0, isActive=true, UseStandardPrice = false);
        insert new PricebookEntry(pricebook2id = MisysPbId,  product2id = testProd_CLDCM.id,unitprice=1.0, isActive=true, UseStandardPrice = false);


        List<OpportunityLineItem> oppListToInsert = new List<OpportunityLineItem>();

        
        Opportunity opp = TestUtility.sampleOpportunity();
        opp.ownerId = testUser.Id;
        opp.CurrencyIsoCode='USD';
        opp.Rollup_Calculate_Batch_Hold__c = false;
        insert opp;

        system.debug('##limitA  = ' + limits.getQueries());


        OpportunityLineItem oli2 = TestUtility.sampleOpportunityLineItemDoNotUpdateOrder(opp, 'SUB (CB)');
        oli2.Pearl_Item__c = true;
        oli2.Commissionable_Value__c = 2;
        oli2.Sold_Value__c = 4;
        oppListToInsert.add(oli2);

        OpportunityLineItem oli3 = TestUtility.sampleOpportunityLineItemDoNotUpdateOrder(opp, 'HOS (CB)');
        oli3.Pearl_Item__c = true;
        oli3.Commissionable_Value__c = 2;
        oli3.Sold_Value__c = 14;
        oppListToInsert.add(oli3);

        OpportunityLineItem oli4 = TestUtility.sampleOpportunityLineItemDoNotUpdateOrder(opp, 'HOS (TB)');
        oli4.Pearl_Item__c = true;
        oli4.Commissionable_Value__c = 2;
        oli4.Sold_Value__c = 4;
        oppListToInsert.add(oli4);

        OpportunityLineItem oli5 = TestUtility.sampleOpportunityLineItemDoNotUpdateOrder(opp, 'HOS (IM)');
        oli5.Pearl_Item__c = true;
        oli5.Commissionable_Value__c = 2;
        oli5.Sold_Value__c = 4;
        oppListToInsert.add(oli5);

        OpportunityLineItem oli1 = TestUtility.sampleOpportunityLineItemDoNotUpdateOrder(opp, 'CLD (TB)');
        oli1.Pearl_Item__c = true;
        oli1.Commissionable_Value__c = 2;
        oli1.Sold_Value__c = 4;
        oppListToInsert.add(oli1);

        /*OpportunityLineItem oli6 = TestUtility.sampleOpportunityLineItem(opp, 'CLD (CB)');
        oli6.Pearl_Item__c = true;
        oli6.Commissionable_Value__c = 2;
        oli6.Sold_Value__c = 2.2;
        oppListToInsert.add(oli6);

        OpportunityLineItem oli7 = TestUtility.sampleOpportunityLineItem(opp, 'CLD (CL)');
        oli7.Pearl_Item__c = true;
        oli7.Commissionable_Value__c = 2;
        oli7.Sold_Value__c = 2.2;
        oppListToInsert.add(oli7);

        OpportunityLineItem oli8 = TestUtility.sampleOpportunityLineItem(opp, 'CLD (CM)');
        oli8.Pearl_Item__c = true;
        oli8.Commissionable_Value__c = 2;
        oli8.Sold_Value__c = 2.2;
        oppListToInsert.add(oli8);*/


        

		

        // update oppListToInsert;

        // List<OpportunityLineItem> oppListToUpdate = new List<OpportunityLineItem>();

        GlobalVar.bSystemAllowOppLineItemDelete = true;
        
            insert oppListToInsert;
        
        Test.startTest();
            system.debug('##limitA  = ' + limits.getQueries());
            Opportunity testOpp = [Select Id,tcv_hos__c,tcv_sub__c,tcv_cld__c,CommValue_HOS__c,CommValue_SUB__c,CommValue_CLD__c  from opportunity where  Id  = :opp.Id];
            System.assertEquals(2,testOpp.CommValue_CLD__c);
            System.assertEquals(4, testOpp.tcv_cld__c);
            System.assertEquals(22, testOpp.tcv_hos__c);
            oli1.Commissionable_Value__c = 4;
            oli1.Sold_Value__c = 2.0;
            update oli1;
            system.debug('##limitB  = ' + limits.getQueries());
            testOpp = [Select Id,tcv_hos__c,tcv_sub__c,tcv_cld__c,CommValue_HOS__c,CommValue_SUB__c,CommValue_CLD__c  from opportunity where  Id  = :opp.Id];
    
            //System.assertEquals(2.00,testOpp.tcv_cld__c);
            System.assertEquals(4,testOpp.CommValue_CLD__c);
            
            system.debug('##limitC  = ' + limits.getQueries());
	        delete oppListToInsert;
			system.debug('##limitD  = ' + limits.getQueries());
        Test.stopTest();

        testOpp = [Select Id,tcv_hos__c,tcv_sub__c,tcv_cld__c,CommValue_HOS__c,CommValue_SUB__c,CommValue_CLD__c  from opportunity where  Id  = :opp.Id];
        System.assertEquals(0.0, testOpp.tcv_sub__c);
        System.assertEquals(0.0, testOpp.tcv_cld__c);
        System.assertEquals(0.0, testOpp.tcv_hos__c);

    }

    // List<OpportunityLineItem> oppListToUpdate = new List<OpportunityLineItem>();

}