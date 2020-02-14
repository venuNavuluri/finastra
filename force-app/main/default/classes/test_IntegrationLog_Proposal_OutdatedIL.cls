@isTest
public class test_IntegrationLog_Proposal_OutdatedIL
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

		// create a basic data that will be replaced:
		baseData = IntegrationLog_Proposal_TestUtils.SetupBasicScenario(proposalId);
        insert baseData.intLogs;

        IntegrationLog_Proposal_SingleOppty.processPPOPPLINE_n_PPOPPMILE(baseData.testOpp, baseData.intLogs, true);
		System.debug(LoggingLevel.ERROR, '@@@ intLog results: ' + baseData.intLogs);
		
				
		// create a new scenario:
		Integration_Log__c[] newIntLogs = new Integration_Log__c[]{};
		Integration_Log__c ilOLI = IntegrationLog_Proposal_TestUtils.createIntLog_OLI(
			proposalId,
			baseData.testOpp.Id,
			baseData.PBEntries[0].Id,
			'DVC1'
		);
		ilOLI.GenString1__c = 'ellisr/703.03-20/07/2012 20:09:40'; // timestamp older
		newIntLogs.add(ilOLI);

		Integration_Log__c ilBSI = IntegrationLog_Proposal_TestUtils.createIntLog_MS(proposalId, baseData.testOpp.Id, 'DVC1');
		ilBSI.GenString1__c = 'ellisr/703.03-20/07/2012 20:09:40'; // timestamp older
		newIntLogs.add(ilBSI);
		
		baseData.intLogs = newIntLogs;
	}
	
	private static void evaluate()
	{
		System.assertEquals(2, resultData.obsHeaders.get(baseData.testOpp.Id).size());

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

		for (Integration_Log__c il : resultData.intLogs) {
			System.assertEquals(true, il.isSuccess__c);
			System.assertEquals(null, il.Message__c);
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

	/* add 2 billing schedules, and 4 OLIs to an existing vanilla oppty
    public static void ExecuteAnonymous()
	{
		Savepoint sp = Database.setSavepoint();
		try {
			setup();
			insert baseData.intLogs;
			resultData = IntegrationLog_Proposal_TestUtils.queryCreatedArtifacts(new Set<Id>{baseData.testOpp.Id});
			evaluate();
		}
		catch (Exception e) {
			Database.rollback(sp);
			throw e;
		}
		Database.rollback(sp);
	}
	*/
}