@IsTest
private class TestDataBulk_Test {

    @IsTest
    static void testinsertBulkObjects() {
        // GIVEN an SObject Json string
        final String TEST_TYPE = 'Test Type';
        String jsonSObj = JSON.serialize(new Debug_Parent__c(Message_Type__c = TEST_TYPE));

        // AND a field update
        final String TEST_SOURCE = 'TestDataBulk_Test';
        Map<String, Object> fieldUpdates = new Map<String, Object> {'Source__c' => TEST_SOURCE};

        // WHEN inserting multiple SObjects
        final Integer quantity = 7;
        Test.startTest();
            TestDataBulk tdb = new TestDataBulk();
            SObject[] sObjects = tdb.insertBulkObjects(quantity, jsonSObj, fieldUpdates, null, Debug_Parent__c.class);
        Test.stopTest();

        // THEN the SObjects will be inserted as expected
        Debug_Parent__c[] results = [SELECT Message_Type__c, Source__c FROM Debug_Parent__c];
        System.assertEquals(quantity, results.size());

        // AND the values populated as expected
        for (Debug_Parent__c record : results) {
            System.assertEquals(TEST_TYPE, record.Message_Type__c);
            System.assertEquals(TEST_SOURCE, record.Source__c);
        }
    }

    @IsTest
    static void testInsertMultipleAccountsSimple() {
        // GIVEN the TestDataBulk class
        TestDataBulk tdb = new TestDataBulk();

        // WHEN using it to insert multiple accounts using defaults
        final Integer quantity = 5;
        Test.startTest();
        Account[] newAccounts = tdb.insertAccounts(quantity);
        Test.stopTest();

        // THEN the accounts will exist with the autonumber fields set up
        Account[] checkAccounts = [SELECT Id, Name FROM Account ORDER BY Name];
        System.assertEquals(quantity, checkAccounts.size());
        for (Integer i = 0; i < quantity; i++) {
            System.assertEquals(newAccounts[i].Id, checkAccounts[i].Id);
            String expectedName = 'Account'+(i+1);
            System.assertEquals(expectedName, checkAccounts[i].Name);
        }
    }

    @IsTest
    static void testInsertMultipleAccountsOnlyOne() {
        // GIVEN the TestDataBulk class
        TestDataBulk tdb = new TestDataBulk();

        // WHEN using it to insert only one account
        Test.startTest();
        Account[] newAccounts = tdb.insertAccounts(1);
        Test.stopTest();

        // THEN the account will exist with the autonumber fields set up
        Account[] checkAccounts = [SELECT Id, Name FROM Account ORDER BY Name];
        System.assertEquals(1, checkAccounts.size());
        System.assertEquals('Account1', checkAccounts[0].Name);
    }

    @IsTest
    static void testInsertMultipleAccountsZeroCount() {
        // GIVEN the TestDataBulk class
        TestDataBulk tdb = new TestDataBulk();

        // WHEN requesting insert zero accounts
        Test.startTest();
        Account[] newAccounts = tdb.insertAccounts(0);
        Test.stopTest();

        // THEN no accounts will exist
        Account[] checkAccounts = [SELECT Id, Name FROM Account ORDER BY Name];
        System.assertEquals(0, checkAccounts.size());
    }

    @IsTest
    static void testInsertMultipleAccounts() {
        // GIVEN the TestDataBulk class
        TestDataBulk tdb = new TestDataBulk();

        // WHEN using it to insert multiple accounts using autonumber (%) notation
        final Integer quantity = 5;
        Map<String, Object> fieldValues = new Map<String, Object>{'Name' => 'TestAccount-%'};
        Test.startTest();
        Account[] newAccounts = tdb.insertAccounts(quantity, fieldValues, null);
        Test.stopTest();

        // THEN the accounts will exist with the autonumber fields set up
        Account[] checkAccounts = [SELECT Id, Name FROM Account ORDER BY Name];
        System.assertEquals(quantity, checkAccounts.size());
        for (Integer i = 0; i < quantity; i++) {
            System.assertEquals(newAccounts[i].Id, checkAccounts[i].Id);
            String expectedName = 'TestAccount-'+(i+1);
            System.assertEquals(expectedName, checkAccounts[i].Name);
        }
    }

