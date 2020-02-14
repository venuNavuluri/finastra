public class CCRTTriggerMethods {
    //This method updates the related Acct By Sub records.
    public static void updateAcctBySub(map<id, CCRT__c> newMap, map<id, CCRT__c> oldMap){
    	list<Acct_By_Sub__c> absUpdateList = new list<Acct_By_Sub__c>();

    	for(Acct_By_Sub__c accBySub : [select id, Account__r.CCRT_entry__c from Acct_By_Sub__c where Account__r.CCRT_entry__c in : newMap.keySet()]){
    		if(newMap.get(accBySub.Account__r.CCRT_entry__c).Client_Site_Number__c != oldMap.get(accBySub.Account__r.CCRT_entry__c).Client_Site_Number__c ||
    			newMap.get(accBySub.Account__r.CCRT_entry__c).NS_Inactive__c != oldMap.get(accBySub.Account__r.CCRT_entry__c).NS_Inactive__c || 
    			newMap.get(accBySub.Account__r.CCRT_entry__c).Client_Name_in_normal_use__c != oldMap.get(accBySub.Account__r.CCRT_entry__c).Client_Name_in_normal_use__c 
    			){
    			accBySub.Synced_To_NS__c = false;
    			accBySub.Synced_To_Extra_NS__c = false;
    			absUpdateList.add(accBySub);
    		}
    	}
    	
    	if(absUpdateList != null && absUpdateList.size() > 0){
    		update absUpdateList;
    	}
    }
}