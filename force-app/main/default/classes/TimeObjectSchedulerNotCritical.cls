global class TimeObjectSchedulerNotCritical implements Schedulable
{
    global void execute(SchedulableContext ctx)
    {
        String ProcessMe = 'true';
        String PriorityVal = 'Critical';
        String SeverityVal = '1 - Critical';
        String strQuery = 'Select Id, Process_Me__c, AccountId, CreatedDate, ClosedDate, Time_Object__c, SLA__c, IsClosed, '
            + 'Priority, Severity__c, Case_Category__c, Status, Category__c, Sub_status__c, Business_Hours_in_Use__c, MetricsStatus__c, '
            + 'Business_Hours_in_Use__r.Business_Hours__c, Business_Hours_in_Use__r.Normal_Working_Day_Length__c, ' 
            + 'Original_Priority__c, Original_SLA__c, Original_Business_Hours_in_Use__c, Workaround_Time_Stamp__c, '
            + 'Original_Business_Hours_in_Use__r.Business_Hours__c, Original_Business_Hours_in_Use__r.Normal_Working_Day_Length__c '
            //+ 'from Case where Time_Object__c != null and Process_Me__c = \'' + ProcessMe + '\' and Priority != \'' + PriorityVal + '\'';
            + 'from Case where Time_Object__c != null and Process_Me__c = \'' + ProcessMe + '\' and Severity__c != \'' + SeverityVal + '\'';
        
        TimeObjectBatchable b = new TimeObjectBatchable(strQuery);
        System.debug('------------------Called Scheduler------------------' + strQuery);
        try
        {
            Database.executeBatch(b);
        }
        catch(Exception e)
        {
            System.debug('------------------Exception Scheduler------------------'+e.getMessage());
        }
    }
    
    //Test Methods in class test_TimeObjectBatchable
}