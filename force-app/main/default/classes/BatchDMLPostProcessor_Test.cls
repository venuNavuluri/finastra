@IsTest
private class BatchDMLPostProcessor_Test {

    @IsTest
    static void testPostProcessorWithBatchReference() {
        // GIVEN that monitoring is enabled
        String messageType = BatchDMLPostProcessor.MESSAGE_TYPE;
        insert new Monitoring__c(Name = messageType, Active__c = true);

        // AND we have a BatchDML class to reference (but we don't need to run it)
        BatchDML batchDML = new BatchDML(UtilsDML.DmlType.UPDATE_OBJECT, new Contact[]{}, true, false, null, null);

        // WHEN post processor class is called
        Test.startTest();
        BatchDMLPostProcessor pp = new BatchDMLPostProcessor();
        pp.performPostProcessing(batchDML);
        Test.stopTest();

        // THEN the post-processing debug messages have been created
        Id dpId = [SELECT Id FROM Debug_Parent__c WHERE Message_Type__c = :messageType].Id;
        Debug_Message__c[] dm = [SELECT Message__c FROM Debug_Message__c WHERE Debug_Parent__c = :dpId];
        System.assertEquals(1, dm.size());
        System.assertEquals(BatchDMLPostProcessor.COMPLETION_MESSAGE, dm[0].Message__c);
    }

    @IsTest
    static void testPostProcessorWithNoMonitoring() {
        // GIVEN that NO monitoring is enabled
        // AND we have a BatchDML class to reference (but we don't need to run it)
        BatchDML batchDML = new BatchDML(UtilsDML.DmlType.UPDATE_OBJECT, new Contact[]{}, true, false, null, null);

        // WHEN post processor class is called
        Test.startTest();
        BatchDMLPostProcessor pp = new BatchDMLPostProcessor();
        pp.performPostProcessing(batchDML);
        Test.stopTest();

        // THEN the post-processing debug messages will not exist
        Debug_Parent__c[] dp = [SELECT Id FROM Debug_Parent__c];
        System.assertEquals(0, dp.size());
        Debug_Message__c[] dm = [SELECT Message__c FROM Debug_Message__c];
        System.assertEquals(0, dm.size());
    }

    @IsTest
    static void testPostProcessorWithNoBatchReference() {
        // GIVEN that monitoring is enabled
        String messageType = BatchDMLPostProcessor.MESSAGE_TYPE;
        insert new Monitoring__c(Name = messageType, Active__c = true);

        // AND we have NO BatchDML class to reference
        // WHEN post processor class is called
        Test.startTest();
        BatchDMLPostProcessor pp = new BatchDMLPostProcessor();
        pp.performPostProcessing(null);
        Test.stopTest();

        // THEN the post-processing debug messages have been created
        Id dpId = [SELECT Id FROM Debug_Parent__c WHERE Message_Type__c = :messageType].Id;
        Debug_Message__c[] dm = [SELECT Message__c FROM Debug_Message__c WHERE Debug_Parent__c = :dpId];
        System.assertEquals(1, dm.size());
        System.assertEquals(BatchDMLPostProcessor.COMPLETION_MESSAGE, dm[0].Message__c);
    }


}