/**
 * @author  Tony Bave
 * @date    07/12/2018
 * @Jira    RBX-534
 * The class tests that the User record fields (Bypass_Lead_Workflow, Bypass_Opportunity_Workflow,
 * Bypass_OpportunityLine_Workflow) when ticked, will prevent the workflows from executing.
 */

@IsTest
private class BypassWorkflow_Test {

    final static String STANDARD_USER_ALIAS = 'std';
    final static String BYPASS_LEAD_ALIAS = 'lea';
    final static String BYPASS_OPPORTUNITY_ALIAS = 'opp';
    final static String BYPASS_OPPLINE_ALIAS = 'oli';
    final static String STANDARD_USER_PROFILE = 'Standard User';
    final static String STANDARD_OPPORTUNITY = 'Opp - Name';
    final static String PRODUCT_FAMILY_GP = 'ILF (CB)';
    final static String DEFAULT_RECORD_TYPE = 'Licenses with/without PS';

    @TestSetup
    static void setupData() {
        TestDataInsert tdf = new TestDataInsert();

        // Users - one with each bypass setting and one with none
        tdf.insertUser(STANDARD_USER_PROFILE, STANDARD_USER_ALIAS, null, null);
        tdf.insertUser(STANDARD_USER_PROFILE, BYPASS_LEAD_ALIAS,
                new Map<String, Object>{ 'Bypass_Lead_Workflow__c' => true }, null);
        tdf.insertUser(STANDARD_USER_PROFILE, BYPASS_OPPORTUNITY_ALIAS,
                new Map<String, Object>{ 'Bypass_Opportunity_Workflow__c' => true }, null);
        tdf.insertUser(STANDARD_USER_PROFILE, BYPASS_OPPLINE_ALIAS,
                new Map<String, Object>{ 'Bypass_OpportunityLine_Workflow__c' => true }, null);

        // Country settings
        insert new Country__c(Name = 'Spain', Sales_Region__c = 'SEUR', ExternalId__c = 'Spain');
        insert new Country__c(Name = 'Norway', Sales_Region__c = 'NEUR', ExternalId__c = 'Norway');

        // Product
        Product2 gpProduct = tdf.insertProduct(new Map<String, Object>{
                'Family' => PRODUCT_FAMILY_GP, 'CanUseRevenueSchedule' => true, 'GP_Product__c' => true}, null);

        // Pricebook
        Id stdPbId = Test.getStandardPricebookId();
        PricebookEntry gpPrice = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = gpProduct.Id,
                UnitPrice = 10000, CurrencyIsoCode = 'GBP', IsActive = true, UseStandardPrice = false);
        insert gpPrice;
    }

    static Opportunity setupOpportunity(String recordTypeName) {

        Id recordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();

        TestDataUpdate tdf = new TestDataUpdate();

        // Create an Account with a name that does not contain "Marbella" or "Test Bank"
        Account acc = tdf.insertAccount(new Map<String, Object>{ 'Name' => 'Alternative' }, null);

        // Create a "power sponsor"
        Contact powerSponsor = tdf.insertContact(new Map<String, Object>{ 'LastName' => 'Sponsor' }, null);

        // Create an Opportunity on the Account
        Opportunity opp = tdf.insertOpportunity(
                new Map<String, Object>{
                        'Name' => STANDARD_OPPORTUNITY,
                        'RecordTypeId' => recordType,
                        'AccountId' => acc.Id,
                        'PS_Sub_Region__c' => 'EUR NEUR Banking',
                        'Name_of_Power_Sponsor__c' => powerSponsor.Id}, null);

        // Reset the Bypass Workflow in case the insert has set it
        tdf.updateOpportunity(opp, new Map<String, Object>{ 'Bypass_Workflows__c' => 0 }, null);

        return opp;
    }

    // ***************************************************************************************************
    // *** LEAD Workflows
    // ***************************************************************************************************
    @IsTest
    static void testLead_TeleHub_SUER_Lead_Assignment() {
        // GIVEN a standard user
        User standardUser = [SELECT Id, LastName FROM User WHERE Alias = :STANDARD_USER_ALIAS];

        // AND the required lead record workflow criteria
        Map<String, Object> ruleCriteria = new Map<String, Object> {
                'Completed_by_TeleHub__c' => true,
                'Lead_Country__c' => 'Spain',
                'Status' => 'Open'
        };

        // WHEN inserting a Lead
        TestDataInsert tdf = new TestDataInsert();
        Lead newLead;
        Test.startTest();
            System.runAs(standardUser) {
                newLead = tdf.insertLead(ruleCriteria, null);
            }
        Test.stopTest();

        // THEN the result should show the workflow did run
        newLead = [SELECT Bypass_Workflows__c FROM Lead WHERE Id = :newLead.Id];
        System.assertEquals(1, newLead.Bypass_Workflows__c, 'Lead Workflow #1 not working');
    }

    @IsTest
    static void testLeadBypass_TeleHub_SUER_Lead_Assignment() {
        // GIVEN a user with Bypass_Lead_Workflow ticked
        User userWithBypass = [SELECT Id, LastName FROM User WHERE Alias = :BYPASS_LEAD_ALIAS];

        // AND the required lead record workflow criteria
        Map<String, Object> ruleCriteria = new Map<String, Object> {
                'Completed_by_TeleHub__c' => true,
                'Lead_Country__c' => 'Spain',
                'Status' => 'Open'
        };

        // WHEN inserting a Lead with/without bypass
        TestDataInsert tdf = new TestDataInsert();
        Lead newLead;
        Test.startTest();
            System.runAs(userWithBypass) {
                newLead = tdf.insertLead(ruleCriteria, null);
            }
        Test.stopTest();

        // THEN the result should show the workflow did NOT run
        newLead = [SELECT Bypass_Workflows__c FROM Lead WHERE Id = :newLead.Id];
        System.assertEquals(0, newLead.Bypass_Workflows__c, 'Lead Workflow #1 bypass failed');
    }

    @IsTest
    static void testLead_TeleHub_NUER_Lead_Assignment() {
        // GIVEN a standard user
        User standardUser = [SELECT Id, LastName FROM User WHERE Alias = :STANDARD_USER_ALIAS];

        // AND the required lead record workflow criteria
        Map<String, Object> ruleCriteria = new Map<String, Object> {
                'Completed_by_TeleHub__c' => true,
                'Lead_Country__c' => 'Norway',
                'Status' => 'Open'
        };

        // WHEN inserting a Lead
        TestDataInsert tdf = new TestDataInsert();
        Lead newLead;
        Test.startTest();
            System.runAs(standardUser) {
                newLead = tdf.insertLead(ruleCriteria, null);
            }
        Test.stopTest();

        // THEN the result should show the workflow did run
        newLead = [SELECT Bypass_Workflows__c FROM Lead WHERE Id = :newLead.Id];
        System.assertEquals(2, newLead.Bypass_Workflows__c, 'Lead Workflow #2 not working');
    }

    @IsTest
    static void testLeadBypass_TeleHub_NUER_Lead_Assignment() {
        // GIVEN a user with Bypass_Lead_Workflow ticked
        User userWithBypass = [SELECT Id, LastName FROM User WHERE Alias = :BYPASS_LEAD_ALIAS];

        // AND the required lead record workflow criteria
        Map<String, Object> ruleCriteria = new Map<String, Object> {
                'Completed_by_TeleHub__c' => true,
                'Lead_Country__c' => 'Norway',
                'Status' => 'Open'
        };

        // WHEN inserting a Lead with/without bypass
        TestDataInsert tdf = new TestDataInsert();
        Lead newLead;
        Test.startTest();
            System.runAs(userWithBypass) {
                newLead = tdf.insertLead(ruleCriteria, null);
            }
        Test.stopTest();

        // THEN the result should show the workflow did NOT run
        newLead = [SELECT Bypass_Workflows__c FROM Lead WHERE Id = :newLead.Id];
        System.assertEquals(0, newLead.Bypass_Workflows__c, 'Lead Workflow #2 bypass failed');
    }

    // ***************************************************************************************************
    // *** OPPORTUNITY Workflows
    // ***************************************************************************************************
    @IsTest
    static void testOpportunity_Notification_Closed_LOST_WON_Opp_PS_Amt_GT_0() {
        // GIVEN a standard user
        User standardUser = [SELECT Id, LastName FROM User WHERE Alias = :STANDARD_USER_ALIAS];

        // WHEN updating an Opportunity to Closed Won
        Opportunity opp;
        System.runAs(standardUser) {
            opp = setupOpportunity('Legacy Opportunity');

            // Create an Opportunity Line Item with a value that will roll up into the Opportunity Services Amount
            TestDataUpdate tdf = new TestDataUpdate();
            tdf.insertOpportunityLineItem(opp, PRODUCT_FAMILY_GP, null, null);

            Map<String, Object> setFields =
                    new Map<String, Object>{ 'StageName' => 'Closed Won', 'Approval_Status__c' => 'Approved',
                    'Client_Signed_contract_attached__c' => true, 'Contractual_Billing_Address__c' => 'Test Address',
                    'Contractual_Shipping_Address__c' => 'Test Address' };

            Test.startTest();
                opp = tdf.updateOpportunity(opp, setFields, null);
            Test.stopTest();
        }

        // THEN the result should show the workflow did run
        opp = [SELECT Bypass_Workflows__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertNotEquals(0, opp.Bypass_Workflows__c, 'Opportunity Workflow #1 not working');
    }

    @IsTest
    static void testOpportunityBypass_Notification_Closed_LOST_WON_Opp_PS_Amt_GT_0() {
        // GIVEN a user with Bypass_Opportunity_Workflow ticked
        User userWithBypass = [SELECT Id, LastName FROM User WHERE Alias = :BYPASS_OPPORTUNITY_ALIAS];

        // WHEN updating an Opportunity to Closed Won
        Opportunity opp;
        System.runAs(userWithBypass) {
            opp = setupOpportunity('Legacy Opportunity');

            // Create an Opportunity Line Item with a value that will roll up into the Opportunity Services Amount
            TestDataUpdate tdf = new TestDataUpdate();
            tdf.insertOpportunityLineItem(opp, PRODUCT_FAMILY_GP, null, null);

            Map<String, Object> setFields =
                    new Map<String, Object>{ 'StageName' => 'Closed Won', 'Approval_Status__c' => 'Approved',
                    'Client_Signed_contract_attached__c' => true, 'Contractual_Billing_Address__c' => 'Test Address',
                    'Contractual_Shipping_Address__c' => 'Test Address' };

            Test.startTest();
                opp = tdf.updateOpportunity(opp, setFields, null);
            Test.stopTest();
        }

        // THEN the result should show the workflow did NOT run
        opp = [SELECT Bypass_Workflows__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(0, opp.Bypass_Workflows__c, 'Opportunity Workflow #1 bypass failed');
    }

    @IsTest
    static void testOpportunity_Notification_Closed_LOST_WON_Opportunity() {
        // GIVEN a standard user
        User standardUser = [SELECT Id, LastName FROM User WHERE Alias = :STANDARD_USER_ALIAS];

        // WHEN updating an Opportunity to Closed Won
        Opportunity opp;
        System.runAs(standardUser) {
            opp = setupOpportunity(DEFAULT_RECORD_TYPE);
            Map<String, Object> setFields =
                    new Map<String, Object>{ 'StageName' => 'Closed Won', 'Approval_Status__c' => 'Approved',
                    'Client_Signed_contract_attached__c' => true, 'Contractual_Billing_Address__c' => 'Test Address',
                    'Contractual_Shipping_Address__c' => 'Test Address', 'MainCompetitor__c' => 'Test',
                    'Loss_review_RT_name__c' => 'Won Review', 'Is_PearlMastered__c' => true };

            TestDataUpdate tdf = new TestDataUpdate();
            Test.startTest();
                opp = tdf.updateOpportunity(opp, setFields, null);
            Test.stopTest();
        }

        // THEN the result should show the workflow did run
        opp = [SELECT Bypass_Workflows__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertNotEquals(0, opp.Bypass_Workflows__c, 'Opportunity Workflow #2 not working');
    }

    @IsTest
    static void testOpportunityBypass_Notification_Closed_LOST_WON_Opportunity() {
        // GIVEN a user with Bypass_Opportunity_Workflow ticked
        User userWithBypass = [SELECT Id, LastName FROM User WHERE Alias = :BYPASS_OPPORTUNITY_ALIAS];

        // WHEN updating an Opportunity to Closed Won
        Opportunity opp;
        System.runAs(userWithBypass) {
            opp = setupOpportunity(DEFAULT_RECORD_TYPE);
            Map<String, Object> setFields =
                    new Map<String, Object>{ 'StageName' => 'Closed Won', 'Approval_Status__c' => 'Approved',
                    'Client_Signed_contract_attached__c' => true, 'Contractual_Billing_Address__c' => 'Test Address',
                    'Contractual_Shipping_Address__c' => 'Test Address', 'MainCompetitor__c' => 'Test',
                    'Loss_review_RT_name__c' => 'Won Review', 'Is_PearlMastered__c' => true };

            TestDataUpdate tdf = new TestDataUpdate();
            Test.startTest();
                opp = tdf.updateOpportunity(opp, setFields, null);
            Test.stopTest();
        }

        // THEN the result should show the workflow did NOT run
        opp = [SELECT Bypass_Workflows__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(0, opp.Bypass_Workflows__c, 'Opportunity Workflow #2 bypass failed');
    }

    @IsTest
    static void testOpportunity_Attach_Sales_Pres_Ltr_if_ILF_GT_1m() {
        // GIVEN a standard user
        User standardUser = [SELECT Id, LastName FROM User WHERE Alias = :STANDARD_USER_ALIAS];

        // WHEN updating an Opportunity to 6. Negotiate
        Opportunity opp;
        System.runAs(standardUser) {
            opp = setupOpportunity(DEFAULT_RECORD_TYPE);

            Test.startTest();
                // Create an Opportunity Line Item with a ILF amount >$1m that will roll up into the Opportunity Services Amount
                TestDataUpdate tdf = new TestDataUpdate();
                tdf.insertOpportunityLineItem(opp, PRODUCT_FAMILY_GP,
                        new Map<String, Object>{ 'TotalPrice' => 1500000.00, 'Text_ILF_B__c' => 'ILF B' }, null);

                Map<String, Object> setFields =
                        new Map<String, Object>{ 'StageName' => '6. Negotiate', 'MainCompetitor__c' => 'Test' };

                opp = tdf.updateOpportunity(opp, setFields, null);
            Test.stopTest();
        }

        // THEN the result should show the workflow did run
        opp = [SELECT Bypass_Workflows__c, Sales_Presentation_Letter_needed__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertNotEquals(0, opp.Bypass_Workflows__c, 'Opportunity Workflow #4 not working');
        System.assertEquals(true, opp.Sales_Presentation_Letter_needed__c, 'Opportunity Workflow #4 not working');
    }

    @IsTest
    static void testOpportunityBypass_Attach_Sales_Pres_Ltr_if_ILF_GT_1m() {
        // GIVEN a user with Bypass_Opportunity_Workflow ticked
        User userWithBypass = [SELECT Id, LastName FROM User WHERE Alias = :BYPASS_OPPORTUNITY_ALIAS];

        // WHEN updating an Opportunity to 6. Negotiate
        Opportunity opp;
        System.runAs(userWithBypass) {
            opp = setupOpportunity(DEFAULT_RECORD_TYPE);

            // Create an Opportunity Line Item with a ILF amount >$1m that will roll up into the Opportunity Services Amount
            TestDataUpdate tdf = new TestDataUpdate();
            tdf.insertOpportunityLineItem(opp, PRODUCT_FAMILY_GP,
                    new Map<String, Object>{ 'TotalPrice' => 1500000.00, 'Text_ILF_B__c' => 'ILF B' }, null);

            Map<String, Object> setFields =
                    new Map<String, Object>{ 'StageName' => '6. Negotiate', 'MainCompetitor__c' => 'Test' };

            Test.startTest();
                opp = tdf.updateOpportunity(opp, setFields, null);
            Test.stopTest();
        }

        // THEN the result should show the workflow did NOT run
        opp = [SELECT Bypass_Workflows__c, Sales_Presentation_Letter_needed__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(0, opp.Bypass_Workflows__c, 'Opportunity Workflow #4 bypass failed');
        System.assertEquals(false, opp.Sales_Presentation_Letter_needed__c, 'Opportunity Workflow #4 bypass failed');
    }

    @IsTest
    static void testOpportunity_Deal_Desk_Requested_Notification_NAM() {
        // GIVEN a standard user
        User standardUser = [SELECT Id, LastName FROM User WHERE Alias = :STANDARD_USER_ALIAS];

        // WHEN updating with "Request Deal Desk Review" AND Sales Region = NAM
        Opportunity opp;
        System.runAs(standardUser) {
            opp = setupOpportunity(DEFAULT_RECORD_TYPE);

            Map<String, Object> setFields =
                    new Map<String, Object>{ 'Request_Deal_Desk_Review__c' => true, 'Sales_Region_FY07__c' => 'NAM' };

            TestDataUpdate tdf = new TestDataUpdate();
            Test.startTest();
                opp = tdf.updateOpportunity(opp, setFields, null);
            Test.stopTest();
        }

        // THEN the result should show the workflow did run
        opp = [SELECT Bypass_Workflows__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertNotEquals(0, opp.Bypass_Workflows__c, 'Opportunity Workflow #17 not working');
    }

    @IsTest
    static void testOpportunityBypass_Deal_Desk_Requested_Notification_NAM() {
        // GIVEN a user with Bypass_Opportunity_Workflow ticked
        User userWithBypass = [SELECT Id, LastName FROM User WHERE Alias = :BYPASS_OPPORTUNITY_ALIAS];

        // WHEN updating with "Request Deal Desk Review" AND Sales Region = NAM
        Opportunity opp;
        System.runAs(userWithBypass) {
            opp = setupOpportunity(DEFAULT_RECORD_TYPE);

            Map<String, Object> setFields =
                    new Map<String, Object>{ 'Request_Deal_Desk_Review__c' => true, 'Sales_Region_FY07__c' => 'NAM' };

            TestDataUpdate tdf = new TestDataUpdate();
            Test.startTest();
                opp = tdf.updateOpportunity(opp, setFields, null);
            Test.stopTest();
        }

        // THEN the result should show the workflow did NOT run
        opp = [SELECT Bypass_Workflows__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(0, opp.Bypass_Workflows__c, 'Opportunity Workflow #17 bypass failed');
    }

    @IsTest
    static void testOpportunity_NEW_Finance_Credit_check_reqd_Develop_stage_EUR() {
        // GIVEN a standard user
        User standardUser = [SELECT Id, LastName FROM User WHERE Alias = :STANDARD_USER_ALIAS];

        // WHEN updating with Deal Type "New Name Customer" AND Sales Region = NEUR AND Stage 5
        Opportunity opp;
        System.runAs(standardUser) {
            opp = setupOpportunity(DEFAULT_RECORD_TYPE);

            Test.startTest();
                // Create an Opportunity Line Item
                TestDataUpdate tdf = new TestDataUpdate();
                tdf.insertOpportunityLineItem(opp, PRODUCT_FAMILY_GP, null, null);

                Map<String, Object> setFields =
                        new Map<String, Object>{ 'StageName' => '5. Prove', 'MainCompetitor__c' => 'Test',
                        'Deal_Type__c' => 'New Name Customer', 'Sales_Region_FY07__c' => 'NEUR' };

                opp = tdf.updateOpportunity(opp, setFields, null);
            Test.stopTest();
        }

        // THEN the result should show the workflow did run
        opp = [SELECT Bypass_Workflows__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(54, opp.Bypass_Workflows__c, 'Opportunity Workflow #54 not working');
    }

    @IsTest
    static void testOpportunityBypass_NEW_Finance_Credit_check_reqd_Develop_stage_EUR() {
        // GIVEN a user with Bypass_Opportunity_Workflow ticked
        User userWithBypass = [SELECT Id, LastName FROM User WHERE Alias = :BYPASS_OPPORTUNITY_ALIAS];

        // WHEN updating with Deal Type "New Name Customer" AND Sales Region = NEUR AND Stage 5
        Opportunity opp;
        System.runAs(userWithBypass) {
            opp = setupOpportunity(DEFAULT_RECORD_TYPE);

            // Create an Opportunity Line Item
            TestDataUpdate tdf = new TestDataUpdate();
            tdf.insertOpportunityLineItem(opp, PRODUCT_FAMILY_GP, null, null);

            Map<String, Object> setFields =
                    new Map<String, Object>{ 'StageName' => '5. Prove', 'MainCompetitor__c' => 'Test',
                    'Deal_Type__c' => 'New Name Customer', 'Sales_Region_FY07__c' => 'NEUR' };

            Test.startTest();
                opp = tdf.updateOpportunity(opp, setFields, null);
            Test.stopTest();
        }

        // THEN the result should show the workflow did NOT run
        opp = [SELECT Bypass_Workflows__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(0, opp.Bypass_Workflows__c, 'Opportunity Workflow #54 bypass failed');
    }

    @IsTest
    static void testOpportunity_SOS_Alert() {
        // GIVEN a standard user
        User standardUser = [SELECT Id, LastName FROM User WHERE Alias = :STANDARD_USER_ALIAS];

        // WHEN updating with Deal Type "New Name Customer" AND Sales Region = NEUR AND Stage 5
        Opportunity opp;
        System.runAs(standardUser) {
            opp = setupOpportunity(DEFAULT_RECORD_TYPE);

            Map<String, Object> setFields =
                    new Map<String, Object>{ 'Pain_Scale__c' => '5', 'ForecastCategoryName' => 'Commit' };

            TestDataUpdate tdf = new TestDataUpdate();
            Test.startTest();
                opp = tdf.updateOpportunity(opp, setFields, null);
            Test.stopTest();
        }

        // THEN the result should show the workflow did run
        opp = [SELECT Bypass_Workflows__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(105, opp.Bypass_Workflows__c, 'Opportunity Workflow #105 not working');
    }

    @IsTest
    static void testOpportunityBypass_SOS_Alert() {
        // GIVEN a user with Bypass_Opportunity_Workflow ticked
        User userWithBypass = [SELECT Id, LastName FROM User WHERE Alias = :BYPASS_OPPORTUNITY_ALIAS];

        // WHEN updating with Deal Type "New Name Customer" AND Sales Region = NEUR AND Stage 5
        Opportunity opp;
        System.runAs(userWithBypass) {
            opp = setupOpportunity(DEFAULT_RECORD_TYPE);

            Map<String, Object> setFields =
                    new Map<String, Object>{ 'Pain_Scale__c' => '5', 'ForecastCategoryName' => 'Commit' };

            TestDataUpdate tdf = new TestDataUpdate();
            Test.startTest();
                opp = tdf.updateOpportunity(opp, setFields, null);
            Test.stopTest();
        }

        // THEN the result should show the workflow did NOT run
        opp = [SELECT Bypass_Workflows__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(0, opp.Bypass_Workflows__c, 'Opportunity Workflow #105 bypass failed');
    }

}