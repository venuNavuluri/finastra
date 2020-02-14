/**
 * @File Name          : AssetTriggerHandler.cls
 * @Description        : Asset Trigger handler
 * @Author             : Peter Sabry
 * @Group              :
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 08/11/2019, 15:04:51
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    04/11/2019   Peter Sabry     Initial Version
 **/
public with sharing class AssetTriggerHandler extends TriggerHandler {
  protected override void beforeInsert() {
    List<Asset> assets = (List<Asset>) Trigger.new;

    //Set Asset Review Date
    setAssetReviewDate(assets, null);
  }

  protected override void afterInsert() {
  }

  protected override void beforeUpdate() {
    List<Asset> assets = (List<Asset>) Trigger.new;
    Map<Id, Asset> oldMap = (Map<Id, Asset>) Trigger.oldMap;

    //Set Asset Review Date
    setAssetReviewDate(assets, oldMap);
  }

  /**
    * @description  Sets the review date initially on asset creation or if the related subscription has changed
        Date is calculated using the subscription start date.
    * @author Peter Sabry | 08/11/2019 
    * @param assetList 
    * @param oldAssetMap 
    * @return void 
    **/
  private void setAssetReviewDate(
    List<Asset> assetList,
    Map<Id, Asset> oldAssetMap
  ) {
    Map<Id, Id> assetSubscriptionsMap = new Map<Id, Id>();
    for (Asset asset : assetList) {
      if (
        (oldAssetMap == null && asset.SBQQ__CurrentSubscription__c != null) ||
        (oldAssetMap != null &&
        oldAssetMap.get(asset.Id).SBQQ__CurrentSubscription__c !=
        asset.SBQQ__CurrentSubscription__c &&
        asset.SBQQ__CurrentSubscription__c != null)
      ) {
        assetSubscriptionsMap.put(asset.Id, asset.SBQQ__CurrentSubscription__c);
      }
    }
    Map<Id, SBQQ__Subscription__c> subsMap = new Map<Id, SBQQ__Subscription__c>(
      [
        SELECT Id, SBQQ__StartDate__c
        FROM SBQQ__Subscription__c
        WHERE Id IN :assetSubscriptionsMap.values()
      ]
    );
    for (Asset asset : assetList) {
      if (assetSubscriptionsMap.containsKey(asset.Id)) {
        Id subscriptionId = assetSubscriptionsMap.get(asset.Id);
        if (subsMap.get(subscriptionId).SBQQ__StartDate__c != null) {
          asset.Review_Date__c = CommonUtils.getNextFinancialYearQuarterStartDate(
              subsMap.get(subscriptionId).SBQQ__StartDate__c
            )
            .date(); // Set the Review date to the first month of quarter that follows one year from today
        }
      }
    }
  }
}
