/**
 * @File Name          : OpportunityTriggerHandlerWS_Test .cls
 * @Description        : Test class for OpportunityTriggerHandlerWS
 * @Author             : ramesh.thulasi@finastra.com
 * @Group              :
 * @Last Modified By   : Ramesh Thulasi
 * @Last Modified On   : 30/01/2020
 **/
@IsTest
public without sharing class OpportunityTriggerHandlerWS_Test {
  private static final String NOT_SALES_USER_ERROR_MSG = 'Accout owner should NOT be sales user before opportunity stage changes from SS1 to SS2';
  private static final String SALES_USER_ERROR_MSG = 'Accout owner should be sales user after opportunity stage changes from SS1 to SS2';
  /**
   * @description  REQ-1467-Positive to test Change Account ownership to Opportunity owner when first Opportunity's stage changes from SS1 to SS2.
   * @author Ramesh Thulasi | 23/01/2020
   * @params None
   * @return None
   **/
  public static testMethod void updateAccountOwnerToOppOwner_SinglePositiveTest(

  ) {
    Opportunity firstOpp = TestDataFactory.createOpportunities(1, 1, true)[0];
    Id oppAccId = firstOpp.AccountId;
    // create users
    List<User> userList = TestDataFactory.createUserList(true);
    Map<String, Profile> profileMap = TestDataFactory.getProfileMap();
    User salesUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SALES_USR_PROFILE).Id
    );
    System.assertNotEquals(
      salesUser.id,
      [SELECT OwnerId FROM Account WHERE Id = :oppAccId]
      .OwnerId,
      NOT_SALES_USER_ERROR_MSG
    );
    Test.startTest();
    firstOpp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CREATE;
    firstOpp.OwnerId = salesUser.id;
    update firstOpp;
    Test.stopTest();
    System.assertEquals(
      salesUser.id,
      [SELECT OwnerId FROM Account WHERE Id = :oppAccId]
      .OwnerId,
      SALES_USER_ERROR_MSG
    );
  }
  /**
   * @description  REQ-1467-Negative to test Change Account ownership to Opportunity owner when first Opportunity's stage changes from SS1 to SS2 and the opportunity owner is  Sales User.
   * @author Ramesh Thulasi | 23/01/2020
   * @params None
   * @return None
   **/
  public static testMethod void updateAccountOwnerToOppOwner_SingleNegativeTest(

  ) {
    Opportunity firstOpp = TestDataFactory.createOpportunities(1, 1, true)[0];
    Test.setCreatedDate(firstOpp.Id, System.now().addDays(-1));
    Id oppAccId = firstOpp.AccountId;

    Opportunity secondOpp = TestDataFactory.createOpportunities(1, 1, false)[0];
    secondOpp.AccountId = oppAccId;
    insert secondOpp;
    System.assertEquals(
      2,
      [SELECT COUNT() FROM Opportunity WHERE AccountId = :oppAccId],
      'Number of opportunities on account should be 2'
    );

    // create users
    List<User> userList = TestDataFactory.createUserList(true);
    Map<String, Profile> profileMap = TestDataFactory.getProfileMap();
    User salesUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SALES_USR_PROFILE).Id
    );
    System.assertNotEquals(
      salesUser.id,
      [SELECT OwnerId FROM Account WHERE Id = :oppAccId]
      .OwnerId,
      NOT_SALES_USER_ERROR_MSG
    );

    Test.startTest();
    secondOpp.OwnerId = salesUser.id;
    firstOpp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CREATE;
    update secondOpp;
    Test.stopTest();
    System.assertNotEquals(
      salesUser.id,
      [SELECT OwnerId FROM Account WHERE Id = :oppAccId]
      .OwnerId,
      NOT_SALES_USER_ERROR_MSG
    );
  }
  /**
   * @description  REQ-1467-Negative to test Change Account ownership to Opportunity owner when first Opportunity's stage changes from SS1 to SS2 and the opportunity owner is not Sales User.
   * @author Ramesh Thulasi | 28/01/2020
   * @params None
   * @return None
   **/
  public static testMethod void updateAccountOwnerToOppOwner_SOSSUser_SingleNegativeTest(

  ) {
    Opportunity firstOpp = TestDataFactory.createOpportunities(1, 1, true)[0];
    Id oppAccId = firstOpp.AccountId;
    // create users
    List<User> userList = TestDataFactory.createUserList(true);
    Map<String, Profile> profileMap = TestDataFactory.getProfileMap();
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    User salesUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SALES_USR_PROFILE).Id
    );
    System.assertNotEquals(
      salesUser.id,
      [SELECT OwnerId FROM Account WHERE Id = :oppAccId]
      .OwnerId,
      NOT_SALES_USER_ERROR_MSG
    );
    Test.startTest();
    firstOpp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CREATE;
    firstOpp.OwnerId = sossUser.id;
    update firstOpp;
    Test.stopTest();
    System.assertNotEquals(
      salesUser.id,
      [SELECT OwnerId FROM Account WHERE Id = :oppAccId]
      .OwnerId,
      NOT_SALES_USER_ERROR_MSG
    );
  }
  /**
   * @description  REQ-1467-Bulk to test Change Account ownership to Opportunity owner when first Opportunity's stage changes from SS1 to SS2.
   * @author Ramesh Thulasi | 23/01/2020
   * @params None
   * @return None
   **/
  public static testMethod void updateAccountOwnerToOppOwner_BulkifiedPositiveTest(

  ) {
    List<Opportunity> insertedOppsList = TestDataFactory.createOpportunities(
      1,
      TestDataFactory.BULK_TEST_RECORD_COUNT,
      true
    );
    Id oppAccId = insertedOppsList[0].AccountId;
    // create users
    List<User> userList = TestDataFactory.createUserList(true);
    Map<String, Profile> profileMap = TestDataFactory.getProfileMap();
    User sossUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SOSS_USR_PROFILE).Id
    );
    User salesUser = TestDataFactory.getProfileUser(
      profileMap.get(Constants.SALES_USR_PROFILE).Id
    );
    System.assertNotEquals(
      salesUser.id,
      [SELECT OwnerId FROM Account WHERE Id = :oppAccId]
      .OwnerId,
      NOT_SALES_USER_ERROR_MSG
    );
    // set owner as 'Sales User' for all the opportunities
    for (Opportunity opp : insertedOppsList) {
      opp.OwnerId = sossUser.id;
      opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_CREATE;
    }
    // set owner as 'SOSS User' for the fist opportinity
    Opportunity firstOpp = insertedOppsList.get(0);
    firstOpp.OwnerId = salesUser.id;
    Test.setCreatedDate(firstOpp.Id, System.now().addDays(-1));
    Test.startTest();
    update insertedOppsList;
    Test.stopTest();
    System.assertEquals(
      salesUser.id,
      [SELECT OwnerId FROM Account WHERE Id = :oppAccId]
      .OwnerId,
      SALES_USER_ERROR_MSG
    );
  }
}
