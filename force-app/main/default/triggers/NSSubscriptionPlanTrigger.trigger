trigger NSSubscriptionPlanTrigger on NS_Subscription_Plan__c (before insert, before update) {
	NSSubscriptionPlanTriggerMethods.updateSubscriptionPlan(trigger.oldMap, trigger.newMap, trigger.new);
}