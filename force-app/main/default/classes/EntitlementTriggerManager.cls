public with sharing class EntitlementTriggerManager extends ProductSetToAccountRollUpManager
{
	private Map<Id, Entitlement__c> oldMap, newMap;
	
	public EntitlementTriggerManager(Map<Id, Entitlement__c> pOldMap, Map<Id, Entitlement__c> pNewMap)
	{
		oldMap = pOldMap;
		newMap = pNewMap;
	}
	
	Set<Id> collectAffectedAccountIds()
	{
		Set<Id> accountIds = new Set<Id>();
		Set<Id> productSetIds = new Set<Id>();
		if (oldMap != null) {
			for (Entitlement__c e : oldMap.values()) {
				productSetIds.add(e.Product_Set__c);
			}
		}
		if (newMap != null) {
			for (Entitlement__c e : newMap.values()) {
				productSetIds.add(e.Product_Set__c);
			}
		}
		
		for (Product_Set__c ps : [select Account__c from Product_Set__c where Id in :productSetIds]) {
			accountIds.add(ps.Account__c);
		}
		return accountIds;
	}
}