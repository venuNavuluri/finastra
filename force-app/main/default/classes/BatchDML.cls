/**
 * @author  Steve Fouracre, Tony Bave
 * @Jira    RBX-332
 * Batch class to perform DML operations.
 * Will be initiated if a call is made to UtilsDML.genericDMLBatch(...)
 * Or when UtilsDML.genericDML(...) is called but the operation is too large to performs synchronously
 *
 */
global class BatchDML implements Database.Batchable<SObject>, Database.Stateful {

    /**
     * The records to be processed
     */
    global SObject[] allRecords;

    /**
     * The DML Operation to be performed
     */
    global UtilsDML.DmlType dmlType;

    /**
     * The results of the DML operations that failed
     */
    global GenericDMLResult[] dmlErrors;

    /**
     * Whether to perform DML in allOrNone mode. If false, allows for partial DML
     * and will collect any DML Errors.
     */
    global Boolean allOrNone;

    /**
     * Whether to record any errors using UtilsMonitoring
     */
    global Boolean saveErrors;

    /**
     * The message type to use when recording monitoring messages
     */
    global String messageType;

    /**
     * A class to perform post-processing
     */
    global String postProcessorClassName;

    /**
     * The number of batches executed
     */
    global Integer batchCount;

    /**
     * The number of batches that failed
     */
    global Integer failedBatchCount;

    /**
     * @Jira RBX-332
     * Constructor.
     *
     * @param operation             The DML operation to be performed
     * @param records               The records to be processed
     * @param allOrNone             Whether to perform DML in allOrNone mode or partial mode
     * @param saveErrors            Whether to record any errors using UtilsMonitoring
     * @param messageType           The message type to use when recording monitoring messages
     * @param postProcessingClass   The name of the class to perform any post-processing required
     */
    global BatchDML(UtilsDML.DmlType operation, SObject[] records, Boolean allOrNone, Boolean saveErrors, String messageType,
                        String postProcessingClass) {
        this.allRecords = records;
        this.dmlType = operation;
        this.allOrNone = allOrNone;
        this.saveErrors = saveErrors;
        this.dmlErrors = new GenericDMLResult[]{};
        this.messageType = messageType;
        this.postProcessorClassName = postProcessingClass;
        this.batchCount = 0;
        this.failedBatchCount = 0;
    }

    /**
     * @Jira RBX-332
     * Start. Identifies the records to be batched.
     *
     * @param bc    Batch context
     *
     * @return      The records to be processed
     */
    global List<SObject> start(Database.BatchableContext bc) {
        return this.allRecords;
    }

    /**
     * @Jira RBX-332
     * Execute. The processing to be performed on one batch of records.
     *
     * @param bc            Batch context
     * @param recordBatch   A single batch of records to be processed
     */
    global void execute(Database.BatchableContext bc, List<SObject> recordBatch) {
        try {
            this.batchCount++;
            System.debug('### Batch Count = '+this.batchCount);
            GenericDMLResult[] batchResults = null;
            if (!this.allOrNone) {
                batchResults = new GenericDMLResult[]{};
            }
            Boolean success = UtilsDML.genericDML(this.dmlType, recordBatch, batchResults, this.saveErrors,
                    this.messageType, false, 0);
            if (batchResults != null) {
                this.dmlErrors.addAll(batchResults);
            }
            if (!success) {
                this.failedBatchCount++;
            }
        }
        catch (Exception ex) {
            this.failedBatchCount++;
        }
    }

    /**
     * @Jira RBX-332
     * Finish. Perform any post-processing requested.
     *
     * @param bc    Batch context
     */
    global void finish(Database.BatchableContext bc) {
        if (String.isNotBlank(postProcessorClassName)) {
            BatchDMLPostProcessorInterface postProcessor =
                    (BatchDMLPostProcessorInterface)Type.forName(postProcessorClassName).newInstance();
            postProcessor.performPostProcessing(this);
        }
    }

}