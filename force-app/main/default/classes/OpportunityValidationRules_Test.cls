/**
•   @file Name : OpportunityValidationRules_Test.cls
•   @description : Class to test validations rules on Opportunity Object
•   @author : Ramesh Thulasi
•   @last Modified By : Ramesh Thulasi
**/

@isTest
private class OpportunityValidationRules_Test {
  private static final map<String, Profile> profileMap = TestDataFactory.getProfileMap();
  private static final String OPP_CANT_MOVE_BK_FROM_SS4_OR_SS5_OR_SS6 = 'Opportunity is qualified when in SS4 or SS5 or SS6 cannot be moved back to SS3 , SS2 or SS1';
  private static final String OPP_CAN_ONLY_MOVE_TO_CL_FROM_SS4_ERROR_MSG = 'An opportunity can only be Closed Lost from SS4 Develop onward. Please Closed Lost the opportunity';
  private static final String OPP_CAN_ONLY_MOVE_TO_CQO_BEFORE_SS4_ERROR_MSG = 'An opportunity can only be Closed Lost from SS4 Develop onward. Please Close Qualify Out the opportunity';
  private static final String SFR_DT_CANT_BE_FRI_SAT_SUN_ERROR_MSG = 'Shape Fit Review Request Date cannot be Friday or weekends. Please select another date';
  private static final String SFR_DT_CANT_BE_LESS_THAN_72_HRS_ERROR_MSG = 'Shape Fit Review Request Date cannot be within 3 days of the current time';
  private static final String SFR_DT_MANDATORY_WHEN_SFQR_CHECKED_ERROR_MSG = 'You have checked the &quot;Shape Fit Qualification Request&quot; field, please update the Shape Fit Review Request Date with the appropriate date by which GSC team should respond.';
  private static final String POWER_SPONSOR_REQUIRED_ERROR_MSG = 'Please nominate a power sponsor for this opportunity';
  private static final String MAIN_COMPETITOR_REQUIRED_ERROR_MSG = 'It is mandatory to update the main competitor on the opportunity in SS3';
  private static final String BDR_USER_CANNOT_CHANGE_OPP_STAGE_ERROR_MSG = 'BDR Can either change stage to Closed Qualified Out or request Sales to accept the Opportunity in Stage 1 to move to 2.';
  private static final String OPP_CANT_MOVE_FROM_SS3_OR_SS2_TO_SS1 = 'Opportunity can\'t be moved back from Qualify or Create to Prospect';
  private static final String OPPORTUNITY_NAMING_CONVENTION_ERROR_MSG = 'Please name opportunities in following format: Bank - Info. Examples: Lloyds - Addl. Users. Please note the hyphen and space before and after hyphen. Use short names for banks.';
  private static final String UPDATE_RFI_DUE_DT_WHEN_GSC_RFI_REQUESTED_ERROR_MSG = 'Please Update the RFI Due Date when the GSC RFI Is Requested';
  private static final String RFI_DUE_DT_CANNOT_BE_IN_PAST_DATE_ERROR_MSG = 'RFI Due Date Can not be in Past Date.';
  private static final String GSC_RFI_NOT_SET_ERROR_MSG = 'GSC_RFI__c should not be set to "Requested"';
  private static final String GSC_RFI_SET_ERROR_MSG = 'GSC_RFI__c should be set to "Requested"';
  private static final String PRIMARY_QUOTE_REQUIRED_ERROR_MSG = 'A Primary Quote needs to be attached to the opportunity to progress to Stage 5 or beyond in the Sales process';
  private static final String CLOSEONE_ERROR_MESSAGE = 'Stage Name should have been closed one.';
  private static final String BILL_TO_SHIP_TO_LOOKUP_FILTER_ERROR = 'Please select an address associated with Opportunity\'s Account.';
  @testSetup
  static void setup() {
    // init Bypass validation custom property
    List<Bypass_Validations__c> valCusSettings = new List<Bypass_Validations__c>();

    List<User> userList = TestDataFactory.createUserList(true);
    User adminUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SYS_ADMIN_PROFILE).Id
    );
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    User bdrUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.BDR_USR_PROFILE).Id
    );
    User salesUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SALES_USR_PROFILE).Id
    );
    // set custom property for admin user
    System.runAs(adminUser) {
      // flag defaults to false means validation rules are NOT bypassed
      valCusSettings.add(
        new Bypass_Validations__c(
          SetupOwnerId = sossUser.id,
          Disable__c = false
        )
      );
      valCusSettings.add(
        new Bypass_Validations__c(SetupOwnerId = bdrUser.id, Disable__c = false)
      );
      valCusSettings.add(
        new Bypass_Validations__c(
          SetupOwnerId = salesUser.id,
          Disable__c = false
        )
      );
      insert valCusSettings;
    }
  }

  /**
* @description :  Test method to test 'Opp_Cant_Move_Bk_From_SS4_Or_SS5_Or_SS6' validation rule. Validation is fired when conditions are met for SOSS User.
* @Rule Name: Opp_Cant_Move_Bk_From_SS4_Or_SS5_Or_SS6
* @Rule Definition: 
AND (
NOT($Setup.Bypass_Validations__c.Disable__c),
ISCHANGED(StageName),
OR(
ISPICKVAL(PRIORVALUE(StageName),"4. Develop"),
ISPICKVAL(PRIORVALUE(StageName),"5. Prove"),
ISPICKVAL(PRIORVALUE(StageName),"6. Negotiate")
),
OR(
ISPICKVAL(StageName, "1. Prospect"),
ISPICKVAL(StageName, "2. Create"),
ISPICKVAL(StageName, "3. Qualify")
)
)
* @autho : Ramesh Thulasi
* @param : None
* @return : None
**/
  private static testMethod void test_Opp_Cant_Move_Bk_From_SS4_Or_SS5_Or_SS6_PositiveTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_DEVELOP
      );
      Test.startTest();
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CREATE;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPP_CANT_MOVE_BK_FROM_SS4_OR_SS5_OR_SS6
      );
      Test.stopTest();
      System.assertEquals(
        true,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'Opp_Cant_Move_Bk_From_SS4_Or_SS5_Or_SS6' validation rule. Validation is NOT fired when conditions are NOT met.
* @Rule Name: Opp_Cant_Move_Bk_From_SS4_Or_SS5_Or_SS6
* @Rule Definition: 
AND (
NOT($Setup.Bypass_Validations__c.Disable__c),
ISCHANGED(StageName),
ISPICKVAL(PRIORVALUE(StageName),"4. Develop"),
OR(
ISPICKVAL(StageName, "1. Prospect"),
ISPICKVAL(StageName, "2. Create"),
ISPICKVAL(StageName, "3. Qualify")
)
)
* @autho : Ramesh Thulasi
* @param : None
* @return : None
**/
  private static testMethod void testOpp_Cant_Move_Bk_From_SS4_Or_SS5_Or_SS6_NegativeTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_QUALIFY
      );
      Test.startTest();
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CREATE;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPP_CANT_MOVE_BK_FROM_SS4_OR_SS5_OR_SS6
      );
      Test.stopTest();
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
   * @description :  Test method to test validation bypass for user.  Validation bypass flag is set to 'true' means validation should be bypassed and record should be inserted
   * @autho : Ramesh Thulasi
   * @param : None
   * @return : None
   **/
  private static testMethod void test_Opp_Cant_Move_Bk_From_SS4_Or_SS5_Or_SS6_Bypass_PositiveTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(sossUser);
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_DEVELOP
      );
      Test.startTest();
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CREATE;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPP_CANT_MOVE_BK_FROM_SS4_OR_SS5_OR_SS6
      );
      Test.stopTest();
      // Record should have been inserted
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'Opp_Can_Only_Move_To_CL_From_SS4' validation rule. From SS4 onwards Opportunity can only be moved to 'Closed Lost' not to ' Closed Qualified Out'.
* @Rule Name: Opp_Can_Only_Move_To_CL_From_SS4
* @Rule Definition: 
AND (
NOT($Setup.Bypass_Validations__c.Disable__c),
ISCHANGED(StageName),
ISPICKVAL(StageName,"Closed Qualified Out"),
OR(
ISPICKVAL(PRIORVALUE(StageName), "4. Develop"),
ISPICKVAL(PRIORVALUE(StageName), "5. Prove"),
ISPICKVAL(PRIORVALUE(StageName), "6. Negotiate")
)
)    
* @autho : Ramesh Thulasi
* @param : None
* @return : None
**/
  private static testMethod void test_OppCanOnlyMoveToCLFromSS4_PositiveTest() {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_DEVELOP
      );
      Test.startTest();
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CQO;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPP_CAN_ONLY_MOVE_TO_CL_FROM_SS4_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        true,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'Opp_Can_Only_Move_To_CL_From_SS4' validation rule. From SS4 onwards Opportunity can only be moved to 'Closed Lost' not to ' Closed Qualified Out'.
* @Rule Name: Opp_Can_Only_Move_To_CL_From_SS4
* @Rule Definition: 
AND (
NOT($Setup.Bypass_Validations__c.Disable__c),
ISCHANGED(StageName),
ISPICKVAL(StageName,"Closed Qualified Out"),
OR(
ISPICKVAL(PRIORVALUE(StageName), "4. Develop"),
ISPICKVAL(PRIORVALUE(StageName), "5. Prove"),
ISPICKVAL(PRIORVALUE(StageName), "6. Negotiate")
)
)    
* @autho : Ramesh Thulasi
* @param : None
* @return : None
**/
  private static testMethod void test_OppCanOnlyMoveToCLFromSS4_NegativeTest() {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_DEVELOP
      );
      Test.startTest();
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CL;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPP_CAN_ONLY_MOVE_TO_CL_FROM_SS4_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
   * @description :  Test method to test validation bypass for user.  Validation bypass flag is set to 'true' means validation should be bypassed and record should be inserted
   * @autho : Ramesh Thulasi
   * @param : None
   * @return : None
   **/
  private static testMethod void test_OppCanOnlyMoveToCLFromSS4_Bypass_PositiveTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(sossUser);
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_DEVELOP
      );
      Test.startTest();
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CQO;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPP_CAN_ONLY_MOVE_TO_CL_FROM_SS4_ERROR_MSG
      );
      Test.stopTest();
      // Record should have been inserted
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'Opp_Can_Only_Move_To_CQO_Before_SS4' validation rule. From SS1,SS2 & SS3 Opportunity can only be move to 'Closed Qualified Out' not to 'Closed Lost'
* @Rule Name: Opp_Can_Only_Move_To_CQO_Before_SS4
* @Rule Definition: 
AND (
NOT($Setup.Bypass_Validations__c.Disable__c),
ISCHANGED(StageName),
ISPICKVAL(StageName,"Closed Lost"),
OR(
ISPICKVAL(PRIORVALUE(StageName), "1. Prospect"),
ISPICKVAL(PRIORVALUE(StageName), "2. Create"),
ISPICKVAL(PRIORVALUE(StageName), "3. Qualify")
)
* @autho : Ramesh Thulasi
* @param : None
* @return : None
**/
  private static testMethod void test_OppCanOnlyMoveToCQOBeforeSS4_PositiveTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_PROSPECT
      );
      Test.startTest();
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CL;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPP_CAN_ONLY_MOVE_TO_CQO_BEFORE_SS4_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        true,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'Opp_Can_Only_Move_To_CQO_Before_SS4' validation rule. From SS1,SS2 & SS3 Opportunity can only be move to 'Closed Qualified Out' not to 'Closed Lost'
* @Rule Name: Opp_Can_Only_Move_To_CQO_Before_SS4
* @Rule Definition: 
AND (
NOT($Setup.Bypass_Validations__c.Disable__c),
ISCHANGED(StageName),
ISPICKVAL(StageName,"Closed Lost"),
OR(
ISPICKVAL(PRIORVALUE(StageName), "1. Prospect"),
ISPICKVAL(PRIORVALUE(StageName), "2. Create"),
ISPICKVAL(PRIORVALUE(StageName), "3. Qualify")
)
* @autho : Ramesh Thulasi
* @param : None
* @return : None
**/
  private static testMethod void test_OppCanOnlyMoveToCQOBeforeSS4_NegativeTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_PROSPECT
      );
      Test.startTest();
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CQO;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPP_CAN_ONLY_MOVE_TO_CQO_BEFORE_SS4_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
   * @description :  Test method to test validation bypass for user.  Validation bypass flag is set to 'true' means validation should be bypassed and record should be inserted
   * @autho : Ramesh Thulasi
   * @param : None
   * @return : None
   **/
  private static testMethod void test_OppCanOnlyMoveToCQOBeforeSS4_Bypass_PositiveTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(sossUser);
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_DEVELOP
      );
      Test.startTest();
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CQO;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPP_CAN_ONLY_MOVE_TO_CQO_BEFORE_SS4_ERROR_MSG
      );
      Test.stopTest();
      // Record should have been inserted
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'SFR_Dt_Mandatory_When_SFQR_Checked' validation rule. Shape Fit Review Request Date is mandatory when Shape Fit Qualification Request is checked
* @Rule Name: SFR_Dt_Mandatory_When_SFQR_Checked
* @Rule Definition: 
AND(
NOT($Setup.Bypass_Validations__c.Disable__c),
Shape_Fit_Qualification_Request__c = True ,
ISBLANK(Shape_Fit_Review_Request_Date__c)
)    
* @autho : Ramesh Thulasi
* @param : None
* @return : None
**/
  private static testMethod void test_SFR_Dt_Mandatory_When_SFQR_Checked_PositiveTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
      Test.startTest();
      opp.Shape_Fit_Qualification_Request__c = true;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        SFR_DT_MANDATORY_WHEN_SFQR_CHECKED_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        true,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'SFR_Dt_Mandatory_When_SFQR_Checked' validation rule. Shape Fit Review Request Date is mandatory when Shape Fit Qualification Request is checked
