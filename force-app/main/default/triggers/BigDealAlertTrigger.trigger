trigger BigDealAlertTrigger on Opportunity (before update) {
    
    if(trigger.isBefore && trigger.isUpdate)
    {
	    //Check if any updated opportunities qualify for the Big Deal Alert
	    ChatterBigDealAlert.CheckForBigDeals(trigger.new);
	    
    }	
   
}