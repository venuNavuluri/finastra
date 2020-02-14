/**
 * @File Name          : OpportunityTriggerHandlerWS.cls
 * @Description        : Opportunity handler class to hanbdle all opportunity trigger events without sharing
 * @Author             : ramesh.thulasi@finastra.com
 * @Group              :
 * @Last Modified By   : Ramesh Thulasi
 * @Last Modified On   : 30/01/2020
 **/
public without sharing class OpportunityTriggerHandlerWS extends TriggerHandler {
  protected override void beforeUpdate() {
    List<Opportunity> opportunities = (List<Opportunity>) Trigger.new;
    Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>) Trigger.oldMap;
    updateAccountOwnerToOppOwner(opportunities, oldMap);
  }
  /**
   * @description REQ-1467-Change Account ownership to Opportunity owner when first Opportunity's stage changes from SS1 to SS2.
   * @author Ramesh Thulasi | 23/01/2020
   * @param newOppsList - Updated opportunities
   * @param oldMap - Old opportunities Map
   * @return void
   **/
  private void updateAccountOwnerToOppOwner(
    List<Opportunity> newOppsList,
    Map<Id, Opportunity> oldMap
  ) {
    Account accToUpdate;
    List<Account> accsToUpdateList = new List<Account>();
    List<Bypass_Validations__c> valCusSettings = new List<Bypass_Validations__c>();

    Set<Id> oppAccIdsSet = new Set<Id>();
    Set<Id> ownerIds = new Set<Id>();
    List<Opportunity> ownerUpdatedOppList = new List<Opportunity>();
    for (Opportunity opp : newOppsList) {
      // filter out only the Opportunities on which the stage changes from SS1 to SS2
      if (
        Constants.OPPORTUNITY_STAGE_NAME_CREATE == opp.StageName &&
        Constants.OPPORTUNITY_STAGE_NAME_PROSPECT ==
        oldMap.get(opp.id).StageName &&
        opp.StageName != oldMap.get(opp.id).StageName
      ) {
        ownerUpdatedOppList.add(opp);
        oppAccIdsSet.add(opp.AccountId);
        ownerIds.add(opp.OwnerId);
      }
    }
    // Retrieve all oportunities on accounts. This is requited to get the first opportunity on account
    Map<Id, Account> accInfoMap = new Map<Id, Account>(
      [
        SELECT
          ID,
          OwnerId,
          (SELECT ID FROM Opportunities ORDER BY CreatedDate ASC)
        FROM Account
        WHERE id IN :oppAccIdsSet
      ]
    );
    for (Account acc : accInfoMap.values()) {
      ownerIds.add(acc.OwnerId);
    }
    Map<Id, User> owners = new Map<Id, User>(
      [SELECT Profile.Name FROM User WHERE Id IN :ownerIDs]
    );
    Id ownerId;
    for (Opportunity opp : ownerUpdatedOppList) {
      accToUpdate = accInfoMap.get(opp.AccountId);
      if (
        isAccountFirstOpportunity(opp, accToUpdate) &&
        !isSalesUser(owners.get(accToUpdate.OwnerId)) &&
        isSalesUser(owners.get(opp.OwnerId))
      ) {
        accToUpdate.OwnerId = opp.OwnerId;
        accsToUpdateList.add(accToUpdate);
      }
    }
    // enable bypass settings for the current user to bypass Only_SOSS_Users_Can_Update_Owner VR
    Bypass_Validations__c bypassVal = new Bypass_Validations__c(
      SetupOwnerId = UserInfo.getUserId(),
      Disable__c = true
    );
    // dont do this for tests
    if (!Test.isRunningTest()) {
      insert bypassVal;
    }
    update accsToUpdateList;
    // dont do this for tests
    if (!Test.isRunningTest()) {
      // disable bypass settings for the current user to allow Only_SOSS_Users_Can_Update_Owner VR work normal
      delete bypassVal;
    }
  }
  /**
   * @description: Helper method to check if the given opportunity is the first opportunity on account.
   * @assumption: The given Account has opportunities included and the child opportunities are sorted in created date ascending order.
   * @author Ramesh Thulasi | 23/01/2020
   * @param opp - Updated opportunity
   * @param accToCheck - Account to check
   * @return result as Boolean
   **/
  private Boolean isAccountFirstOpportunity(
    Opportunity opp,
    Account accToCheck
  ) {
    if (
      null != opp &&
      null != accToCheck &&
      accToCheck.opportunities.size() > 0
    ) {
      return opp.id == accToCheck.opportunities.get(0).id;
    }
    return false;
  }
  /**
   * @description: Helper method to check if the given User profile name is 'Sales User'.
   * @author Ramesh Thulasi | 28/01/2020
   * @param owner - owner of the record to check
   * @return result as Boolean
   **/
  private Boolean isSalesUser(User owner) {
    return Constants.SALES_USR_PROFILE == owner.Profile.Name;
  }
}