* @Rule Name: SFR_Dt_Mandatory_When_SFQR_Checked
* @Rule Definition: 
AND(
NOT($Setup.Bypass_Validations__c.Disable__c),
Shape_Fit_Qualification_Request__c = True ,
ISBLANK(Shape_Fit_Review_Request_Date__c)
)    
* @autho : Ramesh Thulasi
* @param : None
* @return : None
**/
  private static testMethod void test_SFR_Dt_Mandatory_When_SFQR_Checked_NegativeTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
      Test.startTest();
      opp.Shape_Fit_Qualification_Request__c = true;
      opp.Shape_Fit_Review_Request_Date__c = TestDataFactory.getNextMonday(
        System.today().addDays(7)
      );
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        SFR_DT_MANDATORY_WHEN_SFQR_CHECKED_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
   * @description :  Test method to test validation bypass for user.  Validation bypass flag is set to 'true' means validation should be bypassed and record should be inserted
   * @autho : Ramesh Thulasi
   * @param : None
   * @return : None
   **/
  private static testMethod void test_SFR_Dt_Mandatory_When_SFQR_Checked_Bypass_PositiveTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(sossUser);
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
      Test.startTest();
      opp.Shape_Fit_Qualification_Request__c = true;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        SFR_DT_MANDATORY_WHEN_SFQR_CHECKED_ERROR_MSG
      );
      // Record should have been inserted
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'SFR_Dt_Cant_Be_Fri_Sat_Sun' validation rule. Shape Fit Review Request Date cant be Friday or Saturday or Sunday
* @Rule Name: SFR_Dt_Cant_Be_Fri_Sat_Sun
* @Rule Definition: 
AND(
NOT($Setup.Bypass_Validations__c.Disable__c),
CASE(MOD(Shape_Fit_Review_Request_Date__c - DATE(1900, 1, 7), 7),
0, 0,
5, 0,
6, 0,
1) = 0
)  
* @autho : Ramesh Thulasi
* @param : None
* @return : None
**/
  private static testMethod void test_SFR_Dt_Cant_Be_Fri_Sat_Sun_PositiveTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
      Test.startTest();
      opp.Shape_Fit_Qualification_Request__c = true;
      opp.Shape_Fit_Review_Request_Date__c = TestDataFactory.getNextFriday(
        System.today().addDays(7)
      );
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        SFR_DT_CANT_BE_FRI_SAT_SUN_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        true,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'SFR_Dt_Cant_Be_Fri_Sat_Sun' validation rule. Shape Fit Review Request Date cant be Friday or Saturday or Sunday
* @Rule Name: SFR_Dt_Cant_Be_Fri_Sat_Sun
* @Rule Definition: 
AND(
NOT($Setup.Bypass_Validations__c.Disable__c),
CASE(MOD(Shape_Fit_Review_Request_Date__c - DATE(1900, 1, 7), 7),
0, 0,
5, 0,
6, 0,
1) = 0
)  
* @autho : Ramesh Thulasi
* @param : None
* @return : None
**/
  private static testMethod void test_SFR_Dt_Cant_Be_Fri_Sat_Sun_NegativeTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
      Test.startTest();
      opp.Shape_Fit_Qualification_Request__c = true;
      opp.Shape_Fit_Review_Request_Date__c = TestDataFactory.getNextMonday(
        System.today().addDays(7)
      );
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        SFR_DT_CANT_BE_FRI_SAT_SUN_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
   * @description :  Test method to test validation bypass for user.  Validation bypass flag is set to 'true' means validation should be bypassed and record should be inserted
   * @autho : Ramesh Thulasi
   * @param : None
   * @return : None
   **/
  private static testMethod void test_SFR_Dt_Cant_Be_Fri_Sat_Sun_Bypass_PositiveTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(sossUser);
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
      Test.startTest();
      opp.Shape_Fit_Qualification_Request__c = true;
      opp.Shape_Fit_Review_Request_Date__c = TestDataFactory.getNextFriday(
        System.today().addDays(7)
      );
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        SFR_DT_CANT_BE_FRI_SAT_SUN_ERROR_MSG
      );
      // Record should have been inserted
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'SFR_Dt_Cant_Be_Less_Than_72_Hrs' validation rule. Shape Fit Review Request Date cannot be within 3 days of the current time
* @Rule Name: SFR_Dt_Cant_Be_Less_Than_72_Hrs
* @Rule Definition: 
AND(
NOT($Setup.Bypass_Validations__c.Disable__c),
CASE(MOD(Shape_Fit_Review_Request_Date__c - DATE(1900, 1, 7), 7),
0, 0,
5, 0,
6, 0,
1) = 1,
OR(
Shape_Fit_Review_Request_Date__c < TODAY(),
Shape_Fit_Review_Request_Date__c - TODAY() < 3,
IF(
OR(
MOD(TODAY() - DATE(1900, 1, 7), 7) = 2,
MOD(TODAY() - DATE(1900, 1, 7), 7) = 3,
MOD(TODAY() - DATE(1900, 1, 7), 7) = 4
),
IF( Shape_Fit_Review_Request_Date__c - TODAY() < 6,TRUE,FALSE),FALSE
)
)
)    
* @autho : Ramesh Thulasi
* @param : None
* @return : None
**/
  private static testMethod void test_SFR_Dt_Cant_Be_Less_Than_72_Hrs_PositiveTest(

  ) {
    Integer dayOfWeek = TestDataFactory.dayOfWeekNumber(Date.today());
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
      Test.startTest();
      opp.Shape_Fit_Qualification_Request__c = true;
      opp.Shape_Fit_Review_Request_Date__c = (dayOfWeek == Constants.THURSDAY ||
        dayOfWeek == Constants.FRIDAY ||
        dayOfWeek == Constants.SATURDAY)
        ? (TestDataFactory.getNextMonday(System.today()))
        : (Date.today().addDays(1));
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        SFR_DT_CANT_BE_LESS_THAN_72_HRS_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        true,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'SFR_Dt_Cant_Be_Less_Than_72_Hrs' validation rule. Shape Fit Review Request Date cannot be within 3 days of the current time
* @Rule Name: SFR_Dt_Cant_Be_Less_Than_72_Hrs
* @Rule Definition: 
AND(
NOT($Setup.Bypass_Validations__c.Disable__c),
CASE(MOD(Shape_Fit_Review_Request_Date__c - DATE(1900, 1, 7), 7),
0, 0,
5, 0,
6, 0,
1) = 1,
OR(
Shape_Fit_Review_Request_Date__c < TODAY(),
Shape_Fit_Review_Request_Date__c - TODAY() < 3,
IF(
OR(
MOD(TODAY() - DATE(1900, 1, 7), 7) = 2,
MOD(TODAY() - DATE(1900, 1, 7), 7) = 3,
MOD(TODAY() - DATE(1900, 1, 7), 7) = 4
),
IF( Shape_Fit_Review_Request_Date__c - TODAY() < 6,TRUE,FALSE),FALSE
)
)
)    
* @autho : Ramesh Thulasi
* @param : None
* @return : None
**/
  private static testMethod void test_SFR_Dt_Cant_Be_Less_Than_72_Hrs_NegativeTest(

  ) {
    Integer dayOfWeek = TestDataFactory.dayOfWeekNumber(Date.today());
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
      Test.startTest();
      opp.Shape_Fit_Qualification_Request__c = true;
      opp.Shape_Fit_Review_Request_Date__c = TestDataFactory.getNextMonday(
        System.today().addDays(7)
      );
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        SFR_DT_CANT_BE_LESS_THAN_72_HRS_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
   * @description :  Test method to test validation bypass for user.  Validation bypass flag is set to 'true' means validation should be bypassed and record should be inserted
   * @autho : Ramesh Thulasi
   * @param : None
   * @return : None
   **/
  private static testMethod void test_SFR_Dt_Cant_Be_Less_Than_72_Hrs_Bypass_PositiveTest(

  ) {
    Integer dayOfWeek = TestDataFactory.dayOfWeekNumber(Date.today());
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(sossUser);
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
      Test.startTest();
      opp.Shape_Fit_Qualification_Request__c = true;
      opp.Shape_Fit_Review_Request_Date__c = (dayOfWeek == Constants.THURSDAY ||
        dayOfWeek == Constants.FRIDAY ||
        dayOfWeek == Constants.SATURDAY)
        ? (TestDataFactory.getNextMonday(System.today()))
        : (Date.today().addDays(1));
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        SFR_DT_CANT_BE_LESS_THAN_72_HRS_ERROR_MSG
      );
      // Record should have been inserted
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
    }
  }

  /**
* @description :  Test method to test 'Power_Sponsor_Required_SS3' validation rule. Validation is fired when conditions are met for Any User.
* @Rule Name: Power_Sponsor_Required_SS3
* @Rule Definition: 
AND (
NOT($Setup.Bypass_Validations__c.Disable__c),
ISBLANK(Power_Sponsor__c),
ISCHANGED(StageName),
ISPICKVAL(StageName, "4. Develop"),
OR( 
ISPICKVAL(PRIORVALUE(StageName), "1. Prospect"), 
ISPICKVAL(PRIORVALUE(StageName), "2. Create"), 
ISPICKVAL(PRIORVALUE(StageName), "3. Qualify")
)
)
* @autho : Peter Sabry
* @param : None
* @return : None
**/
  private static testMethod void test_PowerSponsorRequired_SS3_PositiveTest() {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(sossUser);
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_PROSPECT
      );
      Test.startTest();
      opp.Power_Sponsor__c = null;
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_DEVELOP;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        POWER_SPONSOR_REQUIRED_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
    }
  }
  private static testMethod void test_PowerSponsorRequired_SS3_NegativeTest() {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_PROSPECT
      );
      Test.startTest();
      opp.Power_Sponsor__c = null;
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_DEVELOP;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        POWER_SPONSOR_REQUIRED_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        true,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'Main_Competitor_Required_SS3' validation rule. Validation is fired when conditions are met for Any User.
* @Rule Name: Main_Competitor_Required_SS3
* @Rule Definition: 
AND (
NOT($Setup.Bypass_Validations__c.Disable__c),
ISPICKVAL(Main_Competitor__c, ""),
ISCHANGED(StageName),
ISPICKVAL(StageName, "4. Develop"),
OR( 
ISPICKVAL(PRIORVALUE(StageName), "1. Prospect"), 
ISPICKVAL(PRIORVALUE(StageName), "2. Create"), 
ISPICKVAL(PRIORVALUE(StageName), "3. Qualify")
)
)
* @autho : Peter Sabry
* @param : None
* @return : None
**/
  private static testMethod void test_MainCompetitorRequired_SS3_PositiveTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(sossUser);
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_PROSPECT
      );
      Test.startTest();
      opp.Main_Competitor__c = '';
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_DEVELOP;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        MAIN_COMPETITOR_REQUIRED_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
    }
  }
  private static testMethod void test_MainCompetitorRequired_SS3_NegativeTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_PROSPECT
      );
      Test.startTest();
      opp.Main_Competitor__c = '';
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_DEVELOP;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        MAIN_COMPETITOR_REQUIRED_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        true,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'Opp_Cant_Move_From_SS3_Or_SS2_To_SS1' validation rule. Validation is fired when conditions are met for Admin User.
* @Rule Name: Opp_Cant_Move_From_SS3_Or_SS2_To_SS1
* @Rule Definition: 
AND (
NOT($Setup.Bypass_Validations__c.Disable__c),
ISCHANGED(StageName),
OR(
ISPICKVAL(PRIORVALUE(StageName),"3. Qualify"),
ISPICKVAL(PRIORVALUE(StageName),"2. Create"),
),
ISPICKVAL(StageName, "1. Prospect")
)
* @autho : Ramesh Thulasi
* @param : None
* @return : None
**/
  private static testMethod void test_Opp_Cant_Move_From_SS3_Or_SS2_To_SS1_PositiveTest(

  ) {
    User adminUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(adminUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_QUALIFY
      );
      Test.startTest();
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_PROSPECT;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPP_CANT_MOVE_FROM_SS3_OR_SS2_TO_SS1
      );
      Test.stopTest();
      System.assertEquals(
        true,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'Opp_Cant_Move_From_SS3_Or_SS2_To_SS1' validation rule. Validation is NOT fired when conditions are NOT met.
* @Rule Name: Opp_Cant_Move_From_SS3_Or_SS2_To_SS1
* @Rule Definition: 
AND (
NOT($Setup.Bypass_Validations__c.Disable__c),
ISCHANGED(StageName),
OR(
ISPICKVAL(PRIORVALUE(StageName),"3. Qualify"),
ISPICKVAL(PRIORVALUE(StageName),"2. Create"),
),
ISPICKVAL(StageName, "1. Prospect")
)
* @autho : Ramesh Thulasi
* @param : None
* @return : None
**/
  private static testMethod void test_Opp_Cant_Move_From_SS3_Or_SS2_To_SS1_NegativeTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_QUALIFY
      );
      Test.startTest();
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CREATE;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPP_CANT_MOVE_FROM_SS3_OR_SS2_TO_SS1
      );
      Test.stopTest();
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
   * @description :  Test method to test validation bypass for user.  Validation bypass flag is set to 'true' means validation should be bypassed and record should be inserted
   * @autho : Ramesh Thulasi
   * @param : None
   * @return : None
   **/
  private static testMethod void test_Opp_Cant_Move_From_SS3_Or_SS2_To_SS1_Bypass_PositiveTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(sossUser);
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_QUALIFY
      );
      Test.startTest();
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_PROSPECT;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPP_CANT_MOVE_FROM_SS3_OR_SS2_TO_SS1
      );
      Test.stopTest();
      // Record should have been inserted
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'BDR_Can_Move_Opp_Stage_To_Closed_Out' validation rule. Validation is fired when conditions are met for BDR User.
* @Rule Name: BDR_Can_Move_Opp_Stage_To_Closed_Out
* @Rule Definition: 
AND (
NOT($Setup.Bypass_Validations__c.Disable__c),
$Profile.Name ='BDR User',
ISCHANGED(StageName),
NOT(ISPICKVAL(PRIORVALUE(StageName), "1. Prospect")),
NOT(ISPICKVAL(StageName, "Closed Qualified Out"))
)
* @autho : Prity Sangwan
* @param : None
* @return : None
**/
  private static testMethod void test_BDR_Can_Move_Opp_Stage_To_Closed_Out_PositiveTest(

  ) {
    User bdrUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.BDR_USR_PROFILE).Id
    );
    System.runAs(bdrUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_PROSPECT
      );
      Test.startTest();
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CREATE;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        BDR_USER_CANNOT_CHANGE_OPP_STAGE_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        true,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'BDR_Can_Move_Opp_Stage_To_Closed_Out' validation rule. Validation is NOT fired when conditions are NOT met.
* @Rule Name: BDR_Can_Move_Opp_Stage_To_Closed_Out
* @Rule Definition: 
AND (
NOT($Setup.Bypass_Validations__c.Disable__c),
$Profile.Name ='BDR User',
ISCHANGED(StageName),
NOT(ISPICKVAL(PRIORVALUE(StageName), "1. Prospect")),
NOT(ISPICKVAL(StageName, "Closed Qualified Out"))
)
* @autho : Prity Sangwan
* @param : None
* @return : None
**/
  private static testMethod void test_BDR_Can_Move_Opp_Stage_To_Closed_Out_NegativeTest(

  ) {
    User bdrUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.BDR_USR_PROFILE).Id
    );
    System.runAs(bdrUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_PROSPECT
      );
      Test.startTest();
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CQO;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        BDR_USER_CANNOT_CHANGE_OPP_STAGE_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
   * @description :  Test method to test validation bypass for user.  Validation bypass flag is set to 'true' means validation should be bypassed and record should be inserted
   * @autho : Prity Sangwan
   * @param : None
   * @return : None
   **/
  private static testMethod void test_BDR_Can_Move_Opp_Stage_To_Closed_Out_Bypass_PositiveTest(

  ) {
    User bdrUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.BDR_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(bdrUser);
    System.runAs(bdrUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_PROSPECT
      );
      Test.startTest();
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CREATE;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        BDR_USER_CANNOT_CHANGE_OPP_STAGE_ERROR_MSG
      );
      Test.stopTest();
      // Record should have been inserted
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
    }
  }

  /**
    * @description :  Test method to test 'Update_RFI_Due_Dt_When_GSC_RFI_Requested	' validation rule. Validation is fired when conditions are met for Sales User.
    * @Rule Name: Update_RFI_Due_Dt_When_GSC_RFI_Requested	
    * @Rule Definition: 
       AND (
			NOT($Setup.Bypass_Validations__c.Disable__c),
			$Profile.Name ='Sales User',
			ISPICKVAL(GSC_RFI__c, "Requested"),
			ISBLANK(RFI_Due_Date__c),
			ISPICKVAL(StageName, "3. Qualify")
			)
    * @autho : Prity Sangwan
    * @param : None
    * @return : None
    **/
  private static testMethod void test_Update_RFI_Due_Dt_When_GSC_RFI_Requested_PositiveTest(

  ) {
    User salesUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SALES_USR_PROFILE).Id
    );
    System.runAs(salesUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_QUALIFY
      );
      Test.startTest();
      opp.GSC_RFI__c = Constants.GSC_REQUESTED;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        UPDATE_RFI_DUE_DT_WHEN_GSC_RFI_REQUESTED_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        true,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }

  /**
    * @description :  Test method to test 'Update_RFI_Due_Dt_When_GSC_RFI_Requested	' validation rule. Validation is NOT fired when conditions are NOT met.
    * @Rule Name: Update_RFI_Due_Dt_When_GSC_RFI_Requested	
    * @Rule Definition: 
        AND (
			NOT($Setup.Bypass_Validations__c.Disable__c),
			$Profile.Name ='Sales User',
			ISPICKVAL(GSC_RFI__c, "Requested"),
			ISBLANK(RFI_Due_Date__c),
			ISPICKVAL(StageName, "3. Qualify")
			)
    * @autho : Prity Sangwan
    * @param : None
    * @return : None
    **/
  private static testMethod void test_Update_RFI_Due_Dt_When_GSC_RFI_Requested_NegativeTest(

  ) {
    User salesUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SALES_USR_PROFILE).Id
    );
    System.runAs(salesUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_QUALIFY
      );
      Test.startTest();
      opp.GSC_RFI__c = Constants.GSC_REQUESTED;
      opp.RFI_Due_Date__c = system.TODAY();
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        UPDATE_RFI_DUE_DT_WHEN_GSC_RFI_REQUESTED_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
   * @description :  Test method to test validation bypass for user.  Validation bypass flag is set to 'true' means validation should be bypassed and record should be inserted
   * @autho : Prity Sangwan
   * @param : None
   * @return : None
   **/
  private static testMethod void test_Update_RFI_Due_Dt_When_GSC_RFI_Requested_Bypass_PositiveTest(

  ) {
    User salesUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SALES_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(salesUser);
    System.runAs(salesUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_QUALIFY
      );
      Test.startTest();
      opp.GSC_RFI__c = Constants.GSC_REQUESTED;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        UPDATE_RFI_DUE_DT_WHEN_GSC_RFI_REQUESTED_ERROR_MSG
      );
      Test.stopTest();
      // Record should have been inserted
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
    }
  }

  /**
    * @description :  Test method to test 'Opportunity_Naming_Convention' validation rule. Define and enforce Opportunity Naming convention. Should raise error if opp name excludes " - "
    * @Rule Name: Opportunity_Naming_Convention
    * @Rule Definition: 
	    AND (
        NOT($Setup.Bypass_Validations__c.Disable__c),
        OR(
        FIND( " - ", Name ) = 0,
        LEFT( Name,1)="-"
        )
      )    
    * @autho : Ramesh Thulasi
    * @param : None
    * @return : None
    **/
  private static testMethod void test_Opportunity_Naming_Convention_PositiveTest1(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
      Test.startTest();
      opp.Name = 'Test Opp';
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPPORTUNITY_NAMING_CONVENTION_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        true,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
    * @description :  Test method to test 'Opportunity_Naming_Convention' validation rule. Define and enforce Opportunity Naming convention.  Should raise error if name starts with  "-"
    * @Rule Name: Opportunity_Naming_Convention
    * @Rule Definition: 
      AND (
        NOT($Setup.Bypass_Validations__c.Disable__c),
        OR(
        FIND( " - ", Name ) = 0,
        LEFT( Name,1)="-"
        )
      )
    * @autho : Ramesh Thulasi
    * @param : None
    * @return : None
    **/
  private static testMethod void test_Opportunity_Naming_Convention_PositiveTest2(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
      Test.startTest();
      opp.Name = '-Test - Opp';
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPPORTUNITY_NAMING_CONVENTION_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        true,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
    * @description :  Test method to test 'Opportunity_Naming_Convention' validation rule. Define and enforce Opportunity Naming convention
    * @Rule Name: Opportunity_Naming_Convention
    * @Rule Definition: 
      AND (
        NOT($Setup.Bypass_Validations__c.Disable__c),
        OR(
        FIND( " - ", Name ) = 0,
        LEFT( Name,1)="-"
        )
      )    
    * @autho : Ramesh Thulasi
    * @param : None
    * @return : None
    **/
  private static testMethod void test_Opportunity_Naming_Convention_NegativeTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Test.startTest();
      Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPPORTUNITY_NAMING_CONVENTION_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
   * @description :  Test method to test validation bypass for user.  Validation bypass flag is set to 'true' means validation should be bypassed and record should be inserted
   * @autho : Ramesh Thulasi
   * @param : None
   * @return : None
   **/
  private static testMethod void test_Opportunity_Naming_Convention_Bypass_PositiveTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(sossUser);
    System.runAs(sossUser) {
      Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
      Test.startTest();
      opp.Name = 'Test Opp';
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        OPPORTUNITY_NAMING_CONVENTION_ERROR_MSG
      );
      // Record should have been inserted
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'RFI_Due_Dt_Cannot_Be_In_Past_Date' validation rule. Validation is fired when conditions are met for Sales User.
* @Rule Name: RFI_Due_Dt_Cannot_Be_In_Past_Date 
* @Rule Definition: 
    AND (
    NOT($Setup.Bypass_Validations__c.Disable__c),
    $Profile.Name ='Sales User',
    ISCHANGED(RFI_Due_Date__c ),
    RFI_Due_Date__c < TODAY()
    )
)
* @autho : Prity Sangwan
* @param : None
* @return : None
**/
  private static testMethod void test_RFI_Due_Dt_Cannot_Be_In_Past_Date_PositiveTest(

  ) {
    User salesUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SALES_USR_PROFILE).Id
    );
    System.runAs(salesUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_QUALIFY
      );
      Test.startTest();
      opp.GSC_RFI__c = Constants.GSC_REQUESTED;
      opp.RFI_Due_Date__c = system.today().addDays(-1);
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        RFI_DUE_DT_CANNOT_BE_IN_PAST_DATE_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        true,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
      System.assertNotEquals(
        Constants.GSC_REQUESTED,
        [SELECT GSC_RFI__c FROM Opportunity WHERE id = :opp.Id]
        .GSC_RFI__c,
        GSC_RFI_SET_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'RFI_Due_Dt_Cannot_Be_In_Past_Date' validation rule.
* Validation is NOT fired when conditions are NOT met.
* @Rule Name: RFI_Due_Dt_Cannot_Be_In_Past_Date 
* @Rule Definition: 
AND (
    NOT($Setup.Bypass_Validations__c.Disable__c),
    $Profile.Name ='Sales User',
    ISCHANGED(RFI_Due_Date__c ),
    RFI_Due_Date__c < TODAY()
    )
* @autho : Prity Sangwan
* @param : None
* @return : None
**/
  private static testMethod void test_RFI_Due_Dt_Cannot_Be_In_Past_Date_NegativeTest(

  ) {
    User salesUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SALES_USR_PROFILE).Id
    );
    System.runAs(salesUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_QUALIFY
      );
      Test.startTest();
      opp.GSC_RFI__c = Constants.GSC_REQUESTED;
      opp.RFI_Due_Date__c = system.TODAY();
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        RFI_DUE_DT_CANNOT_BE_IN_PAST_DATE_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
      System.assertEquals(
        Constants.GSC_REQUESTED,
        [SELECT GSC_RFI__c FROM Opportunity WHERE id = :opp.Id]
        .GSC_RFI__c,
        GSC_RFI_SET_ERROR_MSG
      );
    }
  }
  /**
   * @description :  Test method to test validation bypass for user.Validation bypass flag is set to 'true' means validation should be bypassed and record should be inserted
   * @autho : Prity Sangwan
   * @param : None
   * @return : None
   **/
  private static testMethod void test_RFI_Due_Dt_Cannot_Be_In_Past_Date_Bypass_PositiveTest(

  ) {
    User salesUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SALES_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(salesUser);
    System.runAs(salesUser) {
      Opportunity opp = TestDataFactory.createOpportunityWithStage(
        Constants.OPPORTUNITY_STAGE_NAME_QUALIFY
      );
      Test.startTest();
      opp.GSC_RFI__c = Constants.GSC_REQUESTED;
      opp.RFI_Due_Date__c = system.today().addDays(-1);
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opp,
        RFI_DUE_DT_CANNOT_BE_IN_PAST_DATE_ERROR_MSG
      );
      Test.stopTest();
      // Record should have been inserted
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
      System.assertEquals(
        Constants.GSC_REQUESTED,
        [SELECT GSC_RFI__c FROM Opportunity WHERE id = :opp.Id]
        .GSC_RFI__c,
        GSC_RFI_SET_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'Opportunity_WithOut_Primary_Quote' validation rule. Define and enforce Opportunity Primary Quote rule
* @Rule Name: Opportunity_WithOut_Primary_Quote
* @Rule Definition: 
	AND (NOT($Setup.Bypass_Validations__c.Disable__c),
	$Profile.Name ='Sales User',
	OR(ISPICKVAL(StageName, "Closed Won"),ISPICKVAL(StageName, "4. Develop"),ISPICKVAL(StageName, "5. Prove"),ISPICKVAL(StageName, "6. Negotiate")), ISBLANK(SBQQ__PrimaryQuote__c) )
* @autho : Sujith Maruthingal
* @param : None
* @return : None
**/
  private static testMethod void test_Opportunity_WithOut_Primary_Quote_PositiveTest(

  ) {
    User salesUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SALES_USR_PROFILE).Id
    );
    System.runAs(salesUser) {
      List<Opportunity> opps = TestDataFactory.createOpportunities(1, 1, true);
      Test.startTest();
      opps[0].StageName = Constants.STAGE_NAME_CLOSED_WON;
      SBQQ__Quote__c primaryQuote = TestDataFactory.createSBQQuote(
        opps[0],
        false,
        true
      );
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opps[0],
        PRIMARY_QUOTE_REQUIRED_ERROR_MSG
      );
      Test.stopTest();
      System.assertEquals(
        true,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
    }
  }
  /**
* @description :  Test method to test 'Opportunity_WithOut_Primary_Quote' validation rule.Validation Rule wont fired for SOSS profile(Other than Sales Profile).
* @Rule Name: Opportunity_WithOut_Primary_Quote
* @Rule Definition: 
	AND (NOT($Setup.Bypass_Validations__c.Disable__c),
	$Profile.Name ='Sales User',
	OR(ISPICKVAL(StageName, "Closed Won"),ISPICKVAL(StageName, "4. Develop"),ISPICKVAL(StageName, "5. Prove"),ISPICKVAL(StageName, "6. Negotiate")), ISBLANK(SBQQ__PrimaryQuote__c) )
* @autho : Sujith Maruthingal
* @param : None
* @return : None
**/
  private static testMethod void test_Opportunity_WithOut_Primary_Quote_NegativeTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      List<Opportunity> opps = TestDataFactory.createOpportunities(1, 1, true);
      Test.startTest();

      opps[0].StageName = Constants.STAGE_NAME_CLOSED_WON;
      SBQQ__Quote__c primaryQuote = TestDataFactory.createSBQQuote(
        opps[0],
        false,
        true
      );
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opps[0],
        PRIMARY_QUOTE_REQUIRED_ERROR_MSG
      );
      Test.stopTest();

      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.DML_VALIDATION_ERROR_MSG
      );
      System.assertEquals(
        Constants.STAGE_NAME_CLOSED_WON,
        [SELECT id, StageName FROM Opportunity WHERE id = :Opps[0].Id]
        .StageName,
        CLOSEONE_ERROR_MESSAGE
      );
    }
  }

  /**
   * @description :  Test method to test validation bypass for user.  Validation bypass flag is set to 'true' means validation should be bypassed and record should be inserted
   * @autho : Sujith Maruthingal
   * @param : None
   * @return : None
   **/
  private static testMethod void test_Opportunity_WithOut_Primary_Quote_Bypass_PositiveTest(

  ) {
    User salesUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SALES_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(salesUser);
    System.runAs(salesUser) {
      List<Opportunity> opps = TestDataFactory.createOpportunities(1, 1, true);
      opps[0].StageName = Constants.STAGE_NAME_CLOSED_WON;
      Test.startTest();
      SBQQ__Quote__c primaryQuote = TestDataFactory.createSBQQuote(
        opps[0],
        false,
        true
      );
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        opps[0],
        PRIMARY_QUOTE_REQUIRED_ERROR_MSG
      );
      Test.stopTest();
      // Record is being updated
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
      System.assertEquals(
        Constants.STAGE_NAME_CLOSED_WON,
        [SELECT id, StageName FROM Opportunity WHERE id = :Opps[0].Id]
        .StageName,
        CLOSEONE_ERROR_MESSAGE
      );
    }
  }
  /**
   * @description RUBX-1200 Lookup Filter error thrown if address record selected for Bill-To is not associated with Opportunity's Account
   * @author Aakanksha Sharma | 27/01/2020
   * @return void
   **/
  private static testMethod void test_Bill_To_Lookup_Filter_PositiveTest() {
    Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
    Address__c addr1 = TestDataFactory.createAccountAddresses(
      opp.AccountId,
      1,
      true
    )[0];
    Account acc2 = TestDataFactory.createAccounts(1, true)[0];
    Address__c addr2 = TestDataFactory.createAccountAddresses(
      acc2.ID,
      1,
      true
    )[0];

    Test.startTest();
    opp.Bill_To__c = addr2.Id;
    Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
      opp,
      BILL_TO_SHIP_TO_LOOKUP_FILTER_ERROR
    );
    Test.stopTest();
    System.assertEquals(
      true,
      containsValidationMsg,
      TestDataFactory.DML_VALIDATION_ERROR_MSG
    );
  }
  /**
   * @description RUBX-1200 Lookup Filter error thrown if address record selected for Bill-To is not associated with Opportunity's Account
   * @author Aakanksha Sharma | 27/01/2020
   * @return void
   **/
  private static testMethod void test_Primary_Ship_To_Lookup_Filter_PositiveTest(

  ) {
    Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
    Address__c addr1 = TestDataFactory.createAccountAddresses(
      opp.AccountId,
      1,
      true
    )[0];
    Account acc2 = TestDataFactory.createAccounts(1, true)[0];
    Address__c addr2 = TestDataFactory.createAccountAddresses(
      acc2.ID,
      1,
      true
    )[0];

    Test.startTest();
    opp.Ship_To__c = addr2.Id;
    Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
      opp,
      BILL_TO_SHIP_TO_LOOKUP_FILTER_ERROR
    );
    Test.stopTest();
    System.assertEquals(
      true,
      containsValidationMsg,
      TestDataFactory.DML_VALIDATION_ERROR_MSG
    );
  }
  /**
   * @description RUBX-1200 Lookup Filter error not thrown if address record selected for Bill-To is associated with with Opportunity's Account
   * @author Aakanksha Sharma | 27/01/2020
   * @return void
   **/
  private static testMethod void test_Primary_Bill_To_Lookup_Filter_NegativeTest(

  ) {
    Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
    Address__c addr1 = TestDataFactory.createAccountAddresses(
      opp.AccountId,
      1,
      true
    )[0];

    Test.startTest();
    opp.Bill_To__c = addr1.Id;
    Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
      opp,
      BILL_TO_SHIP_TO_LOOKUP_FILTER_ERROR
    );
    Test.stopTest();
    List<Opportunity> oppUpdated = [
      SELECT Bill_To__c
      FROM Opportunity
      WHERE id = :opp.id
    ];
    System.assertEquals(
      false,
      containsValidationMsg,
      TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
    );
    System.assertEquals(addr1.Id, oppUpdated[0].Bill_To__c);
  }

  /**
   * @description RUBX-1672 Lookup Filter error not thrown if address record selected for Ship-To is associated with Opportunity's Account
   * @author Aakanksha Sharma | 27/01/2020
   * @return void
   **/
  private static testMethod void test_Primary_Ship_To_Lookup_Filter_NegativeTest(

  ) {
    Opportunity opp = TestDataFactory.createOpportunities(1, 1, true)[0];
    Address__c addr1 = TestDataFactory.createAccountAddresses(
      opp.AccountId,
      1,
      true
    )[0];

    Test.startTest();
    opp.Ship_To__c = addr1.Id;
    Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
      opp,
      BILL_TO_SHIP_TO_LOOKUP_FILTER_ERROR
    );
    Test.stopTest();
    List<Opportunity> oppUpdated = [
      SELECT Ship_To__c
      FROM Opportunity
      WHERE id = :opp.id
    ];
    System.assertEquals(
      false,
      containsValidationMsg,
      TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
    );
    System.assertEquals(addr1.Id, oppUpdated[0].Ship_To__c);
  }
}
