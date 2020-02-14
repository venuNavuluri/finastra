public class LeadTriggerHandler {
    
    public static List<Lead> leadWithNoCurrentConsent = new List<Lead>();
    public static List<Lead> leadWithCurrentConsent = new List<Lead>(); 
    
    public static void createCurrentConsent(List<lead> leadsList, Map<Id,Lead> oldLeadMap) {
        
        for(Lead l : leadsList) {
            
            if(l.IndividualId != null && l.Individual.Total_Current_Consent__c == 0 && l.Individual.Total_Current_Consent__c != null) {
                
                leadWithNoCurrentConsent.add(l);
                
            }
            
            else if(l.IndividualId != null && l.Individual.Total_Current_Consent__c != 0 && l.Individual.Total_Current_Consent__c != null) {
                
                leadWithCurrentConsent.add(l);
            }
        }
        
        if(!leadWithNoCurrentConsent.isEmpty()) {
            
            IndividualTriggerHandler.createIndividualConsent(leadWithNoCurrentConsent);
        }
        
        if(!leadWithCurrentConsent.isEmpty()) {
            
            updateConsentRecord(leadWithCurrentConsent, oldLeadMap);
        }
    }
    
    public static void updateConsentRecord(List<Lead> leadsList, Map<Id,Lead> oldLeadMap) {
        
        Set<Id> individualIds = new Set<Id>();
        Map<Id,Lead> leadMap = new Map<Id,Lead>();
        List<Current_Consent__c> currentConsentToUpdate = new List<Current_Consent__c>();
        boolean consentUpdated = false;
        
        for(Lead l : leadsList) {
            
            individualIds.add(l.IndividualId);
            leadMap.put(l.IndividualId,l);
            
        }
        
        List<Current_Consent__c> ccList = [select Individual__c, Communication_Type__c, Email_Consent__c, Email_Consent_Last_Modified__c, Email_Consent_Notes__c, Email_Consent_Updated_By_User__c,
                                                  Phone_Consent__c, Phone_Consent_Last_Modified__c, Phone_Consent_Notes__c, Phone_Consent_Updated_By_User__c 
                                                  from Current_Consent__c
                                                  where Individual__c in: individualIds];
                                                  
         for(Current_Consent__c cc : ccList) {
            
            if(!leadMap.isEmpty() && cc.Individual__c != null && leadMap.get(cc.Individual__c) != null) {
            //corporate annoucements
                if(!oldLeadMap.isEmpty() && leadMap.get(cc.Individual__c).Corp_E_Consent__c != oldLeadMap.get(leadMap.get(cc.Individual__c).Id).Corp_E_Consent__c &&
                   cc.Communication_Type__c == 'Corporate announcements') {
                   
                    cc.Email_Consent__c = leadMap.get(cc.Individual__c).Corp_E_Consent__c;
                    cc.Email_Consent_Last_Modified__c = leadMap.get(cc.Individual__c).Corp_E_Consent_LU__c;
                    cc.Email_Consent_Notes__c = leadMap.get(cc.Individual__c).Corp_E_Consent_NT__c;
                    cc.Email_Consent_Updated_By_User__c = leadMap.get(cc.Individual__c).Corp_E_Consent_USR__c;
                    consentUpdated = true;
                    
                       
                }
                
                if(!oldLeadMap.isEmpty() && leadMap.get(cc.Individual__c).Corp_P_Consent__c != oldLeadMap.get(leadMap.get(cc.Individual__c).Id).Corp_P_Consent__c &&
                   cc.Communication_Type__c == 'Corporate announcements') {
                    
                    cc.Phone_Consent__c= leadMap.get(cc.Individual__c).Corp_P_Consent__c;
                    cc.Phone_Consent_Last_Modified__c = leadMap.get(cc.Individual__c).Corp_P_Consent_LU__c;
                    cc.Phone_Consent_Notes__c = leadMap.get(cc.Individual__c).Corp_P_Consent_NT__c;
                    cc.Phone_Consent_Updated_By_User__c = leadMap.get(cc.Individual__c).Corp_P_Consent_USR__c;
                    consentUpdated = true;
                      
                }
                
                //Product and solution updates
                if(!oldLeadMap.isEmpty() && leadMap.get(cc.Individual__c).PrdSol_E_Consent__c != oldLeadMap.get(leadMap.get(cc.Individual__c).Id).PrdSol_E_Consent__c &&
                   cc.Communication_Type__c == 'Product and solution updates') {
                   
                    cc.Email_Consent__c = leadMap.get(cc.Individual__c).PrdSol_E_Consent__c;
                    cc.Email_Consent_Last_Modified__c = leadMap.get(cc.Individual__c).PrdSol_E_Consent_LU__c;
                    cc.Email_Consent_Notes__c = leadMap.get(cc.Individual__c).PrdSol_E_Consent_NT__c;
                    cc.Email_Consent_Updated_By_User__c = leadMap.get(cc.Individual__c).PrdSol_E_Consent_USR__c;
                    consentUpdated = true;
                    
                       
                }
                
                if(!oldLeadMap.isEmpty() && leadMap.get(cc.Individual__c).PrdSol_P_Consent__c != oldLeadMap.get(leadMap.get(cc.Individual__c).Id).PrdSol_P_Consent__c &&
                   cc.Communication_Type__c == 'Product and solution updates') {
                    
                    cc.Phone_Consent__c= leadMap.get(cc.Individual__c).PrdSol_P_Consent__c;
                    cc.Phone_Consent_Last_Modified__c = leadMap.get(cc.Individual__c).PrdSol_P_Consent_LU__c;
                    cc.Phone_Consent_Notes__c = leadMap.get(cc.Individual__c).PrdSol_P_Consent_NT__c;
                    cc.Phone_Consent_Updated_By_User__c = leadMap.get(cc.Individual__c).PrdSol_P_Consent_USR__c;
                    consentUpdated = true;
                      
                }
                
                //Finastra events
                if(!oldLeadMap.isEmpty() && leadMap.get(cc.Individual__c).FinEv_E_Consent__c != oldLeadMap.get(leadMap.get(cc.Individual__c).Id).FinEv_E_Consent__c &&
                   cc.Communication_Type__c == 'Finastra events') {
                   
                    cc.Email_Consent__c = leadMap.get(cc.Individual__c).FinEv_E_Consent__c;
                    cc.Email_Consent_Last_Modified__c = leadMap.get(cc.Individual__c).FinEv_E_Consent_LU__c;
                    cc.Email_Consent_Notes__c = leadMap.get(cc.Individual__c).FinEv_E_Consent_NT__c;
                    cc.Email_Consent_Updated_By_User__c = leadMap.get(cc.Individual__c).FinEv_E_Consent_USR__c;
                    consentUpdated = true;
                    
                       
                }
                
                if(!oldLeadMap.isEmpty() && leadMap.get(cc.Individual__c).PrdSol_P_Consent__c != oldLeadMap.get(leadMap.get(cc.Individual__c).Id).PrdSol_P_Consent__c &&
                   cc.Communication_Type__c == 'Finastra events') {
                    
                    cc.Phone_Consent__c= leadMap.get(cc.Individual__c).FinEv_P_Consent__c;
                    cc.Phone_Consent_Last_Modified__c = leadMap.get(cc.Individual__c).FinEv_P_Consent_LU__c;
                    cc.Phone_Consent_Notes__c = leadMap.get(cc.Individual__c).FinEv_P_Consent_NT__c;
                    cc.Phone_Consent_Updated_By_User__c = leadMap.get(cc.Individual__c).FinEv_P_Consent_USR__c;
                    consentUpdated = true;
                      
                }
                
                //Industry news
                if(!oldLeadMap.isEmpty() && leadMap.get(cc.Individual__c).Ind_E_Consent__c != oldLeadMap.get(leadMap.get(cc.Individual__c).Id).Ind_E_Consent__c &&
                   cc.Communication_Type__c == 'Industry news') {
                   
                    cc.Email_Consent__c = leadMap.get(cc.Individual__c).Ind_E_Consent__c;
                    cc.Email_Consent_Last_Modified__c = leadMap.get(cc.Individual__c).Ind_E_Consent_LU__c;
                    cc.Email_Consent_Notes__c = leadMap.get(cc.Individual__c).Ind_E_Consent_NT__c;
                    cc.Email_Consent_Updated_By_User__c = leadMap.get(cc.Individual__c).Ind_E_Consent_USR__c;
                    consentUpdated = true;
                    
                       
                }
                
                if(!oldLeadMap.isEmpty() && leadMap.get(cc.Individual__c).Ind_P_Consent__c != oldLeadMap.get(leadMap.get(cc.Individual__c).Id).Ind_P_Consent__c &&
                   cc.Communication_Type__c == 'Industry news') {
                    
                    cc.Phone_Consent__c= leadMap.get(cc.Individual__c).Ind_P_Consent__c;
                    cc.Phone_Consent_Last_Modified__c = leadMap.get(cc.Individual__c).Ind_P_Consent_LU__c;
                    cc.Phone_Consent_Notes__c = leadMap.get(cc.Individual__c).Ind_P_Consent_NT__c;
                    cc.Phone_Consent_Updated_By_User__c = leadMap.get(cc.Individual__c).Ind_P_Consent_USR__c;
                    consentUpdated = true;
                      
                }
                
                //Market and analyst reports
                if(!oldLeadMap.isEmpty() && leadMap.get(cc.Individual__c).Rep_E_Consent__c != oldLeadMap.get(leadMap.get(cc.Individual__c).Id).Rep_E_Consent__c &&
                   cc.Communication_Type__c == 'Market and analyst reports') {
                   
                    cc.Email_Consent__c = leadMap.get(cc.Individual__c).Rep_E_Consent__c;
                    cc.Email_Consent_Last_Modified__c = leadMap.get(cc.Individual__c).Rep_E_Consent_LU__c;
                    cc.Email_Consent_Notes__c = leadMap.get(cc.Individual__c).Rep_E_Consent_NT__c;
                    cc.Email_Consent_Updated_By_User__c = leadMap.get(cc.Individual__c).Rep_E_Consent_USR__c;
                    consentUpdated = true;
                    
                       
                }
                
                if(!oldLeadMap.isEmpty() && leadMap.get(cc.Individual__c).Ind_P_Consent__c != oldLeadMap.get(leadMap.get(cc.Individual__c).Id).Ind_P_Consent__c &&
                   cc.Communication_Type__c == 'Market and analyst reports') {
                    
                    cc.Phone_Consent__c= leadMap.get(cc.Individual__c).Rep_P_Consent__c;
                    cc.Phone_Consent_Last_Modified__c = leadMap.get(cc.Individual__c).Rep_P_Consent_LU__c;
                    cc.Phone_Consent_Notes__c = leadMap.get(cc.Individual__c).Rep_P_Consent_NT__c;
                    cc.Phone_Consent_Updated_By_User__c = leadMap.get(cc.Individual__c).Rep_P_Consent_USR__c;
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