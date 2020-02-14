public with sharing class CurrentConsentTriggerHandler {
    
    public static Set<Id> indIds = new Set<Id>(); 
    public static Map<Id,Individual> individualMap; 
    public static List<Current_Consent__c> currentConsentList = new List<Current_Consent__c>();
    
    public static void updateTotalConsent(List<Current_Consent__c> currentConsents, boolean isInsert) {
    	
    	for(Current_Consent__c cc: currentConsents) {
    		
    		indIds.add(cc.Individual__c);
    	}
    	
    	individualMap = new Map<Id, Individual>([select Id, Total_Current_Consent__c from Individual where Id in: indIds]);
    	
    	currentConsentList = [select Id from Current_Consent__c where Individual__c in: indIds];
    	
    	for(Current_Consent__c cc: currentConsents) {
    		
    		if(individualMap.get(cc.Individual__c) != null) {
    			
    			if(individualMap.get(cc.Individual__c).Total_Current_Consent__c == null) {
    				 
    				individualMap.get(cc.Individual__c).Total_Current_Consent__c = 0;
    			}
    
				if(isInsert) { 
					
					individualMap.get(cc.Individual__c).Total_Current_Consent__c += 1;
				}
				
				else if(!isInsert && individualMap.get(cc.Individual__c).Total_Current_Consent__c != 0) {
					
					individualMap.get(cc.Individual__c).Total_Current_Consent__c -= 1;
				}		
    				
    		}
    	}
    	
    	if(!individualMap.isEmpty()) {
    		update individualMap.values();
    	}
    }
}