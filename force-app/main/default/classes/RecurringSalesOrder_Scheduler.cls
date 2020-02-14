global class RecurringSalesOrder_Scheduler implements Schedulable {
   /* global void execute(SchedulableContext sc) {
        database.executebatch(new RecurringSalesOrder_Batch(), 4);
    }*/
     public static String CRON_EXP = '0 0 0 * * ?';

    public static String scheduleBatchJob(){
        String jobID = System.schedule('RecurringSalesOrder_Batch', CRON_EXP, new RecurringSalesOrder_Scheduler());
        return jobID;
    }
    global void execute(SchedulableContext sc){
        RecurringSalesOrder_Batch job = new RecurringSalesOrder_Batch();
        ID batchprocessid = Database.executeBatch(job);
        // TODo: consider debugging this out to debug log for future prod monitoring
    }

}