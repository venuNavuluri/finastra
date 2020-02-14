public with sharing class CapiAccountChangeTriggerManager
{
	Map<Id, Account> oldMap, newMap;
	
	public CapiAccountChangeTriggerManager(Map<Id, Account> pOldMap, Map<Id, Account> pNewMap)
	{
		oldMap = pOldMap;
		newMap = pNewMap;
	}
	
	public void Execute()
	{
		List<Id> acctIdsToProcess = new List<Id>();
		Account acctOld;
		for (Account acctNew: newMap.values()) {
			acctOld = oldMap.get(acctNew.Id);
			if (acctNew.Institution_Type__c != acctOld.Institution_Type__c ||
				acctNew.Pyramid_Tier__c != acctOld.Pyramid_Tier__c ||
				acctNew.Business_Footprint__c != acctOld.Business_Footprint__c
			) {
				acctIdsToProcess.add(acctNew.Id);
			}
		}
		if(!acctIdsToProcess.isEmpty()) {
			Profile_details__c[] profDetailsRecs = getProfDetailsRecs(acctIdsToProcess);

			CapiUtils.UpdateProfileDetails(profDetailsRecs);
			update profDetailsRecs;
		}
	}
	
	private Profile_details__c[] getProfDetailsRecs(List<Id> acctIds)
	{
		Profile_details__c[] profDetailsRecs = [
			select Id, InstitutionFootprint__c, Whitespace__c 
			from Profile_details__c
			where Acct_Profile__r.Account__c in :acctIds
		];
		
		return profDetailsRecs;
	}
}