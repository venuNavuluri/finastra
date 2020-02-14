global class MassUpdateEmailAddress implements Database.Batchable<sObject>, Database.Stateful {
	
	private Integer currentBatchChain;
	
    public static void executeDataMaskingJob() {
		MassUpdateEmailAddress mb = new MassUpdateEmailAddress();
		Database.executeBatch(mb, 200);
    }
    
	public MassUpdateEmailAddress() {
		
		currentBatchChain = 1;
	}
	 
	public MassUpdateEmailAddress(Integer chain) {
		
		currentBatchChain = chain;
	}
	 
	global Database.QueryLocator start(Database.BatchableContext BC) {
		
		String qry = '';
		 
		if(currentBatchChain == 1)	{
			
			qry = 'Select Id, Email, Assistant_Email__c, Alternative_Email__c FROM Contact where Email != \'xxx@xxxx.xxx\' AND Alternative_Email__c != \'xxx@xxxx.xxx\'';
		}
		else if(currentBatchChain == 2)	{
			
			qry = 'Select Id, Email, Employee_Email__c, Assistant_Email__c FROM Lead WHERE IsConverted = false AND Email != \'xxx@xxxx.xxx\' AND Employee_Email__c != \'xxx@xxxx.xxx\' AND Assistant_Email__c != \'xxx@xxxx.xxx\'';
		}
		
		if(qry != '' && isSandbox()) { // we do not want to run this in Prod!
			
			return Database.getQueryLocator(qry);
		}
		
		else {
			
			return null;
		}	
	}
	 
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
	   
	   List<Contact> contactsToUpdate = new List<Contact>();
	   List<Lead> leadsToUpdate = new List<Lead>();
	   
	   // for GDPR reasons, just masking customer's email ids
	   if(currentBatchChain == 1) {
	   	
	   	  for( Contact  c: (List<Contact>)scope) {
	   	  	
	   	  	c.Email = !String.isBlank(c.Email) ? 'xxx@xxxx.xxx' : c.Email;
	   	  	c.Alternative_Email__c = !String.isBlank(c.Alternative_Email__c) ? 'xxx@xxxx.xxx' : c.Alternative_Email__c;
	   	  	contactsToUpdate.add(c);
	   	  }
	   }
	   
	   if(currentBatchChain == 2) {
	   		
	   		for( Lead  l: (List<Lead>)scope) {
	   	  	
		   	  	l.Email = !String.isBlank(l.Email) ? 'xxx@xxxx.xxx' : l.Email;
                l.Employee_Email__c = !String.isBlank(l.Employee_Email__c) ? 'xxx@xxxx.xxx' : l.Employee_Email__c;
				l.Assistant_Email__c = !String.isBlank(l.Assistant_Email__c) ? 'xxx@xxxx.xxx' : l.Assistant_Email__c;
		   	  	
		   	  	leadsToUpdate.add(l);
	   	  }	   		
	   }
	   
	   update contactsToUpdate;
       update leadsToUpdate;
	}
	 
	global void finish(Database.BatchableContext BC) {
        if(currentBatchChain == 1) {
			
			MassUpdateEmailAddress mb = new MassUpdateEmailAddress(currentBatchChain+1);
			Database.executeBatch(mb, 200);
		}
	}
    
    public Boolean isSandbox() {
        if(Test.isRunningTest()) {//if tests are run, return true to avoid errorring
            return true;
        }else {
    		return [Select IsSandbox From Organization].IsSandbox;
        }
	} 
}