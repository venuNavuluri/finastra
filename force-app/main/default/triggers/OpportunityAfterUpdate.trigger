trigger OpportunityAfterUpdate on Opportunity (after update) {

	if(Label.Disable_Opportunity_Triggers == 'Disable')
    {
    	system.debug('Opportunity Triggers Disabled.  Update Custom Label Disable_Opportunity_Triggers to re-enable');
    }
    else
    {
		if(Trigger.isAfter)
		{
			OpportunityTriggerMethods.updateOLIWhenTermMonthsChanged((List<Opportunity>)Trigger.new, (Map<Id, Opportunity>)Trigger.oldMap);
			//Update the PS line item scheduled date when the opportunity close data is updated
			OpportunityTriggerMethods.UpdateOppLineItems(Trigger.New, Trigger.Old);
			            
			//Update the Quota Credit lines
			OpportunityTriggerMethods.UpdateQuotaCredits(Trigger.new, Trigger.oldMap);
			
			//Update the Contact Roles
			if(OpportunityTriggerMethods.firstRun){
				system.debug('trigger.newMap = ' + trigger.newMap);
				system.debug('trigger.oldMap = ' + trigger.oldMap);
				OpportunityTriggerMethods.UpdateContactRoles(trigger.newMap, trigger.oldMap);
				OpportunityTriggerMethods.firstRun = false;
			}
	    }
	    
	    /*  
	    if(Userinfo.getUserId().substring(0,15) == Label.MBS_Admin_Integration_UserId){
	        OpportunityTriggerMethods.UpdateIntegrationLog(Trigger.newMap,Trigger.oldMap);
	    }
	    */
    }
    
}