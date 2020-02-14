/**
 * @File Name          : OpportunityTriggerHandler.cls
 * @Description        : Opportunity handler class to hanbdle all opportunity trigger events.
 * @Author             : venu.navuluri@finastra.com
 * @Group              :
 * @Last Modified By   : Aakanksha Sharma
 * @Last Modified On   : 29/01/2020, 17:42:48
 **/
public with sharing class OpportunityTriggerHandler extends TriggerHandler {
  protected override void beforeInsert() {
    List<Opportunity> opportunities = (List<Opportunity>) Trigger.new;
    List<Opportunity> fullOppRecords = new List<Opportunity>();
    for (Opportunity opp : opportunities) {
      if (
        opp.AccountId != null &&
        opp.RecordTypeId == Constants.OPPORTUNITY_FULL_RECORDTYPEID
      ) {
        fullOppRecords.add(opp);
      }
    }
    populateFullOpptyFields(fullOppRecords);
  }

  protected override void beforeUpdate() {
    List<Opportunity> opportunities = (List<Opportunity>) Trigger.new;
    Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) Trigger.oldMap;
    setOppStageToClosedWon(opportunities, oldMap);
    validateSalesRepAssignment(opportunities, oldMap);
    updateOwnerAfterApproval(opportunities, oldMap);
    checkContactRoleOnOpportunity((Map<Id, Opportunity>) Trigger.newmap);
  }

  protected override void afterUpdate() {
    postSLANotificationToChatter(
      (List<Opportunity>) Trigger.new,
      (Map<Id, Opportunity>) Trigger.oldMap
    );
  }

  /** Opportunity Trigger logic **/

  private void setOppStageToClosedWon(
    List<Opportunity> oppListUpdate,
    Map<Id, Opportunity> oldMap
  ) {
    for (Opportunity oppUpdate : oppListUpdate) {
      if (
        oppUpdate.CAT_Logging_Stage__c !=
        oldMap.get(oppUpdate.Id).CAT_Logging_Stage__c &&
        oppUpdate.CAT_Logging_Stage__c == Constants.CAT_LOGGING_STAGE_COMPLETE
      ) {
        // RUBX-19 - set opportunity stage to Closed Won
        oppUpdate.StageName = Constants.STAGE_NAME_CLOSED_WON;
      }
    }
  }
  /**
   * @description RUBX-466- Check to throw an error if an opportunity without any contact role is moved beyond Stage 2
   * @author Sujith Maruthingal | 28/11/2019
   * @param oppNewMap
   * @param oldMap
   * @return void
   **/
  private void checkContactRoleOnOpportunity(Map<Id, Opportunity> oppNewMap) {
    for (Opportunity opp : [
      SELECT Id, StageName, (SELECT Id FROM OpportunityContactRoles)
      FROM Opportunity
      WHERE Id IN :oppNewMap.keySet()
    ]) {
      // RUBX-3255 - Unexpected error while creating quote on Opportunity in SS2
      if (
        oppNewMap.get(opp.id).stageName ==
        Constants.OPPORTUNITY_STAGE_NAME_QUALIFY ||
        oppNewMap.get(opp.id).stageName ==
        Constants.OPPORTUNITY_STAGE_NAME_DEVELOP ||
        oppNewMap.get(opp.id).StageName ==
        Constants.OPPORTUNITY_STAGE_NAME_PROVE ||
        oppNewMap.get(opp.id).stageName ==
        Constants.OPPORTUNITY_STAGE_NAME_NEGOTIATE ||
        oppNewMap.get(opp.id).stageName ==
        Constants.OPPORTUNITY_STAGE_NAME_CWP ||
        oppNewMap.get(opp.id).stageName == Constants.OPPORTUNITY_STAGE_NAME_CW
      ) {
        if (opp.OpportunityContactRoles.isEmpty()) {
          // RUBX-466 - Add Contact Roles on opportunity
          oppNewMap.get(opp.id).addError(Constants.OPP_CONTACT_ROLE_ERROR_MSG);
        }
      }
    }
  }

  /**
   * @description : RUBX-452- Updates default values for fields for Full Opportunitty after creation
   * @author Aakanksha Sharma | 03/12/2019
   * @param newOppList
   * @return void
   **/
  private void populateFullOpptyFields(List<Opportunity> newOppList) {
    Set<Id> accountIds = new Set<Id>();
    for (Opportunity oppty : newOppList) {
      accountIds.add(oppty.AccountId);
    }
    Map<Id, Account> accInfoMap = new Map<Id, Account>(
      [
        SELECT
          ID,
          CurrencyIsoCode,
          Country__c,
          Primary_Ship_To__c,
          Primary_Bill_To__c
        FROM Account
        WHERE id IN :accountIds
      ]
    );
    Account acc;
    for (Opportunity opp : newOppList) {
      acc = accInfoMap.get(opp.AccountId);
      if (
        acc.CurrencyIsoCode != null &&
        opp.CurrencyIsoCode != acc.CurrencyIsoCode
      ) {
        opp.CurrencyIsoCode = acc.CurrencyIsoCode;
      }
      if (acc.Country__c != null && opp.Pricing_Country__c != acc.Country__c) {
        opp.Pricing_Country__c = acc.Country__c;
      }
      if (opp.StageName != Constants.OPPORTUNITY_STAGE_NAME_PROSPECT) {
        opp.StageName = Constants.OPPORTUNITY_STAGE_NAME_PROSPECT;
      }
      if (opp.Finastra_Forecast__c != Constants.EXEMPT_FORECAST) {
        opp.Finastra_Forecast__c = Constants.EXEMPT_FORECAST;
      }
      if (opp.Finastra_Forecast__c != Constants.EXEMPT_FORECAST) {
        opp.Finastra_Forecast__c = Constants.EXEMPT_FORECAST;
      }
      //RUBX-1199
      if (opp.Bill_To__c == null && acc.Primary_Bill_To__c != null) {
        opp.Bill_To__c = acc.Primary_Bill_To__c;
      }
      //RUBX-1199
      if (opp.Ship_To__c == null && acc.Primary_Ship_To__c != null) {
        opp.Ship_To__c = acc.Primary_Ship_To__c;
      }
    }
  }
  /**
   * @description RUBX-456 Validates that the opportunity can be assigned to a Sales Rep - Opportunity should have atleast one Task with the subject containing' Meeting ' assigned to the BDR
   * @author Peter Sabry | 03/12/2019
   * @param oppListUpdate
   * @param oldMap
   * @return void
   **/
  private void validateSalesRepAssignment(
    List<Opportunity> oppListUpdate,
    Map<Id, Opportunity> oldMap
  ) {
    Map<Id, Opportunity> oppsInApproval = new Map<Id, Opportunity>();
    for (Opportunity oppUpdate : oppListUpdate) {
      Opportunity oldOpp = oldMap.get(oppUpdate.Id);
      if (
        (string.isEmpty(oldOpp.Sales_Rep_Assignment_Status__c) ||
        oldOpp.Sales_Rep_Assignment_Status__c ==
        Constants.OPPORTUNITY_ASSIGNMENT_STATUS_NOT_ASSIGNED ||
        oldOpp.Sales_Rep_Assignment_Status__c ==
        Constants.OPPORTUNITY_ASSIGNMENT_STATUS_REJECTED) &&
        oppUpdate.Sales_Rep_Assignment_Status__c ==
        Constants.OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT
      ) {
        oppsInApproval.put(oppUpdate.Id, oppUpdate);
      }
      //RUBX-457: Sales Rep must select rejection reason
      if (
        (oldOpp.Sales_Rep_Assignment_Status__c ==
        Constants.OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT ||
        oldOpp.Sales_Rep_Assignment_Status__c ==
        Constants.OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT_OVERDUE) &&
        oppUpdate.Sales_Rep_Assignment_Status__c ==
        Constants.OPPORTUNITY_ASSIGNMENT_STATUS_REJECTED
      ) {
        if (string.isEmpty(oppUpdate.Rejection_Reason__c)) {
          oppUpdate.addError(Constants.OPPORTUNITY_ASSIGNMENT_REJ_ERROR_MSG);
        }
      }
    }

    final String TASK_SUBJECT_MEETING_STR = '%Meeting%';

    if (oppsInApproval.size() > 0) {
      //Opportunity should have at-least one Task with the subject containing' Meeting ' assigned to the BDR , in 'Completed' status
      // OR  A meeting associated to the opportunity, synced from Outlook - which has already been held
      // TODO: Update the below query to check for synced outlook meetings
      List<Task> oppTasks = new List<Task>(
        [
          SELECT WhatId, OwnerId
          FROM Task
          WHERE
            WhatId IN :oppsInApproval.keyset()
            AND Subject LIKE :TASK_SUBJECT_MEETING_STR
            AND Status = :Constants.TASK_STATUS_COMPLETED
        ]
      );
      Map<Id, Integer> oppMeetings = new Map<Id, Integer>();
      for (Task meeting : oppTasks) {
        Integer meetingCount = 0;
        if (oppMeetings.containsKey(meeting.WhatId)) {
          meetingCount = oppMeetings.get(meeting.WhatId);
        }
        if (meeting.OwnerId == oppsInApproval.get(meeting.WhatId).OwnerId) {
          meetingCount++;
        }
        oppMeetings.put(meeting.WhatId, meetingCount);
      }
      for (Opportunity oppUpdate : oppListUpdate) {
        if (oppsInApproval.containsKey(oppUpdate.Id)) {
          Integer numberOfMeetings = 0;
          if (oppMeetings.containsKey(oppUpdate.Id)) {
            numberOfMeetings = oppMeetings.get(oppUpdate.Id);
          }
          if (numberOfMeetings == 0) {
            oppUpdate.addError(Constants.OPPORTUNITY_ASSIGNMENT_ERROR_MSG);
          }
        }
      }
    }
  }
  /**
   * @description RUBX-459: Update the Opportunity Owner after the Sales rep accepts the assignment from the BDR
   * @author Peter Sabry | 05/12/2019
   * @param oppListUpdate
   * @param oldMap
   * @return void
   **/
  private void updateOwnerAfterApproval(
    List<Opportunity> oppListUpdate,
    Map<Id, Opportunity> oldMap
  ) {
    for (Opportunity oppUpdate : oppListUpdate) {
      Opportunity oldOpp = oldMap.get(oppUpdate.Id);
      if (
        (oldOpp.Sales_Rep_Assignment_Status__c ==
        Constants.OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT ||
        oldOpp.Sales_Rep_Assignment_Status__c ==
        Constants.OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT_OVERDUE) &&
        oppUpdate.Sales_Rep_Assignment_Status__c ==
        Constants.OPPORTUNITY_ASSIGNMENT_STATUS_ASSIGNED
      ) {
        //Set BDR Rep to the previous opp owner
        oppUpdate.BDR_Rep__c = oppUpdate.OwnerId;
        //Set Opportunity Owner to Approver
        oppUpdate.OwnerId = UserInfo.getUserId();
        //Set Forecast Category to Likely
        oppUpdate.Finastra_Forecast__c = Constants.OPPORTUNITY_FORECAST_LIKELY;
      }
    }
  }

  /**
   * @description RUBX-458: Sales SLA for accepting/rejecting opportunity: Post to chatter if the sales rep didn't accept or reject the opportunity within the SLA period
   * @author Peter Sabry | 17/12/2019
   * @param oppNewMap
   * @param oldMap
   * @return void
   **/
  private void postSLANotificationToChatter(
    List<Opportunity> oppUpdateList,
    Map<Id, Opportunity> oldMap
  ) {
    Set<Id> slaOpportunities = new Set<Id>();
    for (Opportunity opp : oppUpdateList) {
      if (
        oldMap.get(opp.Id).Sales_Rep_Assignment_Status__c ==
        Constants.OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT &&
        opp.Sales_Rep_Assignment_Status__c ==
        Constants.OPPORTUNITY_ASSIGNMENT_STATUS_PENDING_ASSIGNMENT_OVERDUE
      ) {
        slaOpportunities.add(opp.Id);
      }
    }

    if (slaOpportunities.size() > 0) {
      String chatterPost = System.Label.Opportunity_Sales_Rep_Assignment_SLA;
      final String TEAM_MEMBER_SALES_STR = '%Sales%';

      //Get the opportunity team members with role includes sales to tag them in the chatter post
      Map<Id, Set<Id>> oppTeamMembersMap = new Map<Id, Set<Id>>();
      for (OpportunityTeamMember oppTeam : [
        SELECT Id, OpportunityId, UserId, User.ManagerId
        FROM OpportunityTeamMember
        WHERE
          OpportunityId IN :slaOpportunities
          AND TeamMemberRole LIKE :TEAM_MEMBER_SALES_STR
      ]) {
        Set<Id> oppTeamMembers = new Set<Id>();
        if (oppTeamMembersMap.containsKey(oppTeam.OpportunityId)) {
          oppTeamMembers = oppTeamMembersMap.get(oppTeam.OpportunityId);
        }
        oppTeamMembers.add(oppTeam.UserId);
        oppTeamMembers.add(oppTeam.User.ManagerId);

        oppTeamMembersMap.put(oppTeam.OpportunityId, oppTeamMembers);
      }

      for (Opportunity opp : oppUpdateList) {
        String usersToNotify = '{' + opp.OwnerId + '} ';
        if (oppTeamMembersMap.containsKey(opp.Id)) {
          for (Id userId : oppTeamMembersMap.get(opp.Id)) {
            if (userId != opp.OwnerId && userId != null) {
              usersToNotify += '{' + userId + '} ';
            }
          }
        }
        ConnectApiHelper.postFeedItemWithMentions(
          Network.getNetworkId(), //community Id where to post, or "internal", or null
          opp.id, //this is the record where the post will appear
          chatterPost +
          ' ' +
          usersToNotify
        );
      }
    }
  }
}
