@isTest
private class NSProjectTriggerMethods_Test {
    private static testMethod void testPipelineProjectCreation() {
        Id licensesWithOrWithoutPSRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Licenses with/without PS').getRecordTypeId();
        Opportunity testOpp = TestUtility.sampleOpportunity();
        testOpp.RecordTypeId=licensesWithOrWithoutPSRecordTypeId;
        testOpp.StageName='4. Develop';
        testOpp.PS_Stage__c='2. Check';
        testOpp.PS_Risk_Category__c='High';
        insert testOpp;
        System.assertNotEquals(null,testOpp.id);


        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '11111111111');
        insert misysEntity;
        
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testOpp.AccountId, Misys_Entity__c = misysEntity.Id, NS_Internal_Id__c = '123');
        insert accBySub;
       

        NS_Project__c pipelineProject = TestDataFactory.createNSProject(false);
        pipelineProject.Trickle_Opportunity_Data__c=true;
        pipelineProject.Deferred_Account_Type__c=OppPipelineUtil.PIPELINE_DEFFERED_NAME;
        pipelineProject.Opportunity__c=testOpp.id;
        pipelineProject.Customer__c=accBySub.id;
        Integer beforeCount = Limits.getEmailInvocations();
        Test.startTest();
        //CONSTANTS.DISABLE_INDIVIDUAL_TRIGGER = true;
        insert pipelineProject;
        Integer afterCount = Limits.getEmailInvocations();
        Test.stopTest();
        NS_Project__c dbPipelineProject = [select Project_Type__c from NS_Project__c where id =: pipelineProject.id];
        System.assertEquals(OppPipelineUtil.PIPELINE_DEFFERED_NAME,dbPipelineProject.Project_Type__c,'Project type should be \'Pipeline\'');
        Organization thisOrg = [select isSandbox from Organization];
        if(thisOrg.isSandbox) {
            System.assert(afterCount>beforeCount,'Should have been sent mail');
        } 
    }

}