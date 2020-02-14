@IsTest
private class GenericDMLResult_Test {

    @IsTest
    static void testConstructorSimpleSuccess() {
        // GIVEN some test values
        Boolean testSuccess = true;
        SObject testObject = new Contact(LastName = 'TestValue');
        Id testId = UserInfo.getUserId();

        // WHEN creating a GenericDMLResult via the constructor
        Test.startTest();
        GenericDMLResult genericResult = new GenericDMLResult(testSuccess, testId, testObject);
        Test.stopTest();

        // THEN the resulting object will be populated correctly
        System.assertEquals(testSuccess, genericResult.success);
        System.assertEquals(testId, genericResult.recordId);
        System.assertEquals('TestValue', genericResult.sObj.get('LastName'));
        System.assertEquals(0, genericResult.errors.size());
    }

    @IsTest
    static void testConstructorSimpleFailure() {
        // GIVEN some test values
        Boolean testFailure = false;
        SObject testObject = new Contact(LastName = 'TestValue');
        Id testId = UserInfo.getUserId();

        // WHEN creating a GenericDMLResult via the constructor
        Test.startTest();
        GenericDMLResult genericResult = new GenericDMLResult(testFailure, testId, testObject);
        Test.stopTest();

        // THEN the resulting object will be populated correctly
        System.assertEquals(testFailure, genericResult.success);
        System.assertEquals(testId, genericResult.recordId);
        System.assertEquals('TestValue', genericResult.sObj.get('LastName'));
        System.assertEquals(0, genericResult.errors.size());
    }

    @IsTest
    static void testConstructorSimpleWithNullValues() {
        // GIVEN nothing
        // WHEN creating a GenericDMLResult via the constructor
        Test.startTest();
        GenericDMLResult genericResult = new GenericDMLResult(null, null, null);
        Test.stopTest();

        // THEN the resulting object will be populated correctly
        System.assertEquals(null, genericResult.success);
        System.assertEquals(null, genericResult.recordId);
        System.assertEquals(null, genericResult.sObj);
        System.assertEquals(0, genericResult.errors.size());
    }

    @IsTest
    static void testConstructorWithSingleErrorMessage() {
        // GIVEN an error message string
        String errMessage = 'Test Error';
        Boolean testFailure = false;
        SObject testObject = new Contact(LastName = 'TestValue');
        Id testId = UserInfo.getUserId();

        // WHEN creating a GenericDMLResult via the constructor
        Test.startTest();
        GenericDMLResult genericResult = new GenericDMLResult(testFailure, testId, testObject, errMessage);
        Test.stopTest();

        // THEN the resulting object will be populated correctly
        System.assertEquals(testFailure, genericResult.success);
        System.assertEquals(testId, genericResult.recordId);
        System.assertEquals('TestValue', genericResult.sObj.get('LastName'));
        System.assertEquals(1, genericResult.errors.size());
        System.assertEquals(errMessage, genericResult.errors[0].message);
    }

    @IsTest
    static void testConstructorWithNullErrorMessage() {
        // GIVEN some test data
        String errorMessage = null;
        Boolean testSuccess = true;
        SObject testObject = new Contact(LastName = 'TestValue');
        Id testId = UserInfo.getUserId();

        // WHEN creating a GenericDMLResult via the constructor with a null Error Message
        Test.startTest();
        GenericDMLResult genericResult = new GenericDMLResult(testSuccess, testId, testObject, errorMessage);
        Test.stopTest();

        // THEN the resulting object will be populated correctly
        System.assertEquals(testSuccess, genericResult.success);
        System.assertEquals(testId, genericResult.recordId);
        System.assertEquals('TestValue', genericResult.sObj.get('LastName'));

        // AND there will be no errors
        System.assertEquals(0, genericResult.errors.size());
    }

    @IsTest
    static void testConstructorWithExtraLongErrorMessage() {
        // GIVEN an extra long error message string (at least 1KB)
        String extraLongErrorMessage;
        for (extraLongErrorMessage = '';
                extraLongErrorMessage.length() < 1024;
                extraLongErrorMessage +=
                        '....:....1....:....2....:....3....:....4....:....5....:....6') {
        }

        Boolean testFailure = false;
        SObject testObject = new Contact(LastName = 'TestValue');
        Id testId = UserInfo.getUserId();

        // WHEN creating a GenericDMLResult via the constructor
        Test.startTest();
        GenericDMLResult genericResult = new GenericDMLResult(testFailure, testId, testObject, extraLongErrorMessage);
        Test.stopTest();

        // THEN the resulting object will be populated correctly
        System.assertEquals(testFailure, genericResult.success);
        System.assertEquals(1, genericResult.errors.size());
        System.assertEquals(extraLongErrorMessage, genericResult.errors[0].message);
    }

