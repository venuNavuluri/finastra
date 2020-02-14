global class ScheduledJobKiller2 implements Database.Batchable<sObject>
{
    global final String Query;
    
    public ScheduledJobKiller2(/*DateTime dt*/)
    {
        Query = 'Select c.State, c.Id, c.CreatedDate' +
            ' From CronTrigger c' +
            ' where State = \'DELETED\'' +
            ' order by CreatedDate' +
            ' limit 150';
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        for(Sobject s : scope) {
            CronTrigger ct = (CronTrigger)s;
            System.abortJob(ct.Id);
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }

    
    global void finish(Database.BatchableContext BC)
    {
    }
}