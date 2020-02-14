/**
 * Created by ngronows on 24/08/2017.
 */

@IsTest
private class test_UpdatePCS {

    static testMethod void shouldUpdatePCS() {

        Campaign campaign = TestUtility.sampleCampaign();
        insert campaign;
        Lead testLead = TestUtility.sampleLead();
        testLead.Primary_Campaign_Source__c = campaign.id;
        insert testLead;

        Test.startTest();
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(testLead.id);
        lc.setOpportunityName(testLead.lastName);

        LeadStatus convertStatus = [select Id, MasterLabel from LeadStatus where IsConverted=true and masterLabel = 'Request to Convert' limit 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setDoNotCreateOpportunity(false);

        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess(),'Lead conversion was not successful');

        Test.stopTest();

        Lead result = [select id, ConvertedOpportunityId from Lead where id = :testLead.Id];
        System.assertNotEquals(null, result.ConvertedOpportunityId, 'Opportunity should be created');

        Opportunity resultOppty = [select id, CampaignId from Opportunity where id = :result.ConvertedOpportunityId];
        System.assertNotEquals(null, resultOppty.CampaignId, 'Campaign id should not be null');
        System.assertEquals(campaign.Id, resultOppty.CampaignId, 'Campaign id should be copied from lead to opportunity');
    }
}