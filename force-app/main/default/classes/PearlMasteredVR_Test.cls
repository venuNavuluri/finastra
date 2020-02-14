/**
 * @author Tony Bave
 * RBX-478
 * Test class to test the Opportunity Validation Rules that are affected by Is_PearlMastered__c and Exclude_from_VRs__c.
 * Specifically:
 * 1. NEW_Cant_close_opp_without_Pearl_Items
 * 2. Pearl_Mastered_cant_Chg_PS_Practice
 * 3. PS_Items_needed_from_Create_ILF2
 */
@IsTest
private class PearlMasteredVR_Test {

    static String TEST_USER_ALIAS = 'pmvr478';
    static String DEFAULT_RECORD_TYPE = 'Licenses with/without PS';
    static String ALT_RECORD_TYPE = 'Maintenance Renewal';
    static String DEFAULT_DEAL_TYPE = 'New Name Customer';
    static String ALT_DEAL_TYPE = 'Renewals';
    static String STAGE_1 = '1. Prospect';
    static String STAGE_2 = '2. Create';
    static String STAGE_5 = '5. Prove';
    static String STAGE_6 = '6. Negotiate';
    static String STAGE_7 = '7. Committed';
    static String STAGE_CLOSED_WON = 'Closed Won';
    static String STAGE_ERROR = 'You cannot change the opportunity stage from &quot;6, Negotiate&quot; onwards or close the deal, if the opportunity line items are not PEARL MASTERED. Please re-push the products via Pearl.';
    static String PRACTICE_1 = 'Europe: Enterprise Risk';
    static String PRACTICE_2 = 'Europe: Core Banking';
    static Decimal DEFAULT_AMOUNT = 1000.00;
    static String PRACTICE_BLANK = '';
    static String PRODUCT_FAMILY_GP = 'FAM (GP)';
    static String PRODUCT_FAMILY_OTHER = 'FAM (OT)';
    static String PRACTICE_ERROR = 'If the deal is Pearl Mastered, you cannot manually change the &quot;PS Practice&quot; value.';
    static String PS_ERROR = 'In order to change the stage please ensure that you have added a manual ILF and PS line item to capture the services/ILF breakdown. If the deal does not contain PS, please add a PS line item at zero value.';
    static String OLI_ERROR = 'Only Sales Execs, Sales Managers, PS Users, Sales &amp; PS Operations can update the Opportunity Products, before proposals are pushed from Pearl.';

    // *** (1) NEW_Cant_close_opp_without_Pearl_Items
    // **************************************************************************************************************

    @IsTest
    static void testVRStage_fires_stage7() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, default Record Type, to Stage 7, Not Pearl Mastered
        Database.SaveResult sr = updateOpportunityStage(
                testUser,            // user / profile
                DEFAULT_RECORD_TYPE, // record type
                STAGE_6,             // initial stage
                STAGE_7,             // updated stage
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get the VR error expected
        System.assert(resultHasValidationError(sr, STAGE_ERROR));
    }

    @IsTest
    static void testVRStage_fires_closedWon() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, default Record Type, to Closed Won, Not Pearl Mastered
        Database.SaveResult sr = updateOpportunityStage(
                testUser,            // user / profile
                DEFAULT_RECORD_TYPE, // record type
                STAGE_6,             // initial stage
                STAGE_CLOSED_WON,    // updated stage
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get the VR error expected
        System.assert(resultHasValidationError(sr, STAGE_ERROR));
    }

