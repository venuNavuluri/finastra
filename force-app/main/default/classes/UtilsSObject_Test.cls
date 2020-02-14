@IsTest
private class UtilsSObject_Test {

    @IsTest
    static void setSObjectFieldsWithValues() {
        // GIVEN an existing SObject with some values set
        Contact testObject = new Contact(LastName='Test',Email='old@test.test');

        // AND a list of field updates with a range of data types
        Map<String, Object> fieldUpdates = new Map<String, Object> {
                'Email' => 'new@test.test',
                'Birthdate' => Date.newInstance(1963,7,21),
                'Title' => 'Developer',
                'Salutation' => 'Mr.',
                'Phone' => '+44 1268 571654',
                'DoNotCall' => true,
                'FusionBanking_Score__c' => 123
        };

        // WHEN calling setSObjectFields()
        Test.startTest();
        testObject = (Contact) UtilsSObject.setSObjectFields(testObject, fieldUpdates);
        Test.stopTest();

        // THEN the SObject will contain the updated field values
        System.assertEquals('Test', testObject.LastName);
        System.assertEquals(fieldUpdates.get('Email'), testObject.Email);
        System.assertEquals(fieldUpdates.get('Birthdate'), testObject.Birthdate);
        System.assertEquals(fieldUpdates.get('Title'), testObject.Title);
        System.assertEquals(fieldUpdates.get('Salutation'), testObject.Salutation);
        System.assertEquals(fieldUpdates.get('Phone'), testObject.Phone);
        System.assertEquals(fieldUpdates.get('DoNotCall'), testObject.DoNotCall);
        System.assertEquals(fieldUpdates.get('FusionBanking_Score__c'), testObject.FusionBanking_Score__c);
    }

    @IsTest
    static void setSObjectFieldsWithNoValues() {
        // GIVEN an existing SObject with some values set
        Contact testObject = new Contact(LastName = 'Test', Email = 'old@test.test');
        String originalState = JSON.serialize(testObject);

        // AND and empty list of field updates
        Map<String, Object> fieldUpdates = new Map<String, Object>{
        };

        // WHEN calling setSObjectFields()
        Test.startTest();
        testObject = (Contact) UtilsSObject.setSObjectFields(testObject, fieldUpdates);
        Test.stopTest();

        // THEN the SObject will be unchanged
        System.assertEquals(originalState, JSON.serialize(testObject));
    }

    @IsTest
    static void setSObjectFieldsWithNullFieldUpdates() {
        // GIVEN an existing SObject with some values set
        Contact testObject = new Contact(LastName = 'Test', Email = 'old@test.test');
        String originalState = JSON.serialize(testObject);

        // WHEN calling setSObjectFields() with Null for the fieldUpdates
        Test.startTest();
        testObject = (Contact) UtilsSObject.setSObjectFields(testObject, null);
        Test.stopTest();

        // THEN the SObject will be unchanged
        System.assertEquals(originalState, JSON.serialize(testObject));
    }

    @IsTest
    static void setSObjectFieldsWithNullSObject() {
        // GIVEN a list of field updates
        Map<String, Object> fieldUpdates = new Map<String, Object>{
                'Name' => 'Test',
                'Email' => 'new@test.test'
        };

        // WHEN calling setSObjectFields() with a Null object
        Test.startTest();
        SObject testObject = UtilsSObject.setSObjectFields(null, fieldUpdates);
        Test.stopTest();

        // THEN the SObject will return as Null
        System.assertEquals(null, testObject);
    }

    @IsTest
    static void setSObjectFieldsWithInvalidFieldNames() {
        // GIVEN an existing SObject with some values set
        Contact testObject = new Contact(LastName='Test',Email='old@test.test');

        // AND a list of field updates that includes a non-existent field name
        Map<String, Object> fieldUpdates = new Map<String, Object> {
                'NoSuchField__c' => 'Field Value'
        };

        // WHEN calling setSObjectFields()
        Test.startTest();
        Boolean exceptionOccurred = false;
        try {
            testObject = (Contact) UtilsSObject.setSObjectFields(testObject, fieldUpdates);
        }
        catch (Exception e) {
            exceptionOccurred = true;
        }
        Test.stopTest();

        // THEN an exception will occur
        System.assertEquals(true, exceptionOccurred);
    }

    @IsTest
    static void extractNewRecordsFromEmptySource() {
        // GIVEN a source list that contains no SObjects
        SObject[] sourceList = new SObject[]{};

        // WHEN extracting new records
        Test.startTest();
        SObject[] newList = UtilsSObject.extractNewRecords(sourceList);
        Test.stopTest();

        // THEN source list will remain empty
        System.assertEquals(0, sourceList.size());

        // AND new records list will also be empty
        System.assertEquals(0, newList.size());
    }

    @IsTest
    static void extractNewRecordsFromAllExisting() {
        // GIVEN a source list that contains only existing SObjects
        Contact c1 = new Contact(LastName='Test1', Email='test1@test.test');
        Contact c2 = new Contact(LastName='Test2', Email='test2@test.test');
        Contact[] contacts = new Contact[]{ c1, c2 };
        insert contacts;

        // WHEN extracting new records
        Test.startTest();
        Contact[] newContacts = (Contact[]) UtilsSObject.extractNewRecords(contacts);
        Test.stopTest();

        // THEN source list will remain the same
        System.assertEquals(2, contacts.size());

        // AND new records list will be empty
        System.assertEquals(0, newContacts.size());
    }

    @IsTest
    static void extractNewRecordsFromAllNew() {
        // GIVEN a source list that contains only new SObjects
        Contact c1 = new Contact(LastName='Test1', Email='test1@test.test');
        Contact c2 = new Contact(LastName='Test2', Email='test2@test.test');
        Contact[] contacts = new Contact[]{ c1, c2 };

        // WHEN extracting new records
        Test.startTest();
        Contact[] newContacts = (Contact[]) UtilsSObject.extractNewRecords(contacts);
        Test.stopTest();

        // THEN source list will now be empty
        System.assertEquals(0, contacts.size());

        // AND new records list will contain the original records from the source
        System.assertEquals(2, newContacts.size());
        System.assertEquals(c1.LastName, newContacts[0].LastName);
        System.assertEquals(c2.LastName, newContacts[1].LastName);
    }

    @IsTest
    static void extractNewRecordsFromMixed() {
        // GIVEN a source list that contains a mixture of new and existing SObjects
        Contact c1 = new Contact(LastName='Test1', Email='test1@test.test');
        Contact c2 = new Contact(LastName='Test2', Email='test2@test.test');
        Contact c3 = new Contact(LastName='Test3', Email='test3@test.test');
        Contact[] contacts = new Contact[]{ c1, c2 };
        insert contacts;
        contacts.add(c3);

        // WHEN extracting new records
        Test.startTest();
        Contact[] newContacts = (Contact[]) UtilsSObject.extractNewRecords(contacts);
        Test.stopTest();

        // THEN source list will now contain only the existing records
        System.assertEquals(2, contacts.size());
        System.assertEquals(c1.LastName, contacts[0].LastName);
        System.assertEquals(c2.LastName, contacts[1].LastName);

        // AND new records list will contain only the new record
        System.assertEquals(1, newContacts.size());
        System.assertEquals(c3.LastName, newContacts[0].LastName);
    }
}