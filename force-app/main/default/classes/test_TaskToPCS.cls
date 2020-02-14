/**
 * Created by ngronows on 25/08/2017.
 */

@IsTest
private class test_TaskToPCS {

    static testMethod void shouldCopyCampaignToOppty() {

        Opportunity opp = TestUtility.sampleOpportunity();
        insert opp;
        Campaign campaign = TestUtility.sampleCampaign();
        insert campaign;

        Task task = new Task();
        task.whatId = opp.Id;
        insert task;

        Task resultTask = [select id, status from Task where id = :task.id];
        System.assertNotEquals('Completed',resultTask.Status, 'Task status should not be completed yet');

        Opportunity reaultOppty = [select id, CampaignId from Opportunity where id = :opp.Id];
        System.assertEquals(null,reaultOppty.CampaignId, 'Campaign id on opportunity should be empty');

        task.Was_this_Opp_generated_from_a_GTM__c = 'Yes';
        task.GTM_Campaign__c = campaign.Id;

        update task;

        resultTask = [select id, status from Task where id = :task.id];
        System.assertEquals('Completed',resultTask.Status, 'Task status should be completed');

        reaultOppty = [select id, CampaignId from Opportunity where id = :opp.Id];
        System.assertEquals(campaign.Id,reaultOppty.CampaignId, 'Campaign id on opportunity should be copied from task');

    }

    static testMethod void shouldCopyNullCampaignToOpptyAndTask() {

        Opportunity opp = TestUtility.sampleOpportunity();
        insert opp;
        Campaign campaign = TestUtility.sampleCampaign();
        insert campaign;

        Campaign nullCampaign = TestUtility.sampleCampaign();
        nullCampaign.Name = 'NULL GTM Campaign';
        insert nullCampaign;

        Task task = new Task();
        task.whatId = opp.Id;
        insert task;

        Task resultTask = [select id, status from Task where id = :task.id];
        System.assertNotEquals('Completed',resultTask.Status, 'Task status should not be completed yet');

        Opportunity reaultOppty = [select id, CampaignId from Opportunity where id = :opp.Id];
        System.assertEquals(null,reaultOppty.CampaignId, 'Campaign id on opportunity should be empty');

        task.Was_this_Opp_generated_from_a_GTM__c = 'No';
        update task;

        resultTask = [select id, status, GTM_Campaign__c from Task where id = :task.id];
        System.assertEquals('Completed',resultTask.Status, 'Task status should be completed');
        System.assertEquals(nullCampaign.Id,resultTask.GTM_Campaign__c, 'Campaign id on task should be null campaign');

        reaultOppty = [select id, CampaignId from Opportunity where id = :opp.Id];
        System.assertEquals(nullCampaign.Id,reaultOppty.CampaignId, 'Campaign id on opportunity should be null campaign');

    }
}