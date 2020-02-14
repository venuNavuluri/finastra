trigger NSProjectTrigger on NS_Project__c (before insert, before update, after insert) {
    if((Trigger.isInsert && Trigger.isBefore) || (Trigger.isUpdate && Trigger.isBefore)) {
        NSProjectTriggerMethods.populateInternalIds(trigger.new, trigger.newMap, trigger.oldMap);
        NSProjectTriggerMethods.populateNSProjectFromOpportunity(trigger.new);
    } else if(Trigger.isInsert && Trigger.isAfter) {
        //NSProjectTriggerMethods.notifyPipelineProjectCreation(trigger.new);
    }
}