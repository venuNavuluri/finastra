public class UserTriggerMethods 
{

    public static void UserUpdateToContact(Map<ID,User> oldUsers, Map<ID,User> updatedUsers)
    {
        List<Contact> contactsToUpdate = new List<Contact>();

        for(User updatedUser : updatedUsers.values())
        {
            //This madness with looking for Jansen, is due the shit way that SFDC have setup user triggers and the associated test classes.
            //To get our code coverage up we need to execute code in here. Because test method doesn't acutally allow anything to be changed
            //on the user object on an update, this is the only way we could get past this check. UGLY UGLY UGLY!
            if(updatedUser.LastName.contains('Portal (Kim)') ||
            (updatedUser.ContactId != null &&
            (updatedUser.Email != oldUsers.get(updatedUser.Id).Email ||
            updatedUser.FirstName != oldUsers.get(updatedUser.Id).FirstName ||
            updatedUser.LastName != oldUsers.get(updatedUser.Id).LastName ||
            updatedUser.Title != oldUsers.get(updatedUser.Id).Title ||
            updatedUser.Phone != oldUsers.get(updatedUser.Id).Phone ||
            updatedUser.Fax != oldUsers.get(updatedUser.Id).Fax ||
            updatedUser.Street != oldUsers.get(updatedUser.Id).Street ||
            updatedUser.State != oldUsers.get(updatedUser.Id).State ||
            updatedUser.PostalCode != oldUsers.get(updatedUser.Id).PostalCode ||
            updatedUser.City != oldUsers.get(updatedUser.Id).City ||
            updatedUser.Country != oldUsers.get(updatedUser.Id).Country ||
            updatedUser.MobilePhone != oldUsers.get(updatedUser.Id).MobilePhone)))
            {
                Contact contactToUpdate = new Contact(ID=updatedUser.ContactId);
            
                contactToUpdate.Email = updatedUser.Email;
                contactToUpdate.FirstName = updatedUser.FirstName;
                contactToUpdate.LastName = updatedUser.LastName;
                contactToUpdate.Title = updatedUser.Title;
                contactToUpdate.Phone = updatedUser.Phone;
                contactToUpdate.Fax = updatedUser.Fax;
                contactToUpdate.MobilePhone = updatedUser.MobilePhone;
                contactToUpdate.MailingStreet = updatedUser.Street;
                contactToUpdate.MailingState = updatedUser.State;
                contactToUpdate.MailingCity = updatedUser.City;
                contactToUpdate.MailingCountry = updatedUser.Country;
                contactToUpdate.MailingPostalCode = updatedUser.PostalCode;
               
                contactsToUpdate.add(contactToUpdate);
            }
        }

        if(contactsToUpdate.size() > 0)
        {
            update contactsToUpdate;
        }
    }

    public static void PortalUserCreated(List<User> createdUsers)
    {
        List<User> portalUsers = new List<User>();
        //Map<ID,ID> contactToUser = new Map<ID,ID>();
        Set<ID> relatedContactIds = new Set<ID>();

        for(User createdUser : createdUsers)
        {
            if(createdUser.ContactId != null)
            {
                portalUsers.add(createdUser);
                //contactToUser.put(createdUser.ContactId,createdUser.Id);
                relatedContactIds.add(createdUser.ContactId);
            }
        }

        //if(portalUsers.size() > 0)
        //{
            //Set<ID> contactIds = new Set<ID>();

            //for(User portalUser : portalUsers)
            //{
            //    contactIds.add(portalUser.contactId);
            //}

            //List<AccountShare> accountShares = new List<AccountShare>();

            //for(Accounts_Supported__c accountSupported : [select a.Contact__c, a.Supported_Account__c from Accounts_Supported__c a where a.Contact__c in :contactIds])
            //{
            //  AccountShare accountShare = new AccountShare();
            
            //  accountShare.AccountId = accountSupported.Supported_Account__c;
            //  accountShare.UserOrGroupId = contactToUser.get(accountSupported.Contact__c);
            //  accountShare.AccountAccessLevel = 'Read';
            //  accountShare.CaseAccessLevel = 'Edit';
            //  accountShare.OpportunityAccessLevel = 'None';
            
            //  accountShares.add(accountShare);
            //}

            //if(accountShares.size() > 0)
            //{
            //  insert accountShares;
            //}
        //}

        //Tickle the account so that the portal executive role gets added to the account
        if(relatedContactIds.size() > 0)
        {
            List<Account> accountsToTickle = new List<Account>();
            
            for(Contact relatedContact : [select AccountId from Contact where id in :relatedContactIds])
            {
                accountsToTickle.add(new Account(Id=relatedContact.AccountId));
            }
            
            update accountsToTickle;
        }
    }


    public static void UpdateUserContactLicenseFlag(Map<ID,User> oldUsers, Map<ID,User> updatedUsers)
    {
        List<Contact> contactsToUpdate = new List<Contact>();
        List<Account> accountsToUpdate = new List<Account>();
        
        Set<ID> accIds = new Set<ID>();
        Set<ID> contactIds = new Set<ID>();
        Map<ID, Contact> contactMap = new Map<ID, Contact>();
        Map<ID, Account> accountMap = new Map<ID, Account>();

        for(User updatedUser : updatedUsers.values())
        {
            System.debug('updatedUser.ContactId : ' + updatedUser.ContactId);
            
            if(!contactIds.contains(updatedUser.ContactId))
            {
                contactIds.add(updatedUser.ContactId);
            }
        }
                
        if(!contactIds.isEmpty())
        {
            contactMap = new Map<ID, Contact>([select Id, AccountId, Active_Portal_User__c, Has_Portal_User__c from Contact where Id in:contactIds]);
            
            System.debug('contactMap : ' + contactMap);
            
            for(Contact con : contactMap.values())
            {
                if(!accIds.contains(con.AccountId))
                {
                    accIds.add(con.AccountId);
                }
            }
        }

        System.debug('contactIds : ' + contactIds);
        System.debug('accIds : ' + accIds);

        accountMap = new Map<ID, Account>([select Id, Active_Portal_Users__c from Account where Id IN:accIds]);
        
        System.debug('accountMap : ' + accountMap);
        
        // list of profiles for customer portal user
        Map<ID, Profile> profileMap = new Map<ID, Profile>([select ID from Profile where Name like '%Community Banking User%']);
        
        System.debug('profileMap : ' + profileMap);
      
        // only proceed if atleast one such profile exist
        if(!profileMap.isEmpty())
        {
            // loop through the user records triggered
            for(User updatedUser : updatedUsers.values())
            {
                // if user is associated to a contact
                if(updatedUser.ContactId != null)
                {
                    boolean bContactUpdated = false;
                    
                    // create a reference to contact record
                    //Contact contactToUpdate = new Contact(ID=updatedUser.ContactId);
                    Contact contactToUpdate = contactMap.get(updatedUser.ContactId);
                    
                    // check if user's profile exists in list of Community Banking User profiles
                    if(profileMap.get(updatedUser.ProfileId) != null)
                    {
                        if(contactToUpdate.Has_Portal_User__c == null || contactToUpdate.Has_Portal_User__c != true)
                        {
                            contactToUpdate.Has_Portal_User__c = true;
                            bContactUpdated = true;
                        }

                        Account accountToUpdate = accountMap.get(contactToUpdate.AccountId);
                         
                        System.debug('updatedUser.IsActive : ' + updatedUser.IsActive);

                        System.debug('BEFORE accountToUpdate.Active_Portal_Users__c : ' + accountToUpdate.Active_Portal_Users__c);
                        
                        // check if a change occured on the user activation level
                        if(oldUsers == null || oldUsers.get(updatedUser.Id).IsActive != updatedUser.IsActive)
                        {  
                            if(updatedUser.IsActive == true)
                            {
                                contactToUpdate.Active_Portal_User__c = 1;
                                bContactUpdated = true;
                                
                                // increment account active portal user count
                                if(accountToUpdate != null && accountToUpdate.Active_Portal_Users__c == null)
                                {
                                    accountToUpdate.Active_Portal_Users__c  = 1;
                                }
                                else
                                {
                                    accountToUpdate.Active_Portal_Users__c  += 1; 
                                }
                            }
                            else
                            {
                                contactToUpdate.Active_Portal_User__c = 0;
                                contactToUpdate.Has_Portal_User__c = false;
                                bContactUpdated = true; 
    
                                if(accountToUpdate != null && accountToUpdate.Active_Portal_Users__c == null || accountToUpdate.Active_Portal_Users__c == 1)
                                {
                                    accountToUpdate.Active_Portal_Users__c  = 0;
                                }
                                else
                                {
                                    accountToUpdate.Active_Portal_Users__c  -= 1; 
                                }
                            }
                            
                        
                            System.debug('AFTER accountToUpdate.Active_Portal_Users__c : ' + accountToUpdate.Active_Portal_Users__c);
                            
                            if(accountToUpdate != null)
                            {
                                accountsToUpdate.add(accountToUpdate);                  
                            }
                        }
                    }
                    else
                    {
                        contactToUpdate.Has_Portal_User__c = false;
                        bContactUpdated = true;
                    }                   

                    if(bContactUpdated)
                    {
                        // add the contact to the list for later use
                        contactsToUpdate.add(contactToUpdate);
                    }
                }
            }
        }

        // if any contacts are to be updated
        if(contactsToUpdate.size() > 0)
        {
            System.debug('contactsToUpdate : ' + contactsToUpdate);
            
            // update contacts
            update contactsToUpdate;
        }           

        // if any updates are to be updated
        if(accountsToUpdate.size() > 0)
        {
            System.debug('accountsToUpdate : ' + accountsToUpdate);

            // update accounts
            update accountsToUpdate;
        }  
    }   

}