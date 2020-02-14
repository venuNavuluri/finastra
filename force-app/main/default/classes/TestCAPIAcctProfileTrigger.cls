@isTest
public class TestCAPIAcctProfileTrigger {
	
	
    public testMethod static void Insert_SALES_TAM() {
    	
    	Account acc = testUtils.getAccount('MS Account');
        acc.Type = 'Prospect';
        acc.CurrencyIsoCode = 'INR';
        insert acc;
    
        Acct_Profile__c TAMRec = new Acct_Profile__c();
        
        TAMRec.Account__c = acc.Id;
        TAMRec.Next_Review_Date__c = System.today();
        TAMRec.Market_opp_CB_commentary__c = 'Equation';
     
        Test.startTest();
        insert TAMRec;
        Test.stopTest();
        
        Account accres = new Account();
		accres = [SELECT Id, Name, TAM_Category__c FROM Account WHERE Id = :acc.Id LIMIT 1];
        
        System.assertEquals('SALES TAM', accres.TAM_Category__c);      
    }
	public testMethod static void Update_SALES_TAM() {
        
        Account acc = testUtils.getAccount('MS Account');
        acc.Type = 'Prospect';
        acc.CurrencyIsoCode = 'INR';
        insert acc;
  
        Acct_Profile__c TAMRec = new Acct_Profile__c();
        
        TAMRec.Account__c = acc.Id;
        TAMRec.Next_Review_Date__c = System.today();

        insert TAMRec;

        TAMRec = [select Id, Account__c, Market_opp_ER_commentary__c 
        		  from Acct_Profile__c WHERE Account__c = :acc.Id LIMIT 1];
        		  
        acc = [SELECT Id, Name, TAM_Category__c FROM Account WHERE Id = :acc.Id LIMIT 1];
         		  
        System.assertEquals(null, acc.TAM_Category__c);  
            		  
        TAMRec.Market_opp_ER_commentary__c = 'IFRS9';
        
        test.startTest();
        update TAMRec;

        test.stopTest();
        
		acc = [SELECT Id, Name, TAM_Category__c FROM Account WHERE Id = :acc.Id LIMIT 1];
   
        System.assertEquals('SALES TAM', acc.TAM_Category__c);      
    }   
    
    public testMethod static void Insert_PM_TAM() {
    	
    	Account acc = testUtils.getAccount('MS Account');
        acc.Type = 'Prospect';
        acc.CurrencyIsoCode = 'INR';
        insert acc;
    
        Acct_Profile__c TAMRec = new Acct_Profile__c();
        
        TAMRec.Account__c = acc.Id;
        TAMRec.Next_Review_Date__c = System.today();
        TAMRec.Suggested_Solution_CM__c = 'Equation';
     
        Test.startTest();
        insert TAMRec;
        Test.stopTest();
        
        Account accres = new Account();
		accres = [SELECT Id, Name, TAM_Category__c FROM Account WHERE Id = :acc.Id LIMIT 1];
        
        System.assertEquals('PM TAM', accres.TAM_Category__c);      
    }
	public testMethod static void Update_PM_TAM() {
        
        Account acc = testUtils.getAccount('MS Account');
        acc.Type = 'Prospect';
        acc.CurrencyIsoCode = 'INR';
        insert acc;
  
        Acct_Profile__c TAMRec = new Acct_Profile__c();
        
        TAMRec.Account__c = acc.Id;
        TAMRec.Next_Review_Date__c = System.today();

        insert TAMRec;

        TAMRec = [select Id, Account__c, Market_opp_ER_commentary__c 
        		  from Acct_Profile__c WHERE Account__c = :acc.Id LIMIT 1];
        		  
        acc = [SELECT Id, Name, TAM_Category__c FROM Account WHERE Id = :acc.Id LIMIT 1];
         		  
        System.assertEquals(null, acc.TAM_Category__c);  
            		  
        TAMRec.Suggested_Solution_CM__c = 'testSolution';
        
        test.startTest();
        update TAMRec;

        test.stopTest();
        
		acc = [SELECT Id, Name, TAM_Category__c FROM Account WHERE Id = :acc.Id LIMIT 1];
   
        System.assertEquals('PM TAM', acc.TAM_Category__c);      
    }   

	public testMethod static void Delete_SALES_TAM() {
        
        Account acc = testUtils.getAccount('MS Account');
        acc.Type = 'Prospect';
        acc.CurrencyIsoCode = 'INR';
        insert acc;
    
        Acct_Profile__c TAMRec = new Acct_Profile__c();
        
        TAMRec.Account__c = acc.Id;
        TAMRec.Next_Review_Date__c = System.today();
        TAMRec.Market_opp_CB_commentary__c = 'Equation';
        insert TAMRec;

        Acct_Profile__c TAMRet = [SELECT Id, Name from Acct_Profile__c WHERE Account__c = :acc.Id LIMIT 1];
        
        test.startTest();
        delete TAMRet;
        test.stopTest();
        
        Account accres = new Account();
		accres = [SELECT Id, Name, TAM_Category__c FROM Account WHERE Id = :acc.Id LIMIT 1];
        
        System.assertEquals(null, accres.TAM_Category__c);      
    }
}