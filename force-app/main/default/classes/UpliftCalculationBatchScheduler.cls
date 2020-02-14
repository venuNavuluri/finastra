global class UpliftCalculationBatchScheduler implements Schedulable {


    // TODO: consider storing this cron exp in a custom setting too to change it in the future w/o
    // code deployment
    public static String CRON_EXP = '0 0 22 * * ?';

    public static String scheduleBatchJob(){
        String jobID = System.schedule('UpliftCalculationBatch', CRON_EXP, new UpliftCalculationBatchScheduler());
        return jobID;
    }
    global void execute(SchedulableContext sc){
        UpliftCalculationBatch job = new UpliftCalculationBatch();
        ID batchprocessid = Database.executeBatch(job);
        // TODo: consider debugging this out to debug log for future prod monitoring
    }

}