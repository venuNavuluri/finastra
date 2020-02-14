public class OpportunityFuture {

	//This class contains 'callFuture' methods and 'Future' methods.  
	//	--'callFuture' methods are used to determine if the system is currently running in @Future context.  If so, the target method is called 
	//		directly.  If not, the necessary data preparation is done and then the target method is called.
	//  --'Future' methods call the asynchronous process
	//	This was set up to more easily run methods in a @Future context without running into problems with calling @Future methods from a 
	//  @Future method.
	//  JRB

	public static void callFuture_UpdateOppLineItemSchedule(string sQuery, integer iNumMonths)
	{
		//Only run this update once per trigger invocation
		if(GlobalVar.bAlreadyUpdatedOppLineItems == false)
		{
			if(GlobalVar.bInFuture == true)
			{
				//Call the method directly, since we are already running in the Future context
				OpportunityTriggerMethods.UpdateOppLineItemSchedule(sQuery,iNumMonths);
			}else{
				//Call the method to run in the Future context
				OpportunityFuture.Future_UpdateOppLineItemSchedule(sQuery,iNumMonths);
			}
			GlobalVar.bAlreadyUpdatedOppLineItems = true;
		}	
	}
	
	@future public static void Future_UpdateOppLineItemSchedule(string sQuery, integer iNumMonths)
	{
		//Set the flag that this is running asynchronously
		GlobalVar.bInFuture = true;
		system.debug('XXXXX In Future_UpdateOppLineItemSchedule - bInFuture='+GlobalVar.bInFuture);
		
		//Call the method
		OpportunityTriggerMethods.UpdateOppLineItemSchedule(sQuery, iNumMonths);
	}

}