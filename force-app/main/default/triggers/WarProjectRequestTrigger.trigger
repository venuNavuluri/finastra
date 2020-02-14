trigger WarProjectRequestTrigger on WAR_Project__c (after update) {
	WarProjectRequestTriggerMethods.updateOpportunityWarStatus(trigger.oldMap, trigger.newMap);
}