    @IsTest
    static void testInsertMultipleAccountsNoFields() {
        // GIVEN the TestDataBulk class
        TestDataBulk tdb = new TestDataBulk();

        // WHEN using it to insert multiple accounts without specifying field values
        final Integer quantity = 5;
        Test.startTest();
        Account[] newAccounts = tdb.insertAccounts(quantity, null, null);
        Test.stopTest();

        // THEN the accounts will exist with the default fields values from the Json Library
        String accountJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_ACCOUNT);
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(accountJson);

        Account[] checkAccounts = [SELECT Id, Name FROM Account];
        System.assertEquals(quantity, checkAccounts.size());
        for (Integer i = 0; i < quantity; i++) {
            System.assertEquals(newAccounts[i].Id, checkAccounts[i].Id);
            System.assertEquals(libraryData.get('Name'), checkAccounts[i].Name);
        }
    }

    @IsTest
    static void testInsertMultipleAccountsWithErrors() {
        // GIVEN the TestDataBulk class
        TestDataBulk tdb = new TestDataBulk();

        // AND we request multiple invalid accounts
        final Integer quantity = 5;
        Map<String, Object> fieldValues = new Map<String, Object>{'Name' => null};

        // AND we have a list to hold any errors
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN calling insertAccounts
        Test.startTest();
        Account[] newAccounts = tdb.insertAccounts(quantity, fieldValues, dbErrors);
        Test.stopTest();

        // THEN the accounts will not exist
        Account[] checkAccounts = [SELECT Id, Name FROM Account];
        System.assertEquals(0, checkAccounts.size());

        // AND there will be errors in the error list
        System.assertEquals(quantity, dbErrors.size());
        for (Integer i = 0; i < quantity; i++) {
            System.assertEquals(false, dbErrors[i].success);
            System.assertEquals(1, dbErrors[i].errors.size());
        }
    }

    @IsTest
    static void testInsertMultipleContactsSimple() {
        // GIVEN the TestDataBulk class
        TestDataBulk tdb = new TestDataBulk();

        // WHEN using it to insert multiple contacts
        final Integer quantity = 5;
        Test.startTest();
        Contact[] newContacts = tdb.insertContacts(quantity);
        Test.stopTest();

        // THEN the contacts will exist with the autonumber fields set up
        Contact[] checkContacts = [SELECT Id, LastName, Email FROM Contact ORDER BY LastName];
        System.assertEquals(quantity, checkContacts.size());
        for (Integer i = 0; i < quantity; i++) {
            System.assertEquals(newContacts[i].Id, checkContacts[i].Id);
            String expectedName = 'Last'+(i+1);
            String expectedEmail = 'test'+(i+1)+'@test.test';
            System.assertEquals(expectedName, checkContacts[i].LastName);
            System.assertEquals(expectedEmail, checkContacts[i].Email);
        }
    }

    @IsTest
    static void testInsertMultipleContactsOnlyOne() {
        // GIVEN the TestDataBulk class
        TestDataBulk tdb = new TestDataBulk();

        // WHEN using it to insert one contact
        Test.startTest();
        Contact[] newContacts = tdb.insertContacts(1);
        Test.stopTest();

        // THEN the contact will exist with the autonumber fields set up
        Contact[] checkContacts = [SELECT Id, LastName, Email FROM Contact ORDER BY LastName];
        System.assertEquals(1, checkContacts.size());
        System.assertEquals('Last1', checkContacts[0].LastName);
        System.assertEquals('test1@test.test', checkContacts[0].Email);
    }

    @IsTest
    static void testInsertMultipleContactsZeroCount() {
        // GIVEN the TestDataBulk class
        TestDataBulk tdb = new TestDataBulk();

        // WHEN request insert zero contacts
        Test.startTest();
        Contact[] newContacts = tdb.insertContacts(0);
        Test.stopTest();

        // THEN no contacts will exist
        Contact[] checkContacts = [SELECT Id, LastName, Email FROM Contact];
        System.assertEquals(0, checkContacts.size());
    }

    @IsTest
    static void testInsertMultipleContacts() {
        // GIVEN the TestDataBulk class
        TestDataBulk tdb = new TestDataBulk();

        // WHEN using it to insert multiple contacts using autonumber (%) notation
        final Integer quantity = 5;
        Map<String, Object> fieldValues = new Map<String, Object>{
                'LastName' => 'TestContact-%',
                'Email' => 'test.contact%@test.test'
        };
        Test.startTest();
        Contact[] newContacts = tdb.insertContacts(quantity, fieldValues, null);
        Test.stopTest();

        // THEN the contacts will exist with the autonumber fields set up
        Contact[] checkContacts = [SELECT Id, LastName, Email FROM Contact ORDER BY LastName];
        System.assertEquals(quantity, checkContacts.size());
        for (Integer i = 0; i < quantity; i++) {
            System.assertEquals(newContacts[i].Id, checkContacts[i].Id);
            String expectedName = 'TestContact-'+(i+1);
            String expectedEmail = 'test.contact'+(i+1)+'@test.test';
            System.assertEquals(expectedName, checkContacts[i].LastName);
            System.assertEquals(expectedEmail, checkContacts[i].Email);
        }
    }

    @IsTest
    static void testInsertMultipleContactsNoFields() {
        // GIVEN the TestDataBulk class
        TestDataBulk tdb = new TestDataBulk();

        // WHEN using it to insert multiple contacts without specifying field values
        final Integer quantity = 5;
        Test.startTest();
        Contact[] newContacts = tdb.insertContacts(quantity, null, null);
        Test.stopTest();

        // THEN the contacts will exist with the default fields values from the Json Library
        String contactJson = new TestDataJsonLibrary.Standard().jsonMap.get(Constants.TDF_CONTACT);
        Map<String, Object> libraryData = (Map<String, Object>) JSON.deserializeUntyped(contactJson);

        Contact[] checkContacts = [SELECT Id, LastName, Email FROM Contact];
        System.assertEquals(quantity, checkContacts.size());
        for (Integer i = 0; i < quantity; i++) {
            System.assertEquals(newContacts[i].Id, checkContacts[i].Id);
            System.assertEquals(libraryData.get('LastName'), checkContacts[i].LastName);
            System.assertEquals(libraryData.get('Email'), checkContacts[i].Email);
        }
    }

    @IsTest
    static void testInsertMultipleContactsWithErrors() {
        // GIVEN the TestDataBulk class
        TestDataBulk tdb = new TestDataBulk();

        // AND we request multiple invalid accounts
        final Integer quantity = 5;
        Map<String, Object> fieldValues = new Map<String, Object>{'LastName' => null};

        // AND we have a list to hold any errors
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN calling insertAccounts
        Test.startTest();
        Contact[] newContacts = tdb.insertContacts(quantity, fieldValues, dbErrors);
        Test.stopTest();

        // THEN the contacts will not exist
        Contact[] checkContacts = [SELECT Id, LastName, Email FROM Contact];
        System.assertEquals(0, checkContacts.size());

        // AND there will be errors in the error list
        System.assertEquals(quantity, dbErrors.size());
        for (Integer i = 0; i < quantity; i++) {
            System.assertEquals(false, dbErrors[i].success);
            System.assertEquals(1, dbErrors[i].errors.size());
        }
    }

    @IsTest
    static void testInsertExceedsLimitsNoBatch() {
        // GIVEN the TestDataBulk class is configured to disallow DMLBatch
        TestDataBulk tdb = new TestDataBulk();
        tdb.allowBatch = false;

        // AND we have a list to hold any errors
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN using tdb to insert multiple accounts that will exceed limits
        Test.startTest();
        Integer amountOverLimits = 10;
        Integer countRecords = Limits.getLimitDmlRows()-amountOverLimits;
        Debug_Parent__c[] dps = new Debug_Parent__c[]{};
        for (Integer i = 0; i<countRecords; i++) {
            dps.add(new Debug_Parent__c(Message_Type__c = 'Dummy'));
        }
        insert dps;
        Integer countAccounts = 2 * amountOverLimits;
        tdb.insertAccounts(countAccounts, new Map<String, Object>{ 'Name' => 'Account%' }, dbErrors);
        Test.stopTest();

        // THEN an error will be returned
        System.assertEquals(1, dbErrors.size());
        System.assertEquals(false, dbErrors[0].success);
        String expectedError = UtilsDML.DmlType.INSERT_OBJECT + UtilsDML.MSG_LIMITS_EXCEEDED;
        System.assertEquals(expectedError, dbErrors[0].errors[0].message);

        // AND no accounts will have been created
        Account[] checkAccounts = [SELECT Id FROM Account];
        System.assertEquals(0, checkAccounts.size());
    }

    @IsTest
    static void testInsertExceedsLimitsWithBatchAndPostProcessing() {
        // GIVEN the TestDataBulk class is configured to allow DMLBatch and Post Processing
        TestDataBulk tdb = new TestDataBulk();
        tdb.allowBatch = true;
        tdb.batchSize = 100;
        tdb.postProcessorClass = 'BatchDMLPostProcessor';

        // AND Monitoring is set up to record post-processing messages
        String postProcessMessageType = BatchDMLPostProcessor.MESSAGE_TYPE;
        insert new Monitoring__c( Name = postProcessMessageType, Active__c = true );

        // AND we have a list to hold any errors
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN using tdb to insert multiple accounts that will exceed limits
        Test.startTest();
        Integer amountOverLimits = 10;
        Integer countRecords = Limits.getLimitDmlRows()-amountOverLimits;
        Debug_Parent__c[] dps = new Debug_Parent__c[]{};
        for (Integer i = 0; i<countRecords; i++) {
            dps.add(new Debug_Parent__c(Message_Type__c = 'Dummy'));
        }
        insert dps;
        Integer countAccounts = 2 * amountOverLimits;
        tdb.insertAccounts(countAccounts, new Map<String, Object>{ 'Name' => 'Account%' }, dbErrors);
        Test.stopTest();

        // THEN no error will be returned
        System.assertEquals(0, dbErrors.size());

        // AND the accounts will have been created
        Account[] checkAccounts = [SELECT Id FROM Account];
        System.assertEquals(countAccounts, checkAccounts.size());

        // AND the post processing will have been completed
        Debug_Parent__c[] dp = [SELECT Id FROM Debug_Parent__c WHERE Message_Type__c = :postProcessMessageType];
        System.assertEquals(1, dp.size());
    }

    @IsTest
    static void testAutonumber() {
        // GIVEN the TestDataBulk class
        TestDataBulk tdb = new TestDataBulk();

        // AND a map containing field values, some of which use the autonumber (%) notation
        Map<String, Object> fieldValues = new Map<String, Object>{
                'TestA' => 'Pass',
                'TestB' => 'Number%',
                'TestC' => 123,
                'TestD' => null,
                'TestE' => 0.234,
                'TestF' => false,
                'TestG' => 'Pass % Pass'
        };
        // WHEN autonumber is called with this list of field values list
        Test.startTest();
        Integer targetValue = 7;
        Map<String, Object> result = tdb.autonumber(fieldValues, targetValue);
        Test.stopTest();

        // THEN the result will be the same values but with the % replaced with the target value
        System.assertEquals(fieldValues.size(), result.size());
        System.assertEquals('Pass', result.get('TestA'));
        System.assertEquals('Number7', result.get('TestB'));
        System.assertEquals(123, result.get('TestC'));
        System.assertEquals(null, result.get('TestD'));
        System.assertEquals(0.234, result.get('TestE'));
        System.assertEquals(false, result.get('TestF'));
        System.assertEquals('Pass 7 Pass', result.get('TestG'));
    }

    @IsTest
    static void testAutonumberWithEmpty() {
        // GIVEN the TestDataBulk class
        TestDataBulk tdb = new TestDataBulk();

        // AND an empty map
        Map<String, Object> emptyMap = new Map<String, Object>();

        // WHEN autonumber is called with the empty map
        Test.startTest();
        Map<String, Object> result = tdb.autonumber(emptyMap, 5);
        Test.stopTest();

        // THEN the result will be an empty map
        System.assertEquals(true, result.isEmpty());
    }

    @IsTest
    static void testAutonumberWithNull() {
        // GIVEN the TestDataBulk class
        TestDataBulk tdb = new TestDataBulk();

        // WHEN autonumber is called with a null list
        Test.startTest();
        Map<String, Object> result = tdb.autonumber(null, 1);
        Test.stopTest();

        // THEN the result will be null
        System.assertEquals(null, result);
    }
}