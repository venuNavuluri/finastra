/**
 * @author Steve Fouracre, Tony Bave
 * RBX-317
 * This class inserts multiple SObject records of the same type. It includes an autonumber feature so that
 * each record created can have a unique number-based value if required. As well as the generic insertBulkObjects()
 * method, this class can be extended by adding SObject-specific insert methods such as insertAccounts() etc.
 *
 */
public virtual class TestDataBulk extends TestDataInsert {

    /**
     * Insert multiple SObject records
     *
     * @param recordCount   The number of SObject records required
     * @param jsonStr       The Json string representation of SObject
     * @param fieldValues   Optional additional field/value settings required (may include % for autonumbers)
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {SObject[]}  The list of SObjects inserted
     */
    public SObject[] insertBulkObjects(Integer recordCount, String jsonStr, Map<String, Object> fieldValues,
                                            GenericDMLResult[] dbErrors, System.Type objType) {
        SObject[] sObj = new SObject[]{};

        //  prevents the records from being inserted individually
        bulkModeOn = true;

        // create the desired number of records
        for (Integer i = 1; i <= recordCount; i++) {

            // performs autonumber on any specified field values
            Map<String, Object> autonumberFields = autonumber(fieldValues, i);

            // adds a new record to the list of objects
            sObj.add(super.insertAnyObject(jsonStr, autonumberFields, dbErrors, objType));
        }

        // perform standard insert on the list of objects
        UtilsDML.genericDML(
                UtilsDML.DmlType.INSERT_OBJECT,
                sObj,
                dbErrors,               // list to save errors into
                this.saveErrors,        // save errors
                this.debugMessageType,  // message type
                this.allowBatch,        // allow batch
                this.batchSize,         // batch size
                this.postProcessorClass // batch post processor
        );

        bulkModeOn = false;

        return sObj;
    }

    /**
     * Converts a field/value map to replace any strings with a "%" placeholder with the number specified
     *
     * @param fieldValues   Source list of field/values
     * @param i             The numeric value to use to replace "%" with
     *
     * @return {Map<String, Object>} A new map with the string values updated accordingly
     */
    @TestVisible
    private Map<String, Object> autonumber(Map<String, Object> fieldValues, Integer i) {
        Map<String, Object> updatedFieldValues;
        if (fieldValues != null) {
            updatedFieldValues = new Map<String, Object>();
            for (String key : fieldValues.keySet()) {
                Object originalValue = fieldValues.get(key);
                if (originalValue instanceof String) {
                    String newValue = ((String) originalValue).replace('%',String.valueOf(i));
                    updatedFieldValues.put(key, newValue);
                }
                else {
                    updatedFieldValues.put(key, originalValue);
                }
            }
        }
        return updatedFieldValues;
    }

    // *************************************************************************************************************
    // Standard Object Bulk Inserts
    // *************************************************************************************************************

    /**
     * Insert multiple Account records
     *
     * @param recordCount   The number of Account records required
     * @param fieldValues   Optional additional field/value settings required (may include % for autonumbers)
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {Account[]}  The list of Accounts inserted
     */
    public Account[] insertAccounts(Integer recordCount, Map<String, Object> fieldValues, GenericDMLResult[] dbErrors) {
        return (Account[]) insertBulkObjects(
                recordCount,
                new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_ACCOUNT),
                fieldValues, dbErrors, Account.class
        );
    }

    /**
     * Insert multiple Account records with the names 'Account1' to 'Account{recordCount}'
     *
     * @param recordCount   The number of Accounts required
     *
     * @return {Account[]}  The list of Accounts inserted
     */
    public Account[] insertAccounts(Integer recordCount) {
        Map<String, Object> fieldValues = new Map<String, Object>{'Name' => 'Account%'};
        return insertAccounts(recordCount, fieldValues, null);
    }

    /**
     * Insert multiple Contact records
     *
     * @param recordCount   The number of Contact records required
     * @param fieldValues   Optional additional field/value settings required (may include % for autonumbers)
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {Contact[]}  The list of Contacts inserted
     */
    public Contact[] insertContacts(Integer recordCount, Map<String, Object> fieldValues, GenericDMLResult[] dbErrors) {
        return (Contact[]) insertBulkObjects(
                recordCount,
                new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_CONTACT),
                fieldValues, dbErrors, Contact.class
        );
    }

    /**
     * Insert multiple Contact records with the LastNames 'Last1' to 'Last{recordCount}'
     * and Emails 'test1@test.test' to 'test{recordCount}@test.test'
     *
     * @param recordCount   The number of Accounts required
     *
     * @return {Contact[]}  The list of Contacts inserted
     */
    public Contact[] insertContacts(Integer recordCount) {
        Map<String, Object> fieldValues = new Map<String, Object>{
                'LastName' => 'Last%',
                'Email' => 'test%@test.test'
        };
        return insertContacts(recordCount, fieldValues, null);
    }

}