trigger NSRlfChangeOrderTrigger on NS_RLF_Change_Order__c (after update, before insert, before update) {
	NSRlfChangeOrderMethods.updateNSPushToken(trigger.oldMap, trigger.newMap, trigger.new);
}