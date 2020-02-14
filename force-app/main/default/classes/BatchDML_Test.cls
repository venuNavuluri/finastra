@IsTest
private class BatchDML_Test {

    @IsTest
    static void batchWithNoErrors() {
        // GIVEN some valid records to insert
        Contact c1 = new Contact(LastName='Test1', Email='test1@test.test');
        Contact c2 = new Contact(LastName='Test2', Email='test2@test.test');
        Contact[] contacts = new Contact[]{ c1, c2 };

        // WHEN the batch is performed
        Test.startTest();
        BatchDML batchJob = new BatchDML(UtilsDML.DmlType.INSERT_OBJECT, contacts, true, false, null, null);
        batchJob.execute(null, contacts);
        Test.stopTest();

        // THEN the batch attributes are updates as expected
        System.assertEquals(UtilsDML.DmlType.INSERT_OBJECT, batchJob.dmlType);
        System.assertEquals(0, batchJob.dmlErrors.size());
        System.assertEquals(1, batchJob.batchCount);
        System.assertEquals(0, batchJob.failedBatchCount);
        System.assertEquals(true, batchJob.allOrNone);
        System.assertEquals(false, batchJob.saveErrors);

        // AND the expected records have been processed
        contacts = [SELECT LastName FROM Contact ORDER BY LastName];
        System.assertEquals(2, contacts.size());
        System.assertEquals(c1.LastName, contacts[0].LastName);
        System.assertEquals(c2.LastName, contacts[1].LastName);

    }

    @IsTest
    static void batchAllOrNoneWithErrors() {
        // GIVEN some valid records to insert
        Contact c1 = new Contact(LastName='Test1', Email='test1@test.test');
        Contact c2 = new Contact(LastName='Test2', Email='test2@test.test');
        Contact[] contacts = new Contact[]{ c1, c2 };

        // AND an invalid record
        contacts.add(new Contact(Email = 'invalid@test.test'));

        // WHEN the batch is performed - allOrNone is True
        Test.startTest();
        BatchDML batchJob = new BatchDML(UtilsDML.DmlType.INSERT_OBJECT, contacts, true, false, null, null);
        batchJob.execute(null, contacts);
        Test.stopTest();

        // THEN the batch attributes are updates as expected
        System.assertEquals(UtilsDML.DmlType.INSERT_OBJECT, batchJob.dmlType);
        System.assertEquals(0, batchJob.dmlErrors.size());
        System.assertEquals(1, batchJob.batchCount);
        System.assertEquals(1, batchJob.failedBatchCount);
        System.assertEquals(true, batchJob.allOrNone);
        System.assertEquals(false, batchJob.saveErrors);

        // AND no records have been processed
        contacts = [SELECT LastName FROM Contact ORDER BY LastName];
        System.assertEquals(0, contacts.size());
    }

    @IsTest
    static void batchPartialWithErrors() {
        // GIVEN some valid records to insert
        Contact c1 = new Contact(LastName='Test1', Email='test1@test.test');
        Contact c2 = new Contact(LastName='Test2', Email='test2@test.test');
        Contact[] contacts = new Contact[]{ c1, c2 };

        // AND an invalid record
        contacts.add(new Contact(Email = 'invalid@test.test'));

        // WHEN the batch is performed - allOrNone is False
        Test.startTest();
        BatchDML batchJob = new BatchDML(UtilsDML.DmlType.INSERT_OBJECT, contacts, false, false, null, null);
        batchJob.execute(null, contacts);
        Test.stopTest();

        // THEN the batch attributes are updates as expected
        System.assertEquals(UtilsDML.DmlType.INSERT_OBJECT, batchJob.dmlType);
        System.assertEquals(1, batchJob.dmlErrors.size());
        System.assertEquals(1, batchJob.batchCount);
        System.assertEquals(1, batchJob.failedBatchCount);
        System.assertEquals(false, batchJob.allOrNone);
        System.assertEquals(false, batchJob.saveErrors);

        // AND the valid records have been processed
        contacts = [SELECT LastName FROM Contact ORDER BY LastName];
        System.assertEquals(2, contacts.size());
        System.assertEquals(c1.LastName, contacts[0].LastName);
        System.assertEquals(c2.LastName, contacts[1].LastName);
    }

    @IsTest
    static void batchWithPostProcessing() {
        // GIVEN some valid records to insert
        Contact c1 = new Contact(LastName='Test1', Email='test1@test.test');
        Contact c2 = new Contact(LastName='Test2', Email='test2@test.test');
        Contact[] contacts = new Contact[]{ c1, c2 };

        // AND a post-processor class
        String postProcessorClass = 'BatchDMLPostProcessor';

        // AND monitoring is enabled
        String messageType = BatchDMLPostProcessor.MESSAGE_TYPE;
        insert new Monitoring__c( Name = messageType, Active__c = true );

        // WHEN the batch is performed
        Test.startTest();
        Database.executeBatch(
                new BatchDML(UtilsDML.DmlType.INSERT_OBJECT, contacts, true, false, null, postProcessorClass),
                200);
        Test.stopTest();

        // THEN the expected records have been processed
        contacts = [SELECT LastName FROM Contact ORDER BY LastName];
        System.assertEquals(2, contacts.size());
        System.assertEquals(c1.LastName, contacts[0].LastName);
        System.assertEquals(c2.LastName, contacts[1].LastName);

        // AND the post-processing debug messages have been created
        Id dpId = [SELECT Id FROM Debug_Parent__c WHERE Message_Type__c = :messageType].Id;
        Debug_Message__c[] dm = [SELECT Message__c FROM Debug_Message__c WHERE Debug_Parent__c = :dpId];
        System.assertEquals(1, dm.size());
        System.assertEquals(BatchDMLPostProcessor.COMPLETION_MESSAGE, dm[0].Message__c);
    }
}