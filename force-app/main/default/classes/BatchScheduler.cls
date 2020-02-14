global class BatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc){
         database.executeBatch(new ScheduledJobKiller2());
    }
    
    public static void RunJob()
    {
        System.schedule('ScheduledJobKiller2', '0 0 * * * ?', new BatchScheduler());
    } 
}