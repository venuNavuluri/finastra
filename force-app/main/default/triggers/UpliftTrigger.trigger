trigger UpliftTrigger on Uplift__c (before insert, before update) {        
    UpliftProrataHandler.calcualteUpliftFactor(Trigger.New); // calcuating uplift factor
}