global class POCreationBatchScheduled implements Schedulable {
    global void execute(SchedulableContext ctx) {
        POCreationBatch PO = new POCreationBatch();
        Database.executeBatch(PO,200);
    }
}