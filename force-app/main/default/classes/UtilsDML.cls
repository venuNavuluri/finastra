/**
 * @author  Steve Fouracre, Tony Bave
 * @Jira    RBX-332
 * Class to perform DML operations which include permission checks, governor limit checks, errors associated with
 * partial success operations, and batch DML.
 *
 */
global with sharing class UtilsDML {

    /**
     * Standard Enum for DML Operations
     */
    global enum DmlType {INSERT_OBJECT,UPDATE_OBJECT,UPSERT_OBJECT,DELETE_OBJECT,UNDELETE_OBJECT}

    /**
     * Error Messages
     */
    @TestVisible
    static final String MSG_NO_PERMISSION    = 'Does not have permission to ';
    @TestVisible
    static final String MSG_LIMITS_EXCEEDED  = ' records not processed due to insufficient governor limits. Processing by batch was not allowed';
    @TestVisible
    static final String MSG_EXCEPTION        = 'Exception occurred: ';
    @TestVisible
    static final String MSG_BATCH_CONTEXT    = 'Processing by batch is not allowed as context is already in batch or future';
    @TestVisible
    static final String MSG_BATCH_FAILED     = 'Failed to create batch job';

    /**
     * @Jira RBX-332
     * Attempts to perform the requested DML operation.
     *
     * @param thisDMLType       The DML Operation requested
     * @param sObj              The SObject records to be processed
     * @param dbErrors          Optional. A list of GenericDMLResult objects, if provided, will be populated with any errors
     *                          relating to records that could not be processed. If null, the DML operation is performed
     *                          as allOrNone.
     * @param saveErrors        If True, errors will be recorded using the UtilsMonitoring class.
     * @param messageType       The message type value used when generating monitoring messages.
     * @param processByBatch    If True, the DML operation can be performed via Batch if insufficient governor limits
     *                          allow it to be performed synchronously.
     * @param batchQuantity     The batch quantity to use if the DML operation is submitted to batch.
     * @param postProcessingClass If submitted to batch, use this class to perform post-processing.
     *
     * @return {Boolean}        Returns True if the DML operation was successful or successfully submitted to batch.
     */
    public static Boolean genericDML(DmlType thisDMLType, SObject[] sObj, GenericDMLResult[] dbErrors, Boolean saveErrors,
            String messageType, Boolean processByBatch, Integer batchQuantity, String postProcessingClass) {
        Boolean errorsOccurred = false;
        String errorMessage;

        // check mandatory parameters have been provided
        if (thisDMLType == null || sObj == null) {
            throw new UtilsDMLException('genericDML: Neither DmlType nor SObject[] can be NULL');
        }

        if (sObj.size() == 1 && sObj[0] == null) {
            throw new UtilsDMLException('genericDML: SObject[] cannot contain NULL');
        }

        // check there is work to do
        if (sObj.isEmpty()) {
            return true;
        }

        try {
            Schema.DescribeSObjectResult objectDescribe = sObj[0].getSObjectType().getDescribe();
            System.debug('## genericDML '+thisDMLType+', '+objectDescribe.getName()+'['+sObj.size()+']');

            UtilsMonitoring.setupMonitoring();

            // check we have permission
            if (!checkPermissionForDML(thisDMLType, objectDescribe)) {
                errorMessage = MSG_NO_PERMISSION + thisDMLType + ' ' + objectDescribe.getName();
                handleError(errorMessage, dbErrors, saveErrors, messageType);
                errorsOccurred = true;
            }
            else {
                Integer dmlCount = 1;
                Integer recordCount = sObj.size();

                // to support UPSERT, create separate lists for INSERT and UPDATE
                SObject[] sObjInsert;
                SObject[] sObjUpdate;
                if (thisDMLType == DmlType.INSERT_OBJECT) {
                    sObjInsert = sObj;
                }
                if (thisDMLType == DmlType.UPDATE_OBJECT) {
                    sObjUpdate = sObj;
                }
                if (thisDMLType == DmlType.UPSERT_OBJECT) {
                    sObjUpdate = new SObject[]{};
                    sObjUpdate.addAll(sObj);
                    sObjInsert = UtilsSObject.extractNewRecords(sObjUpdate);
                    if (!sObjInsert.isEmpty() && !sObjUpdate.isEmpty()) {
                        dmlCount = 2;
                    }
                }

                // check we have sufficient governor limits for number of DML statements
                if (checkDMLLimits(dmlCount, recordCount)) {

                    // if a dbErrors[] has been passed then allow partial DML and retrieve any errors
                    if (dbErrors != null) {

                        Integer errorCount = dbErrors.size();
                        // perform INSERT operation OR insert part of UPSERT operation
                        if ((thisDMLType == DmlType.INSERT_OBJECT)
                                || (thisDMLType == DmlType.UPSERT_OBJECT && !sObjInsert.isEmpty())) {
                            Database.SaveResult[] insertResults = Database.insert(sObjInsert, false);
                            GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(insertResults, sObjInsert);
                            dbErrors.addAll(getDMLErrors(genericResults, saveErrors, messageType));
                        }
                        // perform UPDATE operation OR update part of UPSERT operation
                        if ((thisDMLType == DmlType.UPDATE_OBJECT)
                                || (thisDMLType == DmlType.UPSERT_OBJECT && !sObjUpdate.isEmpty())) {
                            Database.SaveResult[] updateResults = Database.update(sObjUpdate, false);
                            GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(updateResults, sObjUpdate);
                            dbErrors.addAll(getDMLErrors(genericResults, saveErrors, messageType));
                        }
                        // perform DELETE operation
                        else if (thisDMLType == DmlType.DELETE_OBJECT) {
                            Database.DeleteResult[] deleteResults = Database.delete(sObj, false);
                            GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(deleteResults, sObj);
                            dbErrors.addAll(getDMLErrors(genericResults, saveErrors, messageType));
                        }
                        // perform UNDELETE operation
                        else if (thisDMLType == DmlType.UNDELETE_OBJECT) {
                            Database.UndeleteResult[] undeleteResults = Database.undelete(sObj, false);
                            GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(undeleteResults, sObj);
                            dbErrors.addAll(getDMLErrors(genericResults, saveErrors, messageType));
                        }
                        if (dbErrors.size() > errorCount) {
                            errorMessage = '';
                            errorsOccurred = true;
                        }

                    }
                    // if no dbErrors[] passed just perform the DML
                    else {

                        // perform INSERT operation OR insert part of UPSERT operation
                        if ((thisDMLType == DmlType.INSERT_OBJECT)
                                || (thisDMLType == DmlType.UPSERT_OBJECT && !sObjInsert.isEmpty())) {
                            insert sObjInsert;
                        }
                        // perform UPDATE operation OR update part of UPSERT operation
                        if ((thisDMLType == DmlType.UPDATE_OBJECT)
                                || (thisDMLType == DmlType.UPSERT_OBJECT && !sObjUpdate.isEmpty())) {
                            update sObjUpdate;
                        }
                        // perform DELETE operation
                        else if (thisDMLType == DmlType.DELETE_OBJECT) {
                            delete sObj;
                        }
                        // perform UNDELETE operation
                        else if (thisDMLType == DmlType.UNDELETE_OBJECT) {
                            undelete sObj;
                        }
                    }
                }

                // insufficient governor limits to perform DML - can we do batch?
                else {
                    if (processByBatch) {
                        if (!genericDMLBatch(thisDMLType, sObj, (dbErrors == null), saveErrors, messageType,
                                batchQuantity, postProcessingClass)) {
                            errorMessage = MSG_BATCH_FAILED;
                            handleError(errorMessage, dbErrors, saveErrors, messageType);
                            errorsOccurred = true;
                        }
                    }
                    else {
                        errorMessage = thisDMLType + MSG_LIMITS_EXCEEDED;
                        handleError(errorMessage, dbErrors, saveErrors, messageType);
                        errorsOccurred = true;
                    }
                }
            }

        }

        // catch any exception
        catch(Exception ex) {
            errorMessage = MSG_EXCEPTION + ex.getMessage();
            handleError(errorMessage, dbErrors, saveErrors, messageType);
            errorsOccurred = true;
        }
        finally {
            if (errorsOccurred && saveErrors) {
                UtilsMonitoring.saveMonitoringMessages(UtilsDML.class);
            }
        }

        if (errorsOccurred && dbErrors == null) {
            // no error list, so raise an exception
            throw new UtilsDMLException(errorMessage);
        }
        return !errorsOccurred;
    }

    /**
     * @Jira RBX-332
     * Alternative signature. As above, but defaults settings: No post-processing.
     *
     */
    public static Boolean genericDML(DmlType thisDMLType, SObject[] sObj, GenericDMLResult[] dbErrors, Boolean saveErrors,
            String messageType, Boolean processByBatch, Integer batchQuantity) {
        return genericDML(thisDMLType, sObj, dbErrors, saveErrors, messageType, processByBatch, batchQuantity, null);
    }

    /**
     * @Jira RBX-332
     * Alternative signature. As above, but defaults settings: No error recording, no batch option.
     *
     */
    public static Boolean genericDML(DmlType thisDMLType, SObject[] sObj) {
        return genericDML(thisDMLType, sObj, null, false, null, false, 0, null);
    }

    /**
     * @Jira RBX-332
     * Submits a DML operation for batch processing.
     *
     * @param thisDMLType       The DML Operation requested
     * @param sObj              The SObject records to be processed
     * @param allOrNone         If True, DML operation is processed allOrNone, otherwise partial DML is permitted
     * @param saveErrors        If True, errors will be recorded using the UtilsMonitoring class.
     * @param messageType       The message type value used when generating monitoring messages.
     * @param batchQuantity     The batch quantity. Default is 200 if none specified.
     *
     * @return {Boolean}        Returns True if the batch job was successfully submitted.
     */
    public static Boolean genericDMLBatch(DmlType thisDMLType, SObject[] sObj, Boolean allOrNone, Boolean saveErrors,
            String messageType, Integer batchQuantity, String postProcessingClass) {
        Boolean errorsOccurred = false;

        // check this is not called from an asynchronous process
        if (System.isBatch() || System.isFuture()) {
            UtilsMonitoring.buildMonitoringMessage(UtilsDML.class, messageType, MSG_BATCH_CONTEXT, null);
            errorsOccurred = true;
        }
        else {

            // submit job to batch queue
            Database.executeBatch(
                    new BatchDML(thisDMLType, sObj, allOrNone, saveErrors, messageType, postProcessingClass),
                                    batchQuantity != null ? batchQuantity : 200
            );
        }

        return !errorsOccurred;
    }

    /**
     * @Jira RBX-332
     * Parses the results of the DML Operation and returns a list of any errors found.
     *
     * @param dmlResults            The results from the DML operation
     * @param saveErrors            If True, errors will be recorded using the UtilsMonitoring class.
     * @param messageType           The message type value used when generating monitoring messages.
     *
     * @return {GenericDMLResult[]} The results of the unsuccessful DML records
     */
    @TestVisible
    private static GenericDMLResult[] getDMLErrors(GenericDMLResult[] dmlResults, Boolean saveErrors, String messageType){
        GenericDMLResult[] dmlErrors = new GenericDMLResult[]{};

        // look through all the results for any failures
        for (GenericDMLResult result : dmlResults) {
            if (!result.success) {
                // operation failed, so keep this result record
                dmlErrors.add(result);
                // report the errors
                if (saveErrors) {
                    for (GenericDMLResult.GenericError err : result.errors) {
                        String errorMsg = err.statusCode + ': ' + err.message;
                        UtilsMonitoring.buildMonitoringMessage(UtilsDML.class, messageType, errorMsg, null);
                    }
                }
            }
        }

        return dmlErrors;
    }

    /**
     * @Jira RBX-332
     * Handle a non-DML related error. If a list of errors exists, a new error is added to the list. If saveErrors is
     * true, a debug message is generated using UtilsMonitoring.
     *
     * @param errorMessage  The error message
     * @param dmlResults    The list of errors
     * @param saveErrors    If True, save errors using UtilsMonitoring
     * @param messageType   The message type associated with the debug message
     */
    @TestVisible
    private static void handleError(String errorMessage, GenericDMLResult[] dmlResults,
                                                    Boolean saveErrors, String messageType) {
        if (dmlResults != null) {
            dmlResults.add(new GenericDMLResult(false, null, null, errorMessage));
        }
        if (saveErrors) {
            UtilsMonitoring.buildMonitoringMessage(UtilsDML.class, messageType, errorMessage, null);
        }
    }

    /**
     * @Jira RBX-332
     * Checks DML Permissions for the specified object
     *
     * @param thisDMLType       DML Operation
     * @param objectDescribe    Object describe
     *
     * @return {Boolean}        Returns True if the user has permission to perform the requested DML
     */
    @TestVisible
    private static Boolean checkPermissionForDML(DmlType thisDMLType, Schema.DescribeSObjectResult objectDescribe) {
        return (
                (thisDMLType == DmlType.INSERT_OBJECT && objectDescribe.isCreateable())
                        || (thisDMLType == DmlType.UPDATE_OBJECT && objectDescribe.isUpdateable())
                        || (thisDMLType == DmlType.UPSERT_OBJECT && objectDescribe.isCreateable() && objectDescribe.isUpdateable())
                        || (thisDMLType == DmlType.DELETE_OBJECT && objectDescribe.isDeletable())
                        || (thisDMLType == DmlType.UNDELETE_OBJECT && objectDescribe.isUndeletable())
        );
    }

    /**
     * @Jira RBX-332
     * Checks the DML Statement count and DML Row count limits
     *
     * @param numStatements     Number of DML statement operations to be performed
     * @param numRows           Number of records in the DML operation to be processed
     *
     * @return {Boolean}        Returns True if the operation will succeed without exceeding governor limits
     */
    @TestVisible
    private static Boolean checkDMLLimits(Integer numStatements, Integer numRows) {
        return (
                (Limits.getDmlStatements() + numStatements <= Limits.getLimitDmlStatements())
                && (Limits.getDmlRows() + numRows <= Limits.getLimitDmlRows())
            );
    }

    /**
     * Custom Exception class
     */
    public class UtilsDMLException extends Exception { }

    }