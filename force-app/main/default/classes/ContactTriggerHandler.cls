public with sharing class ContactTriggerHandler {
    
    public static List<Individual> individualsToInsert;
    public static List<Contact> contactWithNoCurrentConsent = new List<Contact>();
    public static List<Contact> contactWithCurrentConsent = new List<Contact>(); 
    
    public static void createIndividual(List<sobject> sobjects) {
        
        individualsToInsert = new List<Individual>();
        Map<Id, Individual> mapSobjIndividual = new Map<Id, Individual>();

        List<sobject> sobj = new List<sobject>();
        
        for(sobject s : sobjects){
    
            Individual indRec = new Individual();
            sObject sObjToUpdate;
      
            if(s.get('IndividualId') == null) {
         
                    indRec.put('LastName', s.get('LastName'));
                    
                    
                    if(string.valueOf(s.Id).startswith(CONSTANTS.CONTACT_OBJECT_PREFIX)) {
                         
                        indRec.put('BirthDate', s.get('BirthDate'));
                        
                    }
                    
                    indRec.put('FirstName', s.get('FirstName'));
                    individualsToInsert.add(indRec);
                    mapSobjIndividual.put(s.Id, indRec);
     
            }
        }
        
        if(!individualsToInsert.isEmpty()) {
            
            insert individualsToInsert;
            
        }
        
     
        //for(Individual ind : individualsToInsert) {
   
            for(sobject s : sobjects) {
                
                sObject sObjToUpdate;

                    if(string.valueOf(s.Id).startswith(CONSTANTS.CONTACT_OBJECT_PREFIX) &&
                            //s.get('FirstName') == ind.FirstName && s.get('LastName') == ind.LastName) {
                            mapSobjIndividual.containsKey(s.Id)) {

                        sObjToUpdate = Schema.getGlobalDescribe().get('Contact').newSObject() ;
                        sObjToUpdate = new Contact(Id = s.Id, IndividualId = mapSobjIndividual.get(s.Id).Id);
                        sobj.add(sObjToUpdate);
                    }

                    else if(string.valueOf(s.Id).startswith(CONSTANTS.LEAD_OBJECT_PREFIX) &&
                            //s.get('FirstName') == ind.FirstName && s.get('LastName') == ind.LastName) {
                            mapSobjIndividual.containsKey(s.Id)) {

                        sObjToUpdate = Schema.getGlobalDescribe().get('Lead').newSObject() ;
                        sObjToUpdate = new Lead(Id = s.Id, IndividualId = mapSobjIndividual.get(s.Id).Id);
                        sobj.add(sObjToUpdate);  
                    }
                    
      
                }
  
        //}
        
        if(!sobj.isEmpty())
            update sobj;
        
         if(!individualsToInsert.isEmpty()) {
            IndividualTriggerHandler.createIndividualConsent(sobj);
         }  
    }
    
    
    public static void createCurrentConsent(List<Contact> contactsList, Map<Id,Contact> oldContactMap) {
        
        for(Contact c : contactsList) {
            
            if(c.IndividualId != null && c.Individual.Total_Current_Consent__c == 0 && c.Individual.Total_Current_Consent__c != null) {
                
                contactWithNoCurrentConsent.add(c);
                
            }
            
            else if(c.IndividualId != null && c.Individual.Total_Current_Consent__c != 0 && c.Individual.Total_Current_Consent__c != null) {
                
                contactWithCurrentConsent.add(c);
            }
        }
        
        if(!contactWithNoCurrentConsent.isEmpty()) {
            
            IndividualTriggerHandler.createIndividualConsent(contactWithNoCurrentConsent);
        }
        
        if(!contactWithCurrentConsent.isEmpty()) {
            
            updateConsentRecord(contactWithCurrentConsent, oldContactMap);
        }
    }
    
    public static void updateConsentRecord(List<Contact> contactsList, Map<Id,Contact> oldContactMap) {
        
        Set<Id> individualIds = new Set<Id>();
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        List<Current_Consent__c> currentConsentToUpdate = new List<Current_Consent__c>();
        boolean consentUpdated = false;
        
        for(Contact c : contactsList) {
            
            individualIds.add(c.IndividualId);
            contactMap.put(c.IndividualId,c);
            
        }
        
        List<Current_Consent__c> ccList = [select Individual__c, Communication_Type__c, Email_Consent__c, Email_Consent_Last_Modified__c, Email_Consent_Notes__c, Email_Consent_Updated_By_User__c,
                                                  Phone_Consent__c, Phone_Consent_Last_Modified__c, Phone_Consent_Notes__c, Phone_Consent_Updated_By_User__c 
                                                  from Current_Consent__c
                                                  where Individual__c in: individualIds];
                                                  
         for(Current_Consent__c cc : ccList) {
            
            if(!contactMap.isEmpty() && cc.Individual__c != null && contactMap.get(cc.Individual__c) != null) {
            
            //corporate annoucements
                if(!oldContactMap.isEmpty() && contactMap.get(cc.Individual__c).Corp_E_Consent__c != oldContactMap.get(contactMap.get(cc.Individual__c).Id).Corp_E_Consent__c &&
                   cc.Communication_Type__c == 'Corporate announcements') {
                   
                    cc.Email_Consent__c = contactMap.get(cc.Individual__c).Corp_E_Consent__c;
                    cc.Email_Consent_Last_Modified__c = contactMap.get(cc.Individual__c).Corp_E_Consent_LU__c;
                    cc.Email_Consent_Notes__c = contactMap.get(cc.Individual__c).Corp_E_Consent_NT__c;
                    cc.Email_Consent_Updated_By_User__c = contactMap.get(cc.Individual__c).Corp_E_Consent_USR__c;
                    consentUpdated = true;
                    
                       
                }
                
                if(!oldContactMap.isEmpty() && contactMap.get(cc.Individual__c).Corp_P_Consent__c != oldContactMap.get(contactMap.get(cc.Individual__c).Id).Corp_P_Consent__c &&
                   cc.Communication_Type__c == 'Corporate announcements') {
                    
                    cc.Phone_Consent__c= contactMap.get(cc.Individual__c).Corp_P_Consent__c;
                    cc.Phone_Consent_Last_Modified__c = contactMap.get(cc.Individual__c).Corp_P_Consent_LU__c;
                    cc.Phone_Consent_Notes__c = contactMap.get(cc.Individual__c).Corp_P_Consent_NT__c;
                    cc.Phone_Consent_Updated_By_User__c = contactMap.get(cc.Individual__c).Corp_P_Consent_USR__c;
                    consentUpdated = true;
                      
                }
                
                //Product and solution updates
                if(!oldContactMap.isEmpty() && contactMap.get(cc.Individual__c).PrdSol_E_Consent__c != oldContactMap.get(contactMap.get(cc.Individual__c).Id).PrdSol_E_Consent__c &&
                   cc.Communication_Type__c == 'Product and solution updates') {
                   
                    cc.Email_Consent__c = contactMap.get(cc.Individual__c).PrdSol_E_Consent__c;
                    cc.Email_Consent_Last_Modified__c = contactMap.get(cc.Individual__c).PrdSol_E_Consent_LU__c;
                    cc.Email_Consent_Notes__c = contactMap.get(cc.Individual__c).PrdSol_E_Consent_NT__c;
                    cc.Email_Consent_Updated_By_User__c = contactMap.get(cc.Individual__c).PrdSol_E_Consent_USR__c;
                    consentUpdated = true;
                    
                       
                }
                
                if(!oldContactMap.isEmpty() && contactMap.get(cc.Individual__c).PrdSol_P_Consent__c != oldContactMap.get(contactMap.get(cc.Individual__c).Id).PrdSol_P_Consent__c &&
                   cc.Communication_Type__c == 'Product and solution updates') {
                    
                    cc.Phone_Consent__c= contactMap.get(cc.Individual__c).PrdSol_P_Consent__c;
                    cc.Phone_Consent_Last_Modified__c = contactMap.get(cc.Individual__c).PrdSol_P_Consent_LU__c;
                    cc.Phone_Consent_Notes__c = contactMap.get(cc.Individual__c).PrdSol_P_Consent_NT__c;
                    cc.Phone_Consent_Updated_By_User__c = contactMap.get(cc.Individual__c).PrdSol_P_Consent_USR__c;
                    consentUpdated = true;
                      
                }
                
                //Finastra events
                if(!oldContactMap.isEmpty() && contactMap.get(cc.Individual__c).FinEv_E_Consent__c != oldContactMap.get(contactMap.get(cc.Individual__c).Id).FinEv_E_Consent__c &&
                   cc.Communication_Type__c == 'Finastra events') {
                   
                    cc.Email_Consent__c = contactMap.get(cc.Individual__c).FinEv_E_Consent__c;
                    cc.Email_Consent_Last_Modified__c = contactMap.get(cc.Individual__c).FinEv_E_Consent_LU__c;
                    cc.Email_Consent_Notes__c = contactMap.get(cc.Individual__c).FinEv_E_Consent_NT__c;
                    cc.Email_Consent_Updated_By_User__c = contactMap.get(cc.Individual__c).FinFv_E_Consent_USR__c;
                    consentUpdated = true;
                    
                       
                }
                
                if(!oldContactMap.isEmpty() && contactMap.get(cc.Individual__c).PrdSol_P_Consent__c != oldContactMap.get(contactMap.get(cc.Individual__c).Id).PrdSol_P_Consent__c &&
                   cc.Communication_Type__c == 'Finastra events') {
                    
                    cc.Phone_Consent__c= contactMap.get(cc.Individual__c).FinEv_P_Consent__c;
                    cc.Phone_Consent_Last_Modified__c = contactMap.get(cc.Individual__c).FinEv_P_Consent_LU__c;
                    cc.Phone_Consent_Notes__c = contactMap.get(cc.Individual__c).FinEv_P_Consent_NT__c;
                    cc.Phone_Consent_Updated_By_User__c = contactMap.get(cc.Individual__c).FinEv_P_Consent_USR__c;
                    consentUpdated = true;
                      
                }
                
                //Industry news
                if(!oldContactMap.isEmpty() && contactMap.get(cc.Individual__c).Ind_E_Consent__c != oldContactMap.get(contactMap.get(cc.Individual__c).Id).Ind_E_Consent__c &&
                   cc.Communication_Type__c == 'Industry news') {
                   
                    cc.Email_Consent__c = contactMap.get(cc.Individual__c).Ind_E_Consent__c;
                    cc.Email_Consent_Last_Modified__c = contactMap.get(cc.Individual__c).Ind_E_Consent_LU__c;
                    cc.Email_Consent_Notes__c = contactMap.get(cc.Individual__c).Ind_E_Consent_NT__c;
                    cc.Email_Consent_Updated_By_User__c = contactMap.get(cc.Individual__c).Ind_E_Consent_USR__c;
                    consentUpdated = true;
                    
                       
                }
                
                if(!oldContactMap.isEmpty() && contactMap.get(cc.Individual__c).Ind_P_Consent__c != oldContactMap.get(contactMap.get(cc.Individual__c).Id).Ind_P_Consent__c &&
                   cc.Communication_Type__c == 'Industry news') {
                    
                    cc.Phone_Consent__c= contactMap.get(cc.Individual__c).Ind_P_Consent__c;
                    cc.Phone_Consent_Last_Modified__c = contactMap.get(cc.Individual__c).Ind_P_Consent_LU__c;
                    cc.Phone_Consent_Notes__c = contactMap.get(cc.Individual__c).Ind_P_Consent_NT__c;
                    cc.Phone_Consent_Updated_By_User__c = contactMap.get(cc.Individual__c).Ind_P_Consent_USR__c;
                    consentUpdated = true;
                      
                }
                
                //Market and analyst reports
                if(!oldContactMap.isEmpty() && contactMap.get(cc.Individual__c).Rep_E_Consent__c != oldContactMap.get(contactMap.get(cc.Individual__c).Id).Rep_E_Consent__c &&
                   cc.Communication_Type__c == 'Market and analyst reports') {
                   
                    cc.Email_Consent__c = contactMap.get(cc.Individual__c).Rep_E_Consent__c;
                    cc.Email_Consent_Last_Modified__c = contactMap.get(cc.Individual__c).Rep_E_Consent_LU__c;
                    cc.Email_Consent_Notes__c = contactMap.get(cc.Individual__c).Rep_E_Consent_NT__c;
                    cc.Email_Consent_Updated_By_User__c = contactMap.get(cc.Individual__c).Rep_E_Consent_USR__c;
                    consentUpdated = true;
                    
                       
                }
                
                if(!oldContactMap.isEmpty() && contactMap.get(cc.Individual__c).Ind_P_Consent__c != oldContactMap.get(contactMap.get(cc.Individual__c).Id).Ind_P_Consent__c &&
                   cc.Communication_Type__c == 'Market and analyst reports') {
                    
                    cc.Phone_Consent__c= contactMap.get(cc.Individual__c).Rep_P_Consent__c;
                    cc.Phone_Consent_Last_Modified__c = contactMap.get(cc.Individual__c).Rep_P_Consent_LU__c;
                    cc.Phone_Consent_Notes__c = contactMap.get(cc.Individual__c).Rep_P_Consent_NT__c;
                    cc.Phone_Consent_Updated_By_User__c = contactMap.get(cc.Individual__c).Rep_P_Consent_USR__c;
                    consentUpdated = true;
                      
                }
            } 
             
             if(consentUpdated) {
                
                currentConsentToUpdate.add(cc);
             }
         }                                            
         
        if(!currentConsentToUpdate.isEmpty()) {
            
            update currentConsentToUpdate;
        }                                               
                                                  
    }
    
    
}