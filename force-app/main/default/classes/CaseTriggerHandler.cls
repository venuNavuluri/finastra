/**
* @File Name          : CaseTriggerHandler.cls
* @Description        : Case Trigger Handler
* @Author             : Peter Sabry
* @Group              : 
* @Last Modified By   : Venu Navuluri
* @Last Modified On   : 1/10/2020, 10:59:40 AM
* @Modification Log   : 
* Ver       Date            Author      		    Modification
* 1.0    04/11/2019   Peter Sabry     Initial Version
**/
public with sharing class CaseTriggerHandler extends TriggerHandler {
    
    protected override void beforeInsert() {}
    
    protected override void afterInsert() {}
    
    protected override void beforeUpdate() {}
    
    protected override void afterUpdate() {
        List<Case> cases = (List<Case>) Trigger.new;
        Map<Id, Case> oldMap = (Map<Id, Case>) Trigger.oldMap;
        
        //Set Asset Review date to case close date + 1 year when LCA case status is changed to closed
        setAssetNextReviewDate(cases, oldMap);
        
        //trigger approval process for awaiting deselection approval
        submitApprovalforLCADeselection(cases, oldMap);
        
        //notified when an audit outcome is compliant
        notifySalesWhenCompliant(cases, oldMap);
    }
    
    protected override void beforeDelete() {}
    
    protected override void afterDelete() {}
    
    protected override void afterUndelete() {}
    
    /**
* @description After the completion of the review, the asset review date is re-calculated using the Case close date.
* @author Peter Sabry | 08/11/2019 
* @param newList 
* @param oldMap 
* @return void 
**/
    private void setAssetNextReviewDate(List<Case> newList, Map<Id, Case> oldMap) {
        Map<String, Id> recordTypesMap = CommonUtils.getRecordTypesByObjectName('Case');            
        Map<Id, Date> assetCaseCloseDateMap = new Map<Id, Date>();
        for(Case assetCase : newList) {
            if(assetCase.RecordTypeId == recordTypesMap.get(Constants.CASE_LCA_RECORD_TYPE_DEV_NAME) && oldMap.get(assetCase.Id).Status != assetCase.Status && (assetCase.Status == Constants.CASE_STATUS_CLOSED || assetCase.Status == Constants.CASE_STATUS_AUDITED || assetCase.Status == Constants.CASE_STATUS_NOT_AUDITED)) {
                assetCaseCloseDateMap.put(assetCase.AssetId, assetCase.ClosedDate.date());
            }
        }
        List<Asset> assetsToUpdate = new List<Asset>([Select Id, Review_Date__c from Asset where Id in :assetCaseCloseDateMap.keyset()]);
        for(Asset asset : assetsToUpdate) {
            asset.Review_Date__c = CommonUtils.getNextFinancialYearQuarterStartDate(assetCaseCloseDateMap.get(asset.Id)).date();
        }
        if(assetsToUpdate.size() > 0) {
            database.update(assetsToUpdate);
        }
    }
    /**
* @description RUBX-82 The ability to trigger approve process when status set to ( =Awaiting Deselection Approval)
* @author Venu Navuluri | 11/11/2019 
* @param newList 
* @param oldMap 
* @return void 
**/
    
    private void submitApprovalforLCADeselection(List<Case> newList, Map<Id, Case> oldMap) {
        
        //Request for all Cases 
        
        Approval.ProcessSubmitRequest [] requestList = new Approval.ProcessSubmitRequest []{};
            Map<String, Id> recordTypesMap = CommonUtils.getRecordTypesByObjectName('Case');    
        Approval.ProcessResult[] processResults = null;
        
        for(Case assetCase : newList) {             
            if(assetCase.status != oldMap.get(assetCase.Id).status && assetCase.status == Constants.CASE_STATUS_DESELECTION_APPROVAL && assetCase.RecordTypeId == recordTypesMap.get(Constants.CASE_LCA_RECORD_TYPE_DEV_NAME) ){
                
                // Create an approval request for the case
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments('Submitting LCA Desection for approval.');
                req.setObjectId(assetCase.id);
                req.setProcessDefinitionNameOrId('LCA_Deselection_Approval');
                requestList.add(req);
            }
            if(!requestList.isEmpty())
                processResults = Approval.process(requestList, false);
        }
    }
 /**
* @description RUBX-1166 - Sales and License Principle to be notified when an audit outcome is compliant
* @author Venu Navuluri| 14/11/2019 
* @param newList 
* @param oldMap 
* @return void 
**/   
    private void notifySalesWhenCompliant(List<Case> newList, Map<Id, Case> oldMap) {
        
        Set<Id> accountIds = new Set<Id>();
        String chatterPost = System.Label.LCA_Notify_Sales_When_Compliant;
        ID groupId = CommonUtils.getChatterGroupId(Constants.LICENSE_PRINCIPLE_TEAM);
        
        for(Case assetCase : newList) { 
            if(assetCase.Compliance_Sub_Status__c  != oldMap.get(assetCase.Id).Compliance_Sub_Status__c 
               && assetCase.status == Constants.CASE_STATUS_AUDITED && assetCase.Compliance_Sub_Status__c == Constants.COMPLIANCE_SUB_STATUS_COMPLIANT){
                   accountIds.add(assetCase.LCA_Account__c);
               }
        }
        Map<Id,Account> accountMap = new Map<Id, Account>([select Id, OwnerId from Account where Id IN :accountIds]);
        
        for(Case assetCase : newList) { 
            if(assetCase.Compliance_Sub_Status__c  != oldMap.get(assetCase.Id).Compliance_Sub_Status__c 
               && assetCase.status == Constants.CASE_STATUS_AUDITED && assetCase.Compliance_Sub_Status__c == Constants.COMPLIANCE_SUB_STATUS_COMPLIANT){
                   
                    ConnectApiHelper.postFeedItemWithMentions(
                       Network.getNetworkId(), //community Id where to post, or "internal", or null
                       assetCase.id, //this is the record where the post will appear
                       '{' + accountMap.get(assetCase.LCA_Account__c).OwnerId + '}'+' '+ '{' + groupId + '}' +' '+ chatterPost +' ' +'{' + assetCase.OwnerId + '}' );
                   
               }
        }
    }
    
    
}