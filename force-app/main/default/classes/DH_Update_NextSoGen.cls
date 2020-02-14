global class DH_Update_NextSoGen implements Database.Batchable<sObject>{    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id FROM Billing_Group__c WHERE DM_Unique_Id__c != NULL');
    }
    
    global void execute(Database.BatchableContext BC, List<Billing_Group__c> scope){ 
        
        List<Billing_Group__c> bgUpdateList = new List<Billing_Group__c>();
        
        List<Billing_Group__c> bg_sub_map = [SELECT Id, (SELECT Id, Next_Billing_Date__c, Next_SO_generation_Date__c FROM Subscriptions__r ) FROM Billing_Group__c WHERE Id IN: scope];
        List<SBQQ__Subscription__c> tempSubs;
        for(Billing_Group__c bg : bg_sub_map){
            tempSubs = new List<SBQQ__Subscription__c>();
            tempSubs = bg.Subscriptions__r;
            if(tempSubs.size() > 0){
                bgUpdateList.add(RLFPackage_ListInit.updateDates(bg.Id, tempSubs));
            }
        }
        
        if(bgUpdateList.size() > 0){
            update bgUpdateList;
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
}