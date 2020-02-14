public class WarProjectRequestTriggerMethods {

	public static void updateOpportunityWarStatus(map<id, WAR_Project__c> oldMap, map<id, WAR_Project__c> newMap) {
		list<Opportunity> oppList = new list<Opportunity>();
		RecordType rt = [select id, name from RecordType where name = 'WAR Project Request - Initial Days' limit 1];
		
		if(trigger.isAfter && trigger.isUpdate){
			for(WAR_Project__c wp : newMap.values()){
				if(wp.RecordTypeId == rt.Id && wp.Opportunity__c != null && wp.WAR_Approval_Status__c == 'APPROVED' && wp.WAR_Approval_Status__c != oldMap.get(wp.id).WAR_Approval_Status__c){
					Opportunity opp = new Opportunity(id = wp.Opportunity__c, WAR_Approval_Status__c = wp.WAR_Approval_Status__c);
					oppList.add(opp);
				} else if(wp.RecordTypeId == rt.Id && wp.Opportunity__c != null && wp.WAR_Approval_Status__c == 'REJECTED' && wp.WAR_Approval_Status__c != oldMap.get(wp.id).WAR_Approval_Status__c){
					Opportunity opp = new Opportunity(id = wp.Opportunity__c, WAR_Approval_Status__c = wp.WAR_Approval_Status__c);
					oppList.add(opp);
				}
			}
		}
		
		if(oppList != null && oppList.size() > 0){
			update oppList;
		}
	}
}