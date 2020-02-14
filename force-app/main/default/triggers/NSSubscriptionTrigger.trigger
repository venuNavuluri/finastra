trigger NSSubscriptionTrigger on NS_Subscriptions__c (before insert, before update) {
	
	NSSubscriptionTriggerMethods.populateNSSubscription(trigger.oldMap, trigger.newMap, trigger.new);
}