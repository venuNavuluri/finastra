global class TimeObjectBatchable implements Database.Batchable<sObject>
{
   	String Query;
   	
   	global TimeObjectBatchable(String q)
   	{	
    	Query = q;
    	system.debug('XXXXXXXXXXXX_Constructor  Query: '+Query);
   	}
   	
   	global Database.QueryLocator start(Database.BatchableContext BC)
   	{        
   		system.debug('XXXXXXXXXXXX_startBatch  Query: '+Query);
   		return Database.getQueryLocator(Query);
   	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope)
   	{
    	try
        {
        	System.debug('----------------------------Size------------------------' + scope.size());
            //Call the TimeCalculator funtion with the list of cases for this batch
            TimeCalculator.CalculateTimesBatch(scope);
            System.debug('--------------------------------Success in Scheduler----------------------------');
        }
        catch(Exception e)
        {
        	System.debug('--------------------------------Exception in Scheduler----------------------------');
            CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),'Scheduled Apex job failure','TimeObjectBatchable',e);
        }
   	}
   
   	global void finish(Database.BatchableContext BC)
   	{
    	System.debug('--------------------------------Finally Success in Scheduler----------------------------');
   	}
}