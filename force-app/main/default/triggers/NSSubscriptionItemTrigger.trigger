trigger NSSubscriptionItemTrigger on NS_Subscription_Item__c (before insert, before update) {
	NSSubscriptionItemTriggerMethods.updateSubscriptionItem(trigger.oldMap, trigger.newMap, trigger.new);
}