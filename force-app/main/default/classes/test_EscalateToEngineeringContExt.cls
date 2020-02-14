@isTest
class test_EscalateToEngineeringContExt 
{
	static testMethod void testConstructorAndCreateEscalatedCaseMethods()
    {
        List<Constants__c> testConstants = TestUtility.loadConstants();
        insert testConstants;
        
        //Set up test data
        Account a = TestUtils.getAccount('ut Acc1');
        insert a;
        Case cs = TestUtils.getCase(a);
        cs.Replication_Steps__c = 'some steps';
        ApexPages.StandardController std = new ApexPages.StandardController(cs);
        EscalateToEngineeringContExt etece = new EscalateToEngineeringContExt(std);
        System.assertEquals(System.Label.You_can_only_escalate_a_committed_Case ,ApexPages.getMessages().get(0).getDetail());
        
        Case parentCase = TestUtils.getCase(a);
        insert parentCase;
        cs.ParentId = parentCase.id;
        insert cs;
        std = new ApexPages.StandardController(cs);
        etece = new EscalateToEngineeringContExt(std);
        System.assertEquals(System.Label.Cases_with_existing_Parents_and_Closed_Cases_cannot_be_escalated, ApexPages.getMessages().get(1).getDetail());
        
        cs.ParentID = null;
        //cs.Status = 'Escalated to Engineering';
        update cs;
        std = new ApexPages.StandardController(cs);
        etece = new EscalateToEngineeringContExt(std);
        
        etece.createEscalatedCase();
        
    }
}