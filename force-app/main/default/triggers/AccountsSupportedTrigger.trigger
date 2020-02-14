trigger AccountsSupportedTrigger on Accounts_Supported__c (after delete, after insert, before insert, before update, after update) {
	
	if(Trigger.isInsert && Trigger.isBefore){
		// Prash(8/18/2009)	:Added CheckAccountSupportedAlreadyOnContact
		AccountsSupportedTriggerMethods.CheckAccountSupportedAlreadyOnContact(Trigger.new);
		
	}
	if(Trigger.isUpdate && Trigger.isBefore){
		// Prash(8/18/2009)	:Added CheckAccountSupportedAlreadyOnContact
		AccountsSupportedTriggerMethods.CheckAccountSupportedAlreadyOnContactUpdate(Trigger.new);
	}
	
	if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter){
		AccountsSupportedTriggerMethods.AddPortalSharingForContactUser(Trigger.new);
	}

	if(Trigger.isDelete && Trigger.isAfter){
		AccountsSupportedTriggerMethods.RemovePortalSharingForContactUser(Trigger.old);
	}
}