trigger OpportunityTrigger on Opportunity (before update, after update, after insert, after delete, after undelete) 
{
    if(Label.Disable_Opportunity_Triggers == 'Disable')
    {
    	system.debug('Opportunity Triggers Disabled.  Update Custom Label Disable_Opportunity_Triggers to re-enable');
    }
    else
    {
	    if(Trigger.isUpdate)
	    {
	        if(Trigger.isBefore)
	        {
	            OpportunityServices.createProjectFromOpportunity(Trigger.newMap, Trigger.oldMap);   
	            
	        }else{
	            //Check if the Opportunity recordtype is for Change Requests and if the updated Status is Closed and Lost
	            map<Id, Opportunity> mapCRoppsClosedLost = new map<Id,Opportunity>();
	            for(Opportunity o : trigger.new){
	            	if(o.recordtypeid == Label.RecType_Opportunity_ChangeReq && o.Original_Opportunity__c != null){
	            		if(o.isClosed == true && o.isWon == false && (trigger.oldMap.get(o.Id).isClosed != true || trigger.oldMap.get(o.Id).isWon != false)
	            		  && o.OLIs_Pushed_To_Parent__c)
		            	{
		            		//This is a Change Opportunity that has just been marked as Closed and Lost.  Any OLI's copied to the Parent opp now need to be removed. 
		            		mapCRoppsClosedLost.put(o.Id,o);
		            	}
	            	}
	            }
	            if(mapCRoppsClosedLost.keySet().size() > 0){
	            	OpportunityServices.getChangeOrderOLIsForDelete(mapCRoppsClosedLost);
	            }
	            
	            //OpportunityServices.copyChangeOrderOLIsToParentOpportunity(Trigger.newMap, Trigger.oldMap);
	            //OpportunityServices.createUpdateAssets(Trigger.newMap, Trigger.oldMap);
	        }
	    }
	    
	    //Ak - update for rollup to account
	    if(trigger.isAfter && (trigger.isUpdate || trigger.isInsert || trigger.isUndelete)){
	    	OpportunityTriggerMethods.rollupToAccount(trigger.new);
	    } 
	    if(trigger.isAfter && trigger.isDelete){
	    	OpportunityTriggerMethods.rollupToAccount(trigger.old);
	    }
    }
}