/**
 * @File Name          : ContactValidationRules_Test.cls
 * @Description        : Test class for all Contact Validation Rules and Lookup Filters
 * @Author             : Aakanksha Sharma
 * @Group              :
 * @Last Modified By   : Aakanksha Sharma
 * @Last Modified On   : 29/01/2020, 13:22:07
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    27/01/2020   Aakanksha Sharma     Initial Version
 **/
@isTest
public with sharing class ContactValidationRules_Test {
  private static final map<String, Profile> profileMap = TestDataFactory.getProfileMap();
  private static final String BILL_TO_SHIP_TO_LOOKUP_FILTER_ERROR = 'Please select an address record associated with the Contact\'s Account';
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
   * @description RUBX-1672 Lookup Filter error thrown if address record selected for Bill-To is not associated with Contact's Account
   * @author Aakanksha Sharma | 27/01/2020
   * @return void
   **/
  private static testMethod void test_Bill_To_Lookup_Filter_PositiveTest() {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      List<Account> accList = TestDataFactory.createAccounts(2, true);
      Contact con = TestDataFactory.createContacts(accList[0].ID, 1, true)[0];
      Address__c addr1 = TestDataFactory.createAccountAddresses(
        accList[0].ID,
        1,
        true
      )[0];
      Address__c addr2 = TestDataFactory.createAccountAddresses(
        accList[1].ID,
        1,
        true
      )[0];
      Test.startTest();
      con.Bill_To__c = addr2.Id;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        con,
        BILL_TO_SHIP_TO_LOOKUP_FILTER_ERROR
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
   * @description RUBX-1672 Lookup Filter error thrown if address record selected for Ship-To is not associated with Contact's Account
   * @author Aakanksha Sharma | 27/01/2020
   * @return void
   **/
  private static testMethod void test_Primary_Ship_To_Lookup_Filter_PositiveTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      List<Account> accList = TestDataFactory.createAccounts(2, true);
      Contact con = TestDataFactory.createContacts(accList[0].ID, 1, true)[0];
      Address__c addr1 = TestDataFactory.createAccountAddresses(
        accList[0].ID,
        1,
        true
      )[0];
      Address__c addr2 = TestDataFactory.createAccountAddresses(
        accList[1].ID,
        1,
        true
      )[0];
      Test.startTest();
      con.Ship_To__c = addr2.Id;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        con,
        BILL_TO_SHIP_TO_LOOKUP_FILTER_ERROR
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
   * @description RUBX-1672 Lookup Filter error not thrown if address record selected for Bill-To is associated with with Contact's Account
   * @author Aakanksha Sharma | 27/01/2020
   * @return void
   **/
  private static testMethod void test_Primary_Bill_To_Lookup_Filter_NegativeTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      List<Account> accList = TestDataFactory.createAccounts(1, true);
      Contact con = TestDataFactory.createContacts(accList[0].ID, 1, true)[0];
      Address__c addr1 = TestDataFactory.createAccountAddresses(
        accList[0].ID,
        1,
        true
      )[0];
      Test.startTest();
      con.Bill_To__c = addr1.Id;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        con,
        BILL_TO_SHIP_TO_LOOKUP_FILTER_ERROR
      );
      Test.stopTest();
      List<Contact> conUpdated = [
        SELECT Bill_To__c
        FROM Contact
        WHERE id = :con.id
      ];
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
      System.assertEquals(addr1.Id, conUpdated[0].Bill_To__c);
    }
  }
  /**
   * @description RUBX-1672 Lookup Filter error not thrown if address record selected for Ship-To is associated with Contact's Account
   * @author Aakanksha Sharma | 27/01/2020
   * @return void
   **/
  private static testMethod void test_Primary_Ship_To_Lookup_Filter_NegativeTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      List<Account> accList = TestDataFactory.createAccounts(1, true);
      Contact con = TestDataFactory.createContacts(accList[0].ID, 1, true)[0];
      Address__c addr1 = TestDataFactory.createAccountAddresses(
        accList[0].ID,
        1,
        true
      )[0];
      Test.startTest();
      con.Ship_To__c = addr1.Id;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        con,
        BILL_TO_SHIP_TO_LOOKUP_FILTER_ERROR
      );
      Test.stopTest();
      List<Contact> conUpdated = [
        SELECT Ship_To__c
        FROM Contact
        WHERE id = :con.id
      ];
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
      System.assertEquals(addr1.Id, conUpdated[0].Ship_To__c);
    }
  }
}
