trigger CCRTAccountRefTrigger on CCRT__c (after delete, after insert, after undelete, after update)
{
	if (Test.isRunningTest() || TriggerStatusCache.GetStatus('CCRTAccountRefTrigger') == true) {
		CCRTAccountRefManager mgr = new CCRTAccountRefManager(trigger.New, trigger.Old, trigger.oldMap);
		mgr.Execute();
	}
	
	if(trigger.isAfter && trigger.isUpdate){
		//AK - Update the related Acct By Subs
		CCRTTriggerMethods.updateAcctBySub(trigger.newMap, trigger.oldMap);
	}
}