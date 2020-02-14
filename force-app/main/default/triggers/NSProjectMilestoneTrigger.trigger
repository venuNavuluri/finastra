trigger NSProjectMilestoneTrigger on NS_Project_Milestone__c (before update) {
	NSProjectMilestoneTriggerMethods.checkForUpdates(trigger.newMap, trigger.oldMap);
}