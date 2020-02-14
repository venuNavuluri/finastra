@isTest(seeAllData = true)
private class Test_EscalationUtils{

    static testMethod void testConstructor(){

        Account a = TestUtils.getAccount('ut Acc1');
        insert a;
        Case csParent = TestUtils.getCase(a);
        insert csParent;

        Case cs = TestUtils.getCase(a);
        cs.ParentID = csParent.id;
        cs.Status = Constants.STATUS_CLOSED;
        insert cs;

        EscalationUtils.QueryCustomerCase(cs.Id);

        EscalationUtils.CreateAndInsertEscalatedCase(cs, 'testing', 5);

    }
}