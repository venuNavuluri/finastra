/**
 * @File Name          : LCACaseCreationBatch.cls
 * @Description        : Batch class that creates LCA Case records for Assets that have review date 7 days in advance
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : venu.navuluri@finastra.com
 * @Last Modified On   : 13/01/2020, 12:20:52
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    11/11/2019   Peter Sabry     Initial Version
**/
global class LCACaseCreationBatch implements Schedulable,Database.Batchable<sobject>  {
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        // Query for assets that have a review date within the next 7 days
        Date lcaPeriodEnd = Date.today().addDays(Constants.LCA_DAYS_TO_CREATE_CASE);
        string expr = 'Select Id, AccountId, ContactId, Review_Date__c, SBQQ__CurrentSubscription__r.SBQQ__Contract__c from Asset where Review_Date__c <= :lcaPeriodEnd';

        return Database.getQueryLocator(expr);
    } 
    global void execute(Database.BatchableContext bc, list<sobject> lrec)
    {
        Map<String, Id> recordTypesMap = CommonUtils.getRecordTypesByObjectName('Case');         
        
        //Query Cases to check that the asset doesn't have an open LCA Case already
        Set<Id> assetsWithOpenCases = new Set<Id>();
        for(Case openLCACase : [Select Id, AssetId from Case where recordTypeId = :recordTypesMap.get(Constants.CASE_LCA_RECORD_TYPE_DEV_NAME) and IsClosed = false and AssetId != null]) {
            assetsWithOpenCases.add(openLCACase.AssetId);
        }
        
        List<Case> casesToCreateList = new List<Case>();
        for(sobject obj: lrec)
        {
			Asset assetRecord = (Asset)obj;
            if(!assetsWithOpenCases.contains(assetRecord.Id)) { //Exclude Assets that already have an open LCA Case
                Case newLCACase = new Case();
                newLCACase.recordTypeId = recordTypesMap.get(Constants.CASE_LCA_RECORD_TYPE_DEV_NAME);
                //Fields to Set
                //RUBX-1924
                newLCACase.LCA_Account__c = assetRecord.AccountId;
                newLCACase.AssetId = assetRecord.Id;
                newLCACase.System_Environment__c = Constants.CASE_ENVIRONMENT_PROD;
                newLCACase.Contract__c = assetRecord.SBQQ__CurrentSubscription__r.SBQQ__Contract__c;

                newLCACase.Status = Constants.CASE_STATUS_NEW;
                newLCACase.Priority = Constants.CASE_PRIORITY_MED;
                
                newLCACase.OwnerId = CommonUtils.getQueueId(Constants.LCA_TEAM_QUEUE_NAME);
                casesToCreateList.add(newLCACase);
            }
        }
		
        if(CasesToCreateList.size() > 0) {
            insert CasesToCreateList;
        }
    }
    global void finish(Database.BatchableContext bc)
    {
        //Do Nothing
    }
    global void execute(SchedulableContext sc){
        database.executeBatch(new LCACaseCreationBatch(),1);
    } 
}