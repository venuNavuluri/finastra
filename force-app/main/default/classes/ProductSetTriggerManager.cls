public with sharing class ProductSetTriggerManager extends ProductSetToAccountRollUpManager
{
	private Map<Id, Product_Set__c> oldMap, newMap;
	
	public ProductSetTriggerManager(Map<Id, Product_Set__c> pOldMap, Map<Id, Product_Set__c> pNewMap)
	{
		oldMap = pOldMap;
		newMap = pNewMap;
	}
	
	Set<Id> collectAffectedAccountIds()
	{
		Set<Id> accountIds = new Set<Id>();
		if (oldMap != null) {
			for (Product_Set__c ps : oldMap.values()) {
				accountIds.add(ps.Account__c);
			}
		}
		if (newMap != null) {
			for (Product_Set__c ps : newMap.values()) {
				accountIds.add(ps.Account__c);
			}
		}
		
		return accountIds;
	}
}