/*
Created By: Abhinit Kohar
Created Date: 11/12/2013
Description: This trigger converts the Services Amount Variance into the USD using the dated exchange rates and populates 
the Services Amount Variance USD field. 

30/04/2019 - Irving - Commented out setSubscriptionsUpliftValues function which is undefined. 

*/
trigger ContractTrigger on Contract (before insert, before update, after update) {   
    System.debug('ContractTrigger Begins');
    if(trigger.isBefore){
        //Added ATG's trigger framework to the beforeinsert Contract trigger.
        if(Trigger.isInsert){
            System.debug('ContractTrigger Abount to call Run');
            new ContractTriggerHandler().Run();
        }
        if(Trigger.isUpdate){
            /* This has been moved to SyncSubscriptions button method on contract */
            //ContractTriggerMethods.beforeUpdate(Trigger.NewMap, Trigger.OldMap);
        }
    }
}