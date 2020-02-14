@isTest
public class test_IntegrationLog_Proposal_MultiOpp
{
	private static IntegrationLog_Proposal_TestUtils.BaseData baseData1;
	private static IntegrationLog_Proposal_TestUtils.BaseData baseData2;
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

        Integer proposalId1 = 123;
		baseData1 = IntegrationLog_Proposal_TestUtils.SetupBasicScenario(proposalId1);
        insert baseData1.intLogs;

		Integer proposalId2 = 456;
		baseData2 = IntegrationLog_Proposal_TestUtils.SetupBasicScenario(proposalId2);
        insert baseData2.intLogs;

}
	
	private static void evaluate()
	{
		System.assertEquals(2, resultData.obsHeaders.keySet().size());  // 2 oppties
		System.assertEquals(2, resultData.obsHeaders.get(baseData1.testOpp.Id).size());  // 2 obs per oppty
		System.assertEquals(2, resultData.obsHeaders.get(baseData2.testOpp.Id).size());

		integer bsiCount = 0;
		for (Opportunity_Billing_Schedule_Item__c[] bsiList : resultData.obsitems.values()) {
			bsiCount += bsiList.size();
		}
		System.assertEquals(4, bsiCount);

		integer oliCount = 0;
		for (OpportunityLineItem[] oliList : resultData.olis.values()) {
			oliCount += oliList.size();
		}
		System.assertEquals(8, oliCount);

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
		resultData = IntegrationLog_Proposal_TestUtils.queryCreatedArtifacts(new Set<Id>{baseData1.testOpp.Id, baseData2.testOpp.Id});
		evaluate();
	}
}