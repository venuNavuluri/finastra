/**
 * @author Steve Fouracre, Tony Bave
 * RBX-317
 * This class can be extended to contain any complex test data setups that are often required, such as creating
 * an Account and related Contact record, etc.
 *
 */
public virtual class TestDataComplexFunctions extends TestDataInsert {

    /**
     * The created account
     */
    public Account newAccount;

    /**
     * The created contact
     */
    public Contact newContact;

    /**
     * Creates an Account and one linked Contact
     *
     * @param fieldValues   Optional additional field/value settings for account and/or contact
     * @param dbErrors      Optional list for storing database error results
     *
     * @return {Account}    The created account record.
     */
    public Account insertAccountAndContact(Map<System.Type, Map<String, Object>> fieldValues, GenericDMLResult[] dbErrors) {

        // get any field values for the account and contact objects
        Map<String, Object> accountFields, contactFields;
        if (fieldValues != null) {
            accountFields = fieldValues.get(Account.class);
            contactFields = fieldValues.get(Contact.class);
        }

        // create the Account
        this.newAccount = super.insertAccount(accountFields, dbErrors);

        // link Contact to Account
        if (contactFields == null) {
            contactFields = new Map<String, Object>();
        }
        contactFields.put('AccountId', this.newAccount.Id);

        // create the Contact
        this.newContact = super.insertContact(contactFields, dbErrors);

        return this.newAccount;
    }

}