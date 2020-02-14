trigger TargetedReleaseTrigger on Targeted_Release__c (after update, after insert) 
{

	TargetedReleaseTriggerMethods.UpdateCustomerCase(Trigger.newMap);
	
	
	if(Trigger.isUpdate)
	{
		// Next line is commented by Nitin because this is now done via SendNotificationMailOnFieldChange method
		//TargetedReleaseTriggerMethods.L3StatusChange(Trigger.newMap, Trigger.oldMap);
		TargetedReleaseTriggerMethods.SendNotificationMailOnFieldChange(Trigger.new[0], Trigger.oldMap.get(Trigger.new[0].Id));	  
	}
	/* This is replaced with the Workflow rule : "New Targeted Release notification"
	if(Trigger.isInsert)
	{
		if(Trigger.new[0].Case__c != null)	  
		  {
		  	//TargetedReleaseTriggerMethods.SendNotificationMail(Trigger.new[0].Case__c,Trigger.new[0]);
		  }
	}
	*/
}