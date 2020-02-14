trigger SystemTrigger on System__c (after delete, after insert, after undelete, after update)
{
	SystemTriggerManager sysTmgr = new SystemTriggerManager(trigger.oldMap, trigger.newMap);
	sysTmgr.Execute();
}