trigger MyProjectTrigger on MyProject__c (after insert) 
{
	if(trigger.isAfter)
	{
		if(trigger.isInsert)
		{
			MyProjectTriggerMethods.createDefaultMilestones(trigger.newMap);		
		}
	}
}