trigger AccBySubTrigger on Acct_By_Sub__c (before insert, before update, after insert) {
	AccBySubTriggerMethods.populateAccBySub(trigger.oldMap, trigger.newMap, trigger.new);
}