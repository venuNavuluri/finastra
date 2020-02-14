public class ContactTriggerMethods 
{
    @future
    public static void updatePortalUser(Set<ID> userIds, Set<ID> contactIds)
    {
        System.debug('in ContactTriggerMethods.updatePortalUser');
        System.debug('userIds : ' + userIds);
        System.debug('contactIds : ' + contactIds);
        if(userIds != null && contactIds != null)
        {
            List<User> lstUser = [select Id, ContactId, EMail, Name, FirstName, LastName, Title, Phone, Fax, Street, State, PostalCode, City, Country, MobilePhone from User where Id in : UserIds];
            Map<ID,Contact> mapContact = new Map<ID,Contact>([select Id, FirstName, LastName, Email, Title, Phone, MobilePhone, Fax, MailingStreet, MailingState, MailingCity, MailingCountry, MailingPostalCode from Contact where Id in : contactIds]);
            for(User usr : lstUser)
            {
                Contact con = mapContact.get(usr.ContactId);
                if(con.Email != null && con.Email != '')
                    usr.Email = con.Email;
                //if(con.FirstName != null && con.FirstName != '')
                    usr.FirstName = con.FirstName;
                if(con.LastName != null && con.LastName != '')
                    usr.LastName = con.LastName;
                //if(con.Title != null && con.Title != '')
                    usr.Title = con.Title;
                //if(con.Phone != null && con.Phone != '')
                    usr.Phone = con.Phone;
                //if(con.Fax != null && con.Fax != '')
                    usr.Fax = con.Fax;
                //if(con.MobilePhone != null && con.MobilePhone != '')
                    usr.MobilePhone = con.MobilePhone;
                //if(con.MailingStreet != null && con.MailingStreet != '')
                    usr.Street = con.MailingStreet;
                //if(con.MailingState != null && con.MailingState != '')
                    usr.State = con.MailingState;
                //if(con.MailingCity != null && con.MailingCity != '')
                    usr.City = con.MailingCity;
                //if(con.MailingCountry != null && con.MailingCountry != '')
                    usr.Country = con.MailingCountry;
                //if(con.MailingPostalCode != null && con.MailingPostalCode != '')
                    usr.PostalCode = con.MailingPostalCode;
           }
           System.debug('lstUser : ' + lstUser);
           if(!Test.IsRunningTest()){
               update lstUser;
           }
        }
    }
    public static void updateAcctBySubs(map<id, Contact> newMap, map<id, Contact> oldMap){
        set<id> contactIds = new set<id>();
        for(Contact contact : newMap.values()){
            if(contact.NS_Internal_Id__c != oldMap.get(contact.Id).NS_Internal_Id__c ){
                contactIds.add(contact.Id);
            }
        }
        system.debug('contactIds = ' + contactIds);
        if(contactIds != null && contactIds.size() > 0){
            list<Acct_By_Sub__c> absList = new list<Acct_By_Sub__c>();
            for(Acct_By_Sub__c abs : [select id, Synced_To_NS__c from Acct_By_Sub__c where Customer_Invoice_Approval__c in :contactIds or Customer_AP_Contact__c in :contactIds]){
                abs.Synced_To_NS__c = false;
                absList.add(abs);
            }
            system.debug('absList = ' + absList);    
            if(absList != null && absList.size() > 0){
                update absList;
            }
        }
    }
    public static void updateSynceFlag(map<id, Contact> newMap, map<id, Contact> oldMap){
        for(Contact contact : newMap.values()){
            if(contact.NS_Primary_Account__c != null && 
                (contact.Salutation != oldMap.get(contact.Id).Salutation || contact.FirstName != oldMap.get(contact.Id).FirstName || 
                contact.Middle_Name__c != oldMap.get(contact.Id).Middle_Name__c || contact.LastName != oldMap.get(contact.Id).LastName || 
                contact.Title != oldMap.get(contact.Id).Title || contact.Phone != oldMap.get(contact.Id).Phone || 
                contact.Fax != oldMap.get(contact.Id).Fax || contact.Email != oldMap.get(contact.Id).Email || 
                contact.Alternative_Email__c != oldMap.get(contact.Id).Alternative_Email__c || contact.HomePhone != oldMap.get(contact.Id).HomePhone ||
                contact.MobilePhone != oldMap.get(contact.Id).MobilePhone || contact.Description != oldMap.get(contact.Id).Description || 
                contact.NS_Export_to_Open_Air__c != oldMap.get(contact.Id).NS_Export_to_Open_Air__c)){
                contact.Synced_To_NS__c = false;
            }
        }
    }
     /* public static void updateTopSolution(List<Contact> lContactNew)
    {
        String topSolution = 'FusionBanking';
        Decimal topScore;
        for(Contact newContact : lContactNew){
            topScore  = Integer.valueOf(newContact .FusionBanking_Score__c);
            if(topScore == null)
            topScore = -9999;
            if (Integer.valueOf(newContact.FusionCapital_Score__c) > topScore)
            {
                topSolution = 'FusionCapital';
                topScore = Integer.valueOf(newContact.FusionCapital_Score__c); 
            }
            if(Integer.valueOf(newContact.FusionCorporate_Score__c) > topScore){
                      topSolution = 'FusionCorporate';
                      topScore = Integer.valueOf(newContact.FusionCorporate_Score__c) ;
            }
            if(Integer.valueOf(newContact.FusionInvest_Score__c) > topScore){
                      topSolution = 'FusionInvest';
                      topScore = Integer.valueOf(newContact.FusionInvest_Score__c);
            }
            if(Integer.valueOf(newContact.FusionRisk_Score__c) > topScore){
                      topSolution = 'FusionRisk';
                      topScore = Integer.valueOf(newContact.FusionRisk_Score__c);
            }
            newContact.topSolution__c = topSolution ;
        }
    }*/
    //Cheryl's code
    public static void updateTopScoringNurture(List<Contact> lContactNew)
    {
        String topSolution = '';
        Decimal topScore;
        for(Contact newContact : lContactNew){
        //    topScore  = Integer.valueOf(newContact.Nurture1_Score__c);
        //    if(topScore == null)
            topScore = 0;
              if (Integer.valueOf(newContact.Nurture1_Score__c) > topScore)
            {
                topSolution = 'Nurture1';
                topScore = Integer.valueOf(newContact.Nurture1_Score__c); 
            }
            if (Integer.valueOf(newContact.Nurture2_Score__c) > topScore)
            {
                topSolution = 'Nurture2';
                topScore = Integer.valueOf(newContact.Nurture2_Score__c); 
            }
            if(Integer.valueOf(newContact.Nurture3_Score__c) > topScore){
                      topSolution = 'Nurture3';
                      topScore = Integer.valueOf(newContact.Nurture3_Score__c) ;
            }
            if(Integer.valueOf(newContact.Nurture4_Score__c) > topScore){
                      topSolution = 'Nurture4';
                      topScore = Integer.valueOf(newContact.Nurture4_Score__c);
            }
            if(Integer.valueOf(newContact.Nurture5_Score__c) > topScore){
                      topSolution = 'Nurture5';
                      topScore = Integer.valueOf(newContact.Nurture5_Score__c);
            }
            newContact.topSolution__c = topSolution ;
            }
            }
    /*
    KK: SD Req 1442818
    Method: updateOppMarketingInvolvedProgram
    Description: To Update the 'Marketing Involved Program' field on all the open opportunities with the 'Marketing Involved Program' value 
                 on respective linked Contact, whenever contact is updated and 'Marketing Involved Program' value is changed .This functionality 
                 is used for tracking Marketing Generated and Influenced Opportunities through Marketo.
    Parameters: Map of ContactId to Contact
    Return: Void
    */
    public static void updateOppMarketingInvolvedProgram(Map<Id,Contact> ContactIdToContactMap){
        Opportunity oppToUpdate;
        Set<Id> OpportunityIdSet = new Set<Id>();
        //To fetch the OpportunityContactRole records based on contactIds
        List<OpportunityContactRole> oppContactRoleList=[Select OpportunityId,contactId From OpportunityContactRole where ContactId in :ContactIdToContactMap.keySet()];
        //To collect the opportunity Ids from the OpportunityContactRole list
        For(OpportunityContactRole oppObj: oppContactRoleList) {
            OpportunityIdSet.add(oppObj.OpportunityId);
        }
        //To fetch the Opportunities linked to corresponding contacts
        Map<Id,Opportunity> opportunitiesMap = new Map<Id,Opportunity>([Select Id,Marketing_Involved_Program__c,Marketing_Involved_Date__c,stageName From Opportunity where id in :OpportunityIdSet]);
        //To update the opportunity 'Marketing_Involved_Program' details with that from corresponding contact
        Map<Id,Opportunity> opportunitiesToUpdate = new Map<Id, Opportunity>();
        for(OpportunityContactRole Obj: oppContactRoleList){
                oppToUpdate=opportunitiesMap.get(Obj.OpportunityId);
                //To check if the opportunity is open before updating the 'Marketing_Involved_Program' details
                if(!oppToUpdate.stageName.equals('Closed Won') && !oppToUpdate.stageName.equals('Closed Lost') && !oppToUpdate.stageName.equals('Closed Qualified Out')){
                    oppToUpdate.Marketing_Involved_Program__c=ContactIdToContactMap.get(Obj.contactId).Marketing_Involved_Program__c;
                    oppToUpdate.Marketing_Involved_Date__c=Date.today();
                    opportunitiesToUpdate.put(oppToUpdate.Id, oppToUpdate); // to avoid duplicate opportunities for duplicate contact roles
                }
            }
        if(!opportunitiesToUpdate.values().isEmpty()){
            update opportunitiesToUpdate.values();
        }   
     }
}