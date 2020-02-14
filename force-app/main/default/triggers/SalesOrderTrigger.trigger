trigger SalesOrderTrigger on Sales_Order__c (before insert, before update, after update, after insert, after delete) {
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        SalesOrderTriggerMethods.populateSalesOrder(trigger.oldMap, trigger.newMap, trigger.new);
        SalesOrderTriggerMethods.applyNewILFSubsAssetSizeOnSubmit(Trigger.new, Trigger.oldMap);  //SEV: Asset Uplift
    }

    //AK - commenting the below as it is now being done via the Informatica job
    /*
    if(trigger.isAfter && trigger.isUpdate){
        SalesOrderTriggerMethods.updateNSPushToken(trigger.oldMap, trigger.newMap, trigger.new);
    }
    */
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isDelete)){
        SalesOrderTriggerMethods.updateOpportunity(trigger.oldMap, trigger.newMap, trigger.new);
    }
}