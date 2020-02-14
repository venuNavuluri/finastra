trigger SubscriptionTrigger on SBQQ__Subscription__c (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    /*G.B 12.07.2019 -  Implement trigger factory pattern. 
    *All SubscriptionTriggerMethods methods have been copied over SubscriptionTriggerHandler
    */
    new SubscriptionTriggerHandler().run();
    
}