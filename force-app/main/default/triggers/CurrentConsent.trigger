trigger CurrentConsent on Current_Consent__c (after delete, after insert) {
    
    if(Trigger.isInsert) {
        
        CurrentConsentTriggerHandler.updateTotalConsent(Trigger.new, true);
        
    }
    
    if(Trigger.isDelete) {
        
        CurrentConsentTriggerHandler.updateTotalConsent(Trigger.old, false);
    }
}