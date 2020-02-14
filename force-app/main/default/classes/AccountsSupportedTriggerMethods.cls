public class AccountsSupportedTriggerMethods {

	public static void CheckAccountSupportedAlreadyOnContact(List<Accounts_Supported__c> newAccountsSupported){
		INTEGER li_Account_Supported_count;
		STRING 	ls_error;
			
		FOR (Integer li_counter = 0; li_counter < newAccountsSupported.size(); li_counter++) {
			li_Account_Supported_count = [SELECT COUNT() FROM Accounts_Supported__c WHERE Contact__c = :newAccountsSupported[li_counter].Contact__c  AND Supported_Account__c = :newAccountsSupported[li_counter].Supported_Account__c];
			IF (li_Account_Supported_count > 0) { // This is a duplicate Accounts_Supported__c and should not be added to the contact again.
            	System.debug('PB: The account supported and should not be created.');
            	
            	//ls_error = 'The account supported ' + newAccountsSupported[li_counter].Suuport_Account_Number__c + ' appears to be duplicate and can not be added again to the contact '); 
                //newAccountsSupported[li_counter].addError('The account already exists on account supported for the client.' );
                newAccountsSupported[li_counter].Supported_Account__c.addError('Error - Duplicate record.  The Accounts Supported relationship being added already exists.' );
            }
			
		}		
	}
	
	
	public static void CheckAccountSupportedAlreadyOnContactUpdate(List<Accounts_Supported__c> newAccountsSupported){
		INTEGER li_Account_Supported_count;
		STRING 	ls_error;
			
		FOR (Integer li_counter = 0; li_counter < newAccountsSupported.size(); li_counter++) {
			li_Account_Supported_count = [SELECT COUNT() FROM Accounts_Supported__c WHERE Contact__c = :newAccountsSupported[li_counter].Contact__c  AND Supported_Account__c = :newAccountsSupported[li_counter].Supported_Account__c];
			IF (li_Account_Supported_count > 1) { // This is a duplicate Accounts_Supported__c and should not be added to the contact again.
            	System.debug('PB: The account supported and should not be created.');
            	
            	//ls_error = 'The account supported ' + newAccountsSupported[li_counter].Suuport_Account_Number__c + ' appears to be duplicate and can not be added again to the contact '); 
                //newAccountsSupported[li_counter].addError('The account already exists on account supported for the client.' );
                newAccountsSupported[li_counter].Supported_Account__c.addError('Error - Duplicate record.  The Accounts Supported relationship being added already exists.' );
            }
			
		}		
	}
	
	public static void AddPortalSharingForContactUser(List<Accounts_Supported__c> newAccountsSupported){

		//Get a list of portal users associated with our new accounts supported objects.
		//If some exist then create Account Share objects for each of them, so they have portal access to that account
		//and cases.
		Set<ID> uniqueContactIds = new Set<Id>();
		
		for(Accounts_Supported__c newAccountSupported : newAccountsSupported){
			uniqueContactIds.add(newAccountSupported.Contact__c);
		}
		system.debug('xxxx uniqueContactIds before adding children='+uniqueContactIds);
		
		Map<ID,ID> contactToPortalUser = new Map<ID,ID>();
		Map<ID,STRING> contactToPortalRole = new Map<ID,STRING>();
		
		list<user> portalUsersToAdd = new list<user>([select Id,ContactId, User.UserRole.PortalRole from User where ContactId in :uniqueContactIds]); 
		system.debug('xxxx portalUsersToAdd='+portalUsersToAdd);
		for(User portalUser : portalUsersToAdd) {
			contactToPortalUser.put(portalUser.ContactId,portalUser.Id);
			contactToPortalRole.put(portalUser.ContactId,portalUser.UserRole.PortalRole);
		}

		if(contactToPortalUser.size() > 0){
			List<AccountShare> accountShares = new List<AccountShare>();

			for(Accounts_Supported__c newAccountSupported : newAccountsSupported){
				if(contactToPortalUser.containsKey(newAccountSupported.Contact__c)){
					AccountShare accountShare = new AccountShare();
					accountShare.AccountId = newAccountSupported.Supported_Account__c;
					accountShare.UserOrGroupId = contactToPortalUser.get(newAccountSupported.Contact__c);
					accountShare.AccountAccessLevel = 'Read';
					// PB(12/14/2009) When Executive Role add edit access on all the cases owned by the account
					if (contactToPortalRole.get(newAccountSupported.Contact__c) == 'Executive') {
						accountShare.CaseAccessLevel = 'Edit';
						accountShare.ContactAccessLevel = 'Read'; // DJ aded 5/June/13
					}
					else { // Else, use default case sharing model.
						accountShare.CaseAccessLevel = 'None';	
					}		
					accountShare.OpportunityAccessLevel = 'None';
					accountShares.add(accountShare);
				}
			}
			system.debug('xxxx account shares before finding uncle accounts'+accountShares);
			
			// DJ Appirio 5/6/13: Now add parent account(s) of the contact(s) from the account share object
			Set<ID> uniqueAccountIds = new Set<Id>();
			list<contact> childContacts = new list<contact>([select id, accountId from contact where id in :uniqueContactIds]);
			for(contact c:childContacts)
			{
				AccountShare accountShare = new AccountShare();
				accountShare.AccountId = c.accountId;
				accountShare.UserOrGroupId = contactToPortalUser.get(c.id);
				accountShare.AccountAccessLevel = 'Read';
				// PB(12/14/2009) When Executive Role add edit access on all the cases owned by the account
				if (contactToPortalRole.get(c.id) == 'Executive') {
					accountShare.CaseAccessLevel = 'Edit';
					accountShare.ContactAccessLevel = 'Read';
				}
				else { // Else, use default case sharing model.
					accountShare.CaseAccessLevel = 'None';	
				}		
				accountShare.OpportunityAccessLevel = 'None';
				accountShares.add(accountShare);
			}
			system.debug('xxxx adding account shares '+accountShares);
			insert accountShares;
		}
	}

	public static void RemovePortalSharingForContactUser(List<Accounts_Supported__c> deletedAccountsSupported){
		Set<ID> uniqueAccountIds = new Set<ID>();
		Set<ID> uniqueContactIds = new Set<ID>();

		for(Accounts_Supported__c deletedAccountSupported : deletedAccountsSupported){
System.debug('XXX: account id: ' + deletedAccountSupported.Supported_Account__c);
			uniqueAccountIds.add(deletedAccountSupported.Supported_Account__c);
			uniqueContactIds.add(deletedAccountSupported.Contact__c);
		}

		//Map<ID,ID> contactIDUserIDMap = new Map<ID,ID>();
		Set<ID> uniqueUserIds = new Set<ID>();

		for(User portalUser: [select Id,ContactId from user where ContactId in :uniqueContactIds]){
			//contactIDUserIDMap.put(portalUser.ContactId,portalUser.Id);
System.debug('XXX: user id: ' + portalUser.Id);
			uniqueUserIds.add(portalUser.Id);
		}

		if(uniqueUserIds.size() > 0){
			List<AccountShare> accountShares = [select Id from AccountShare where AccountId in :uniqueAccountIds and UserOrGroupId in :uniqueUserIds];
			try{
				delete accountShares;
			}catch(Exception e){
				System.debug('XXX: Exception thrown for portal sharing removal: ' + e.getMessage());
			}
		}
	}
    // AC 9/4/09 - test methods moved to separate test class
}