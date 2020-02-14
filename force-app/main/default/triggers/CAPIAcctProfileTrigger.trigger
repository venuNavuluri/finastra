trigger CAPIAcctProfileTrigger on Acct_Profile__c (after delete) {
    
    CAPIAcctProfileTriggerHandler.updateTAMCategory(Trigger.old); 
}