@isTest
public class CPQ_Terminate_Contr_On_Termin_Date_Test {
    static final String TESTED_PROCESS_NAME = 'CPQ_Terminate_Contract_On_Termination_Date';
    @isTest static void activateContract(){
        
        Account sobjAcc = TestUtility.sampleAccount();
        insert sobjAcc;
        Contract sobjContract= TestUtility.sampleContract(sobjAcc.Id);
        sobjContract.Active__c = false;
        insert sobjContract;
        List<FlowInterview> listFlowInterview = [SELECT Id FROM FlowInterview WHERE OwnerId = :UserInfo.getUserId() AND InterviewLabel LIKE :TESTED_PROCESS_NAME + '%'];
        System.assertEquals(0, listFlowInterview.size());
        
        Test.startTest();
        	sobjContract.StartDate = System.today();
            sobjContract.ContractTerm = 1;
            sobjContract.EndDate = System.today().addmonths(1);
            sobjContract.Active__c = true;
            update sobjContract;
        Test.stopTest();
        sobjContract = [Select StartDate, EndDate, Active__c,ContractTerm From Contract Limit 1 ];
        System.debug('## sobjContract ' +sobjContract);
        listFlowInterview = [SELECT Id FROM FlowInterview WHERE OwnerId = :UserInfo.getUserId() AND InterviewLabel LIKE :TESTED_PROCESS_NAME + '%' LIMIT 1];
        System.assert(listFlowInterview.size() == 1, 'Process should run scheduled action');
    }
}