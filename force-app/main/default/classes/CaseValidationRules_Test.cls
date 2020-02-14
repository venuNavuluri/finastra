/**
 * @File Name          : CaseValidationRules_Test.cls
 * @Description        :
 * @Author             : venu.navuluri@finastra.com
 * @Group              :
 * @Last Modified By   : Aakanksha Sharma
 * @Last Modified On   : 07/01/2020, 16:36:11
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    12/18/2019   venu.navuluri@finastra.com    Initial Version
 * 2.0    22/01/2020   irfan.khan@finastra.com       Added CS_Contact_must_belong_to_CS_Account related test methods
 **/
@isTest
private class CaseValidationRules_Test {
  private static final String CASE_AUDIT_RESULT_SUMMARY_REQUIRED = 'Audit Result Summary is required.';
  private static final String CASE_STATUS_FLOW = 'LCA case status should move in particular order';
  private static final map<String, Profile> profileMap = TestDataFactory.getProfileMap();
  private static final String CS_CONTACT_MUST_BELONG_TO_CS_ACCOUNT = 'Please select contact which belongs to the same account added to the case';

  @testSetup
  static void setup() {
    // init Bypass validation custom property
    List<Bypass_Validations__c> valCusSettings = new List<Bypass_Validations__c>();

    List<User> userList = TestDataFactory.createUserList(true);
    User adminUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SYS_ADMIN_PROFILE).Id
    );
    // set custom property for admin user
    System.runAs(adminUser) {
      // flag defaults to false means validation rules are NOT bypassed
      valCusSettings.add(
        new Bypass_Validations__c(
          SetupOwnerId = adminUser.id,
          Disable__c = false
        )
      );
      insert valCusSettings;
    }
  }

  /**
* @description :  Test method to test 'Audit_Result_Summary_required' validation rule. Validation is fired when conditions are met.
* @Rule Name: Audit_Result_Summary_required
* @Rule Definition: 
    AND(
    RecordType.DeveloperName = 'License_Compliance_Audit',
    OR(ISPICKVAL(Status, 'Result for Concurrence'),ISPICKVAL(Status, 'Awaiting Deselection Approval'),ISPICKVAL(Status, 'Audited - Pending Opportunity'),ISPICKVAL(Status, 'Not Audited (Closed)'),ISPICKVAL(Status, 'Audited (Closed)')),
    ISBLANK( Audit_Result_Summary__c ),
    NOT($Setup.Bypass_Validations__c.Disable__c)
    )
* @autho : Venu Navuluri
* @param : None
* @return : None
**/
  private static testMethod void test_caseAuditSummaryValidation_PositiveTest(

  ) {
    Case cs = TestDataFactory.CreateLCACase(null, null, true);
    // Perform test
    Test.startTest();
    cs.Status = Constants.CASE_STATUS_DESELECTION_APPROVAL;
    Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
      cs,
      CASE_AUDIT_RESULT_SUMMARY_REQUIRED
    );
    Test.stopTest();
    System.assertEquals(
      true,
      containsValidationMsg,
      TestDataFactory.DML_VALIDATION_ERROR_MSG
    );
  }

  /**
* @description :  Test method to test 'Audit_Result_Summary_required' validation rule. Validation is not fired when conditions are not met.
* @Rule Name: Audit_Result_Summary_required
* @Rule Definition: 
    AND(
    RecordType.DeveloperName = 'License_Compliance_Audit',
    OR(ISPICKVAL(Status, 'Result for Concurrence'),ISPICKVAL(Status, 'Awaiting Deselection Approval'),ISPICKVAL(Status, 'Audited - Pending Opportunity'),ISPICKVAL(Status, 'Not Audited (Closed)'),ISPICKVAL(Status, 'Audited (Closed)')),
    ISBLANK( Audit_Result_Summary__c ),
    NOT($Setup.Bypass_Validations__c.Disable__c)
    )
* @autho : Venu Navuluri
* @param : None
* @return : None
**/

  private static testMethod void test_caseAuditSummaryValidation_NegativeTest(

  ) {
    Case cs = TestDataFactory.CreateLCACase(null, null, true);
    // Perform test
    Test.startTest();
    cs.Status = Constants.CASE_STATUS_DESELECTION_APPROVAL;
    cs.Audit_Result_Summary__c = CASE_STATUS_FLOW;
    Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
      cs,
      CASE_AUDIT_RESULT_SUMMARY_REQUIRED
    );
    Test.stopTest();
    System.assertEquals(
      false,
      containsValidationMsg,
      TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
    );
  }

  /**
   * @description :  Test method to test validation bypass for user.  Validation bypass flag is set to 'true' means validation should be bypassed and record should be inserted
   * @autho : Venu Navuluri
   * @param : None
   * @return : None
   **/

  private static testMethod void test_caseAuditSummaryValidation_Bypass_PositiveTest(

  ) {
    User adminUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SYS_ADMIN_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(adminUser);
    System.runAs(adminUser) {
      Case cs = TestDataFactory.CreateLCACase(null, null, true);
      // Perform test
      Test.startTest();
      cs.Status = Constants.CASE_STATUS_DESELECTION_APPROVAL;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        cs,
        CASE_AUDIT_RESULT_SUMMARY_REQUIRED
      );
      Test.stopTest();

      // Record should have been updated
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
    }
  }

  /**
* @description :  Test method to test 'LCA_Case_Status_flow ' validation rule. Validation is fired when conditions are met.
* @Rule Name: LCA_Case_Status_flow 
* @Rule Definition: 
        AND(ISCHANGED( Status ),
    NOT($Setup.Bypass_Validations__c.Disable__c),
    OR(
    AND(ISPICKVAL(Status, "With AM to Review"),
    NOT(ISPICKVAL( PRIORVALUE( Status ), "Pre-work"))),
    AND(ISPICKVAL(Status, "Customer Communication"),
    NOT(ISPICKVAL( PRIORVALUE( Status ), "With AM to Review"))),
    AND(ISPICKVAL(Status, "Report Queued for Analysis"),
    NOT(ISPICKVAL( PRIORVALUE( Status ), "Customer Communication"))),
    AND(ISPICKVAL(Status, "Result for Concurrence"),
    NOT(ISPICKVAL( PRIORVALUE( Status ), "Report Queued for Analysis"))),
    AND(ISPICKVAL(Status, "Audited - Pending Opportunity"),
    NOT(ISPICKVAL( PRIORVALUE( Status ), "Report Queued for Analysis"))),
    AND(ISPICKVAL(Status, "Audited (Closed)"),
    NOT(ISPICKVAL( PRIORVALUE( Status ), "Audited - Pending Opportunity"))),
    AND(ISPICKVAL(Status, "Deselection Rejected"),
    NOT(ISPICKVAL( PRIORVALUE( Status ), "Awaiting Deselection Approval")))
    ))
* @autho : Venu Navuluri
* @param : None
* @return : None
**/

  private static testMethod void test_caseStatusFlowValidation_PositiveTest() {
    Case cs = TestDataFactory.CreateLCACase(null, null, false);
    cs.status = Constants.CASE_STATUS_PRE_WORK;
    insert cs;
    // Perform test
    Test.startTest();
    cs.Status = Constants.CASE_STATUS_AUDITED;
    Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
      cs,
      CASE_STATUS_FLOW
    );
    Test.stopTest();
    System.assertEquals(
      true,
      containsValidationMsg,
      TestDataFactory.DML_VALIDATION_ERROR_MSG
    );
  }

  /**
* @description :  Test method to test 'LCA_Case_Status_flow ' validation rule. Validation is fired when conditions are not met.
* @Rule Name: LCA_Case_Status_flow 
* @Rule Definition: 
        AND(ISCHANGED( Status ),
    NOT($Setup.Bypass_Validations__c.Disable__c),
    OR(
    AND(ISPICKVAL(Status, "With AM to Review"),
    NOT(ISPICKVAL( PRIORVALUE( Status ), "Pre-work"))),
    AND(ISPICKVAL(Status, "Customer Communication"),
    NOT(ISPICKVAL( PRIORVALUE( Status ), "With AM to Review"))),
    AND(ISPICKVAL(Status, "Report Queued for Analysis"),
    NOT(ISPICKVAL( PRIORVALUE( Status ), "Customer Communication"))),
    AND(ISPICKVAL(Status, "Result for Concurrence"),
    NOT(ISPICKVAL( PRIORVALUE( Status ), "Report Queued for Analysis"))),
    AND(ISPICKVAL(Status, "Audited - Pending Opportunity"),
    NOT(ISPICKVAL( PRIORVALUE( Status ), "Report Queued for Analysis"))),
    AND(ISPICKVAL(Status, "Audited (Closed)"),
    NOT(ISPICKVAL( PRIORVALUE( Status ), "Audited - Pending Opportunity"))),
    AND(ISPICKVAL(Status, "Deselection Rejected"),
    NOT(ISPICKVAL( PRIORVALUE( Status ), "Awaiting Deselection Approval")))
    ))
* @autho : Venu Navuluri
* @param : None
* @return : None
**/
  private static testMethod void test_caseStatusFlowValidation_NegativeTest() {
    Case cs = TestDataFactory.CreateLCACase(null, null, false);
    cs.status = Constants.CASE_STATUS_PRE_WORK;
    insert cs;
    // Perform test
    Test.startTest();
    cs.Status = Constants.CASE_STATUS_WITH_AM_TO_REVIEW;
    Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
      cs,
      CASE_STATUS_FLOW
    );
    Test.stopTest();
    System.assertEquals(
      false,
      containsValidationMsg,
      TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
    );
  }

  /**
   * @description :  Test method to test validation bypass for user.  Validation bypass flag is set to 'true' means validation should be bypassed and record should be inserted
   * @autho : Venu Navuluri
   * @param : None
   * @return : None
   **/

  private static testMethod void test_caseStatusFlowValidation_Bypass_PositiveTest(

  ) {
    User adminUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SYS_ADMIN_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(adminUser);
    System.runAs(adminUser) {
      Case cs = TestDataFactory.CreateLCACase(null, null, false);
      cs.status = Constants.CASE_STATUS_PRE_WORK;
      insert cs;
      // Perform test
      Test.startTest();
      cs.Status = Constants.CASE_STATUS_AUDITED;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        cs,
        CASE_STATUS_FLOW
      );
      Test.stopTest();

      // Record should have been updated
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.BYPASS_VALIDATION_ERROR_MSG
      );
    }
  }

  /**
* @description : Validation Rule 'CS_Contact_must_belong_to_CS_Account' should not fire (negative test).
* @Rule Name: CS_Contact_must_belong_to_CS_Account
* @Rule Definition: 
    AND(
RecordType.DeveloperName = &#39;Customer_Service&#39;,
Contact.AccountId !=   AccountId,
NOT($Setup.Bypass_Validations__c.Disable__c)
)
* @author : Irfan Khan
* @param : None
* @return : None
**/

  @isTest
  static void cs_Contact_must_belong_to_CS_Account_NegativeTest() {
    User supportRepUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SUPPORT_REP).Id
    );
    Case csCase = TestDataFactory.createCSCase(null, null, false);
    // Perform test
    Test.startTest();
    System.runAs(supportRepUser) {
      insert csCase;
    }
    Test.stopTest();
    system.assertEquals(
      1,
      [SELECT COUNT() FROM Case WHERE Id = :csCase.Id],
      'Validation Rule CS_Contact_must_belong_to_CS_Account should not fire'
    );
  }

  /**
* @description : 'CS_Contact_must_belong_to_CS_Account' should fire in this positive test.
* @Rule Name: CS_Contact_must_belong_to_CS_Account
* @Rule Definition: 
    AND(
RecordType.DeveloperName = &#39;Customer_Service&#39;,
Contact.AccountId !=   AccountId,
NOT($Setup.Bypass_Validations__c.Disable__c)
)
* @author : Irfan Khan
* @param : None
* @return : None
**/

  @isTest
  static void cs_Contact_must_belong_to_CS_Account_PositiveTest() {
    Boolean containsValidationMsg;
    User supportRepUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SUPPORT_REP).Id
    );
    Case csCase = TestDataFactory.createCSCase(null, null, true);
    Account account = TestDataFactory.createAccount('RobinHoodTestBank');
    insert account;
    Contact contact = TestDataFactory.createContact(
      account.Id,
      'Batman',
      'Robin',
      true
    );

    // Perform test
    Test.startTest();
    System.runAs(supportRepUser) {
      //Now change the contact which is a child to different account
      csCase.contactId = contact.Id;
      //It shd return true if validation is successfully fired
      containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        csCase,
        CS_CONTACT_MUST_BELONG_TO_CS_ACCOUNT
      );
    }
    Test.stopTest();
    system.assertEquals(
      true,
      containsValidationMsg,
      CS_CONTACT_MUST_BELONG_TO_CS_ACCOUNT
    );
  }

  /**
* @description : Bypassing Test for 'CS_Contact_must_belong_to_CS_Account'.
* @Rule Name: CS_Contact_must_belong_to_CS_Account
* @Rule Definition: 
    AND(
RecordType.DeveloperName = &#39;Customer_Service&#39;,
Contact.AccountId !=   AccountId,
NOT($Setup.Bypass_Validations__c.Disable__c)
)
* @author : Irfan Khan
* @param : None
* @return : None
**/

  @isTest
  static void cs_Contact_must_belong_to_CS_Account_byPass() {
    Boolean containsValidationMsg;
    User supportRepUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SUPPORT_REP).Id
    );
    //Bypass val rule for support rep profile
    TestDataFactory.createByPassValidationRecord(supportRepUser);

    Case csCase = TestDataFactory.createCSCase(null, null, true);
    Account account = TestDataFactory.createAccount('RobinHoodTestBank');
    insert account;
    Contact contact = TestDataFactory.createContact(
      account.Id,
      'Batman',
      'Robin',
      true
    );

    // Perform test
    Test.startTest();
    System.runAs(supportRepUser) {
      //Now change the contact which is a child to different account
      csCase.contactId = contact.Id;
      //It shd return false if validation is not fired
      containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        csCase,
        CS_CONTACT_MUST_BELONG_TO_CS_ACCOUNT
      );
    }
    Test.stopTest();
    system.assertEquals(
      false,
      containsValidationMsg,
      'VR : ' +
      CS_CONTACT_MUST_BELONG_TO_CS_ACCOUNT +
      ' should bypass.'
    );
  }
}
