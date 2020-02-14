/**
 * Created by tonybave on 19/12/2018.
 */

@IsTest
private class OpportunityLineItemTrigger_Test {
    // Test Pearl Mastered rules
    final static String PRODUCT_FAMILY_GP = 'FAM (GP)';
    final static String PRODUCT_FAMILY_OTHER = 'FAM (OT)';
    final static String EXPECTED_ERROR = 'You cannot manually add misys products, please use Pearl to push your proposal to the Opportunity';

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
    static void testOpportunityNotPearlMasteredWithMixedProducts() {
        Opportunity opp;
        Boolean errorOccurred = false;
        String errorMessage;

        // GIVEN we are a standard user
        System.runAs(TestUtils.getTestUser('inv893', 'M Sales User')) {

            // AND we have an Opportunity which is NOT Pearl Mastered
            opp = TestUtility.sampleOpportunity();
            insert opp;

            // WHEN adding two Opportunities, one is a GP Product and one is not
            Test.startTest();
            try {
                OpportunityLineItem oli1 = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_GP);
                insert oli1;
                OpportunityLineItem oli2 = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_OTHER);
                insert oli2;
            }
            catch (Exception ex) {
                errorOccurred = true;
                errorMessage = ex.getMessage();
            }
            Test.stopTest();
        }

        // THEN no error occurred
        System.assertEquals(false, errorOccurred);
    }

    @IsTest
    static void testOpportunityPearlMasteredWithGPProduct() {
        Opportunity opp;
        Boolean errorOccurred = false;
        String errorMessage;

        // GIVEN we are a standard user
        System.runAs(TestUtils.getTestUser('inv893', 'M Sales User')) {

            // AND we have an Opportunity that is Pearl Mastered
            opp = TestUtility.sampleOpportunity();
            opp.Is_PearlMastered__c = true;
            insert opp;

            // WHEN adding an Opportunity GP Product as a Standard User
            Test.startTest();
            try {
                OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_GP);
                insert oli;
            }
            catch (Exception ex) {
                errorOccurred = true;
                errorMessage = ex.getMessage();
            }
            Test.stopTest();
        }

        // THEN no error occurred
        System.assertEquals(false, errorOccurred);
    }

    @IsTest
    static void testOpportunityPearlMasteredWithOtherProduct() {
        Opportunity opp;
        Boolean errorOccurred = false;
        String errorMessage;

        // GIVEN we are a standard user
        System.runAs(TestUtils.getTestUser('inv893', 'M Sales User')) {
            opp = TestUtility.sampleOpportunity();
            opp.Is_PearlMastered__c = true;
            insert opp;

            // WHEN adding an Opportunity Non-GP Product
            Test.startTest();
            try {
                OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_OTHER);
                insert oli;
            } catch (Exception ex) {
                errorOccurred = true;
                errorMessage = ex.getMessage();
            }
            Test.stopTest();
        }

        // THEN an error occurred
        System.assertEquals(true, errorOccurred);
        System.assertEquals(true, errorMessage.contains(EXPECTED_ERROR));
    }

    @IsTest
    static void testOpportunityPearlMasteredWithOtherProductAdminProfile() {
        Opportunity opp;
        Boolean errorOccurred = false;
        String errorMessage;

        // GIVEN we are an Admin user
        System.runAs(TestUtils.getAdminUser('inv893')) {
            opp = TestUtility.sampleOpportunity();
            opp.Is_PearlMastered__c = true;
            insert opp;

            // WHEN adding an Opportunity Non-GP Product
            Test.startTest();
            try {
                OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_OTHER);
                insert oli;
            } catch (Exception ex) {
                errorOccurred = true;
                errorMessage = ex.getMessage();
            }
            Test.stopTest();
        }

        // THEN no error occurred
        System.assertEquals(false, errorOccurred);
    }

    static void testOpportunityPearlMasteredWithOtherProductPSProfile() {
        Opportunity opp;
        Boolean errorOccurred = false;
        String errorMessage;

        // GIVEN we are an Admin user
        System.runAs(TestUtils.getTestUser('inv893','M PS Standard User')) {
            opp = TestUtility.sampleOpportunity();
            opp.Is_PearlMastered__c = true;
            insert opp;

            // WHEN adding an Opportunity Non-GP Product
            Test.startTest();
            try {
                OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_OTHER);
                insert oli;
            } catch (Exception ex) {
                errorOccurred = true;
                errorMessage = ex.getMessage();
            }
            Test.stopTest();
        }

        // THEN no error occurred
        System.assertEquals(false, errorOccurred);
    }
}