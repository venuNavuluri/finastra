/**
 * @author     Steve Fouracre,Tony Bave
 * @Jira       RBX-317
 * This class inserts a single SObject based upon a Json string definition (which should be referenced from the
 * TestDataJsonLibrary). As well as the generic insertAnyObject() method, this class can be extended by adding
 * SObject-specific insert methods such as insertAccount() etc.
 *
 * There are a number attributes which can be used to override various defaults:
 *
 * overrideJson {Map}       a map of Json strings to replace any passed value, thus overriding the TestDataJsonLibrary
 * bulkModeOn   {Boolean}   if set True, this will inhibit the insert operation and only return the SObject
 * saveErrors   {Boolean}   if set True, will send errors to the UtilsMonitoring class to be saved
 * debugMessageType
 *              {String}    if saveErrors is True, this defines the messageType under which errors are saved
 * allowBatch   {Boolean}   if set True, will allow large DML operations to be sent for Batch processing
 * batchSize    {Integer}   if processing by Batch, this indicates the batch size
 * postProcessorClass
 *              {String}    if processing by Batch, this specifies an optional class to perform post-DML processing
 *
 */
public virtual class TestDataInsert extends TestDataReturn {

    /**
     * A map of Json strings that can be used to override those in the TestDataJsonLibrary
     */
    public Map<System.Type, String> overrideJson = new Map<System.Type, String>();

    /**
     * Indicates when in the process of creating multiple records, and as such DML operations should not be performed.
     */
    public Boolean bulkModeOn = false;

    /**
     * Whether to save errors to Debug Message via UtilsMonitoring
     */
    public Boolean saveErrors = false;

    /**
     * The message type used for Debug Messages
     */
    public String debugMessageType = 'Test Data Framework';

    /**
     * Whether to allow DML to invoke batch if insufficient governor limits are available
     */
    public Boolean allowBatch = false;

    /**
     * The batch size to use if a BatchDML is executed
     */
    public Integer batchSize = 200;

    /**
     * The name of the Post-processing class to execute after DMLBatch
     */
    public String postProcessorClass;

    /**
     * @Jira       RBX-317
     * Inserts a single SObject based on the specified JSON string. The JSON passed as a parameter can
     * be overridden if the overrideJson map contains an entry for this object type.
     *
     * @param jsonStr       SObject definition in JSON format
     * @param fieldValues   Optional additional field/value settings required
     * @param dbErrors      Optional list for storing database error results
     * @param objType       SObject type, used to check for any overrideJSON value
     *
     * @return {SObject}    The inserted SObject record
     */
    public SObject insertAnyObject(String jsonStr, Map<String, Object> fieldValues,
                                        GenericDMLResult[] dbErrors, System.Type objType){

        // checks if override JSON is defined for this objType
        if (overrideJson != null && overrideJson.containsKey(objType)) {
            jsonStr = overrideJson.get(objType);
        }

        SObject newObject = super.prepareSObject(jsonStr, fieldValues)[0];

        // bulkMode
        if (bulkModeOn == false) {

            // perform standard insert
            UtilsDML.genericDML(
                    UtilsDML.DmlType.INSERT_OBJECT,
                    new SObject[]{ newObject },
                    dbErrors,               // list to save errors into
                    this.saveErrors,        // save errors
                    this.debugMessageType,  // message type
                    this.allowBatch,        // allow batch
                    this.batchSize,         // batch size
                    this.postProcessorClass // batch post processor
            );
        }

        return newObject;
    }

    // *************************************************************************************************************
    // Standard Object Inserts
    // *************************************************************************************************************

    /**
     * Inserts one Account based on the standard JSON library definition
     *
     * @param fieldValues   Optional additional field/value settings required
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {Account}    The inserted Account record
     */
    public Account insertAccount(Map<String, Object> fieldValues, GenericDMLResult[] dbErrors) {
        return (Account) insertAnyObject(
                new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_ACCOUNT),
                fieldValues,
                dbErrors,
                Account.class
        );
    }

    /**
     * Inserts one Account based on the specified custom JSON library definition
     *
     * @param jsonKey       The key to reference the required custom JSON string in the library
     * @param fieldValues   Optional additional field/value settings required
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {Account}    The inserted Account record
     */
    public Account insertAccount(String jsonKey, Map<String, Object> fieldValues, GenericDMLResult[] dbErrors) {
        if (new TestDataJsonLibrary.Custom().jsonMap.containsKey(jsonKey)) {
            return (Account) insertAnyObject(
                    new TestDataJsonLibrary.Custom().jsonMap.get(jsonKey),
                    fieldValues,
                    dbErrors,
                    Account.class);
        }
        else {
            return null;
        }
    }

    /**
     * Inserts one Contact based on the standard JSON library definition
     *
     * @param fieldValues   Optional additional field/value settings required
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {Contact}    The inserted Contact record
     */
    public Contact insertContact(Map<String, Object> fieldValues, GenericDMLResult[] dbErrors) {
        return (Contact) insertAnyObject(
                new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_CONTACT),
                fieldValues,
                dbErrors,
                Contact.class
        );
    }

    /**
     * Inserts one Lead based on the standard JSON library definition
     *
     * @param fieldValues   Optional additional field/value settings required
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {Lead}       The inserted Lead record
     */
    public Lead insertLead(Map<String, Object> fieldValues, GenericDMLResult[] dbErrors) {
        return (Lead) insertAnyObject(
                new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_LEAD),
                fieldValues,
                dbErrors,
                Lead.class
        );
    }

    /**
     * Inserts one Opportunity based on the standard JSON library definition
     *
     * @param fieldValues   Optional additional field/value settings required
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {Opportunity} The inserted Opportunity record
     */
    public Opportunity insertOpportunity(Map<String, Object> fieldValues, GenericDMLResult[] dbErrors) {
        return (Opportunity) insertAnyObject(
                new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_OPPORTUNITY),
                    fieldValues,
                    dbErrors,
                    Opportunity.class
        );
    }

    /**
     * Inserts one User based on the standard JSON library definition
     *
     * @param profileName   Required. Name of user Profile
     * @param alias         Optional value to be used in User fields to make it unique
     * @param fieldValues   Optional additional field/value settings required
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {User}       The inserted User record
     */
    public User insertUser(String profileName, String alias, Map<String, Object> fieldValues, GenericDMLResult[] dbErrors) {
        if (fieldValues == null) {
            fieldValues = new Map<String, Object>();
        }

        // obtain the profile id
        Id profileId = [SELECT Id FROM Profile WHERE Name LIKE :'%'+profileName+'%' LIMIT 1].Id;
        fieldValues.put('ProfileId', profileId);

        // amend it to make unique
        if (!String.isBlank(alias)) {
            fieldValues.put('Alias', alias);
            fieldValues.put('LastName', 'Test-'+alias);
            fieldValues.put('Email', alias+'.test@test.test');
            fieldValues.put('Username', alias+'.test@test.test');
            fieldValues.put('CommunityNickname', alias+'182');
        }

        return (User) insertAnyObject(
                new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_USER),
                fieldValues,
                dbErrors,
                User.class
        );
    }

    /**
     * Inserts one Opportunity Product based on the standard JSON library definition
     *
     * @param opp           the Opportunity record to add this line item to
     * @param productFamily the product family name used to identify which existing product to add
     * @param fieldValues   Optional additional field/value settings required
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {OpportunityLineItem} the inserted OpportunityLineItem
     */
    public OpportunityLineItem insertOpportunityLineItem(Opportunity opp, String productFamily,
            Map<String, Object> fieldValues, GenericDMLResult[] dbErrors) {
        if (fieldValues == null) {
            fieldValues = new Map<String, Object>();
        }

        // link record to Opportunity and Pricebook Entry
        PricebookEntry pbEntry = [
                SELECT Id FROM PricebookEntry WHERE IsActive = TRUE
                AND CurrencyIsoCode = :opp.CurrencyIsoCode
                AND Product2.Family = :productFamily LIMIT 1];
        fieldValues.put('PricebookEntryId', pbEntry.Id);
        fieldValues.put('OpportunityId', opp.Id);

        return (OpportunityLineItem) insertAnyObject(
                new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_OPP_LINE_ITEM),
                fieldValues,
                dbErrors,
                OpportunityLineItem.class
        );
    }

    /**
     * Inserts one Product based on the standard JSON library definition
     *
     * @param fieldValues   Optional additional field/value settings required
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {Product2}   The inserted Product record
     */
    public Product2 insertProduct(Map<String, Object> fieldValues, GenericDMLResult[] dbErrors) {
        return (Product2) insertAnyObject(
                new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_PRODUCT),
                fieldValues,
                dbErrors,
                Product2.class
        );
    }

}