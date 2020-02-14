/**
 * @File Name          : AccountTeamMemberTriggerHandlerTest.cls
 * @Description        : Test class for AccountTeamMemberTriggerHandler
 * @Author             : sujith maruthingal
 * @Group              :
 * @Last Modified By   : Sujith Maruthingal
 * @Last Modified On   : 06/01/2020, 16:39:56
 **/
@IsTest
public with sharing class AccountTeamMemberTriggerHandler_Test {
  private static final Integer BULK_ACCOUNTS = 10 ;
   /**
   * @description checkAccountTeamMemberTest method to restrict Read/Write Access 
   *              to Account and Opportunities access level and dont allow to insert Account team member
   * @author Sujith Maruthingal | 20/12/2019
   * @return void
   **/
    public static testMethod void checkAccountTeamMemberTest_NegativeSingleTest() {
    List<Account> acc = TestDataFactory.createAccounts(1, true);
    Map<String, Profile> profilesMap = TestDataFactory.getProfileMap();
    List<User> usersList = TestDataFactory.createUserList(true);
    User salesUser = TestDataFactory.getProfileUser(
      profilesMap.get(Constants.SALES_USR_PROFILE).Id
    );
    Test.startTest();
    try {
      AccountTeamMember accTeamMember = TestDataFactory.createAccountTeamMember(
        acc[0].Id,
        salesUser.Id,
        Constants.EDIT_ONLY,
        Constants.EDIT_ONLY,
        true
      );
      AccountShare accShare = TestDataFactory.createAccountShare(
        acc[0].Id,
        salesUser.Id,
        Constants.EDIT_ONLY,
        Constants.EDIT_ONLY,
        true
      );
      System.assert(false, Constants.ACC_TEAM_MEMBER_ERROR_MSG);
    } catch (DmlException dmlExp) {
      String errStr = dmlExp.getMessage();
      List<AccountTeamMember> insertedAccTeamMember = [
        SELECT UserId
        FROM AccountTeamMember
        WHERE AccountId = :acc[0].Id AND UserId = :salesUser.Id
      ];
      System.assertEquals(0, insertedAccTeamMember.size());
    }
    Test.stopTest();
  }
  /**
   * @description checkAccountTeamMemberTest_PositiveSingleTest method not to restrict Read Access 
   *              to Account and Opportunities access level and allows Account Team Member added to Account 
   * @author Sujith Maruthingal | 20/12/2019
   * @return void
   **/
    public static testMethod void checkAccountTeamMemberTest_PositiveSingleTest() {
    List<Account> acc = TestDataFactory.createAccounts(1, true);
    Map<String, Profile> profilesMap = TestDataFactory.getProfileMap();
    List<User> usersList = TestDataFactory.createUserList(true);
    User salesUser = TestDataFactory.getProfileUser(
      profilesMap.get(Constants.SALES_USR_PROFILE).Id
    );
    Test.startTest();
    AccountTeamMember accTeamMember = TestDataFactory.createAccountTeamMember(
      acc[0].Id,
      salesUser.Id,
      Constants.READ_ONLY,
      Constants.READ_ONLY,
      true
    );
    AccountShare accShare = TestDataFactory.createAccountShare(
      acc[0].Id,
      salesUser.Id,
      Constants.READ_ONLY,
      Constants.READ_ONLY,
      true
    );
    Test.stopTest();
    AccountTeamMember insertedAccountTeamMember = [
      SELECT UserId
      FROM AccountTeamMember
      WHERE AccountId = :acc[0].ID];
    System.assertEquals(salesUser.ID, insertedAccountTeamMember.UserId);
  }

  /**
   * @description checkAccountTeamMemberTest_BulkifiedPositiveTest to check bulkified scenario 
   * @author Sujith Maruthingal | 20/12/2019
   * @return void
   **/
    public static testMethod void checkAccountTeamMemberTest_BulkifiedPositiveTest() {
    List<Account> accs = TestDataFactory.createAccounts(BULK_ACCOUNTS, true);
    Map<String, Profile> profilesMap = TestDataFactory.getProfileMap();
    List<User> usersList = TestDataFactory.createUserList(true);
    User salesUser = TestDataFactory.getProfileUser(
      profilesMap.get(Constants.SALES_USR_PROFILE).Id
    );
    List<AccountTeamMember> accTeamMembersList = new List<AccountTeamMember>();
    for (Account acc : accs) {
      AccountTeamMember salesUserTM = TestDataFactory.createAccountTeamMember(
        acc.Id,
        salesUser.Id,
        Constants.READ_ONLY,
        Constants.READ_ONLY,
        false
      );
      accTeamMembersList.add(salesUserTM);
    }
    update accs;
    insert accTeamMembersList;

    Test.StartTest();
    Integer accNum = [
      SELECT COUNT()
      FROM AccountTeamMember
      WHERE UserId = :salesUser.Id
    ];
    Test.StopTest();
    System.assertEquals(BULK_ACCOUNTS, accNum, 'Expected'+ BULK_ACCOUNTS + 'account team members but received' + accnum);
  }
}