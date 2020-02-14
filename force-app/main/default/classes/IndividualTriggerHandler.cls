public class IndividualTriggerHandler {
    
    public static set<Id> sobjectIds = new set<Id>();
   	
    public static void createIndividualConsent(List<Sobject> sobjectList) {
    	
    	string sobj;
    	for(sobject s : sobjectList) {
    		
    		system.debug('Here in the loop...'+s.Id);
    		if(string.valueOf(s.Id).startswith(CONSTANTS.CONTACT_OBJECT_PREFIX)) {
    			
    			sobj = 'Contact';
    		}
    		else {
    			
    			sobj = 'Lead';
    		}
    		system.debug('sobject idsss....'+sobjectIds);        
    		sobjectIds.add(s.Id);
    	}
    	system.debug('sobjList....'+sobjectList);    
    	string queryString = 'select Id, IndividualId , Corp_E_Consent__c, Corp_E_Consent_DL__c, Corp_E_Consent_NT__c,'; 
	           queryString += 'Corp_P_Consent__c, Corp_P_Consent_DL__c, Corp_P_Consent_NT__c,';
	           queryString += 'Rep_E_Consent__c, Rep_E_Consent_DL__c, Rep_E_Consent_NT__c,';
	           queryString += 'Rep_P_Consent__c, Rep_P_Consent_DL__c, Rep_P_Consent_NT__c,';
	           queryString += 'PrdSol_E_Consent__c, PrdSol_E_Consent_DL__c, PrdSol_E_Consent_NT__c,';
	           queryString += 'PrdSol_P_Consent__c, PrdSol_P_Consent_DL__c, PrdSol_P_Consent_NT__c,';
	           queryString += 'Ind_E_Consent__c, Ind_E_Consent_DL__c, Ind_E_Consent_NT__c,';
	           queryString += 'Ind_P_Consent__c, Ind_P_Consent_DL__c, Ind_P_Consent_NT__c,';
	           queryString += 'FinEv_E_Consent__c, FinEv_E_Consent_DL__c, FinEv_E_Consent_NT__c,';
	           queryString += 'FinEv_P_Consent__c, FinEv_P_Consent_DL__c, FinEv_P_Consent_NT__c from ';
	           queryString += sobj+ ' where Id in: sobjectIds';
	    system.debug('Query string....'+queryString);    
	    List<Sobject> sobjs = database.query(queryString);
	                            
	    createIndividualCurrentConsent(sobjs);
	  
    }
    
    public static void createIndividualCurrentConsent(List<sobject> sobjects) {
        
        List<Current_Consent__c> individualCurrentConsetToInsert = new List<Current_Consent__c>();
        
        for(sobject s: sobjects) {

            individualCurrentConsetToInsert = createIndividualConsentRecord(individualCurrentConsetToInsert, 'Corporate announcements', s);
            individualCurrentConsetToInsert = createIndividualConsentRecord(individualCurrentConsetToInsert, 'Product and solution updates', s);
            individualCurrentConsetToInsert = createIndividualConsentRecord(individualCurrentConsetToInsert, 'Finastra events', s);
            individualCurrentConsetToInsert = createIndividualConsentRecord(individualCurrentConsetToInsert, 'Industry news', s);
            individualCurrentConsetToInsert = createIndividualConsentRecord(individualCurrentConsetToInsert, 'Market and analyst reports', s);
            
        }
        
        insert individualCurrentConsetToInsert;
    } 
    
    public static List<Current_Consent__c> createIndividualConsentRecord(List<Current_Consent__c> individualCurrentConsetToInsert, String CommType, sobject s) {
    	
    	 
        Current_Consent__c indCurrentConsent = new Current_Consent__c();
            
    	if(CommType == 'Corporate announcements') {
    		
    		indCurrentConsent.Communication_Type__c = 'Corporate announcements';
    		indCurrentConsent.put('Individual__c',s.get('IndividualId'));
	        indCurrentConsent.put('Email_Consent__c',s.get('Corp_E_Consent__c'));
	        indCurrentConsent.put('Email_Consent_Expiry_Date__c',s.get('Corp_E_Consent_DL__c'));
	        indCurrentConsent.put('Email_Consent_Notes__c',s.get('Corp_E_Consent_NT__c')); 
    		indCurrentConsent.put('Phone_Consent__c', s.get('Corp_P_Consent__c'));
	        indCurrentConsent.put('Phone_Consent_Expiry_Date__c',s.get('Corp_P_Consent_DL__c'));
	        indCurrentConsent.put('Phone_Consent_Notes__c',s.get('Corp_P_Consent_NT__c'));
    	}
    	
    	if(CommType == 'Product and solution updates') {
    		
    		indCurrentConsent.Communication_Type__c = 'Product and solution updates';
    		indCurrentConsent.put('Individual__c',s.get('IndividualId'));
    		indCurrentConsent.put('Email_Consent__c',s.get('PrdSol_E_Consent__c'));
	        indCurrentConsent.put('Email_Consent_Expiry_Date__c',s.get('PrdSol_E_Consent_DL__c'));
	        indCurrentConsent.put('Email_Consent_Notes__c',s.get('PrdSol_E_Consent_NT__c')); 
    		
    		indCurrentConsent.put('Phone_Consent__c',s.get('PrdSol_P_Consent__c'));
	        indCurrentConsent.put('Phone_Consent_Expiry_Date__c', s.get('PrdSol_P_Consent_DL__c'));
	        indCurrentConsent.put('Phone_Consent_Notes__c',s.get('PrdSol_P_Consent_NT__c'));
       	}
    	
    	if(CommType == 'Finastra events') {
    		
    		indCurrentConsent.Communication_Type__c = 'Finastra events';
    		indCurrentConsent.put('Individual__c',s.get('IndividualId'));
	        indCurrentConsent.put('Email_Consent__c',s.get('FinEv_E_Consent__c'));
	        indCurrentConsent.put('Email_Consent_Expiry_Date__c',s.get('FinEv_E_Consent_DL__c'));
	        indCurrentConsent.put('Email_Consent_Notes__c',s.get('FinEv_E_Consent_NT__c')); 
    	  
    	    indCurrentConsent.put('Phone_Consent__c',s.get('FinEv_P_Consent__c'));
	        indCurrentConsent.put('Phone_Consent_Expiry_Date__c',s.get('FinEv_P_Consent_DL__c'));
	        indCurrentConsent.put('Phone_Consent_Notes__c',s.get('FinEv_P_Consent_NT__c'));
      	}
    	
    	if(CommType == 'Industry news') {
    		
    		indCurrentConsent.Communication_Type__c = 'Industry news';
    		indCurrentConsent.put('Individual__c',s.get('IndividualId'));
            indCurrentConsent.put('Email_Consent__c',s.get('Ind_E_Consent__c'));
            indCurrentConsent.put('Email_Consent_Expiry_Date__c',s.get('Ind_E_Consent_DL__c'));
            indCurrentConsent.put('Email_Consent_Notes__c',s.get('Ind_E_Consent_NT__c')); 
		
            indCurrentConsent.put('Phone_Consent__c',s.get('Ind_P_Consent__c'));
            indCurrentConsent.put('Phone_Consent_Expiry_Date__c',s.get('Ind_P_Consent_DL__c'));
            indCurrentConsent.put('Phone_Consent_Notes__c',s.get('Ind_P_Consent_NT__c'));
    	}
    	
    	if(CommType == 'Market and analyst reports') {
    		
    		indCurrentConsent.Communication_Type__c = 'Market and analyst reports';
    		indCurrentConsent.put('Individual__c',s.get('IndividualId'));
			indCurrentConsent.put('Email_Consent__c',s.get('Rep_E_Consent__c'));
            indCurrentConsent.put('Email_Consent_Expiry_Date__c', s.get('Rep_E_Consent_DL__c'))	;
            indCurrentConsent.put('Email_Consent_Notes__c',s.get('Rep_E_Consent_NT__c')); 
	
            indCurrentConsent.put('Phone_Consent__c',s.get('Rep_P_Consent__c'));
            indCurrentConsent.put('Phone_Consent_Expiry_Date__c',s.get('Rep_P_Consent_DL__c'));
            indCurrentConsent.put('Phone_Consent_Notes__c',s.get('Rep_P_Consent_NT__c'));
      	}
    	
    	individualCurrentConsetToInsert.add(indCurrentConsent);
    	return individualCurrentConsetToInsert;
    }
}