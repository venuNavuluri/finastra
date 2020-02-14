@isTest
private class Uplift_Test {

   /* @isTest
    public static void shouldExecuteEmailBatch(){
        // having
        Uplift_TestUtils.BaseData baseData = Uplift_TestUtils.SetupBasicScenario();
        // when
        Test.startTest();
        UpliftEmailBatch job = new UpliftEmailBatch();
        ID batchprocessid = Database.executeBatch(job);
        Test.stopTest();
        // then
        Uplift_TestUtils.ResultData result = Uplift_TestUtils.queryCreatedArtifacts(baseData.uplift1Id);
      //  System.assertEquals(360, result.resultSubscriptions.get(baseData.sub21Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
      //  System.assertEquals(345, result.resultQLineToTiers.get(baseData.line122Id).Unit_Price__c, 'Unit price on tier should be increased by uptick');
    }*/

    @isTest
    public static void shouldExecuteBatch(){
        // having
        Uplift_TestUtils.BaseData baseData = Uplift_TestUtils.SetupBasicScenario();
        // when
        Test.startTest();
        UpliftCalculationBatch job = new UpliftCalculationBatch();
        ID batchprocessid = Database.executeBatch(job);
        Test.stopTest();
        // then
        Uplift_TestUtils.ResultData result = Uplift_TestUtils.queryCreatedArtifacts(baseData.uplift1Id);
        System.assertEquals(300, result.resultSubscriptions.get(baseData.sub21Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
         System.assertEquals(30, result.resultSubscriptions.get(baseData.sub21Id).Fair_Value__c, 'Fair value on subscription should be increased by uptick');
        System.assertEquals(300, result.resultQLineToTiers.get(baseData.line122Id).Unit_Price__c, 'Unit price on tier should be increased by uptick');
    }

    @isTest
    public static void shouldScheduleBatch(){

        Uplift_TestUtils.BaseData baseData = Uplift_TestUtils.SetupBasicScenario();
        Test.startTest();
        String jobId = UpliftCalculationBatchScheduler.scheduleBatchJob();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,
                NextFireTime
        FROM CronTrigger WHERE id = :jobId];

        System.assertEquals(UpliftCalculationBatchScheduler.CRON_EXP,  ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }

}