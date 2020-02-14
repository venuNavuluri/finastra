global class UpdateOpptyScheduleInBatch //implements Database.Batchable<sObject>
{
	/*********** JRB - Apr 6, 2011
	************ Deactivated this process and re-implemented as a Future process
	************ This was done to prevent errors that occured on Opportunity edit due to too many pending Batch Apex jobs 
	
	global final String Query;
	global Integer iMonthBtw;

	global UpdateOpptyScheduleInBatch(String q, Integer iMonthD)
	{
		Query = q;
		system.debug('Nitin----Query-->'+Query);
		iMonthBtw = iMonthD;
		system.debug('Nitin----iMonthBtw-->'+iMonthBtw);
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
	{   		
		return Database.getQueryLocator(query);
	}

   global void execute(Database.BatchableContext BC, List<sObject> scope)
   {
   		List<OpportunityLineItemSchedule> lOpptyLineItemSchedule = new List<OpportunityLineItemSchedule>();
		for(sObject s : scope)
		{
			OpportunityLineItemSchedule obj = (OpportunityLineItemSchedule)s;
      		system.debug('Nitin---Obj 1--->'+obj);
      		obj.ScheduleDate = obj.ScheduleDate.addMonths(iMonthBtw);
      		system.debug('Nitin---Obj 2--->'+obj);
			lOpptyLineItemSchedule.add(obj);
		}
		system.debug('Nitin------>'+lOpptyLineItemSchedule.size());
		if(lOpptyLineItemSchedule.size() > 0)
			update lOpptyLineItemSchedule;
   }
   global void finish(Database.BatchableContext BC)
   {
	   system.debug('--------------------------------Finally Success in Scheduler----------------------------');
   }
   //@istest
	public static testmethod void testUpdateContactInBatch()
	{
		Test.StartTest();
		\ *
		Account A = [Select eRx_Customer_Type__c,Client_Type__c from Account limit 1];
		A.Client_Type__c = 'ePrescribe';
		A.eRx_Customer_Type__c = 'Platinum Basic';
		update A;
		List<ID> AccID = new List<ID>();		
		AccID.add(A.Id);
		String qStr = 'Select c.Do_Not_Solicit__c, c.Do_Not_Mail__c, c.AccountId From Contact c where AccountId in ';
    	String str = '(';
    	for(ID ids:AccID)
    		str += '\'' + ids +'\',';
    	str = str.substring(0,str.length()-1) + ')';
    	qStr += str;
	 	UpdateOpptyScheduleInBatchimplements b = new UpdateOpptyScheduleInBatchimplements(qStr);
	 	database.executebatch(b); * /
		Test.StopTest();
	}
	
	********************************/
}