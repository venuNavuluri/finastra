/**
 * @author Tony Bave
 * RBX-478
 * Test class to test the "Update Exclude from VRs" (Process Builder) which in turn calls processExcludeOppValidationRule()
 * When an Opportunity Product is added to an Opportunity, then Exclude_from_VRs__c will be set true if it is a GP Product.
 */
@isTest
private class UtilInvocableMethods_Test {

    final static String PRODUCT_FAMILY_GP = 'FAM (GP)';
    final static String PRODUCT_FAMILY_OTHER = 'FAM (OT)';

    @TestSetup
    static void setupData() {
        List<Product2> products = new List<Product2>();

        // Create a GP product
        Product2 gpProduct = TestUtility.sampleProduct();
        gpProduct.Family = PRODUCT_FAMILY_GP;
        gpProduct.CanUseRevenueSchedule= true;
        gpProduct.GP_Product__c = true;
        products.add(gpProduct);

        // Create a non-GP product
        Product2 otherProduct = TestUtility.sampleProduct();
        otherProduct.Family = PRODUCT_FAMILY_OTHER;
        otherProduct.CanUseRevenueSchedule= true;
        otherProduct.GP_Product__c = false;
        products.add(otherProduct);

        insert products;

        // Create pricebook
        Id stdPbId = Test.getStandardPricebookId();

        List<PricebookEntry> pricebook = new List<PricebookEntry>();
        PricebookEntry gpPrice = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = gpProduct.Id, UnitPrice = 10000, CurrencyIsoCode='GBP', IsActive = true, UseStandardPrice = false);
        pricebook.add(gpPrice);

        PricebookEntry otherPrice = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = otherProduct.Id, UnitPrice = 10000, CurrencyIsoCode='GBP', IsActive = true, UseStandardPrice = false);
        pricebook.add(otherPrice);

        insert pricebook;
    }

    @IsTest
    static void testOpportunityWithGPProduct() {
        // GIVEN an Opportunity
        Opportunity opp = TestUtility.sampleOpportunity();
        insert opp;
        Id oppId = opp.Id;
        opp = [SELECT Id, Name, Exclude_from_VRs__c, CurrencyIsoCode FROM Opportunity WHERE Id = :oppId];
        System.assertEquals(false, opp.Exclude_from_VRs__c);

        // WHEN adding an Opportunity GP Product
        Test.startTest();
        OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_GP);
        insert oli;
        Test.stopTest();

        // THEN Opportunity will have Exclude_from_VRs set to True
        opp = [SELECT Id, Name, Exclude_from_VRs__c FROM Opportunity WHERE Id = :oppId];
        System.assertEquals(true, opp.Exclude_from_VRs__c);
    }

    @IsTest
    static void testOpportunityWithOtherProduct() {
        // GIVEN an Opportunity
        Opportunity opp = TestUtility.sampleOpportunity();
        insert opp;
        Id oppId = opp.Id;
        opp = [SELECT Id, Name, Exclude_from_VRs__c, CurrencyIsoCode FROM Opportunity WHERE Id = :oppId];
        System.assertEquals(false, opp.Exclude_from_VRs__c);

        // WHEN adding an Opportunity Non-GP Product
        Test.startTest();
        OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_OTHER);
        insert oli;
        Test.stopTest();

        // THEN Opportunity will not have Exclude_from_VRs set to True
        opp = [SELECT Id, Name, Exclude_from_VRs__c FROM Opportunity WHERE Id = :oppId];
        System.assertEquals(false, opp.Exclude_from_VRs__c);
    }

    @IsTest
    static void testOpportunityWithMixedProducts() {
        // GIVEN an Opportunity
        Opportunity opp = TestUtility.sampleOpportunity();
        insert opp;
        Id oppId = opp.Id;
        opp = [SELECT Id, Name, Exclude_from_VRs__c, CurrencyIsoCode FROM Opportunity WHERE Id = :oppId];
        System.assertEquals(false, opp.Exclude_from_VRs__c);

        // WHEN adding two Opportunities, one is a GP Product and one is not
        Test.startTest();
        OpportunityLineItem oli1 = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_GP);
        insert oli1;
        OpportunityLineItem oli2 = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_OTHER);
        insert oli2;
        Test.stopTest();

        // THEN Opportunity will have Exclude_from_VRs set to False
        opp = [SELECT Id, Name, Exclude_from_VRs__c FROM Opportunity WHERE Id = :oppId];
        System.assertEquals(false, opp.Exclude_from_VRs__c);
    }

}