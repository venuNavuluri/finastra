trigger BillingEntityTrigger on Billing_Entity__c (after update) {
	if(trigger.isAfter && trigger.isUpdate){
		MisysEntityTriggerMethods.updateContactRoles(trigger.newMap, trigger.oldMap);
	}
}