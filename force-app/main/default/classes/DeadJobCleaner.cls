global class DeadJobCleaner implements Schedulable
{

    global void execute(SchedulableContext sc)
    {
         database.executeBatch(new ScheduledJobKiller2());
    }
    
}