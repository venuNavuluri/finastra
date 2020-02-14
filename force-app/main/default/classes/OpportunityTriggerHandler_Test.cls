/**
 * @File Name          : OpportunityTriggerHandlerTest.cls
 * @Description        : Test class for OpportunityHandler
 * @Author             : venu.navuluri@finastra.com
 * @Group              :
 * @Last Modified By   : Aakanksha Sharma
 * @Last Modified On   : 29/01/2020, 19:19:14
 **/
@IsTest
public with sharing class OpportunityTriggerHandler_Test {
  public final static String OPP_WITH_VALIDATION_ERR_MSG = 'Opportunity Save should throw error';
  public final static String OPP_WITHOUT_VALIDATION_ERR_MSG = 'Opportunity records should have been udpated with out any error with Stagename ';

  public final static String MEETING_SUBJECT = 'Meeting with Customer';
  public final static String TEAM_MEMBER_ROLE = 'Sales Executive - Retail';
  public final static String OPP_ACCESS_EDIT = 'Edit';

  public static testMethod void setOppStageToClosedWonTest_PositiveSingleTest(

  ) {
    List<Opportunity> opps = TestDataFactory.createOpportunities(1, 1, true);
    // Perform test
    Test.startTest();
    opps[0].CAT_Logging_Stage__c = Constants.CAT_LOGGING_STAGE_COMPLETE;
    SBQQ__Quote__c primaryQuote = TestDataFactory.createSBQQuote(
      opps[0],
      true,
      true
    );
    update opps;
    Test.stopTest();

    //Verify results
    System.assertEquals(
      Constants.STAGE_NAME_CLOSED_WON,
      [SELECT id, StageName FROM Opportunity WHERE id = :opps[0].Id]
      .StageName
    );
  }

  public static testMethod void setOppStageToClosedWonTest_NegativeSingleTest(

  ) {
    Opportunity[] opps = TestDataFactory.createOpportunities(1, 1, true);
    // Perform test
    Test.startTest();
    opps[0].CAT_Logging_Stage__c = null;
    update opps;
    Test.stopTest();

    //Verify results
    System.assertNotEquals(
      Constants.STAGE_NAME_CLOSED_WON,
      [SELECT id, StageName FROM Opportunity WHERE id = :Opps[0].Id]
      .StageName
    );
  }

  public static testMethod void setOppStageToClosedWonTest_BulkifiedTest() {
    List<Opportunity> opps = TestDataFactory.CreateOpportunities(1, 200, true);
    List<SBQQ__Quote__c> quotesToInsert = TestDataFactory.createSBQQuotes(
      opps,
      true,
      true
    );
    List<Opportunity> updatedOpps = new List<Opportunity>();
    // Perform test
    Test.startTest();
    for (Opportunity oppToUpdate : opps) {
      oppToUpdate.CAT_Logging_Stage__c = Constants.CAT_LOGGING_STAGE_COMPLETE;
      updatedOpps.add(oppToUpdate);
    }
    update updatedOpps;
    Test.stopTest();

    //Verify results
    System.assertEquals(
      Constants.STAGE_NAME_CLOSED_WON,
      [SELECT id, StageName FROM Opportunity WHERE id = :opps[50].Id]
      .StageName
    );
  }
  /**
   * @description : RUBX-466 - Moving an Opportunity beyond Stage 2 should not throw an error if a contact role is associated to it
   * @author Sujith Maruthingal | 28/11/2019
   * @return
   **/
  public static testMethod void checkContactRoleOnOpportunityTest_NegativeSingleTest(

  ) {
    List<Opportunity> opps = TestDataFactory.createOpportunities(1, 1, true);

    // Perform test
    Test.startTest();
    opps[0].stageName = Constants.OPPORTUNITY_STAGE_NAME_QUALIFY;
    Database.SaveResult result = Database.update(opps[0], true);
    System.assertEquals(
      true,
      result.isSuccess(),
      OPP_WITHOUT_VALIDATION_ERR_MSG
    );
    Test.stopTest();
    //Verify results
    System.assertEquals(
      Constants.OPPORTUNITY_STAGE_NAME_QUALIFY,
      [SELECT id, StageName FROM Opportunity WHERE id = :opps[0].Id]
      .StageName
    );
  }

  /**
   * @description RUBX-466 - Moving an Opportunity beyond Stage 2 should throw an error if a contact role is not associated to it
   * @author Sujith Maruthingal | 28/11/2019
   * @return
   **/
  public static testMethod void checkContactRoleOnOpportunityTest_PositiveSingleTest(

  ) {
    List<Opportunity> opps = TestDataFactory.CreateOpportunities(1, 1, true);
    List<OpportunityContactRole> ocrs = [
      SELECT Id
      FROM OpportunityContactRole
      WHERE OpportunityId = :opps[0].Id
    ];
    delete ocrs;
    // Perform test
    Test.startTest();
    opps[0].stageName = Constants.OPPORTUNITY_STAGE_NAME_QUALIFY;
    try {
      Database.SaveResult result = Database.update(opps[0], true);
      System.assert(false, OPP_WITH_VALIDATION_ERR_MSG);
    } catch (DmlException dmlExp) {
      String errStr = dmlExp.getMessage();
      System.assertEquals(
        true,
        errStr.contains(Constants.OPP_CONTACT_ROLE_ERROR_MSG),
        OPP_WITH_VALIDATION_ERR_MSG +
        Constants.OPP_CONTACT_ROLE_ERROR_MSG +
        '"'
      );
      System.assertNotEquals(
        Constants.OPPORTUNITY_STAGE_NAME_QUALIFY,
        [SELECT id, StageName FROM Opportunity WHERE id = :opps[0].Id]
        .StageName
      );
    }
    Test.stopTest();
    //Verify results
  }

  /**
   * @description RUBX-466 - Moving bulk Opportunities beyond Stage 2 should not hit governor limits
   * @author Sujith Maruthingal | 28/11/2019
   * @return testMethod
   **/
  public static testMethod void checkContactRoleOnOpportunityTest_BulkifiedTest(

  ) {
    Opportunity[] opps = TestDataFactory.createOpportunities(
      1,
      Constants.NO_OF_REC_FOR_BULK_TEST,
      true
    );
    List<Opportunity> updatedOpps = new List<Opportunity>();
    // Perform test
    Test.startTest();
    for (Opportunity oppsToUpdate : opps) {
      oppsToUpdate.stageName = Constants.OPPORTUNITY_STAGE_NAME_QUALIFY;
      updatedOpps.add(oppsToUpdate);
    }
    update updatedOpps;
    Test.stopTest();

    //Verify results
    updatedOpps = [
      SELECT id, StageName
      FROM Opportunity
      WHERE StageName = :Constants.OPPORTUNITY_STAGE_NAME_QUALIFY
    ];
    System.assertEquals(
      Constants.NO_OF_REC_FOR_BULK_TEST,
      updatedOpps.size(),
      OPP_WITHOUT_VALIDATION_ERR_MSG +
      Constants.OPPORTUNITY_STAGE_NAME_QUALIFY +
      '"'
    );
  }

  /**
   * @description RUBX-452/1199 : Fields should be populated properly on creation of Full Opportunity
   * @author Aakanksha Sharma | 03/12/2019
   * @return void
   **/
  public static testMethod void populateFullOpptyFields_PositiveSingleTest() {
    List<Opportunity> opps = TestDataFactory.createOpportunities(1, 1, false);
    List<Account> insertedAcc = new List<Account>(
      [
        SELECT
          Id,
          Primary_Bill_To__c,
          Primary_Ship_To__c,
          CurrencyIsoCode,
          Country__c
        FROM Account
        WHERE id = :opps[0].AccountId
      ]
    );
    Address__c addr = TestDataFactory.createAccountAddresses(
      insertedAcc[0].Id,
      1,
      true
    )[0];
    insertedAcc[0].Primary_Bill_To__c = addr.Id;
    insertedAcc[0].Primary_Ship_To__c = addr.Id;
    update insertedAcc;
    // Perform test
    Test.startTest();
    opps[0].stageName = Constants.OPPORTUNITY_STAGE_NAME_QUALIFY;
    opps[0].CurrencyIsoCode = Constants.USD_CURRENCY;
    opps[0].Pricing_Country__c = Constants.USA_COUNTRY;
    opps[0].RecordTypeId = Constants.OPPORTUNITY_FULL_RECORDTYPEID;
    Database.SaveResult result = Database.insert(opps[0], true);
    Test.stopTest();

    //Verify results
    List<Opportunity> insertedOpp = new List<Opportunity>(
      [
        SELECT
          id,
          StageName,
          CurrencyIsoCode,
          Pricing_Country__c,
          Bill_To__c,
          Ship_To__c
        FROM opportunity
        WHERE id = :opps[0].Id
      ]
    );

    System.assertEquals(
      insertedOpp[0].StageName,
      Constants.OPPORTUNITY_STAGE_NAME_PROSPECT
    );
    System.assertEquals(
      insertedOpp[0].CurrencyIsoCode,
      insertedAcc[0].CurrencyIsoCode
    );
    System.assertEquals(
      insertedOpp[0].Pricing_Country__c,
      insertedAcc[0].Country__c
    );
    System.assertEquals(
      insertedOpp[0].Bill_To__c,
      insertedAcc[0].Primary_Bill_To__c
    );
    System.assertEquals(
      insertedOpp[0].Ship_To__c,
      insertedAcc[0].Primary_Ship_To__c
    );
  }
  /**
   * @description RUBX-452 : If Account country is null, it should not override Opportunity country
				  RUBX-1199 : If Account Primary addresses are not populated, it should not override what user selects at time of creation
   * @author Aakanksha Sharma | 03/12/2019
   * @return testMethod
   **/
  public static testMethod void populateFullOpptyFields_negativeSingleTest() {
    List<Opportunity> opps = TestDataFactory.createOpportunities(1, 1, false);
    Account acc = [
      SELECT Id, Country__c
      FROM Account
      WHERE id = :opps[0].AccountId
    ];
    acc.Country__c = null;
    update acc;
    Address__c addr = TestDataFactory.createAccountAddresses(
      acc.Id,
      1,
      true
    )[0];

    // Perform test
    Test.startTest();
    opps[0].stageName = Constants.OPPORTUNITY_STAGE_NAME_QUALIFY;
    opps[0].Pricing_Country__c = Constants.USA_COUNTRY;
    opps[0].RecordTypeId = Constants.OPPORTUNITY_FULL_RECORDTYPEID;
    opps[0].Bill_To__c = addr.Id;
    opps[0].Ship_To__c = addr.Id;
    Database.SaveResult result = Database.insert(opps[0], true);
    Test.stopTest();

    //Verify results
    List<Opportunity> insertedOpp = new List<Opportunity>(
      [
        SELECT id, Pricing_Country__c, Bill_To__c, Ship_To__c
        FROM opportunity
        WHERE id = :opps[0].Id
      ]
    );

    System.assertEquals(
      insertedOpp[0].Pricing_Country__c,
      Constants.USA_COUNTRY
    );
    System.assertEquals(insertedOpp[0].Bill_To__c, addr.Id);
    System.assertEquals(insertedOpp[0].Ship_To__c, addr.Id);
  }
  /**
   * @description RUBX-452/1199 : Bulk insertion of Full Opportunities should not hit governor limits and should populate fields correctly
   * @author Aakanksha Sharma | 03/12/2019
   * @return testMethod
   **/
  /**
   * @description RUBX-452 : Bulk insertion of Full Opportunities should not hit governor limits and should populate fields correctly
   * @author Aakanksha Sharma | 03/12/2019
   * @return testMethod
   **/
  public static testMethod void populateFullOpptyFields_BulkifiedTest() {
    List<Opportunity> opps = TestDataFactory.createOpportunities(
      1,
      Constants.NO_OF_REC_FOR_BULK_TEST,
      false
    );
    Account insertedAcc = [
      SELECT
        Id,
        Primary_Bill_To__c,
        Primary_Ship_To__c,
        CurrencyIsoCode,
        Country__c
      FROM Account
      WHERE id = :opps[0].AccountId
    ];
    Address__c addr = TestDataFactory.createAccountAddresses(
      insertedAcc.Id,
      1,
      true
    )[0];
    insertedAcc.Primary_Bill_To__c = addr.Id;
    insertedAcc.Primary_Ship_To__c = addr.Id;
    update insertedAcc;

    List<Opportunity> insertOpps = new List<Opportunity>();
    // Perform test
    Test.startTest();
    for (Opportunity oppty : opps) {
      oppty.stageName = Constants.OPPORTUNITY_STAGE_NAME_QUALIFY;
      oppty.CurrencyIsoCode = Constants.USD_CURRENCY;
      oppty.Pricing_Country__c = Constants.USA_COUNTRY;
      oppty.RecordTypeId = Constants.OPPORTUNITY_FULL_RECORDTYPEID;
      insertOpps.add(oppty);
    }
    insert insertOpps;
    Test.stopTest();

    //check total inserted records
    List<Opportunity> updatedOpps = new List<Opportunity>(
      [
        SELECT id, CurrencyIsoCode
        FROM Opportunity
        WHERE
          stageName = :Constants.OPPORTUNITY_STAGE_NAME_PROSPECT
          AND Bill_To__c = :addr.Id
          AND Ship_To__c = :addr.Id
      ]
    );
    System.assertEquals(Constants.NO_OF_REC_FOR_BULK_TEST, updatedOpps.size());
  }
  /**
   * @description RUBX-456: required validation before firing the approval process - positive test
   * @author Peter Sabry | 09/12/2019
   * @return testMethod
   **/
  public static testMethod void validateSalesRepAssignment_SinglePositiveTest(

  ) {
    final String TASK_SUBJECT_MEETING_STR = 'Meeting with Customer';
    List<Opportunity> opps = TestDataFactory.createOpportunities(1, 1, true);

    String bdrUser;
    Map<String, Profile> profilesMap = TestDataFactory.getProfileMap();
    List<User> usersList = TestDataFactory.createUserList(true);
    List<Id> approverIds = new List<Id>();
    for (User u : usersList) {
      if (u.profileId == profilesMap.get(Constants.SALES_USR_PROFILE).Id) {
        approverIds.add(u.Id);
      }
      if (u.profileId == profilesMap.get(Constants.BDR_USR_PROFILE).Id) {
        bdrUser = u.Id;
      }
    }

    opps[0].ownerId = bdrUser;
    update opps;

    Task newTask = new Task(
      WhatId = opps[0].Id,
      OwnerId = bdrUser,
      status = Constants.TASK_STATUS_COMPLETED,
      Subject = TASK_SUBJECT_MEETING_STR
    );
    insert newTask;

    Test.startTest();

    //Submit Opportunity for approval to a Sales Rep user
    List<Approval.ProcessSubmitRequest> requestList = new List<Approval.ProcessSubmitRequest>();
    List<Approval.ProcessResult> processResults = null;

    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    req.setComments('Assigning Opportunity to Sales Rep.');
    req.setObjectId(opps[0].id);
    req.setProcessDefinitionNameOrId('Sales_Rep_AP');
    req.setNextApproverIds(approverIds);
    requestList.add(req);

    processResults = Approval.process(requestList, false);

    Test.stopTest();

    //Assert that opportunity is in approval
    List<processInstance> processInstances = [
      SELECT Id, Status
      FROM ProcessInstance
      WHERE TargetObjectId = :opps[0].id
    ];
    System.assertEquals(
      processInstances.size(),
      1,
      'Opportunity should be in approval'
    );
  }
  /**
   * @description RUBX-456: required validation before firing the approval process - negative test because no tasks are created on the opportunity
   * @author Peter Sabry | 10/12/2019
   * @return testMethod
   **/
  public static testMethod void validateSalesRepAssignment_SingleNegativeTest(

  ) {
    string bdrUser;
    Map<String, Profile> profilesMap = TestDataFactory.getProfileMap();
    List<User> usersList = TestDataFactory.createUserList(true);
    List<Id> approverIds = new List<Id>();
    for (User u : usersList) {
      if (u.profileId == profilesMap.get(Constants.SALES_USR_PROFILE).Id) {
        approverIds.add(u.Id);
      }
      if (u.profileId == profilesMap.get(Constants.BDR_USR_PROFILE).Id) {
        bdrUser = u.Id;
      }
    }
    List<Opportunity> opps = TestDataFactory.createOpportunities(1, 1, false);
    opps[0].OwnerId = bdrUser;
    opps[0]
      .Sales_Rep_Assignment_Status__c = Constants.OPPORTUNITY_ASSIGNMENT_STATUS_NOT_ASSIGNED;
    insert opps;

    Test.startTest();

    //Submit Opportunity for approval to a Sales Rep user
    List<Approval.ProcessSubmitRequest> requestList = new List<Approval.ProcessSubmitRequest>();
    List<Approval.ProcessResult> processResults = null;

    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    req.setComments('Assigning Opportunity to Sales Rep.');
    req.setObjectId(opps[0].id);
    req.setProcessDefinitionNameOrId('Sales_Rep_AP');
    req.setNextApproverIds(approverIds);
    requestList.add(req);

    processResults = Approval.process(requestList, false);

    Test.stopTest();

    //Assert that opportunity is in approval
    List<processInstance> processInstances = [
      SELECT Id, Status
      FROM ProcessInstance
      WHERE TargetObjectId = :opps[0].id
    ];
    System.assertEquals(
      processInstances.size(),
      0,
      'Opportunity should not be in approval'
    );
  }
  /**
   * @description RUBX-459: Update Opportunity after Approval Positive test
   * @author Peter Sabry | 11/12/2019
   * @return testMethod
   **/
  public static testMethod void updateOwnerAfterApproval_SinglePositiveTest() {
    List<Opportunity> opps = TestDataFactory.createOpportunities(1, 1, true);

    User bdrUser;
    User salesUser;
    Map<String, Profile> profilesMap = TestDataFactory.getProfileMap();
    List<User> usersList = TestDataFactory.createUserList(true);
    List<Id> approverIds = new List<Id>();
    for (User u : usersList) {
      if (u.profileId == profilesMap.get(Constants.SALES_USR_PROFILE).Id) {
        approverIds.add(u.Id);
        salesUser = u;
      }
      if (u.profileId == profilesMap.get(Constants.BDR_USR_PROFILE).Id) {
        bdrUser = u;
      }
    }

    Task newTask = new Task(
      WhatId = opps[0].Id,
      OwnerId = bdrUser.Id,
      status = Constants.TASK_STATUS_COMPLETED,
      Subject = 'Meeting with Customer'
    );
    insert newTask;

    opps[0].OwnerId = bdrUser.Id;
    opps[0]
      .Sales_Rep_Assignment_Status__c = Constants.OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT;
    update opps;

    //Submit Opportunity for approval to a Sales Rep user
    List<Approval.ProcessSubmitRequest> requestList = new List<Approval.ProcessSubmitRequest>();
    List<Approval.ProcessResult> processResults = null;

    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    req.setComments('Assigning Opportunity to Sales Rep.');
    req.setObjectId(opps[0].id);
    req.setProcessDefinitionNameOrId('Sales_Rep_AP');
    req.setNextApproverIds(approverIds);
    requestList.add(req);

    processResults = Approval.process(requestList, false);

    List<Id> newWorkItemIds = new List<Id>();
    for (List<ProcessInstance> pis : [
      SELECT (SELECT Id FROM Workitems)
      FROM ProcessInstance p
      WHERE p.TargetObjectId = :opps[0].Id AND p.Status = 'Pending'
    ]) {
      for (ProcessInstance pi : pis) {
        for (List<ProcessInstanceWorkitem> wis : pi.Workitems) {
          for (ProcessInstanceWorkitem wi : wis) {
            newWorkItemIds.add(wi.id);
          }
        }
      }
    }

    Test.startTest();

    //Approving the request
    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
    req2.setComments('Approving request.');
    req2.setAction('Approve');
    req2.setNextApproverIds(new List<Id>{salesUser.Id});
    req2.setWorkitemId(newWorkItemIds.get(0));

    // Submit the request for approval
    Approval.ProcessResult result2 = Approval.process(req2);
    Test.stopTest();

    //Assert that opportunity BDR rep is set and forecast is set to Likely
    opps = [SELECT Id, BDR_Rep__c, Finastra_Forecast__c FROM Opportunity];
    System.assertEquals(
      opps[0].BDR_Rep__c,
      bdrUser.Id,
      'BDR Rep should be set to BDR Rep'
    );
    System.assertEquals(
      opps[0].Finastra_Forecast__c,
      Constants.OPPORTUNITY_FORECAST_LIKELY,
      'Forecast should be set to Likely'
    );
  }
  /**
   * @description RUBX-459: Update Opportunity after Approval Negative test
   * @author Peter Sabry | 11/12/2019
   * @return testMethod
   **/
  public static testMethod void updateOwnerAfterApproval_SingleNegativeTest() {
    List<Opportunity> opps = TestDataFactory.createOpportunities(1, 1, true);

    User bdrUser;
    User salesUser;
    Map<String, Profile> profilesMap = TestDataFactory.getProfileMap();
    List<User> usersList = TestDataFactory.createUserList(true);
    List<Id> approverIds = new List<Id>();
    for (User u : usersList) {
      if (u.profileId == profilesMap.get(Constants.SALES_USR_PROFILE).Id) {
        approverIds.add(u.Id);
        salesUser = u;
      }
      if (u.profileId == profilesMap.get(Constants.BDR_USR_PROFILE).Id) {
        bdrUser = u;
      }
    }

    Task newTask = new Task(
      WhatId = opps[0].Id,
      OwnerId = bdrUser.Id,
      status = Constants.TASK_STATUS_COMPLETED,
      Subject = 'Meeting with Customer'
    );
    insert newTask;

    opps[0].OwnerId = bdrUser.Id;
    opps[0]
      .Sales_Rep_Assignment_Status__c = Constants.OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT;
    update opps;

    //Submit Opportunity for approval to a Sales Rep user
    List<Approval.ProcessSubmitRequest> requestList = new List<Approval.ProcessSubmitRequest>();
    List<Approval.ProcessResult> processResults = null;

    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    req.setComments('Assigning Opportunity to Sales Rep.');
    req.setObjectId(opps[0].id);
    req.setProcessDefinitionNameOrId('Sales_Rep_AP');
    req.setNextApproverIds(approverIds);
    requestList.add(req);

    processResults = Approval.process(requestList, false);

    List<Id> newWorkItemIds = new List<Id>();
    for (List<ProcessInstance> pis : [
      SELECT (SELECT Id FROM Workitems)
      FROM ProcessInstance p
      WHERE p.TargetObjectId = :opps[0].Id AND p.Status = 'Pending'
    ]) {
      for (ProcessInstance pi : pis) {
        for (List<ProcessInstanceWorkitem> wis : pi.Workitems) {
          for (ProcessInstanceWorkitem wi : wis) {
            newWorkItemIds.add(wi.id);
          }
        }
      }
    }

    Test.startTest();

    opps[0].Rejection_Reason__c = 'Shape fit';
    update opps;

    //Rejecting the request
    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
    req2.setComments('Rejecting request.');
    req2.setAction('Reject');
    req2.setNextApproverIds(new List<Id>{bdrUser.Id});
    req2.setWorkitemId(newWorkItemIds.get(0));

    // Submit the request for approval
    Approval.ProcessResult result2 = Approval.process(req2);
    Test.stopTest();

    //Assert that opportunity BDR rep is not set
    opps = [SELECT Id, BDR_Rep__c, Finastra_Forecast__c FROM Opportunity];
    System.assertEquals(opps[0].BDR_Rep__c, null, 'BDR Rep should not be set');
  }
  /**
   * @description RUBX-458: Single Positive Test For SLA notification
   * @author Peter Sabry | 17/12/2019
   * @return testMethod
   **/
  //caused by: System.UnsupportedOperationException:
  //ConnectApi methods are not supported in data siloed tests. Please use @IsTest(SeeAllData=true) recommended by salesforce.
  @isTest(SeeAllData=true)
  public static void postSLANotificationToChatter_SinglePositiveTest() {
    List<Opportunity> opps = TestDataFactory.createOpportunities(1, 1, true);

    Map<String, Profile> profilesMap = TestDataFactory.getProfileMap();
    List<User> usersList = TestDataFactory.createUserList(true);

    User bdrUser = TestDataFactory.getProfileUser(
      profilesMap.get(Constants.BDR_USR_PROFILE).Id
    );
    User salesUser = TestDataFactory.getProfileUser(
      profilesMap.get(Constants.SALES_USR_PROFILE).Id
    );

    Task newTask = TestDataFactory.createTask(
      opps[0].Id,
      bdrUser.Id,
      Constants.TASK_STATUS_COMPLETED,
      MEETING_SUBJECT,
      true
    );

    opps[0].ownerId = bdrUser.Id;
    opps[0]
      .Sales_Rep_Assignment_Status__c = Constants.OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT;
    update opps;

    //add opportunity team member
    OpportunityTeamMember salesUserTM = TestDataFactory.createOppTeamMember(
      opps[0].Id,
      salesUser.Id,
      OPP_ACCESS_EDIT,
      TEAM_MEMBER_ROLE,
      true
    );

    Test.StartTest();

    opps[0]
      .Sales_Rep_Assignment_Status__c = Constants.OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT_OVERDUE;
    update opps;

    Test.StopTest();

    List<FeedItem> feedItems = [
      SELECT Id, ParentId
      FROM FeedItem
      WHERE ParentId = :opps[0].Id
    ];
    System.assertEquals(
      1,
      feedItems.size(),
      'A Chatter Post should be created because of SLA violation'
    );
  }
  /**
   * @description RUBX-458: Single Negative Test For SLA notification
   * @author Peter Sabry | 17/12/2019
   * @return testMethod
   **/
  public static testMethod void postSLANotificationToChatter_SingleNegativeTest(

  ) {
    List<Opportunity> opps = TestDataFactory.createOpportunities(1, 1, true);

    Map<String, Profile> profilesMap = TestDataFactory.getProfileMap();
    List<User> usersList = TestDataFactory.createUserList(true);

    User bdrUser = TestDataFactory.getProfileUser(
      profilesMap.get(Constants.BDR_USR_PROFILE).Id
    );
    User salesUser = TestDataFactory.getProfileUser(
      profilesMap.get(Constants.SALES_USR_PROFILE).Id
    );

    Task newTask = TestDataFactory.createTask(
      opps[0].Id,
      bdrUser.Id,
      Constants.TASK_STATUS_COMPLETED,
      MEETING_SUBJECT,
      true
    );

    opps[0].ownerId = bdrUser.Id;
    opps[0]
      .Sales_Rep_Assignment_Status__c = Constants.OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT;
    update opps;

    //add opportunity team member
    OpportunityTeamMember salesUserTM = TestDataFactory.createOppTeamMember(
      opps[0].Id,
      salesUser.Id,
      OPP_ACCESS_EDIT,
      TEAM_MEMBER_ROLE,
      true
    );

    Test.StartTest();

    opps[0]
      .Sales_Rep_Assignment_Status__c = Constants.OPPORTUNITY_ASSIGNMENT_STATUS_ASSIGNED;
    update opps;

    Test.StopTest();

    List<FeedItem> feedItems = [
      SELECT Id, ParentId
      FROM FeedItem
      WHERE ParentId = :opps[0].Id
    ];
    System.assertEquals(
      0,
      feedItems.size(),
      'No chatter posts because the opportunity was assigned'
    );
  }
  /**
   * @description RUBX-458: Bulkified Test For SLA notification
   * @author Peter Sabry | 18/12/2019
   * @return testMethod
   **/
  @isTest(SeeAllData=true)
  public static void postSLANotificationToChatter_BulkifiedPositiveTest() {
    final integer NO_OF_ACC_FOR_BULK = 10;
    final integer NO_OF_OPP_FOR_BULK = 10;

    List<Opportunity> opps = TestDataFactory.createOpportunities(
      NO_OF_ACC_FOR_BULK,
      NO_OF_OPP_FOR_BULK,
      true
    );

    Map<String, Profile> profilesMap = TestDataFactory.getProfileMap();
    List<User> usersList = TestDataFactory.createUserList(true);

    User bdrUser = TestDataFactory.getProfileUser(
      profilesMap.get(Constants.BDR_USR_PROFILE).Id
    );
    User salesUser = TestDataFactory.getProfileUser(
      profilesMap.get(Constants.SALES_USR_PROFILE).Id
    );

    List<Task> tasksList = new List<Task>();
    List<OpportunityTeamMember> oppTeamMembersList = new List<OpportunityTeamMember>();
    for (Opportunity opp : opps) {
      Task newTask = TestDataFactory.createTask(
        opp.Id,
        bdrUser.Id,
        Constants.TASK_STATUS_COMPLETED,
        MEETING_SUBJECT,
        false
      );
      tasksList.add(newTask);

      opp.ownerId = bdrUser.Id;
      opp.Sales_Rep_Assignment_Status__c = Constants.OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT;

      OpportunityTeamMember salesUserTM = TestDataFactory.createOppTeamMember(
        opp.Id,
        salesUser.Id,
        OPP_ACCESS_EDIT,
        TEAM_MEMBER_ROLE,
        false
      );
      oppTeamMembersList.add(salesUserTM);
    }
    insert tasksList;

    update opps;

    insert oppTeamMembersList;

    Test.StartTest();

    for (Opportunity opp : opps) {
      opp.Sales_Rep_Assignment_Status__c = Constants.OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT_OVERDUE;
    }
    update opps;

    Test.StopTest();
    final integer EXPECTED_CHATTER_POSTS = 100;

    List<FeedItem> feedItems = [
      SELECT Id, ParentId
      FROM FeedItem
      WHERE ParentId IN :opps
    ];
    System.assertEquals(
      EXPECTED_CHATTER_POSTS,
      feedItems.size(),
      'A Chatter Post should be created for each opportunity because of SLA violation'
    );
  }
}
