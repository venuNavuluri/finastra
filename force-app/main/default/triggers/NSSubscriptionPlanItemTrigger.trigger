trigger NSSubscriptionPlanItemTrigger on NS_Subscription_Plan_Item__c (before insert, before update) {
	NSSubscriptionPlanItemTriggerMethods.updateSubscriptionPlanItem(trigger.oldMap, trigger.newMap, trigger.new);
}