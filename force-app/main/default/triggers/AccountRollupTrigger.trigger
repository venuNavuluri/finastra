trigger AccountRollupTrigger on Account_Rollup__c (before insert, before update, after insert, after update) {
    AccountRollupTriggerMethods.rollupValues(trigger.new);
}