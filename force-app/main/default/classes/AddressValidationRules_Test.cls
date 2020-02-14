/**
 * @File Name          : AddressValidationRules_Test.cls
 * @Description        : Test class for all Address Validation Rules
 * @Author             : Aakanksha Sharma
 * @Group              :
 * @Last Modified By   : Aakanksha Sharma
 * @Last Modified On   : 30/01/2020, 17:00:10
 * @Modification Log   :
 * Ver       Date            Author              Modification
 * 1.0    27/01/2020   Aakanksha Sharma     Initial Version
 **/
@isTest
public with sharing class AddressValidationRules_Test {
  private static final map<String, Profile> profileMap = TestDataFactory.getProfileMap();
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

  private static final String EITHER_ACCOUNT_OR_CONTACT_ASSOCIATION_ERROR = 'Either an account or a contact can be associated with an address.';
  private static final String NAMING_CONVENTION_ERROR = 'Please name the address in the following format: City - Zipcode. Example: Seattle - 10010. Please note the hyphen and space before and after hyphen';
  /**
    * @description : RUBX-1672 Validation Rule fires if both account and contact fields are populated on Address
    * @Rule Name: Either_Account_or_Contact_Association
    * @Rule Definition: 
      AND (
    NOT($Setup.Bypass_Validations__c.Disable__c),
    OR( ISCHANGED(Account__c),ISCHANGED(Contact__c),ISNEW()),
    NOT(ISBLANK(Account__c)),
    NOT(ISBLANK(Contact__c))
    )   
    * @author : Aakanksha Sharma
    * @param : None
    * @return : None
    **/
  private static testMethod void test_Either_Account_or_Contact_Association_PositiveTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Account acc = TestDataFactory.createAccounts(1, true)[0];
      Contact con = TestDataFactory.createContacts(acc.ID, 1, true)[0];
      Address__c addr = TestDataFactory.createAccountAddresses(
        acc.ID,
        1,
        true
      )[0];
      Test.startTest();
      addr.Contact__c = con.ID;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        addr,
        EITHER_ACCOUNT_OR_CONTACT_ASSOCIATION_ERROR
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
    * @description : RUBX-1672 Validation Rule is not fired if only account field is populated on Address
    * @Rule Name: Either_Account_or_Contact_Association
    * @Rule Definition: 
      AND (
    NOT($Setup.Bypass_Validations__c.Disable__c),
    OR( ISCHANGED(Account__c),ISCHANGED(Contact__c),ISNEW()),
    NOT(ISBLANK(Account__c)),
    NOT(ISBLANK(Contact__c))
    )   
    * @author : Aakanksha Sharma
    * @param : None
    * @return : None
    **/
  private static testMethod void test_Either_Account_or_Contact_Association_NegativeTest1(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Account acc = TestDataFactory.createAccounts(1, true)[0];
      Address__c addr = TestDataFactory.createAccountAddresses(
        acc.ID,
        1,
        false
      )[0];
      Test.startTest();
      insert addr;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        addr,
        EITHER_ACCOUNT_OR_CONTACT_ASSOCIATION_ERROR
      );
      Test.stopTest();
      List<Address__c> addrInserted = [
        SELECT Account__c
        FROM Address__c
        WHERE id = :addr.id
      ];
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
      System.assertEquals(acc.Id, addrInserted[0].Account__c);
    }
  }
  /**
    * @description :RUBX-1672 Validation Rule is not fired if only contact field is populated on Address
    * @Rule Name: Either_Account_or_Contact_Association
    * @Rule Definition: 
      AND (
    NOT($Setup.Bypass_Validations__c.Disable__c),
    OR( ISCHANGED(Account__c),ISCHANGED(Contact__c),ISNEW()),
    NOT(ISBLANK(Account__c)),
    NOT(ISBLANK(Contact__c))
    )   
    * @author : Aakanksha Sharma
    * @param : None
    * @return : None
    **/
  private static testMethod void test_Either_Account_or_Contact_Association_NegativeTest2(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Account acc = TestDataFactory.createAccounts(1, true)[0];
      Contact con = TestDataFactory.createContacts(acc.ID, 1, true)[0];
      Address__c addr = TestDataFactory.createContactAddresses(
        con.ID,
        1,
        false
      )[0];
      Test.startTest();
      insert addr;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        addr,
        EITHER_ACCOUNT_OR_CONTACT_ASSOCIATION_ERROR
      );
      Test.stopTest();
      List<Address__c> addrInserted = [
        SELECT Contact__c
        FROM Address__c
        WHERE id = :addr.id
      ];
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
      System.assertEquals(con.Id, addrInserted[0].Contact__c);
    }
  }
  /**
    * @description : RUBX-1672 Test method to validate bypass - Validation Bypass flag set to true
    * @Rule Name: Either_Account_or_Contact_Association
    * @Rule Definition: 
      AND (
    NOT($Setup.Bypass_Validations__c.Disable__c),
    OR( ISCHANGED(Account__c),ISCHANGED(Contact__c),ISNEW()),
    NOT(ISBLANK(Account__c)),
    NOT(ISBLANK(Contact__c))
    )   
    * @author : Aakanksha Sharma
    * @param : None
    * @return : None
    **/
  private static testMethod void test_Either_Account_or_Contact_Association_BypassTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(sossUser);
    System.runAs(sossUser) {
      Account acc = TestDataFactory.createAccounts(1, true)[0];
      Address__c addr = TestDataFactory.createAccountAddresses(
        acc.ID,
        1,
        true
      )[0];
      Contact con = TestDataFactory.createContacts(acc.ID, 1, true)[0];
      Test.startTest();
      addr.Contact__c = con.Id;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        addr,
        EITHER_ACCOUNT_OR_CONTACT_ASSOCIATION_ERROR
      );
      Test.stopTest();
      List<Address__c> addrUpdated = [
        SELECT Contact__c
        FROM Address__c
        WHERE id = :addr.id
      ];
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
      System.assertEquals(con.Id, addrUpdated[0].Contact__c);
    }
  }
  /**
    * @description : RUBX-3907 Validation Rule fires if Name is not in correct format
    * @Rule Name: Address_Naming_Convention
    * @Rule Definition: 
    AND (
    NOT($Setup.Bypass_Validations__c.Disable__c),
    Name != City__c + ' - ' + Zip_Postal_Code__c
    )   
    * @author : Aakanksha Sharma
    * @param : None
    * @return : None
    **/
  private static testMethod void test_Address_Naming_Convention_PositiveTest() {
    Final String INCORRECT_NAME = 'Test Name';
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Account acc = TestDataFactory.createAccounts(1, true)[0];
      Address__c addr = TestDataFactory.createAccountAddresses(
        acc.ID,
        1,
        true
      )[0];
      Test.startTest();
      addr.Name = INCORRECT_NAME;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        addr,
        NAMING_CONVENTION_ERROR
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
    * @description : RUBX-3907 Validation Rule is not fired if naming convention is correct
    * @Rule Name: Address_Naming_Convention
    * @Rule Definition: 
    AND (
    NOT($Setup.Bypass_Validations__c.Disable__c),
    Name != City__c + ' - ' + Zip_Postal_Code__c
    )   
    * @author : Aakanksha Sharma
    * @param : None
    * @return : None
    **/
  private static testMethod void test_Address_Naming_Convention_NegativeTest() {
    Final String CITY_NAME = 'Manhattan';
    Final String ZIP_CODE =  'NY 3478';
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Account acc = TestDataFactory.createAccounts(1, true)[0];
      Address__c addr = TestDataFactory.createAccountAddresses(
        acc.ID,
        1,
        true
      )[0];
      Test.startTest();
      addr.City__c = CITY_NAME;
      addr.Zip_Postal_Code__c = ZIP_CODE;
      addr.Name = CITY_NAME + ' - ' + ZIP_CODE;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        addr,
        NAMING_CONVENTION_ERROR
      );
      Test.stopTest();
      List<Address__c> addr1 = [
        SELECT Name
        FROM Address__c
        WHERE id = :addr.id
      ];
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
      System.assertEquals('Manhattan' + ' - ' + 'NY 3478', addr1[0].Name);
    }
  }
  /**
    * @description : RUBX-3907 Validation Rule is not fired if bypass is set
    * @Rule Name: Address_Naming_Convention
    * @Rule Definition: 
    AND (
    NOT($Setup.Bypass_Validations__c.Disable__c),
    Name != City__c + ' - ' + Zip_Postal_Code__c
    )   
    * @author : Aakanksha Sharma
    * @param : None
    * @return : None
    **/
  private static testMethod void test_Address_Naming_Convention_BypassTest() {
    Final String INCORRECT_NAME = 'Test Name';
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(sossUser);
    System.runAs(sossUser) {
      Account acc = TestDataFactory.createAccounts(1, true)[0];
      Address__c addr = TestDataFactory.createAccountAddresses(
        acc.ID,
        1,
        true
      )[0];
      Test.startTest();
      addr.Name = INCORRECT_NAME;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        addr,
        NAMING_CONVENTION_ERROR
      );
      Test.stopTest();
      List<Address__c> addr1 = [
        SELECT Name
        FROM Address__c
        WHERE id = :addr.id
      ];
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
      System.assertEquals('Test Name', addr1[0].Name);
    }
  }
  private static final String BOTH_ACCOUNT_CONTACT_BLANK_ERROR = 'Please select either an Account or a Contact for this address record. Note: You can not select both.';
 /**
    * @description : RUBX-3969 Validation Rule fires if both Account and Contact are not selected
    * @Rule Name: Both_Account_and_Contact_Cannot_Be_Blank
    * @Rule Definition: 
        AND (
        NOT($Setup.Bypass_Validations__c.Disable__c),
        OR( ISCHANGED(Account__c),ISCHANGED(Contact__c),ISNEW()),
        ISBLANK(Account__c),
        ISBLANK(Contact__c)
        )
    * @author : Aakanksha Sharma
    * @param : None
    * @return : None
    **/
  private static testMethod void test_Both_Account_and_Contact_Cannot_Be_Blank_PositiveTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Account acc = TestDataFactory.createAccounts(1, true)[0];
      Address__c addr = TestDataFactory.createAccountAddresses(
        acc.ID,
        1,
        true
      )[0];
      Test.startTest();
      addr.Account__c = null;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        addr,
        BOTH_ACCOUNT_CONTACT_BLANK_ERROR
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
    * @description : RUBX-3969 Validation Rule is not fired if either Account or Contact field is not null
    * @Rule Name: Both_Account_and_Contact_Cannot_Be_Blank
    * @Rule Definition: 
        AND (
        NOT($Setup.Bypass_Validations__c.Disable__c),
        OR( ISCHANGED(Account__c),ISCHANGED(Contact__c),ISNEW()),
        ISBLANK(Account__c),
        ISBLANK(Contact__c)
        )
    * @author : Aakanksha Sharma
    * @param : None
    * @return : None
    **/
  private static testMethod void test_Both_Account_and_Contact_Cannot_Be_Blank_NegativeTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    System.runAs(sossUser) {
      Account acc = TestDataFactory.createAccounts(1, true)[0];
      Contact con = TestDataFactory.createContacts(acc.ID, 1, true)[0];
      Address__c addr = TestDataFactory.createAccountAddresses(
        acc.ID,
        1,
        true
      )[0];
      Test.startTest();
      addr.Account__c = null;
      addr.Contact__c = con.Id;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        addr,
        BOTH_ACCOUNT_CONTACT_BLANK_ERROR
      );
      Test.stopTest();
      List<Address__c> addr1 = [
        SELECT Contact__c,
        Account__c
        FROM Address__c
        WHERE id = :addr.id
      ];
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
      System.assertEquals(null,addr1[0].Account__c);
      System.assertEquals(con.Id,addr1[0].Contact__c);    
    }
  }
 /**
    * @description : RUBX-3969 Validation Rule is not fired if bypass is set
    * @Rule Name: Both_Account_and_Contact_Cannot_Be_Blank
    * @Rule Definition: 
        AND (
        NOT($Setup.Bypass_Validations__c.Disable__c),
        OR( ISCHANGED(Account__c),ISCHANGED(Contact__c),ISNEW()),
        ISBLANK(Account__c),
        ISBLANK(Contact__c)
        )  
    * @author : Aakanksha Sharma
    * @param : None
    * @return : None
    **/
  private static testMethod void test_Both_Account_and_Contact_Cannot_Be_Blank_BypassTest(

  ) {
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    TestDataFactory.setBypassValidationForUser(sossUser);
    System.runAs(sossUser) {
      Account acc = TestDataFactory.createAccounts(1, true)[0];
      Contact con = TestDataFactory.createContacts(acc.ID, 1, true)[0];
      Address__c addr = TestDataFactory.createAccountAddresses(
        acc.ID,
        1,
        true
      )[0];
       Test.startTest();
      addr.Contact__c = con.Id;
      Boolean containsValidationMsg = TestDataFactory.checkValidationErrorMessage(
        addr,
        BOTH_ACCOUNT_CONTACT_BLANK_ERROR
      );
      Test.stopTest();
      List<Address__c> addr1 = [
        SELECT Contact__c,
        Account__c
        FROM Address__c
        WHERE id = :addr.id
      ];
      System.assertEquals(
        false,
        containsValidationMsg,
        TestDataFactory.NO_DML_VALIDATION_ERROR_MSG
      );
      System.assertEquals(acc.Id,addr1[0].Account__c);
      System.assertEquals(con.Id,addr1[0].Contact__c);    
    }
  }
}
