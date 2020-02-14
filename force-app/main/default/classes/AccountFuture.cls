public class AccountFuture {

	//This class contains 'callFuture' methods and 'Future' methods.  
	//	--'callFuture' methods are used to determine if the system is currently running in @Future context.  If so, the target method is called 
	//		directly.  If not, the necessary data preparation is done and then the target method is called.
	//  --'Future' methods call the asynchronous process
	//	This was set up to more easily run methods in a @Future context without running into problems with calling @Future methods from a 
	//  @Future method.
	//  JRB

	public static void callFuture_SetAccountSharing(List<Account> updatedAccounts)
	{
		if(GlobalVar.bInFuture == true)
		{
			//Call the method directly, since we are already running in the Future context
			AccountTriggerMethods.SetAccountSharing(updatedAccounts);
		}else{
			//Prepare to call the method in the @Future context by sending only primitive data types
			Set<Id> sUpdatedAccounts = new Set<Id>();
			for(Account updAcct : updatedAccounts)
			{
				sUpdatedAccounts.add(updAcct.Id);
			}
			system.debug('JRB:    set sUpdatedAccounts size = '+sUpdatedAccounts.size());
			system.debug('JRB:    set sUpdatedAccounts = '+sUpdatedAccounts);
			//Call the method to run in the @Future context
			AccountFuture.Future_SetAccountSharing(sUpdatedAccounts);
		}
	}

	@future public static void Future_SetAccountSharing(Set<Id> sUpdAccounts)
	{
		//Set the flag that this is running as a Future process
		GlobalVar.bInFuture = true;
		system.debug('XXXXX In Future_SetAccountSharing - bInFuture='+GlobalVar.bInFuture);
		
		//Query to get the account data, then call the method
		List<Account> lUpdatedAccounts = [select Id, Name from Account where Id in :sUpdAccounts];
		AccountTriggerMethods.SetAccountSharing(lUpdatedAccounts);
	}

}