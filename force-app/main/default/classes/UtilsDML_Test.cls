@IsTest
private class UtilsDML_Test {

    @IsTest
    static void genericDML_NullDmlType() {
        // GIVEN some records
        Contact[] contacts = sampleRecords(1);

        // WHEN calling genericDML with no DmlType
        Test.startTest();
            Boolean exceptionOccurred = false;
            try {
                Boolean success = UtilsDML.genericDML(null, contacts);
            }
            catch(UtilsDml.UtilsDMLException ex) {
                exceptionOccurred = true;
            }
        Test.stopTest();

        // THEN exception should be raised
        System.assertEquals(true, exceptionOccurred);
    }

    @IsTest
    static void genericDML_NullRecords() {
        // GIVEN nothing
        // WHEN calling genericDML to INSERT but not providing any records
        Test.startTest();
            Boolean exceptionOccurred = false;
            try {
                Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.INSERT_OBJECT, null);
            }
            catch(UtilsDML.UtilsDMLException ex) {
                exceptionOccurred = true;
            }
        Test.stopTest();

        // THEN exception should be raised
        System.assertEquals(true, exceptionOccurred);
    }

    @IsTest
    static void genericDML_SimpleInsert() {
        // GIVEN sample records to insert
        Contact[] sample = sampleRecords(2);

        // WHEN calling genericDML to INSERT these records
        Test.startTest();
            Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.INSERT_OBJECT, sample);
        Test.stopTest();

        // THEN success should be true
        System.assertEquals(true, success);

        // AND the records have been inserted successfully
        System.assertEquals(true, verifyData(sample));
    }

    @IsTest
    static void genericDML_SimpleUpdate() {
        // GIVEN existing records
        Contact[] existing = sampleRecords(2);
        insert existing;

        // WHEN calling genericDML to UPDATE these records
        Test.startTest();
            existing[0].LastName='Fred';
            existing[1].LastName='James';
            Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.UPDATE_OBJECT, existing);
        Test.stopTest();

        // THEN success should be true
        System.assertEquals(true, success);

        // AND the records have been updated correctly
        System.assertEquals(true, verifyData(existing));
    }

    @IsTest
    static void genericDML_SimpleUpsert() {
        // GIVEN some existing records
        Contact[] existing = sampleRecords(2);
        insert existing;

        // AND some records which include both changes and new records
        Contact[] contacts = sampleRecords(5);
        contacts[0].Id = existing[0].Id;
        contacts[0].LastName = 'Fred';  // change to existing record
        contacts[1].Id = existing[1].Id;
        contacts[1].LastName = 'James'; // change to existing record

        // WHEN calling genericDML to UPSERT these records
        Test.startTest();
            Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.UPSERT_OBJECT, contacts);
        Test.stopTest();

        // THEN success should be true
        System.assertEquals(true, success);

        // AND the records have been inserted/updated successfully
        System.assertEquals(true, verifyData(contacts));
    }

    @IsTest
    static void genericDML_SimpleDelete() {
        // GIVEN existing records
        Contact[] existing = sampleRecords(2);
        insert existing;

        // WHEN calling genericDML to UPDATE these records
        Test.startTest();
            Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.DELETE_OBJECT, existing);
        Test.stopTest();

        // THEN success should be true
        System.assertEquals(true, success);

        // AND the records have been deleted successfully
        Contact[] noRecords = new Contact[]{};
        System.assertEquals(true, verifyData(noRecords));
    }

    @IsTest
    static void genericDML_SimpleUndelete() {
        // GIVEN existing records which have been deleted
        Contact[] deleted = sampleRecords(2);
        insert deleted;
        delete deleted;

        // WHEN calling genericDML to UNDELETE these records
        Test.startTest();
            Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.UNDELETE_OBJECT, deleted);
        Test.stopTest();

        // THEN success should be true
        System.assertEquals(true, success);

        // AND the records have been restored successfully
        System.assertEquals(true, verifyData(deleted));
    }

    @IsTest
    static void genericDML_InsertWithNoErrors() {
        // GIVEN some valid records to insert
        Contact[] contacts = sampleRecords(3);

        // AND a list to store some errors in
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN calling genericDML to INSERT these records
        Test.startTest();
            Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.INSERT_OBJECT, contacts, dbErrors, false, null, false, 0);
        Test.stopTest();

        // THEN success should be true
        System.assertEquals(true, success);

        // AND the records have been inserted successfully
        System.assertEquals(true, verifyData(contacts));

        // AND the list of errors is empty
        System.assertEquals(0, dbErrors.size());
    }

    @IsTest
    static void genericDML_UpdateWithNoErrors() {
        // GIVEN some existing records
        Contact[] existing = sampleRecords(2);
        insert existing;

        // AND some changes to be updated
        existing[0].LastName = 'Fred';
        existing[1].LastName = 'James';

        // AND a list to store some errors in
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN calling genericDML to UPSERT these records
        Test.startTest();
            Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.UPDATE_OBJECT, existing, dbErrors, false, null, false, 0);
        Test.stopTest();

        // THEN success should be true
        System.assertEquals(true, success);

        // AND the records have been updated successfully
        System.assertEquals(true, verifyData(existing));

        // AND the list of errors is empty
        System.assertEquals(0, dbErrors.size());
    }

    @IsTest
    static void genericDML_UpsertWithNoErrors() {
        // GIVEN some existing records
        Contact[] existing = sampleRecords(2);
        insert existing;

        // AND some records which include both changes and new records
        Contact[] contacts = sampleRecords(5);
        contacts[0].Id = existing[0].Id;
        contacts[0].LastName = 'Fred';  // change to existing record
        contacts[1].Id = existing[1].Id;
        contacts[1].LastName = 'James'; // change to existing record

        // AND a list to store some errors in
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN calling genericDML to UPSERT these records
        Test.startTest();
            Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.UPSERT_OBJECT, contacts, dbErrors, false, null, false, 0);
        Test.stopTest();

        // THEN success should be true
        System.assertEquals(true, success);

        // AND the records have been inserted/updated successfully
        System.assertEquals(true, verifyData(contacts));

        // AND the list of errors is empty
        System.assertEquals(0, dbErrors.size());
    }

    @IsTest
    static void genericDML_DeleteWithNoErrors() {
        // GIVEN some existing records
        Contact[] existing = sampleRecords(2);
        insert existing;

        // AND a list to store some errors in
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN calling genericDML to DELETE these records
        Test.startTest();
            Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.DELETE_OBJECT, existing, dbErrors, false, null, false, 0);
        Test.stopTest();

        // THEN success should be true
        System.assertEquals(true, success);

        // AND the records have been deleted successfully
        Contact[] noRecords = new Contact[]{};
        System.assertEquals(true, verifyData(noRecords));

        // AND the list of errors is empty
        System.assertEquals(0, dbErrors.size());
    }

    @IsTest
    static void genericDML_UndeleteWithNoErrors() {
        // GIVEN some deleted records
        Contact[] deleted = sampleRecords(2);
        insert deleted;
        delete deleted;

        // AND a list to store some errors in
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN calling genericDML to UNDELETE these records
        Test.startTest();
            Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.UNDELETE_OBJECT, deleted, dbErrors, false, null, false, 0);
        Test.stopTest();

        // THEN success should be true
        System.assertEquals(true, success);

        // AND the records have been restored successfully
        System.assertEquals(true, verifyData(deleted));

        // AND the list of errors is empty
        System.assertEquals(0, dbErrors.size());
    }

    @IsTest
    static void genericDML_InsertWithErrors() {
        // GIVEN one valid record to insert
        Contact[] contacts = sampleRecords(1);

        // AND one record that will not insert because of errors
        contacts.add(new Contact()); // missing mandatory fields);

        // AND a list to store some errors in
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // AND we do not request the errors to be saved
        Boolean saveErrors = false;
        String messageType = 'Test';

        // AND even though monitoring is enabled for the User
        insert new MonitoringCoverage__c(SetupOwnerId=UserInfo.getUserId(), Enable__c=true);

        // WHEN calling genericDML to INSERT these records
        Test.startTest();
            Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.INSERT_OBJECT, contacts, dbErrors, saveErrors, messageType, false, 0);
        Test.stopTest();

        // THEN success should be false
        System.assertEquals(false, success);

        // AND only the valid record has been inserted successfully
        System.assertEquals(true, verifyData(new Contact[]{contacts[0]}));

        // AND the list of errors has one entry
        System.assertEquals(1, dbErrors.size());

        // AND no Debug Messages have been saved
        System.assertEquals(null, getDebugMessages(messageType));
    }

    @IsTest
    static void genericDML_InsertWithErrorsAndSave() {
        // GIVEN one valid record to insert
        Contact[] contacts = sampleRecords(1);

        // AND one record that will not insert because of errors
        contacts.add(new Contact()); // missing mandatory fields);

        // AND a list to store some errors in
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // AND we request that the errors are saved
        Boolean saveErrors = true;
        String messageType = 'Test';

        // AND monitoring is enabled for the User
        insert new MonitoringCoverage__c(SetupOwnerId=UserInfo.getUserId(), Enable__c=true);
        UtilsMonitoring.setupMonitoring();

        // WHEN calling genericDML to INSERT these records
        Test.startTest();
            Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.INSERT_OBJECT, contacts, dbErrors, saveErrors, messageType, false, 0);
        Test.stopTest();

        // THEN success should be false
        System.assertEquals(false, success);

        // AND only the valid record has been inserted successfully
        System.assertEquals(true, verifyData(new Contact[]{contacts[0]}));

        // AND the list of errors has one entry
        System.assertEquals(1, dbErrors.size());

        // AND a Debug Message exists
        System.assertEquals(1, getDebugMessages(messageType).size());
    }

    @IsTest
    static void genericDML_NoPermission() {
        // GIVEN a valid record to insert
        Debug_Parent__c dp = new Debug_Parent__c(Message_Type__c = 'Parent');
        Debug_Parent__c[] dps = new Debug_Parent__c[]{ dp };

        // AND a standard user who does not have permissions on that object
        User user1 = TestUtils.getStandardInternalUser('User1');
        insert user1;

        // AND a list to store some errors in
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // AND we want the errors to be saved
        Boolean saveErrors = true;
        String messageType = 'Test';

        System.runAs(user1) {

            // AND monitoring is enabled for the User
            insert new MonitoringCoverage__c(SetupOwnerId=user1.Id, Enable__c=true);

            // WHEN calling genericDML to INSERT these records
            Test.startTest();
                Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.INSERT_OBJECT, dps, dbErrors, saveErrors, messageType, false, 0);
            Test.stopTest();

            // THEN success should be false
            System.assertEquals(false, success);
        }

        // AND the record has not been inserted
        System.assertEquals(null, getDebugMessages('Parent'));

        // AND the list of errors contains the permission error
        System.assertEquals(1, dbErrors.size());
        System.assertEquals(true, dbErrors[0].errors[0].message.startsWith(UtilsDML.MSG_NO_PERMISSION));

        // AND the debug message contains the permission error
        Debug_Message__c[] dm = getDebugMessages(messageType);
        System.assertEquals(1, dm.size());
        System.assertEquals(true, dm[0].Message__c.startsWith(UtilsDML.MSG_NO_PERMISSION));
    }

    @IsTest
    static void genericDML_InsertExceedsDMLStatementsNoBatch() {
        // GIVEN some valid records to insert
        Contact[] contacts = sampleRecords(10);

        // AND batch mode is disabled
        Boolean batchModeAllowed = false;

        // AND a list to store some errors in
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // WHEN calling genericDML to INSERT these records after DML Statement count is set to be exceeded
        Test.startTest();
            for (Integer i = 0; i<Limits.getLimitDmlStatements(); i++) {
                insert new Debug_Parent__c(Message_Type__c = 'Dummy');
            }
            Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.INSERT_OBJECT, contacts, dbErrors, false, null, batchModeAllowed, 0);
        Test.stopTest();

        // THEN success should be false
        System.assertEquals(false, success);

        // AND no records have been inserted
        Contact[] noRecords = new Contact[]{};
        System.assertEquals(true, verifyData(noRecords));

        // AND the error message is as expected
        String expectedError = UtilsDML.DmlType.INSERT_OBJECT + UtilsDML.MSG_LIMITS_EXCEEDED;
        System.assertEquals(1, dbErrors.size());
        System.assertEquals(expectedError, dbErrors[0].errors[0].message);
    }

    @IsTest
    static void genericDML_InsertExceedsDMLRowsNoBatch() {
        // GIVEN some valid records to insert
        Contact[] contacts = sampleRecords(10);

        // AND a list to store some errors in
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // AND we request that the errors are saved
        Boolean saveErrors = true;
        String messageType = 'Test';

        // AND monitoring is enabled for the User
        insert new MonitoringCoverage__c(SetupOwnerId=UserInfo.getUserId(), Enable__c=true);

        // AND batch mode is disabled
        Boolean batchModeAllowed = false;

        // WHEN calling genericDML to INSERT these records after DML Rows count is set to be exceeded
        Test.startTest();
            Debug_Parent__c[] dps = new Debug_Parent__c[]{};
            for (Integer i = 0; i<Limits.getLimitDmlRows()-5; i++) {
                dps.add(new Debug_Parent__c(Message_Type__c = 'Dummy'));
            }
            insert dps;
            Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.INSERT_OBJECT, contacts, dbErrors, saveErrors, messageType, batchModeAllowed, 0);
        Test.stopTest();

        // THEN success should be false
        System.assertEquals(false, success);

        // AND no records have been inserted
        Contact[] noRecords = new Contact[]{};
        System.assertEquals(true, verifyData(noRecords));

        // AND the error is as expected
        Debug_Message__c[] dm = getDebugMessages(messageType);
        System.assertEquals(1, dm.size());
        String expectedError = UtilsDML.DmlType.INSERT_OBJECT + UtilsDML.MSG_LIMITS_EXCEEDED;
        System.assertEquals(expectedError, dm[0].Message__c);
    }

    @IsTest
    static void genericDML_InsertDoesBatch() {
        // GIVEN some valid records to insert
        Contact[] contacts = sampleRecords(9);
        contacts.add(new Contact(Email='test@test.test'));

        // AND a list to store some errors in
        GenericDMLResult[] dbErrors = new GenericDMLResult[]{};

        // AND batch mode is disabled
        Boolean batchModeAllowed = true;
        String postProcessingClass = 'BatchDMLPostProcessor';

        // WHEN calling genericDML to INSERT these records after DML Rows count is set to be exceeded
        Test.startTest();
            Debug_Parent__c[] dps = new Debug_Parent__c[]{};
            for (Integer i = 0; i<Limits.getLimitDmlRows()-5; i++) {
                dps.add(new Debug_Parent__c(Message_Type__c = 'Dummy'));
            }
            insert dps;
            Boolean success = UtilsDML.genericDML(UtilsDML.DmlType.INSERT_OBJECT, contacts, dbErrors, false, null,
                    batchModeAllowed, 50, postProcessingClass);
        Test.stopTest();

        // THEN success should be true
        System.assertEquals(true, success);

        // AND the records have been inserted successfully
        contacts.remove(9);
        System.assertEquals(true, verifyData(contacts));
    }

    @IsTest
    static void checkDMLLimitsPass() {
        // GIVEN system governor limits for DML statements and DML rows
        Integer dmlMaxStatements = Limits.getLimitDmlStatements();
        Integer dmlMaxRows = Limits.getLimitDmlRows();

        // AND some limits are already used
        Test.startTest();
            Contact[] contacts = sampleRecords(2);
            insert contacts;
            Integer dmlStatementsUsed = Limits.getDmlStatements();
            Integer dmlRowsUsed = Limits.getLimitDmlRows();

            // WHEN checking DML limits for any number of statements & rows that do not exceed the limits
            Boolean result1 = UtilsDML.checkDMLLimits(1, 1);
            Boolean result2 = UtilsDML.checkDMLLimits(1, dmlMaxRows-dmlRowsUsed);
            Boolean result3 = UtilsDML.checkDMLLimits(dmlMaxStatements-dmlStatementsUsed, 1);
            Boolean result4 = UtilsDML.checkDMLLimits(dmlMaxStatements-dmlStatementsUsed, dmlMaxRows-dmlRowsUsed);
        Test.stopTest();

        // THEN the results should pass
        System.assertEquals(true, result1);
        System.assertEquals(true, result2);
        System.assertEquals(true, result3);
        System.assertEquals(true, result4);
    }

    @IsTest
    static void checkDMLLimitsFail() {
        // GIVEN system governor limits for DML statements and DML rows
        Integer dmlMaxStatements = Limits.getLimitDmlStatements();
        Integer dmlMaxRows = Limits.getLimitDmlRows();

        // AND some limits are already used
        Test.startTest();
            Contact[] contacts = sampleRecords(2);
            insert contacts;
            Integer dmlStatementsUsed = Limits.getDmlStatements();
            Integer dmlRowsUsed = Limits.getDmlRows();

            // WHEN checking DML limits for any number of statements & rows that will exceed the limits
            Boolean result1 = UtilsDML.checkDMLLimits(dmlMaxStatements-dmlStatementsUsed+1, 1);
            Boolean result2 = UtilsDML.checkDMLLimits(1, dmlMaxRows-dmlRowsUsed+1);
            Boolean result3 = UtilsDML.checkDMLLimits(dmlMaxStatements-dmlStatementsUsed+1, dmlMaxRows-dmlRowsUsed+1);
        Test.stopTest();

        // THEN the results should fail
        System.assertEquals(false, result1);
        System.assertEquals(false, result2);
        System.assertEquals(false, result3);
    }

    @IsTest
    static void checkPermissionForDMLFail() {
        // GIVEN I'm a user with no access to the Debug Parent object
        User user1 = TestUtils.getStandardInternalUser('User1');
        insert user1;

        System.runAs(user1) {

            // WHEN I check for permissions to the Debug Parent object
            Test.startTest();
                Schema.DescribeSObjectResult debugParentDescribe = Debug_Parent__c.getSObjectType().getDescribe();
                Boolean resultInsert   = UtilsDML.checkPermissionForDML(UtilsDML.DmlType.INSERT_OBJECT, debugParentDescribe);
                Boolean resultUpdate   = UtilsDML.checkPermissionForDML(UtilsDML.DmlType.UPDATE_OBJECT, debugParentDescribe);
                Boolean resultUpsert   = UtilsDML.checkPermissionForDML(UtilsDML.DmlType.UPSERT_OBJECT, debugParentDescribe);
                Boolean resultDelete   = UtilsDML.checkPermissionForDML(UtilsDML.DmlType.DELETE_OBJECT, debugParentDescribe);
                Boolean resultUndelete = UtilsDML.checkPermissionForDML(UtilsDML.DmlType.UNDELETE_OBJECT, debugParentDescribe);
            Test.stopTest();

            // THEN the results should be false
            System.assertEquals(false, resultInsert);
            System.assertEquals(false, resultUpdate);
            System.assertEquals(false, resultUpsert);
            System.assertEquals(false, resultDelete);
            System.assertEquals(false, resultUndelete);
        }
    }

    @IsTest
    static void checkPermissionForDMLPass() {
        // GIVEN I'm a user with full access to the Debug Parent object
        User user1 = TestUtils.getAdminUser('Admin1');
        insert user1;

        System.runAs(user1) {

            // WHEN I check for permissions to the Debug Parent object
            Test.startTest();
                Schema.DescribeSObjectResult debugParentDescribe = Debug_Parent__c.getSObjectType().getDescribe();
                Boolean resultInsert   = UtilsDML.checkPermissionForDML(UtilsDML.DmlType.INSERT_OBJECT, debugParentDescribe);
                Boolean resultUpdate   = UtilsDML.checkPermissionForDML(UtilsDML.DmlType.UPDATE_OBJECT, debugParentDescribe);
                Boolean resultUpsert   = UtilsDML.checkPermissionForDML(UtilsDML.DmlType.UPSERT_OBJECT, debugParentDescribe);
                Boolean resultDelete   = UtilsDML.checkPermissionForDML(UtilsDML.DmlType.DELETE_OBJECT, debugParentDescribe);
                Boolean resultUndelete = UtilsDML.checkPermissionForDML(UtilsDML.DmlType.UNDELETE_OBJECT, debugParentDescribe);
            Test.stopTest();

            // THEN the results should be true
            System.assertEquals(true, resultInsert);
            System.assertEquals(true, resultUpdate);
            System.assertEquals(true, resultUpsert);
            System.assertEquals(true, resultDelete);
            System.assertEquals(true, resultUndelete);
        }
    }

    @IsTest
    static void handleErrorWithNoErrorListAndNoSave() {
        // GIVEN an error message
        String errorMessage = 'Test Error 1';

        // WHEN handleError is called without an error list and without saveErrors
        Test.startTest();
            Boolean saveErrors = false;
            UtilsDML.handleError(errorMessage, null, saveErrors, null);
        Test.stopTest();

        // THEN no error is saved to UtilsMonitoring
        System.assertEquals(null, UtilsMonitoring.saveMonitoringMessagesMap);
    }

    @IsTest
    static void handleErrorWithErrorListButNoSave() {
        // GIVEN an error message
        String errorMessage = 'Test Error 1';

        // AND monitoring is set up
        String messageType = 'Testing';
        insert new Monitoring__c(Name=messageType);
        UtilsMonitoring.setupMonitoring();

        // AND we have an error list
        GenericDMLResult[] errorList = new GenericDMLResult[]{};

        // WHEN handleError is called with the error list but without saveErrors
        Test.startTest();
            Boolean saveErrors = false;
            UtilsDML.handleError(errorMessage, errorList, saveErrors, messageType);
        Test.stopTest();

        // THEN an error is added to the error list
        System.assertEquals(1, errorList.size());
        System.assertEquals(errorMessage, errorList[0].errors[0].message);

        // AND no error is saved to UtilsMonitoring
        System.assertEquals(0, UtilsMonitoring.saveMonitoringMessagesMap.size());
    }

    @IsTest
    static void handleErrorWithNoErrorListButSave() {
        // GIVEN an error message
        String errorMessage = 'Test Error 1';

        // AND monitoring is set up
        String messageType = 'Testing';
        insert new Monitoring__c( Name = messageType, Active__c = true);
        UtilsMonitoring.setupMonitoring();

        // WHEN handleError is called with no error list but saveErrors is True
        Test.startTest();
            Boolean saveErrors = true;
            UtilsDML.handleError(errorMessage, null, saveErrors, messageType);
        Test.stopTest();

        // THEN the error is saved to UtilsMonitoring
        System.assertEquals(true, UtilsMonitoring.saveMonitoringMessagesMap.containsKey(UtilsDML.class));
        Map<String, List<UtilsMonitoring.ErrorMessage>> monitorMessages = UtilsMonitoring.saveMonitoringMessagesMap.get(UtilsDML.class);
        System.assertEquals(errorMessage, monitorMessages.get(messageType)[0].msg);
    }

    @IsTest
    static void handleErrorWithErrorListAndSave() {
        // GIVEN an error message
        String errorMessage = 'Test Error 1';

        // AND monitoring is set up
        String messageType = 'Testing';
        insert new Monitoring__c( Name = messageType, Active__c = true);
        UtilsMonitoring.setupMonitoring();

        // AND we have an error list
        GenericDMLResult[] errorList = new GenericDMLResult[]{};

        // WHEN handleError is called with the error list and saveErrors is True
        Test.startTest();
            Boolean saveErrors = true;
            UtilsDML.handleError(errorMessage, errorList, saveErrors, messageType);
        Test.stopTest();

        // THEN an error is added to the error list
        System.assertEquals(1, errorList.size());
        System.assertEquals(errorMessage, errorList[0].errors[0].message);

        // AND the error is saved to UtilsMonitoring
        System.assertEquals(true, UtilsMonitoring.saveMonitoringMessagesMap.containsKey(UtilsDML.class));
        Map<String, List<UtilsMonitoring.ErrorMessage>> monitorMessages = UtilsMonitoring.saveMonitoringMessagesMap.get(UtilsDML.class);
        System.assertEquals(errorMessage, monitorMessages.get(messageType)[0].msg);
    }

    @IsTest
    static void getDMLErrorsNoError() {
        // GIVEN a DML operation result with no errors
        Contact c1 = new Contact(LastName='Test1', Email='test1@test.test');
        Contact[] contacts = new Contact[]{ c1 };
        Database.SaveResult[] sr = Database.insert(contacts, false);

        // WHEN getDMLErrors is called without saveErrors
        Test.startTest();
            Boolean saveErrors = false;
            GenericDMLResult[] result = UtilsDML.getDMLErrors(GenericDMLResult.makeGeneric(sr, contacts), saveErrors, null);
        Test.stopTest();

        // THEN the resulting error list is empty
        System.assertEquals(0, result.size());
    }

    @IsTest
    static void getDMLErrorsWithErrorButNoSave() {
        // GIVEN a DML operation result with an errors
        Contact c1 = new Contact(LastName='Test1', Email='test1@test.test');
        Contact c2 = new Contact(Email='test2@test.test');
        Contact[] contacts = new Contact[]{ c1, c2 };
        Database.SaveResult[] sr = Database.insert(contacts, false);

        // AND monitoring is set up
        String messageType = 'Testing';
        insert new Monitoring__c( Name = messageType, Active__c = true);
        UtilsMonitoring.setupMonitoring();

        // WHEN getDMLErrors is called without saveErrors
        Test.startTest();
            Boolean saveErrors = false;
            GenericDMLResult[] result = UtilsDML.getDMLErrors(GenericDMLResult.makeGeneric(sr, contacts), saveErrors, null);
        Test.stopTest();

        // THEN the resulting error list contains an error
        System.assertEquals(1, result.size());
        System.assertEquals(false, result[0].success);
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, result[0].errors[0].statusCode);

        // AND no error is saved to UtilsMonitoring
        System.assertEquals(0, UtilsMonitoring.saveMonitoringMessagesMap.size());
    }

    @IsTest
    static void getDMLErrorsWithErrorAndSave() {
        // GIVEN a DML operation result with an errors
        Contact c1 = new Contact(LastName='Test1', Email='test1@test.test');
        Contact c2 = new Contact(Email='test2@test.test');
        Contact[] contacts = new Contact[]{ c1, c2 };
        Database.SaveResult[] sr = Database.insert(contacts, false);

        // AND monitoring is set up
        String messageType = 'Testing';
        insert new Monitoring__c( Name = messageType, Active__c = true);
        UtilsMonitoring.setupMonitoring();

        // WHEN getDMLErrors is called with saveErrors = True
        Test.startTest();
            Boolean saveErrors = true;
            GenericDMLResult[] result = UtilsDML.getDMLErrors(GenericDMLResult.makeGeneric(sr, contacts), saveErrors, messageType);
        Test.stopTest();

        // THEN the resulting error list contains an error
        System.assertEquals(1, result.size());
        System.assertEquals(false, result[0].success);
        System.assertEquals(StatusCode.REQUIRED_FIELD_MISSING, result[0].errors[0].statusCode);

        // AND the error is saved to UtilsMonitoring
        System.assertEquals(true, UtilsMonitoring.saveMonitoringMessagesMap.containsKey(UtilsDML.class));
        Map<String, List<UtilsMonitoring.ErrorMessage>> monitorMessages = UtilsMonitoring.saveMonitoringMessagesMap.get(UtilsDML.class);
        System.assertEquals(true, monitorMessages.get(messageType)[0].msg.startsWith(String.valueOf(StatusCode.REQUIRED_FIELD_MISSING)));
    }

    @IsTest
    static void genericDMLBatchOk() {
        // GIVEN some valid records to insert
        Contact[] contacts = sampleRecords(3);

        // AND a post-processor class
        String postProcessorClass = 'BatchDMLPostProcessor';

        // AND monitoring is enabled
        String messageType = BatchDMLPostProcessor.MESSAGE_TYPE;
        insert new Monitoring__c( Name = messageType, Active__c = true );

        // WHEN calling genericDMLBatch to INSERT these records
        Test.startTest();
            Boolean success = UtilsDML.genericDMLBatch(UtilsDML.DmlType.INSERT_OBJECT, contacts, true, false, null, 100, postProcessorClass);
        Test.stopTest();

        // THEN success should be true
        System.assertEquals(true, success);

        // AND the records have been inserted successfully
        System.assertEquals(true, verifyData(contacts));

        // AND the post-processing debug messages have been created
        Id dpId = [SELECT Id FROM Debug_Parent__c WHERE Message_Type__c = :messageType].Id;
        Debug_Message__c[] dm = [SELECT Message__c FROM Debug_Message__c WHERE Debug_Parent__c = :dpId];
        System.assertEquals(1, dm.size());
        System.assertEquals(BatchDMLPostProcessor.COMPLETION_MESSAGE, dm[0].Message__c);
    }

    /**
     * Create some sample Contact records but do not save to database
     *
     * @param count         The number of Contact records required
     *
     * @return {Contact[]}  The list of Contact records created
     */
    static Contact[] sampleRecords(Integer count) {
        Contact[] records = new Contact[]{};
        for (Integer i=1; i<=count; i++) {
            String iString = String.valueOf(i).leftPad(5,'0'); // e.g. '00001';
            records.add(new Contact(LastName='Test'+iString,Email='test'+iString+'@test.test'));
        }
        return records;
    }

    /**
     * Check that database contains the Contact records as per passed sample
     *
     * @param sample        A list of Contact records to check
     *
     * @return {Boolean}    True if database contains only those records
     */
    static Boolean verifyData(Contact[] sample) {
        Contact[] contacts = [SELECT LastName, Email FROM Contact ORDER BY LastName];
        System.assertEquals(sample.size(), contacts.size());
        for (Integer i=0; i<contacts.size(); i++) {
            System.assertEquals(sample[i].LastName, contacts[i].LastName);
            System.assertEquals(sample[i].Email, contacts[i].Email);
        }
        return true;
    }

    /**
     * Retrieve any debug messages saved to the database for a given messageType
     *
     * @param messageType   The messageType used to save debug messages
     *
     * @return {Debug_Message__c[]} The list of debug messages, or null if the messageType is not found
     */
    static Debug_Message__c[] getDebugMessages(String messageType) {
        Debug_Parent__c[] dp = [SELECT Id FROM Debug_Parent__c WHERE Message_Type__c = :messageType];
        if (!dp.isEmpty()) {
            Id parentId = dp[0].Id;
            return [SELECT Message__c FROM Debug_Message__c WHERE Debug_Parent__c = :parentId];
        }
        else {
            return null;
        }
    }
}