    @IsTest
    static void testVRStage_notFires_stage6() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, default Record Type, to before Stage 7, Not Pearl Mastered
        Database.SaveResult sr = updateOpportunityStage(
                testUser,            // user / profile
                DEFAULT_RECORD_TYPE, // record type
                STAGE_5,             // initial stage
                STAGE_6,             // updated stage
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get the no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRStage_notFires_adminProfile() {
        // GIVEN a System Admin User
        User testAdmin = TestUtils.getAdminUser(TEST_USER_ALIAS);
        //insert testAdmin;

        // WHEN updating an Opportunity via an Admin User, default Record Type, to Stage 7, Not Pearl Mastered
        Database.SaveResult sr = updateOpportunityStage(
                testAdmin,           // user / profile
                DEFAULT_RECORD_TYPE, // record type
                STAGE_6,             // initial stage
                STAGE_7,             // updated stage
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get the no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRStage_notFires_recordType() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, "Maintenance Renewal" Record Type, to Stage 7, Not Pearl Mastered
        Database.SaveResult sr = updateOpportunityStage(
                testUser,            // user / profile
                ALT_RECORD_TYPE,     // record type
                STAGE_6,             // initial stage
                STAGE_7,             // updated stage
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get the no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRStage_notFires_pearlMastered() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, default Record Type, to Stage 7, AND IS Pearl Mastered
        Database.SaveResult sr = updateOpportunityStage(
                testUser,            // user / profile
                DEFAULT_RECORD_TYPE, // record type
                STAGE_6,             // initial stage
                STAGE_7,             // updated stage
                true,                // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get the no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRStage_notFires_excludeVRs() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, default Record Type, to Stage 7, AND Exclude from VRs
        Database.SaveResult sr = updateOpportunityStage(
                testUser,            // user / profile
                DEFAULT_RECORD_TYPE, // record type
                STAGE_6,             // initial stage
                STAGE_7,             // updated stage
                false,               // pearl mastered
                true                 // exclude from VRs
        );

        // THEN we get the no VR error
        System.assert(resultNoErrors(sr));
    }

    // *** (2) Pearl_Mastered_cant_Chg_PS_Practice (Not Affected By Exclude_from_VRs__c)
    // **************************************************************************************************************

    @IsTest
    static void testVRPractice_fires() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, changing PS Practice, AND IS Pearl Mastered
        Database.SaveResult sr = updateOpportunityPractice(
                testUser,            // user / profile
                PRACTICE_1,          // initial practice
                PRACTICE_2,          // updated practice
                true,                // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get the VR error expected
        System.assert(resultHasValidationError(sr, PRACTICE_ERROR));
    }

    @IsTest
    static void testVRPractice_fires_excludeVRs() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, changing PS Practice to blank, AND Exclude from VRs
        Database.SaveResult sr = updateOpportunityPractice(
                testUser,           // user / profile
                PRACTICE_1,          // initial practice
                PRACTICE_2,          // updated practice
                true,                // pearl mastered
                true                 // exclude from VRs
        );

        // THEN we get the VR error expected
        System.assert(resultHasValidationError(sr, PRACTICE_ERROR));
    }

    @IsTest
    static void testVRPractice_notFires_noChange() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, NOT changing PS Practice, AND IS Pearl Mastered
        Database.SaveResult sr = updateOpportunityPractice(
                testUser,            // user / profile
                PRACTICE_1,          // initial practice
                PRACTICE_1,          // updated practice
                true,                // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get the no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRPractice_notFires_blank() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, changing PS Practice to blank, AND IS Pearl Mastered
        Database.SaveResult sr = updateOpportunityPractice(
                testUser,            // user / profile
                PRACTICE_1,          // initial practice
                PRACTICE_BLANK,      // updated practice
                true,                // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get the no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRPractice_notFires_adminProfile() {
        // GIVEN a System Admin User
        User testAdmin = TestUtils.getAdminUser(TEST_USER_ALIAS);
        //insert testAdmin;

        // WHEN updating an Opportunity via an Admin User, changing PS Practice, AND IS Pearl Mastered
        Database.SaveResult sr = updateOpportunityPractice(
                testAdmin,           // user / profile
                PRACTICE_1,          // initial practice
                PRACTICE_2,          // updated practice
                true,                // pearl mastered
                false                // exclude from VRs

        );

        // THEN we get the no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRPractice_notFires_notPearlMastered() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, changing PS Practice to blank, NOT Pearl Mastered
        Database.SaveResult sr = updateOpportunityPractice(
                testUser,           // user / profile
                PRACTICE_1,          // initial practice
                PRACTICE_2,          // updated practice
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get the no VR error
        System.assert(resultNoErrors(sr));
    }

    // *** (3) PS_Items_needed_from_Create_ILF2
    // **************************************************************************************************************

    @IsTest
    static void testVRPS_fires1() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, default Record Type, to Stage 7, Not Pearl Mastered
        // AND ILF Items is False
        Database.SaveResult sr = updateOpportunityPSStage(
                testUser,            // user / profile
                DEFAULT_DEAL_TYPE,   // deal type
                DEFAULT_RECORD_TYPE, // record type
                STAGE_5,             // initial stage
                STAGE_6,             // updated stage
                false,               // ILF Items
                true,                // PS Items
                true,                // PS Zero Item
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get the VR error expected
        System.assert(resultHasValidationError(sr, PS_ERROR));
    }

    @IsTest
    static void testVRPS_fires2() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, default Record Type, to Stage 7, Not Pearl Mastered
        // AND both PS Items are False
        Database.SaveResult sr = updateOpportunityPSStage(
                testUser,            // user / profile
                DEFAULT_DEAL_TYPE,   // deal type
                DEFAULT_RECORD_TYPE, // record type
                STAGE_5,             // initial stage
                STAGE_6,             // updated stage
                true,                // ILF Items
                false,               // PS Items
                false,               // PS Zero Item
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get the VR error expected
        System.assert(resultHasValidationError(sr, PS_ERROR));
    }

    @IsTest
    static void testVRPS_notFires_adminProfile() {
        // GIVEN an Admin User
        User testAdmin = TestUtils.getAdminUser(TEST_USER_ALIAS);
        //insert testAdmin;

        // WHEN updating an Opportunity via an Admin User
        Database.SaveResult sr = updateOpportunityPSStage(
                testAdmin,            // user / profile
                DEFAULT_DEAL_TYPE,   // deal type
                DEFAULT_RECORD_TYPE, // record type
                STAGE_5,             // initial stage
                STAGE_6,             // updated stage
                false,               // ILF Items
                true,                // PS Items
                true,                // PS Zero Item
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRPS_notFires_altDealType() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, alternative Deal Type
        Database.SaveResult sr = updateOpportunityPSStage(
                testUser,            // user / profile
                ALT_DEAL_TYPE,       // deal type
                DEFAULT_RECORD_TYPE, // record type
                STAGE_5,             // initial stage
                STAGE_6,             // updated stage
                false,               // ILF Items
                true,                // PS Items
                true,                // PS Zero Item
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRPS_notFires_altRecordType() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, alternative Record Type
        Database.SaveResult sr = updateOpportunityPSStage(
                testUser,            // user / profile
                DEFAULT_DEAL_TYPE,   // deal type
                ALT_RECORD_TYPE,     // record type
                STAGE_5,             // initial stage
                STAGE_6,             // updated stage
                false,               // ILF Items
                true,                // PS Items
                true,                // PS Zero Item
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRPS_notFires_noStageChange() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, no change of Stage
        Database.SaveResult sr = updateOpportunityPSStage(
                testUser,            // user / profile
                DEFAULT_DEAL_TYPE,   // deal type
                DEFAULT_RECORD_TYPE, // record type
                STAGE_5,             // initial stage
                STAGE_5,             // updated stage
                false,               // ILF Items
                true,                // PS Items
                true,                // PS Zero Item
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRPS_notFires_stage1() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, change to Stage 1
        Database.SaveResult sr = updateOpportunityPSStage(
                testUser,            // user / profile
                DEFAULT_DEAL_TYPE,   // deal type
                DEFAULT_RECORD_TYPE, // record type
                STAGE_2,             // initial stage
                STAGE_1,             // updated stage
                false,               // ILF Items
                true,                // PS Items
                true,                // PS Zero Item
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRPS_notFires_ILFIsTrue1() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, ILF Items is True but PS Items are not both False
        Database.SaveResult sr = updateOpportunityPSStage(
                testUser,            // user / profile
                DEFAULT_DEAL_TYPE,   // deal type
                DEFAULT_RECORD_TYPE, // record type
                STAGE_5,             // initial stage
                STAGE_6,             // updated stage
                true,                // ILF Items
                true,                // PS Items
                true,                // PS Zero Item
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRPS_notFires_ILFIsTrue2() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, ILF Items is True but PS Items are not both False
        Database.SaveResult sr = updateOpportunityPSStage(
                testUser,            // user / profile
                DEFAULT_DEAL_TYPE,   // deal type
                DEFAULT_RECORD_TYPE, // record type
                STAGE_5,             // initial stage
                STAGE_6,             // updated stage
                true,                // ILF Items
                false,               // PS Items
                true,                // PS Zero Item
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRPS_notFires_ILFIsTrue3() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, ILF Items is True but PS Items are not both False
        Database.SaveResult sr = updateOpportunityPSStage(
                testUser,            // user / profile
                DEFAULT_DEAL_TYPE,   // deal type
                DEFAULT_RECORD_TYPE, // record type
                STAGE_5,             // initial stage
                STAGE_6,             // updated stage
                true,                // ILF Items
                true,                // PS Items
                false,               // PS Zero Item
                false,               // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRPS_notFires_pearlMastered() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, IS Pearl Mastered
        Database.SaveResult sr = updateOpportunityPSStage(
                testUser,            // user / profile
                DEFAULT_DEAL_TYPE,   // deal type
                DEFAULT_RECORD_TYPE, // record type
                STAGE_5,             // initial stage
                STAGE_6,             // updated stage
                true,                // ILF Items
                false,               // PS Items
                false,               // PS Zero Item
                true,                // pearl mastered
                false                // exclude from VRs
        );

        // THEN we get no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testVRPS_notFires_excludeVRs() {
        // GIVEN a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        // WHEN updating an Opportunity via a Standard User, Exclude from VRs
        Database.SaveResult sr = updateOpportunityPSStage(
                testUser,            // user / profile
                DEFAULT_DEAL_TYPE,   // deal type
                DEFAULT_RECORD_TYPE, // record type
                STAGE_5,             // initial stage
                STAGE_6,             // updated stage
                true,                // ILF Items
                false,               // PS Items
                false,               // PS Zero Item
                false,               // pearl mastered
                true                 // exclude from VRs
        );

        // THEN we get no VR error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testBlockEdits_fires() {
        // GIVEN a product pricebook
        setupPricebook();

        // AND running as a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        Database.SaveResult sr;
        System.runAs(testUser) {
            // AND an existing opportunity
            Opportunity opp = createOpportunity(DEFAULT_DEAL_TYPE, DEFAULT_RECORD_TYPE, STAGE_2, PRACTICE_1,
                    DEFAULT_AMOUNT, true, true, true, false, false);
            Id oppId = opp.Id;

            // WHEN attempting to create a new Opportunity Product (OLI)
            Test.startTest();
            OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_OTHER);
            //opp = [SELECT Id, StageName, RecordTypeId, Amount, Is_PearlMastered__c, Exclude_from_VRs__c FROM Opportunity WHERE Id = :oppId];
            sr = Database.insert(oli, false);
            Test.stopTest();
        }

        // THEN we get the expected validation error
        System.assert(resultHasValidationError(sr, OLI_ERROR));
    }

    @IsTest
    static void testBlockEdits_notFires_adminUser() {
        // GIVEN a product pricebook
        setupPricebook();

        // AND running as an Admin User
        User testAdmin = TestUtils.getAdminUser(TEST_USER_ALIAS);
        //insert testAdmin;

        Database.SaveResult sr;
        System.runAs(testAdmin) {
            // AND an existing opportunity
            Opportunity opp = createOpportunity(DEFAULT_DEAL_TYPE, DEFAULT_RECORD_TYPE, STAGE_2, PRACTICE_1,
                    DEFAULT_AMOUNT, true, true, true, false, false);
            Id oppId = opp.Id;

            // WHEN attempting to create a new Opportunity Product (OLI)
            Test.startTest();
            OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_OTHER);
            sr = Database.insert(oli, false);
            Test.stopTest();
        }

        // THEN we get no validation error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testBlockEdits_notFires_stage6() {
        // GIVEN a product pricebook
        setupPricebook();

        // AND running as a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        Database.SaveResult sr;
        System.runAs(testUser) {
            // AND an existing opportunity
            Opportunity opp = createOpportunity(DEFAULT_DEAL_TYPE, DEFAULT_RECORD_TYPE, STAGE_6, PRACTICE_1,
                    DEFAULT_AMOUNT, true, true, true, false, false);
            Id oppId = opp.Id;

            // WHEN attempting to create a new Opportunity Product (OLI)
            Test.startTest();
            OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_OTHER);
            sr = Database.insert(oli, false);
            Test.stopTest();
        }

        // THEN we get no validation error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testBlockEdits_notFires_altRecordType() {
        // GIVEN a product pricebook
        setupPricebook();

        // AND running as a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        Database.SaveResult sr;
        System.runAs(testUser) {
            // AND an existing opportunity
            Opportunity opp = createOpportunity(DEFAULT_DEAL_TYPE, ALT_RECORD_TYPE, STAGE_2, PRACTICE_1,
                    DEFAULT_AMOUNT, true, true, true, false, false);
            Id oppId = opp.Id;

            // WHEN attempting to create a new Opportunity Product (OLI)
            Test.startTest();
            OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_OTHER);
            sr = Database.insert(oli, false);
            Test.stopTest();
        }

        // THEN we get no validation error
        System.assert(resultNoErrors(sr));
    }

    @IsTest
    static void testBlockEdits_notFires_AmountZero() {
        // GIVEN a product pricebook
        setupPricebook();

        // AND running as a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        Database.SaveResult sr;
        System.runAs(testUser) {
            // AND an existing opportunity
            Opportunity opp = createOpportunity(DEFAULT_DEAL_TYPE, DEFAULT_RECORD_TYPE, STAGE_2, PRACTICE_1,
                    0.00, true, true, true, false, false);
            Id oppId = opp.Id;

            // WHEN attempting to create a new Opportunity Product (OLI)
            Test.startTest();
            OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_OTHER);
            sr = Database.insert(oli, false);
            Test.stopTest();
        }

        // THEN we get no validation error
        System.assert(resultNoErrors(sr));
    }

    /* Changes to requirements invalidates this test
    @IsTest
    static void testBlockEdits_notFires_pearlMastered() {
        // GIVEN a product pricebook
        setupPricebook();

        // AND running as a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        Database.SaveResult sr;
        System.runAs(testUser) {
            // AND an existing opportunity
            Opportunity opp = createOpportunity(DEFAULT_DEAL_TYPE, DEFAULT_RECORD_TYPE, STAGE_2, PRACTICE_1,
                    DEFAULT_AMOUNT, true, true, true, true, false);
            Id oppId = opp.Id;

            // WHEN attempting to create a new Opportunity Product (OLI)
            Test.startTest();
            OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_OTHER);
            sr = Database.insert(oli, false);
            Test.stopTest();
        }

        // THEN we get no validation error
        System.assert(resultNoErrors(sr));
    }
    */

    @IsTest
    static void testBlockEdits_notFires_excludeVRs() {
        // GIVEN a product pricebook
        setupPricebook();

        // AND running as a Standard User
        User testUser = TestUtils.getStandardInternalUser(TEST_USER_ALIAS);
        //insert testUser;

        Database.SaveResult sr;
        System.runAs(testUser) {
            // AND an existing opportunity
            Opportunity opp = createOpportunity(DEFAULT_DEAL_TYPE, DEFAULT_RECORD_TYPE, STAGE_2, PRACTICE_1,
                    DEFAULT_AMOUNT, true, true, true, false, true);
            Id oppId = opp.Id;

            // WHEN attempting to create a new Opportunity Product (OLI)
            Test.startTest();
            OpportunityLineItem oli = TestUtility.sampleOpportunityLineItem1(opp, PRODUCT_FAMILY_OTHER);
            sr = Database.insert(oli, false);
            Test.stopTest();
        }

        // THEN we get no validation error
        System.assert(resultNoErrors(sr));
    }

    // *** Helper Methods
    // **************************************************************************************************************

    static void setupPricebook() {
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

    static Opportunity createOpportunity(String dealType, String recordTypeName, String oppStage, String oppPractice,
            Decimal oppAmount, Boolean ilf, Boolean ps, Boolean psZero, Boolean pearlMastered, Boolean excludeFromVRs) {

        // Create a "power sponsor"
        Contact powerSponsor = new Contact(LastName='Test', Email='test@test.test');
        insert powerSponsor;

        // Create an Opportunity
        Opportunity opp = new Opportunity(
                Name = 'Test - Test Users',
                Deal_Type__c = dealType,
                StageName = oppStage,
                PS_Practice__c = oppPractice,
                Amount = oppAmount,
                ILF_Items__c = ilf,
                PS_Items__c = ps,
                PS_zero_Item__c = psZero,
                Is_PearlMastered__c = pearlMastered,
                Exclude_from_VRs__c = excludeFromVRs,
                Name_of_Power_Sponsor__c = powerSponsor.Id,
                CurrencyIsoCode = 'GBP',
                MainCompetitor__c = 'Amazon',
                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId(),
                CloseDate = System.today()+7
        );
        insert opp;

        return opp;
    }

    static Database.SaveResult updateOpportunityPSStage(User u, String dealType, String recordTypeName, String fromStage,
            String toStage, Boolean ilf, Boolean ps, Boolean psZero, Boolean pearlMastered, Boolean excludeFromVRs) {

        Database.SaveResult sr;
        System.runAs(u) {

            // Create an Opportunity with the specified record type name, stage and pearl mastered values
            Opportunity opp = createOpportunity(dealType, recordTypeName, fromStage, PRACTICE_1, DEFAULT_AMOUNT,
                                                    ilf, ps, psZero, pearlMastered, excludeFromVRs);

            // WHEN we update the opportunity stage
            opp.StageName = toStage;
            if (toStage == STAGE_1) {
                opp.Misys_Forecast__c = 'Exempt';
            }
            sr = Database.update(opp, false);
        }

        return sr;
    }

    static Database.SaveResult updateOpportunityStage(User u, String recordTypeName, String fromStage, String toStage,
            Boolean pearlMastered, Boolean excludeFromVRs) {

        return updateOpportunityPSStage(u, DEFAULT_DEAL_TYPE, recordTypeName, fromStage, toStage, true, true, true,
                pearlMastered, excludeFromVRs);
    }

    static Database.SaveResult updateOpportunityPractice(User u, String fromPractice, String toPractice,
            Boolean pearlMastered, Boolean excludeFromVRs) {

        Database.SaveResult sr;
        System.runAs(u) {

            // Create an Opportunity with the specified record type name, stage and pearl mastered values
            Opportunity opp = createOpportunity(DEFAULT_DEAL_TYPE, DEFAULT_RECORD_TYPE, STAGE_5, fromPractice,
                    DEFAULT_AMOUNT, true, true, true, pearlMastered, excludeFromVRs );

            // WHEN we update the opportunity stage
            opp.PS_Practice__c = toPractice;
            sr = Database.update(opp, false);
        }

        return sr;
    }

    static Boolean resultNoErrors(Database.SaveResult sr) {
        Database.Error[] errs = sr.getErrors();
        return (sr.success == true && errs.size() == 0);
    }

    static Boolean resultHasValidationError(Database.SaveResult sr, String errorMessage) {
        Database.Error[] errs = sr.getErrors();
        Boolean foundError = false;
        for (Database.Error err : errs) {
            if (err.getStatusCode() == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION &&
                    err.getMessage().startsWith(errorMessage)) {
                foundError = true;
            }
        }
        return (sr.success == false && errs.size() > 0 && foundError);
    }
}