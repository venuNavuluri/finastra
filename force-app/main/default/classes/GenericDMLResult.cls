/**
 * @author  Steve Fouracre, Tony Bave
 * @Jira    RBX-332
 * A generic class to represent results of a single DML operation
 */
public class GenericDMLResult {

    /**
     * Record Id related to this result
     */
    public Id recordId;
    /**
     * The SObject record
     */
    public SObject sObj;
    /**
     * Whether the DML operation on this record was successful
     */
    public Boolean success;
    /**
     * A list of errors associated with the DML operation
     */
    public GenericError[] errors;

    /**
     * @Jira RBX-332
     * Constructor.
     *
     * @param isSuccess     True = Error condition
     * @param recId         Optional Id of record causing error
     * @param recObject     Optional SObject record
     */
    public GenericDMLResult(Boolean isSuccess, Id recId, SObject recObject) {
        this.success = isSuccess;
        this.recordId = recId;
        this.sObj = recObject;
        this.errors = new GenericError[]{};
    }

    /**
     * @Jira RBX-332
     * Alternative Constructor. Adds a single error message.
     *
     * @param isSuccess     True = Error condition
     * @param recId         Optional Id of record causing error
     * @param recObject     Optional SObject record
     * @param errorMessage  Optional Error Message
     */
    public GenericDMLResult(Boolean isSuccess, Id recId, SObject recObject, String errorMessage) {
        this(isSuccess, recId, recObject);
        if (errorMessage != null) {
            this.errors.add(new GenericError(errorMessage, null, null));
        }
    }

    /**
     * @Jira RBX-332
     * Alternative Constructor. Adds a list of Database.Errors
     *
     * @param dmlSuccess    Whether the DML operation on this record was successful
     * @param dmlRecordId   Record Id related to this result
     * @param sObj          The record being processed
     * @param dmlErrors     A list of errors associated with the DML operation
     */
    public GenericDMLResult(Boolean dmlSuccess, Id dmlRecordId, SObject dmlObject, Database.Error[] dmlErrors) {
        this(dmlSuccess, dmlRecordId, dmlObject);
        if (dmlErrors != null) {
            for (Database.Error dmlError : dmlErrors) {
                this.errors.add(new GenericError(dmlError));
            }
        }
    }

    /**
     * Inner class to represent the individual errors in a serializable format.
     */
    public class GenericError {
        public String message;
        public String fields;
        public StatusCode statusCode;

        /**
         * Constructor.
         *
         * @param errorMessage  The error message
         * @param errorFields   Optional message to list fields associated with the error
         * @param errorCode     Optional System StatusCode
         */
        public GenericError(String errorMessage, String errorFields, StatusCode errorCode) {
            this.message = errorMessage;
            this.fields = errorFields;
            this.statusCode = errorCode;
        }

        /**
         * Alternative Constructor.
         *
         * @param dmlError  Database.Error value is converted to GenericError
         */
        public GenericError(Database.Error dmlError) {
            this(dmlError.getMessage(), String.join(dmlError.getFields(),','), dmlError.getStatusCode());
        }
    }

    /**
     * @Jira RBX-332
     * Converts SaveResult[] to GenericDmlResult[]
     *
     * @param results   The INSERT / UPDATE results as a SaveResult[]
     *
     * @return {GenericDmlResult[]} The converted results
     */
    public static GenericDMLResult[] makeGeneric(Database.SaveResult[] results, SObject[] records) {
        GenericDMLResult[] genericResults = new GenericDMLResult[]{};
        for (Integer i=0; i<results.size(); i++) {
            genericResults.add(new GenericDMLResult(results[i].isSuccess(), results[i].getId(), records[i], results[i].getErrors()));
        }
        return genericResults;
    }

    /**
     * @Jira RBX-332
     * Converts UpsertResult[] to GenericDmlResult[]
     *
     * @param results   The UPSERT results as a UpsertResult[]
     *
     * @return {GenericDmlResult[]} The converted results
     */
    public static GenericDMLResult[] makeGeneric(Database.UpsertResult[] results, SObject[] records) {
        GenericDMLResult[] genericResults = new GenericDMLResult[]{};
        for (Integer i=0; i<results.size(); i++) {
            genericResults.add(new GenericDMLResult(results[i].isSuccess(), results[i].getId(), records[i], results[i].getErrors()));
        }
        return genericResults;
    }

    /**
     * @Jira RBX-332
     * Converts DeleteResult[] to GenericDmlResult[]
     *
     * @param results   The DELETE results as a DeleteResult[]
     *
     * @return {GenericDmlResult[]} The converted results
     */
    public static GenericDMLResult[] makeGeneric(Database.DeleteResult[] results, SObject[] records) {
        GenericDMLResult[] genericResults = new GenericDMLResult[]{};
        for (Integer i=0; i<results.size(); i++) {
            genericResults.add(new GenericDMLResult(results[i].isSuccess(), results[i].getId(), records[i], results[i].getErrors()));
        }
        return genericResults;
    }

    /**
     * @Jira RBX-332
     * Converts UndeleteResult[] to GenericDmlResult[]
     *
     * @param results   The UNDELETE results as a UndeleteResult[]
     *
     * @return {GenericDmlResult[]} The converted results
     */
    public static GenericDMLResult[] makeGeneric(Database.UndeleteResult[] results, SObject[] records) {
        GenericDMLResult[] genericResults = new GenericDMLResult[]{};
        for (Integer i=0; i<results.size(); i++) {
            genericResults.add(new GenericDMLResult(results[i].isSuccess(), results[i].getId(), records[i], results[i].getErrors()));
        }
        return genericResults;
    }

}