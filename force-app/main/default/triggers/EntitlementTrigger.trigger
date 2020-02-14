trigger EntitlementTrigger on Entitlement__c (after delete, after insert, after update, after undelete) {
	EntitlementTriggerManager etmgr = new EntitlementTriggerManager(trigger.oldMap, trigger.newMap);
	etmgr.Execute();
}