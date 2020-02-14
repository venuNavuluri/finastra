trigger NSCustomerBillingScheduleTrigger on NS_Customer_Billing_Schedule__c (before update) {
	NSCustomerBillingScheduleTriggerMethods.updateSyncFlag(trigger.oldMap, trigger.newMap, trigger.new);
}