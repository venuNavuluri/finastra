trigger NSReturnAuthorisationTrigger on NS_Return_Authorisation__c (before insert, before update) {
	NSReturnAuthorisationTriggerMethods.populateNSReturnAuthorisation(trigger.oldMap, trigger.newMap, trigger.new);
}