trigger AccountTrigger on Account (before insert, before update, after update, after insert, before delete) 
{
	if(Trigger.isBefore && Trigger.isInsert)
	{
		AccountTriggerMethods.UpdateCountryInfo(Trigger.new, null);
	}

	if(Trigger.isBefore && Trigger.isUpdate)
	{
		AccountTriggerMethods.UpdateCountryInfo(Trigger.new, Trigger.oldMap);
	}
	//AK - this is to delete the existing Health Index from Account while merging/deleting the account.
    if(trigger.isDelete && trigger.isBefore){
        AccountTriggerMethods.deleteHealthIndex(trigger.old);
    }
	
	// Prash(11/16/2009) : SetAccountSharing may only be applicable for Inserts. Whereas Update would take care of Owner change and sharing
	// Before my change this trigger was After Update only and both the functions below were invoked on AFTER UPDATE event
	if(Trigger.isInsert && Trigger.isAfter)
	{
        AccountTriggerMethods.SetAccountSharing(Trigger.new);
    }

	if(Trigger.isUpdate && Trigger.isAfter)
	{
        //JRB 26/4/11 - Changed to run as an asynchronous process due to errors when creating a new portal user (MIXED_DML_OPERATION error updating both User and AccountShare)
        //AccountTriggerMethods.SetAccountSharing(Trigger.new);
        AccountFuture.callFuture_SetAccountSharing(Trigger.new);
        
        //When the Account owner changes, sharing gets removed, so we need to replace the sharing records
        AccountTriggerMethods.AccountOwnerChangeAddSharing(Trigger.newMap,Trigger.oldMap);
        List<Account> lAcc = new List<Account>();
        List<String> lAccIds = new List<String>();
		for(Account Acc: Trigger.new)
		{
			if(Acc.OwnerId != Trigger.oldMap.get(Acc.Id).OwnerId)
				lAccIds.add(Acc.Id);
		}
		if(lAccIds.size() > 0)
			AccountTriggerMethods.AccountOwnerChangeOpptyChild(lAccIds);
			
		//AK - Update the related Acct By Subs	
		AccountTriggerMethods.updateAcctBySub(trigger.newMap, trigger.oldMap);
    }
    
    //The Tickle Me field is used to trigger updates that would otherwise only run under certain conditions.  This sets the field back to False once the items are triggered.
    if(!trigger.isDelete){
        for(Account Accnt : Trigger.new)
        {
            if(Accnt.Tickle_Me__c == true)
            {
                system.debug('Tickled Account: '+Accnt.Id + ' ' + Accnt.Name);
                Accnt.Tickle_Me__c = false;
            }
        }
    }
	
}