trigger CustomerCaseSynchTrigger on Case (before update)
{
	if (Test.isRunningTest() || TriggerStatusCache.GetStatus('CustomerCaseSynchTrigger') == true) {
		CustomerCaseSynchManager mgr = new CustomerCaseSynchManager(trigger.newMap, trigger.oldMap);
		mgr.Execute();
	}
}