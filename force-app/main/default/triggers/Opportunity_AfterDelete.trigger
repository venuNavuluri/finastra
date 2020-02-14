trigger Opportunity_AfterDelete on Opportunity (before delete) {
	
	if(Label.Disable_Opportunity_Triggers != 'Disable')
    {
		Map<Id, Opportunity> mapCRopps = new Map<Id,Opportunity>();
		//Determine if the OLIs have been pushed to the Parent Opp for this Opp
		for(Opportunity o : trigger.old){
			if(o.OLIs_Pushed_To_Parent__c == true){
				mapCRopps.put(o.Id,o);
			}
		}
		if(!mapCRopps.isEmpty())
			OpportunityServices.getChangeOrderOLIsForDelete(mapCRopps);
    }
		
}