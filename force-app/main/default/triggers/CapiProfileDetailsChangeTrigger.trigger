trigger CapiProfileDetailsChangeTrigger on Profile_details__c (before insert, before update)
{
	CapiProfileDetailsChangeTriggerManager capiPDChgMgr =
		new CapiProfileDetailsChangeTriggerManager(trigger.new, trigger.oldMap, trigger.newMap);
	capiPDChgMgr.Execute();
}