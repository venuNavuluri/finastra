/**
 * @author  Steve Fouracre, Tony Bave
 * @Jira    RBX-332
 * Example Post-Processor class for BatchDML. Created for test purposes.
 */
public class BatchDMLPostProcessor implements BatchDMLPostProcessorInterface {

    public static String MESSAGE_TYPE = 'DML Post Processing';
    public static String COMPLETION_MESSAGE = 'Post Processing Complete';

    /**
     * @Jira RBX-332
     * Called from BatchDML after batch processing is finished. Used to perform any post-processing required.
     * This example performs no function other than debug and monitoring messages.
     *
     * @param batchDML  the BatchDML object
     */
    public void performPostProcessing( BatchDML batchDML ) {
        UtilsMonitoring.setupMonitoring();
        System.debug('### Post-Processing... ');
        if (batchDML != null) {
            System.debug('### DML Operation was : '+batchDML.dmlType);
            System.debug('### Total Number of records : '+batchDML.allRecords.size());
            System.debug('### Number of batches : '+batchDML.batchCount);
            System.debug('### Number of failed batches : '+batchDML.failedBatchCount);
            System.debug('### Number of records with errors : '+batchDML.dmlErrors.size());
            System.debug('### Errors are : '+batchDML.dmlErrors);
        }
        System.debug('### Post-Processing Complete');
        UtilsMonitoring.buildMonitoringMessage(BatchDMLPostProcessor.class, MESSAGE_TYPE, COMPLETION_MESSAGE, null);
        UtilsMonitoring.saveMonitoringMessages();
    }

}