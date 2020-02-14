public with sharing class CapiProfileDetailsChangeTriggerManager
{
	Map<Id, Profile_details__c> oldMap, newMap;
	List<Profile_details__c> triggerNew;
	
	public CapiProfileDetailsChangeTriggerManager(List<Profile_details__c> pTriggerNew,
		Map<Id, Profile_details__c> pOldMap, Map<Id, Profile_details__c> pNewMap)
	{
		oldMap = pOldMap;
		newMap = pNewMap;
		triggerNew = pTriggerNew;
	}
	
	public void Execute()
	{
		List<Profile_details__c> toUpdate;

		if (trigger.isInsert) { toUpdate = triggerNew; }
		else {
			toUpdate = new List<Profile_details__c>();
			Profile_details__c oldPd;
			for (Profile_details__c newPd : newMap.values()) {
				oldPd = oldMap.get(newPd.Id);
				if (newPd.Business_Area__c != oldPd.Business_Area__c) {
					toUpdate.add(newPd);
				}
			}
		}
		
		CapiUtils.UpdateProfileDetails(toUpdate);
	}
}