    @IsTest
    static void testConstructorWithTestValues() {
        // GIVEN some test values
        Boolean testSuccess = true;
        SObject testObject = new Contact(LastName = 'TestValue');
        Id testId = UserInfo.getUserId();
        Database.Error[] testErrors = new Database.Error[]{
        };

        // WHEN creating a GenericDMLResult via the constructor
        Test.startTest();
        GenericDMLResult genericResult = new GenericDMLResult(testSuccess, testId, testObject, testErrors);
        Test.stopTest();

        // THEN the resulting object will be populated correctly
        System.assertEquals(testSuccess, genericResult.success);
        System.assertEquals(testId, genericResult.recordId);
        System.assertEquals('TestValue', genericResult.sObj.get('LastName'));
        System.assertEquals(testErrors.size(), genericResult.errors.size());
    }

    @IsTest
    static void testConstructorWithDMLResultFailSingleField() {
        // GIVEN an invalid record to insert
        Contact c = new Contact(); // will fail - LastName is mandatory
        Database.SaveResult sr = Database.insert(c, false);

        // WHEN creating a GenericDMLResult via the constructor
        Test.startTest();
        GenericDMLResult genericResult = new GenericDMLResult(sr.isSuccess(), sr.getId(), c, sr.getErrors());
        Test.stopTest();

        // THEN the resulting object will be populated correctly
        System.assertEquals(false, genericResult.success);
        System.assertEquals(null, genericResult.recordId);

        // AND inner class GenericError is also populated correctly
        System.assertEquals(1, genericResult.errors.size());
        System.assertEquals(sr.getErrors().size(), genericResult.errors.size());
        Database.Error dmlError = sr.getErrors().get(0);
        System.assertEquals('LastName', genericResult.errors[0].fields);
        System.assertEquals(dmlError.getMessage(), genericResult.errors[0].message);
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, genericResult.errors[0].statusCode);
    }

    @IsTest
    static void testConstructorWithDMLResultFailMultipleFields() {
        // GIVEN an invalid record to insert
        Opportunity opp = new Opportunity(); // will fail - Name, StageName, CloseDate are mandatory
        Database.SaveResult sr = Database.insert(opp, false);

        // WHEN creating a GenericDMLResult via the constructor
        Test.startTest();
        GenericDMLResult genericResult = new GenericDMLResult(sr.isSuccess(), sr.getId(), opp, sr.getErrors());
        Test.stopTest();

        // THEN the resulting object will be populated correctly
        System.assertEquals(false, genericResult.success);
        System.assertEquals(null, genericResult.recordId);

        // AND inner class GenericError is also populated correctly
        System.assertEquals(1, genericResult.errors.size());
        System.assertEquals(sr.getErrors().size(), genericResult.errors.size());
        Database.Error dmlError = sr.getErrors().get(0);
        System.assertEquals('Name,StageName,CloseDate', genericResult.errors[0].fields);
        System.assertEquals(dmlError.getMessage(), genericResult.errors[0].message);
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, genericResult.errors[0].statusCode);
    }

    @IsTest
    static void testConstructorWithDMLResultFailNoFields() {
        // GIVEN an invalid record to update
        Account acc = new Account(); // update will fail - record does not exist / no Id specified
        Database.SaveResult sr = Database.update(acc, false);

        // WHEN creating a GenericDMLResult via the constructor
        Test.startTest();
        GenericDMLResult genericResult = new GenericDMLResult(sr.isSuccess(), sr.getId(), acc, sr.getErrors());
        Test.stopTest();

        // THEN the resulting object will be populated correctly
        System.assertEquals(false, genericResult.success);
        System.assertEquals(null, genericResult.recordId);

        // AND inner class GenericError is also populated correctly
        System.assertEquals(1, genericResult.errors.size());
        System.assertEquals(sr.getErrors().size(), genericResult.errors.size());
        Database.Error dmlError = sr.getErrors().get(0);
        System.assertEquals('', genericResult.errors[0].fields);
        System.assertEquals(dmlError.getMessage(), genericResult.errors[0].message);
        System.assertEquals(StatusCode.MISSING_ARGUMENT, genericResult.errors[0].statusCode);
    }

    @IsTest
    static void testConstructorWithDMLResultPass() {
        // GIVEN a valid record to insert
        String testEmail = 'test@test.test';
        String testName = 'Test-name';
        Contact c = new Contact(LastName = testName, Email = testEmail);
        Database.SaveResult sr = Database.insert(c, false);

        // WHEN creating a GenericDMLResult via the constructor
        Test.startTest();
        GenericDMLResult genericResult = new GenericDMLResult(sr.isSuccess(), sr.getId(), c, sr.getErrors());
        Test.stopTest();

        // THEN the resulting object will be populated correctly
        System.assertEquals(true, genericResult.success);
        System.assertEquals(c.Id, genericResult.recordId);
        System.assertEquals(testEmail, genericResult.sObj.get('Email'));
        System.assertEquals(0, genericResult.errors.size());
    }

    @IsTest
    static void testConstructorWithAnyProfile() {
        // GIVEN we are a Standard User
        User standardUser = TestUtils.getStandardInternalUser('std');
        System.runAs(standardUser) {

            // AND we have a valid record to insert
            Contact c = new Contact(LastName = 'Test', Email = 'test@test.test');
            Database.SaveResult sr = Database.insert(c, false);

            // WHEN creating a GenericDMLResult via the constructor
            Test.startTest();
            GenericDMLResult genericResult = new GenericDMLResult(sr.isSuccess(), sr.getId(), c, sr.getErrors());
            Test.stopTest();

            // THEN the resulting object will be populated correctly
            System.assertEquals(true, genericResult.success);
            System.assertEquals(c.Id, genericResult.recordId);
            System.assertEquals(0, genericResult.errors.size());
        }
    }

    @IsTest
    static void genericErrorConstructor() {
        // GIVEN some error message parameters
        String errorMessage = 'Test Message 1';
        String errorFields = 'One,Two,Three';
        StatusCode errorCode = StatusCode.REQUIRED_FIELD_MISSING;

        // WHEN calling the GenericError constructor
        Test.startTest();
        GenericDMLResult.GenericError ge = new GenericDMLResult.GenericError(errorMessage, errorFields, errorCode);
        Test.stopTest();

        // THEN the GenericError attributes will be populated accordingly
        System.assertEquals(errorMessage, ge.message);
        System.assertEquals(errorFields, ge.fields);
        System.assertEquals(errorCode, ge.statusCode);
    }

    @IsTest
    static void genericErrorConstructorWithNullValues() {
        // GIVEN nothing
        // WHEN calling the GenericError constructor with null values
        Test.startTest();
        GenericDMLResult.GenericError ge = new GenericDMLResult.GenericError(null, null, null);
        Test.stopTest();

        // THEN the GenericError attributes will be populated accordingly
        System.assertEquals(null, ge.message);
        System.assertEquals(null, ge.fields);
        System.assertEquals(null, ge.statusCode);
    }

    @IsTest
    static void genericErrorConstructorWithDatabaseError() {
        // GIVEN an invalid record to insert
        String testEmail = 'test@test.test';
        Contact c = new Contact(Email = testEmail); // will fail - LastName is mandatory
        Database.SaveResult sr = Database.insert(c, false);
        Database.Error de = sr.getErrors()[0];

        // WHEN calling the GenericError constructor passing the DML error
        Test.startTest();
        GenericDMLResult.GenericError ge = new GenericDMLResult.GenericError(de);
        Test.stopTest();

        // THEN the resulting object will be populated correctly
        System.assertEquals(de.getMessage(), ge.message);
        System.assertEquals('LastName', ge.fields);
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, ge.statusCode);
    }

    @IsTest
    static void genericErrorConstructorWithDatabaseError2() {
        // GIVEN a valid contact
        Contact c = new Contact(LastName = 'Test Name', Email = 'test@test.test');
        insert c;

        // AND as a user without permission
        User testUser = TestUtils.getStandardInternalUser('user1');
        System.runAs(testUser) {

            // AND attempting to delete the record
            Database.DeleteResult dr = Database.delete(c, false);
            Database.Error de = dr.getErrors()[0];

            // WHEN calling the GenericError constructor passing the DML error
            Test.startTest();
            GenericDMLResult.GenericError ge = new GenericDMLResult.GenericError(de);
            Test.stopTest();

            // THEN the resulting object will be populated correctly
            System.assertEquals(de.getMessage(), ge.message);
            System.assertEquals('', ge.fields);
            System.assertEquals(StatusCode.INSUFFICIENT_ACCESS_OR_READONLY, ge.statusCode);
        }
    }

    @IsTest
    static void makeGenericFromInsertResultsSimple() {
        // GIVEN we have the results from inserting records
        Account acc = new Account(Name = 'Test Account');
        Account[] accs = new Account[]{ acc };
        Database.SaveResult[] sr = Database.insert(accs, false);

        // WHEN calling makeGeneric
        Test.startTest();
        GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(sr, accs);
        Test.stopTest();

        // THEN there should be 1 results
        System.assertEquals(1, genericResults.size());

        // AND the result will be successful
        System.assertEquals(true, genericResults[0].success);
        System.assertEquals(acc.Id, genericResults[0].recordId);
        System.assertEquals(0, genericResults[0].errors.size());
    }

    @IsTest
    static void makeGenericFromInsertResultsMixed() {
        // GIVEN we have the results from inserting records
        Contact c1 = new Contact(LastName = 'Test1', Email = 'test1@test.test');
        Contact c2 = new Contact(Email = 'test2@test.test');
        Contact[] contacts = new Contact[]{ c1, c2 };
        Database.SaveResult[] sr = Database.insert(contacts, false);

        // WHEN calling makeGeneric
        Test.startTest();
        GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(sr, contacts);
        Test.stopTest();

        // THEN there should be 2 results
        System.assertEquals(2, genericResults.size());

        // AND the first result will be successful (c1)
        System.assertEquals(true, genericResults[0].success);
        System.assertEquals(sr[0].getId(), genericResults[0].recordId);
        System.assertEquals(c1.Email, genericResults[0].sObj.get('Email'));
        System.assertEquals(0, genericResults[0].errors.size());

        // AND the second result will be failed (c2)
        System.assertEquals(false, genericResults[1].success);
        System.assertEquals(sr[1].getId(), genericResults[1].recordId);
        System.assertEquals(c2.Email, genericResults[1].sObj.get('Email'));
        System.assertEquals(sr[1].getErrors().size(), genericResults[1].errors.size());
    }

    @IsTest
    static void makeGenericFromUpdateResultsSuccess() {
        // GIVEN we have some existing records
        Contact c1 = new Contact(LastName = 'Test1', Email = 'test1@test.test');
        Contact c2 = new Contact(LastName = 'Test2', Email = 'test2@test.test');
        Contact[] contacts = new Contact[]{ c1, c2 };
        insert contacts;

        // AND we have the results from performing an update
        c1.FirstName = 'New1';
        c2.LastName = 'New2';
        Database.SaveResult[] sr = Database.update(contacts, false);

        // WHEN calling makeGeneric
        Test.startTest();
        GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(sr, contacts);
        Test.stopTest();

        // THEN there should be 2 results
        System.assertEquals(2, genericResults.size());

        // AND the first result will be successful (c1)
        System.assertEquals(true, genericResults[0].success);
        System.assertEquals(sr[0].getId(), genericResults[0].recordId);
        System.assertEquals(c1.Email, genericResults[0].sObj.get('Email'));
        System.assertEquals(c1.FirstName, genericResults[0].sObj.get('FirstName'));
        System.assertEquals(0, genericResults[0].errors.size());

        // AND the second result will be successful (c2)
        System.assertEquals(true, genericResults[1].success);
        System.assertEquals(sr[1].getId(), genericResults[1].recordId);
        System.assertEquals(c2.Email, genericResults[1].sObj.get('Email'));
        System.assertEquals(c2.LastName, genericResults[1].sObj.get('LastName'));
        System.assertEquals(0, genericResults[1].errors.size());
    }

    @IsTest
    static void makeGenericFromUpdateResultsFailure() {
        // GIVEN we have some existing records
        Contact c1 = new Contact(LastName = 'Test1', Email = 'test1@test.test');
        insert c1;
        Contact[] contacts = new Contact[]{ c1 };

        // AND we have the results from performing an invalid update
        c1.LastName = null;
        Database.SaveResult[] sr = Database.update(contacts, false);

        // WHEN calling makeGeneric
        Test.startTest();
        GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(sr, contacts);
        Test.stopTest();

        // THEN there should be 1 results
        System.assertEquals(1, genericResults.size());

        // AND the result will be failed
        System.assertEquals(false, genericResults[0].success);
        System.assertEquals(sr[0].getId(), genericResults[0].recordId);
        System.assertEquals(1, genericResults[0].errors.size());
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, genericResults[0].errors[0].statusCode);
    }

    @IsTest
    static void makeGenericFromUpsertResultsSuccess() {
        // GIVEN we have an existing record to update
        Contact c1 = new Contact(LastName = 'Test1', Email = 'test1@test.test');
        insert c1;
        c1.FirstName = 'New1';

        // AND a new record to insert
        Contact c2 = new Contact(LastName = 'Test2', Email = 'test2@test.test');
        Contact[] contacts = new Contact[]{ c1, c2 };

        // AND we have the results from performing an upsert
        Database.UpsertResult[] ur = Database.upsert(contacts, false);

        // WHEN calling makeGeneric
        Test.startTest();
        GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(ur, contacts);
        Test.stopTest();

        // THEN there should be 2 results
        System.assertEquals(2, genericResults.size());

        // AND the first result will be successful (c1)
        System.assertEquals(true, genericResults[0].success);
        System.assertEquals(ur[0].getId(), genericResults[0].recordId);
        System.assertEquals(c1.Email, genericResults[0].sObj.get('Email'));
        System.assertEquals(c1.FirstName, genericResults[0].sObj.get('FirstName'));
        System.assertEquals(0, genericResults[0].errors.size());

        // AND the second result will be successful (c2)
        System.assertEquals(true, genericResults[1].success);
        System.assertEquals(ur[1].getId(), genericResults[1].recordId);
        System.assertEquals(c2.Email, genericResults[1].sObj.get('Email'));
        System.assertEquals(0, genericResults[1].errors.size());
    }

    @IsTest
    static void makeGenericFromUpsertResultsFailure() {
        // GIVEN we have an existing record to update
        Contact c1 = new Contact(LastName = 'Test1', Email = 'test1@test.test');
        insert c1;
        c1.LastName = null; // invalid update

        // AND a new record to insert
        Contact c2 = new Contact(Email = 'test2@test.test'); // invalid
        Contact[] records = new Contact[]{ c1, c2 };

        // AND we have the results from performing an upsert
        Database.UpsertResult[] ur = Database.upsert(records, false);

        // WHEN calling makeGeneric
        Test.startTest();
        GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(ur, records);
        Test.stopTest();

        // THEN there should be 2 results
        System.assertEquals(2, genericResults.size());

        // AND the first result will be a failure (con)
        System.assertEquals(false, genericResults[0].success);
        System.assertEquals(c1, genericResults[0].sObj);
        System.assertEquals(1, genericResults[0].errors.size());
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, genericResults[0].errors[0].statusCode);

        // AND the second result will also be a failure (acc)
        System.assertEquals(false, genericResults[1].success);
        System.assertEquals(c2, genericResults[1].sObj);
        System.assertEquals(1, genericResults[1].errors.size());
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, genericResults[1].errors[0].statusCode);
    }

    @IsTest
    static void makeGenericFromDeleteResultsSuccess() {
        // GIVEN we have some existing records of mixed types
        Contact con = new Contact(LastName = 'Test1', Email = 'test1@test.test');
        Account acc = new Account(Name = 'Test Account');
        SObject[] records = new SObject[]{ con, acc };
        insert records;

        // AND we have the results from performing a delete
        Database.DeleteResult[] dr = Database.delete(records, false);

        // WHEN calling makeGeneric
        Test.startTest();
        GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(dr, records);
        Test.stopTest();

        // THEN there should be 2 results
        System.assertEquals(2, genericResults.size());

        // AND the first result will be successful (c1)
        System.assertEquals(true, genericResults[0].success);
        System.assertEquals(dr[0].getId(), genericResults[0].recordId);
        System.assertEquals(con.LastName, genericResults[0].sObj.get('LastName'));
        System.assertEquals(0, genericResults[0].errors.size());

        // AND the second result will be successful (c2)
        System.assertEquals(true, genericResults[1].success);
        System.assertEquals(dr[1].getId(), genericResults[1].recordId);
        System.assertEquals(acc.Name, genericResults[1].sObj.get('Name'));
        System.assertEquals(0, genericResults[1].errors.size());
    }

    @IsTest
    static void makeGenericFromDeleteResultsFailure() {
        // GIVEN we have some existing records of mixed types
        Contact con = new Contact(LastName = 'Test1', Email = 'test1@test.test');
        SObject[] records = new SObject[]{ con };
        insert records;

        // AND we are logged in as a user without permission to delete those records
        User standardUser = TestUtils.getStandardInternalUser('std');
        Database.DeleteResult[] dr;
        System.runAs(standardUser) {

            // AND we have the results from attempting to delete
            dr = Database.delete(records, false);
        }

        // WHEN calling makeGeneric
        Test.startTest();
        GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(dr, records);
        Test.stopTest();

        // THEN there should be 1 results
        System.assertEquals(1, genericResults.size());

        // AND the result will be a failure
        System.assertEquals(false, genericResults[0].success);
        System.assertEquals(con.Id, genericResults[0].recordId);
        System.assertEquals(1, genericResults[0].errors.size());
        System.assertEquals(StatusCode.INSUFFICIENT_ACCESS_OR_READONLY, genericResults[0].errors[0].statusCode);
    }

    @IsTest
    static void makeGenericFromDeleteResultsFailure2() {
        // GIVEN we have an existing record
        Account acc = new Account(Name = 'Test Account');
        Account[] accounts = new Account[]{ acc };
        insert acc;

        // BUT already deleted
        delete acc;

        // AND we have the results from attempting a delete
        Database.DeleteResult[] dr = Database.delete(accounts, false);

        // WHEN calling makeGeneric
        Test.startTest();
        GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(dr, accounts);
        Test.stopTest();

        // THEN there should be 1 result
        System.assertEquals(1, genericResults.size());

        // AND the result will be a failure
        System.assertEquals(false, genericResults[0].success);
        System.assertEquals(1, genericResults[0].errors.size());
        System.assertEquals(StatusCode.ENTITY_IS_DELETED, genericResults[0].errors[0].statusCode);
    }

    @IsTest
    static void makeGenericFromUndeleteResultsSuccess() {
        // GIVEN we have some existing records that have been deleted
        Contact c1 = new Contact(LastName = 'Test1', Email = 'test1@test.test');
        Contact c2 = new Contact(LastName = 'Test2', Email = 'test2@test.test');
        Contact[] contacts = new Contact[]{ c1, c2 };
        insert contacts;
        delete contacts;

        // AND we have the results from performing an undelete
        Database.UndeleteResult[] xr = Database.undelete(contacts, false);

        // WHEN calling makeGeneric
        Test.startTest();
        GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(xr, contacts);
        Test.stopTest();

        // THEN there should be 2 results
        System.assertEquals(2, genericResults.size());

        // AND the first result will be successful (c1)
        System.assertEquals(true, genericResults[0].success);
        System.assertEquals(xr[0].getId(), genericResults[0].recordId);
        System.assertEquals(c1.Email, genericResults[0].sObj.get('Email'));
        System.assertEquals(0, genericResults[0].errors.size());

        // AND the second result will be successful (c2)
        System.assertEquals(true, genericResults[1].success);
        System.assertEquals(xr[1].getId(), genericResults[1].recordId);
        System.assertEquals(c2.Email, genericResults[1].sObj.get('Email'));
        System.assertEquals(0, genericResults[1].errors.size());
    }

    @IsTest
    static void makeGenericFromUndeleteResultsFailure() {
        // GIVEN we have some existing records
        Contact c1 = new Contact(LastName = 'Test1', Email = 'test1@test.test');
        Contact c2 = new Contact(LastName = 'Test2', Email = 'test2@test.test');
        Contact[] contacts = new Contact[]{ c1, c2 };
        insert contacts;

        // AND only one is deleted
        delete c1;

        // AND we have attempt to undelete both
        Database.UndeleteResult[] xr = Database.undelete(contacts, false);

        // WHEN calling makeGeneric
        Test.startTest();
        GenericDMLResult[] genericResults = GenericDMLResult.makeGeneric(xr, contacts);
        Test.stopTest();

        // THEN there should be 2 results
        System.assertEquals(2, genericResults.size());

        // AND the first result will be successful (c1)
        System.assertEquals(true, genericResults[0].success);
        System.assertEquals(xr[0].getId(), genericResults[0].recordId);
        System.assertEquals(c1.Email, genericResults[0].sObj.get('Email'));
        System.assertEquals(0, genericResults[0].errors.size());

        // AND the second result will be a failure (c2)
        System.assertEquals(false, genericResults[1].success);
        System.assertEquals(xr[1].getId(), genericResults[1].recordId);
        System.assertEquals(1, genericResults[1].errors.size());
        System.assertEquals(StatusCode.UNDELETE_FAILED, genericResults[1].errors[0].statusCode);
    }
}