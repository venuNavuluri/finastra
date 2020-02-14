public class CAPIAcctProfileTriggerHandler {
	
	static set<Id> accIds = new set<Id>();
	static List<Account> accListToUpdate = new List<Account>();
    
    public static void updateTAMCategory(List<Acct_Profile__c> accProfileList) {
    	
    	for (Acct_Profile__c acctProf : accProfileList) {
    		
    		if(acctProf.Account__c != null) 
    			accIds.add(acctProf.Account__c);
        }
        
        for(Account a : [select Id, TAM_Category__c, Type from Account where Id in: accIds]) {
        	
        	a.TAM_Category__c = null;
        	accListToUpdate.add(a); 
        }
        
        update accListToUpdate;
    }
    
}