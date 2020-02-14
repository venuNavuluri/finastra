@isTest
public class test_IntegrationLog_Proposal_NoMS{
    private static IntegrationLog_Proposal_TestUtils.BaseData baseData;
    private static IntegrationLog_Proposal_TestUtils.ResultData resultData;

    public static boolean TestSetup = false;

    private static void setup(){

        User u = TestUtility.sampleUser();
        system.runAs(u){
            ProposalConsumerSettings__c cs = new ProposalConsumerSettings__c();
            cs.Batch_Size__c = 80;
            cs.Schedule_Delay__c = 5;
            cs.Start_Time__c = datetime.now();
            insert cs;
        }
        Integer proposalId = 123;

        // create a basic data that will be replaced:
        baseData = IntegrationLog_Proposal_TestUtils.SetupBasicScenario(proposalId);
        IntegrationLog_Proposal_SingleOppty.processPPOPPLINE_n_PPOPPMILE(baseData.testOpp, baseData.intLogs, true);

        // create a new scenario:
        Integration_Log__c[] newIntLogs = new Integration_Log__c[]{
        };
        Integration_Log__c ilOLI = IntegrationLog_Proposal_TestUtils.createIntLog_OLI(
                proposalId,
                baseData.testOpp.Id,
                baseData.PBEntries[0].Id,
                'DVC1'
        );
        ilOLI.GenString1__c = 'ellisr/703.03-20/07/2012 20:09:50';
        newIntLogs.add(ilOLI);

        baseData.intLogs = newIntLogs;
    }

    private static void evaluate(){
        System.assert(resultData.obsHeaders.get(baseData.testOpp.Id) == null);

        string key = baseData.testOpp.Id + '#null';
        System.assertEquals(1, resultData.olis.get(key).size());
    }

    /* add 2 billing schedules, and 4 OLIs to an existing vanilla oppty
    */
    public static testmethod void DoTest(){

        setup();
        Test.startTest();
        insert baseData.intLogs;
        IntegrationLog_Proposal_BatchJob3 job = new IntegrationLog_Proposal_BatchJob3();
        ID idBatch = Database.executeBatch(job);
        Test.stopTest();
        resultData = IntegrationLog_Proposal_TestUtils.queryCreatedArtifacts(new Set<Id>{
                baseData.testOpp.Id
        });
        evaluate();
    }
}