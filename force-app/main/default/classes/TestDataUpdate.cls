/**
 * @author Steve Fouracre, Tony Bave
 * RBX-317
 * This class updates a single SObject record, already existing in the database. As well as the generic updateAnyObject()
 * method, this class can be extended by adding SObject-specific update methods such as updateAccount() etc.
 *
 */
public class TestDataUpdate extends TestDataInsert {

    /**
     * Updates any single pre-existing SObject record using the update field/values passed
     *
     * @param sObj          The existing SObject record, must exist in the database
     * @param updateValues  The field/values to be updated
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {SObject}    The updated SObject record
     */
    public SObject updateAnyObject(SObject sObj, Map<String, Object> updateValues, GenericDMLResult[] dbErrors) {

        // Update the field values
        if (updateValues != null) {
            UtilsSObject.setSObjectFields(sObj, updateValues);
        }

        // perform standard updates
        UtilsDML.genericDML(
                UtilsDML.DmlType.UPDATE_OBJECT,
                new SObject[]{ sObj },
                dbErrors,               // list to save errors into
                this.saveErrors,        // save errors
                this.debugMessageType,  // message type
                this.allowBatch,        // allow batch
                this.batchSize,         // batch size
                this.postProcessorClass // batch post processor
        );

        return sObj;
    }

    // *************************************************************************************************************
    // Standard Object Updates
    // *************************************************************************************************************

    /**
     * Update a single Account record with new field values.
     *
     * @param acc           The current Account record, must exist in the database
     * @param updateValues  The field/values to be updated
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {Account}    The updated Account record
     */
    public Account updateAccount(Account acc, Map<String, Object> updateValues, GenericDMLResult[] dbErrors) {
        return (Account) updateAnyObject(acc, updateValues, dbErrors);
    }

    /**
     * Creates a single Account record and the updates it with new field values.
     *
     * @param insertValues  The initial field/values to be inserted
     * @param updateValues  The field/values to be updated
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {Account}    The updated Account record
     */
    public Account insertAndUpdateAccount(Map<String, Object> insertValues, Map<String, Object> updateValues,
                                    GenericDMLResult[] dbErrors) {

        // Insert the new Account
        Account acc = super.insertAccount(insertValues, dbErrors);

        return updateAccount(acc, updateValues, dbErrors);
    }

    /**
     * Update a single Opportunity record with new field values.
     *
     * @param opp           The current Opportunity record, must exist in the database
     * @param updateValues  The field/values to be updated
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {Opportunity} The updated Opportunity record
     */
    public Opportunity updateOpportunity(Opportunity opp, Map<String, Object> updateValues, GenericDMLResult[] dbErrors) {
        return (Opportunity) updateAnyObject(opp, updateValues, dbErrors);
    }

    /**
     * Creates a single Opportunity record and the updates it with new field values.
     *
     * @param insertValues  The initial field/values to be inserted
     * @param updateValues  The field/values to be updated
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {Opportunity} The updated Opportunity record
     */
    public Opportunity insertAndUpdateOpportunity(Map<String, Object> insertValues, Map<String, Object> updateValues,
            GenericDMLResult[] dbErrors) {

        // Insert the new Opportunity
        Opportunity opp = super.insertOpportunity(insertValues, dbErrors);

        return updateOpportunity(opp, updateValues, dbErrors);
    }
}