public abstract class ProductSetToAccountRollUpManager
{
	abstract Set<Id> collectAffectedAccountIds();

	public void Execute()
	{
		Map<Id, Account> acctMap = getAffectedAccounts(collectAffectedAccountIds());
		resetAccounts(acctMap);
		
		for (Entitlement__c e :	[select Product_Set__c, Product_Set__r.Account__c, Product_Set__r.Name/*, Product_Set__r.xxxBusiness_Group__c*/ from Entitlement__c
			where System__r.Environment2__c = 'PROD'
			and Status__c = 'Active'
			and Product_Set__r.Account__c in :acctMap.keySet()]
		) {
			Account acct = acctMap.get(e.Product_Set__r.Account__c);
			if (acct != null) {
				acct.Family_Group__c = (acct.Family_Group__c == null ? e.Product_Set__r.Name : acct.Family_Group__c + ';' + e.Product_Set__r.Name);
			}
		}
		
		update acctMap.values();
	}

	private Map<Id, Account> getAffectedAccounts(Set<Id> accountIds)
	{
		// query all accounts
		Map<Id, Account> acctMap = new Map<Id, Account>([select Id, Family_Group__c from Account where Id in :accountIds]);
		return acctMap;
	}
	
	private void resetAccounts(Map<Id, Account> acctMap)
	{
		for (Account acct : acctMap.values()) {
			acct.Family_Group__c = null;
		}
	}

}