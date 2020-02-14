@IsTest
private class TestDataReturn_Test {

    // Extend tha abstract class so we can instantiate it
    private class TestDataReturnClass extends TestDataReturn { }

    static final String JSON_FORMAT_ACCOUNT = '{"attributes":{"type":"Account"},"Name":"Test Account"}';
    static final String TEST_ACCOUNT_NAME = 'Test Account';

    @IsTest
    static void prepareSObject_Simple() {
        // GIVEN a simple SObject definition in Json format
        // WHEN we use prepareSObject() to create an SObject instance
        Test.startTest();
            TestDataReturn tdr = new TestDataReturnClass();
            SObject[] sObjects = tdr.prepareSObject(JSON_FORMAT_ACCOUNT, null);
        Test.stopTest();

        // THEN the SObject is created with the values expected
        System.assertEquals(1, sObjects.size());
        System.assertEquals(TEST_ACCOUNT_NAME, sObjects[0].get('Name'));

        // AND this can be cast to an Account object
        Account acc = (Account) sObjects[0];
        System.assertEquals(TEST_ACCOUNT_NAME, acc.Name);
    }

    @IsTest
    static void prepareSObject_FieldUpdates() {
        // GIVEN some field updates to be applied
        Map<String, Object> setFields = new Map<String, Object>{
                'AccountNumber' => 'ACCOUNT-12345',
                'Type' => 'Customer',
                'Budget__c' => 1000.00,
                'Next_Audit_date__c' => System.today()+7
        };

        // WHEN we use prepareSObject() to create an Account instance
        Test.startTest();
            TestDataReturn tdr = new TestDataReturnClass();
            Account[] accounts = (Account[]) tdr.prepareSObject(JSON_FORMAT_ACCOUNT, setFields);
        Test.stopTest();

        // THEN the Account is created with the values expected
        Account acc = accounts[0];
        System.assertEquals(TEST_ACCOUNT_NAME, acc.Name);
        System.assertEquals(setFields.get('AccountNumber'), acc.AccountNumber);
        System.assertEquals(setFields.get('Type'), acc.Type);
        System.assertEquals(setFields.get('Budget__c'), acc.Budget__c);
        System.assertEquals(setFields.get('Next_Audit_date__c'), acc.Next_Audit_date__c);
    }

    @IsTest
    static void prepareSObject_InvalidFieldName() {
        // GIVEN a field update referencing a non-existent field
        Map<String, Object> setFields = new Map<String, Object>{
                'INVALID_FIELD' => 'Test Value'
        };

        // WHEN we use prepareSObject() to create an Account instance
        Account[] accounts;
        Test.startTest();
            Boolean exceptionOccurred = false;
            TestDataReturn tdr = new TestDataReturnClass();
            try {
                accounts = (Account[]) tdr.prepareSObject(JSON_FORMAT_ACCOUNT, setFields);
            }
            catch (Exception ex) {
                exceptionOccurred = true;
            }
        Test.stopTest();

        // THEN an exception will have been raised
        System.assertEquals(true, exceptionOccurred);
    }

    @IsTest
    static void prepareSObject_InvalidFieldValue() {
        // GIVEN a field update trying to set an invalid value
        Map<String, Object> setFields = new Map<String, Object>{
                'Budget__c' => 'XYZ'
        };

        // WHEN we use prepareSObject() to create an Account instance
        Account[] accounts;
        Test.startTest();
            Boolean exceptionOccurred = false;
            TestDataReturn tdr = new TestDataReturnClass();
            try {
                accounts = (Account[]) tdr.prepareSObject(JSON_FORMAT_ACCOUNT, setFields);
            }
            catch (Exception ex) {
                exceptionOccurred = true;
            }
        Test.stopTest();

        // THEN an exception will have been raised
        System.assertEquals(true, exceptionOccurred);
    }
}