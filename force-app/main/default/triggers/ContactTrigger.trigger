trigger ContactTrigger on Contact(after insert, after Update, before update)
{
    
    if(trigger.isAfter && trigger.isInsert) {
       
       if(!CONSTANTS.DISABLE_INDIVIDUAL_TRIGGER) {
       		
       		ContactTriggerHandler.createIndividual(Trigger.new);
       }		
    } 
    
    if(trigger.isAfter && trigger.isUpdate){
        
        ContactTriggerHandler.createCurrentConsent(Trigger.new, Trigger.oldMap);
        List<User> lstUser = new List<User>();
        lstUser = [select Id, ContactId, EMail, Name, FirstName, LastName, Title, Phone, Fax, Street, State, PostalCode, City, Country, MobilePhone from User where ContactId in :trigger.newMap.keySet() and IsActive = true and ContactId != null and UserType = 'PowerCustomerSuccess'];
        //List<User> lstUserToUpdate = new List<User>();
        Set<ID> userIds = new Set<ID>(); 
        Set<ID> contactIds = new Set<ID>();
        if(lstUser != null && lstUser.size() > 0)
        {
            for(User usr : lstUser)
            {
                Contact con = trigger.newMap.get(usr.ContactId);
                Contact oldCon = trigger.oldMap.get(con.Id);
                if (con.EMail != usr.EMail || con.FirstName != usr.FirstName || con.LastName != usr.LastName || con.Title != usr.Title || con.Phone != usr.Phone || con.MobilePhone != usr.MobilePhone || con.Fax != usr.Fax || con.MailingStreet != usr.Street
                    || con.MailingState != usr.State
                    || con.MailingCity != usr.City
                    || con.MailingCountry != usr.Country
                    || con.MailingPostalCode != usr.PostalCode)
                {
                    System.debug('Contact changed');
                    System.debug('usr.Id : ' + usr.Id);
                    System.debug('usr.ContactId : ' + usr.ContactId);
                    userIds.add(usr.Id);
                    contactIds.add(usr.ContactId);
                }
            }
        }
        if(userIds.size() > 0 && contactIds.size() > 0)
        {
            System.debug('Updating User');
            ContactTriggerMethods.updatePortalUser(userIds, contactIds);
        }
        //call the method to update Acct By Subs once the contacts are synced with NS
        ContactTriggerMethods.updateAcctBySubs(trigger.newMap, trigger.oldMap);
        /*
        KK: SD Req 1442818
        Description: To Update the 'Marketing Involved Program' field on all the open opportunities with the 'Marketing Involved Program' value 
                     on respective linked Contact, whenever contact is updated and 'Marketing Involved Program' value is changed .This functionality 
                     is used for tracking Marketing Generated and Influenced Opportunities through Marketo.
        */
        Map<Id,Contact> ContactIdToContactMap= new Map<Id,Contact>();
        for ( Integer count = 0; count < Trigger.New.size(); count++ ){
            //To check if 'Marketing Involved Program' field value is changed on contact
             if ( Trigger.New[count].Marketing_Involved_Program__c != Trigger.Old[count].Marketing_Involved_Program__c ) {
                 ContactIdToContactMap.put(Trigger.New[count].Id,Trigger.New[count]);
             }
        }
        //To call updateOppMarketingInvolvedProgram method of ContactTriggerMethods class to update the opps
        if(ContactIdToContactMap.size() >0){
            ContactTriggerMethods.updateOppMarketingInvolvedProgram(ContactIdToContactMap);
        }
    }
    if(trigger.isBefore && trigger.isUpdate){
        ContactTriggerMethods.updateSynceFlag(trigger.newMap, trigger.oldMap);
    }
     if(trigger.isBefore ){
          ContactTriggerMethods.updateTopScoringNurture(trigger.new);
    }
}