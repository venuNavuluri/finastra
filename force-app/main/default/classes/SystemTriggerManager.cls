public with sharing class SystemTriggerManager extends ProductSetToAccountRollUpManager
{
	private Map<Id, System__c> oldMap, newMap;
	
	public SystemTriggerManager(Map<Id, System__c> pOldMap, Map<Id, System__c> pNewMap)
	{
		oldMap = pOldMap;
		newMap = pNewMap;
	}
	
	Set<Id> collectAffectedAccountIds()
	{
		Set<Id> accountIds = new Set<Id>();
		Set<Id> systemIds = new Set<Id>();
		if (oldMap != null) {
			systemIds.addAll(oldMap.keySet());
		}
		if (newMap != null) {
			systemIds.addAll(newMap.keySet());
		}
		
		for (Entitlement__c e : [select Product_Set__r.Account__c from Entitlement__c where System__c in :systemIds]) {
			accountIds.add(e.Product_Set__r.Account__c);
		}
		return accountIds;
	}
}