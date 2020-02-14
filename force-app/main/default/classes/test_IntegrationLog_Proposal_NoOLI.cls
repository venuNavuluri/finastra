@isTest
public class test_IntegrationLog_Proposal_NoOLI
{
	private static IntegrationLog_Proposal_TestUtils.BaseData baseData;
	private static IntegrationLog_Proposal_TestUtils.ResultData resultData;
	
	
	private static void setup()
	{
        User u = TestUtility.sampleUser();
        system.runAs(u){
            ProposalConsumerSettings__c cs = new ProposalConsumerSettings__c();
            cs.Batch_Size__c = 80;
            cs.Schedule_Delay__c = 5;
            cs.Start_Time__c = datetime.now().addDays(-1);
            insert cs;
        }

		Integer proposalId = 123;
		baseData = IntegrationLog_Proposal_TestUtils.SetupBasicScenario(proposalId, false, true);
        insert baseData.intLogs;
}
	
	private static void evaluate()
	{
		System.assertEquals(2, resultData.obsHeaders.get(baseData.testOpp.Id).size());

		// check the OBS headers
		Set<string> expectedOBSHeaderNames = new Set<string>{'123-ILF-' + baseData.testOpp.Order_Number__c, '123-SVFP-' + baseData.testOpp.Order_Number__c};
		expectedOBSHeaderNames.remove(resultData.obsHeaders.get(baseData.testOpp.Id)[0].Key__c);
		System.debug(LoggingLevel.Error, '@@@ obsheadername0: ' + resultData.obsHeaders.get(baseData.testOpp.Id)[0].Name);
		expectedOBSHeaderNames.remove(resultData.obsHeaders.get(baseData.testOpp.Id)[1].Key__c);
		System.assertEquals(0, expectedOBSHeaderNames.size());
		
		// check the BSIs and OLIs
		for (Opportunity_Billing_Schedule__c obs : resultData.obsHeaders.get(baseData.testOpp.Id)) {
			string key = baseData.testOpp.Id + '#' + obs.Id;
			System.debug(LoggingLevel.Error, '@@@ key1: ' + key + '~~~ obsItems: ' + resultData.obsItems);
			string procType = obs.Processing_Type__c;
			for (Opportunity_Billing_Schedule_Item__c bsi : resultData.obsItems.get(key)) {
				System.assertEquals(procType, bsi.LineItem_Process_Type__c);
			}
			System.assertEquals(null, resultData.olis.get(key));
		}
	}
	
	/* add 2 billing schedules, and 4 OLIs to an existing vanilla oppty
	*/
    public static testmethod void DoTest()
	{
		setup();
		Test.startTest();
			IntegrationLog_Proposal_BatchJob3 job = new IntegrationLog_Proposal_BatchJob3();
			ID idBatch = Database.executeBatch(job);
		Test.stopTest();
		resultData = IntegrationLog_Proposal_TestUtils.queryCreatedArtifacts(new Set<Id>{baseData.testOpp.Id});
		evaluate();
	}
}