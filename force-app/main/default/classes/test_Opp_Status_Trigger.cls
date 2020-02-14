/**
 * Created by ngronows on 25/08/2017.
 */

@IsTest
private class test_Opp_Status_Trigger {

    static testMethod void shouldSetOpportunityToPending()
    {

        Opportunity opp = new Opportunity(Name='Apex - Test Opportunity',StageName='Suspect', CloseDate=System.today());
        insert opp;

        Deal_Approval__c da = new Deal_Approval__c(Name='Apex Test Deal Approval', Opportunity__c = opp.Id, Approval_Status__c = 'Not started', Approval_Ref__c='DEALSHEET 123');
        insert da;

        Opportunity resultOpp = [select id, Approval_Status__c from Opportunity where id = :opp.Id];
        System.assertNotEquals('Pending Approval', resultOpp.Approval_Status__c, 'Status should not be pending yet');

        da.Approval_Status__c = 'Pending';
        update da;

        resultOpp = [select id, Approval_Status__c from Opportunity where id = :opp.Id];
        System.assertEquals('Pending Approval', resultOpp.Approval_Status__c, 'Status on opportunity should be updated to pending');
    }

    static testMethod void shouldSetOpportunityToRejected()
    {

        Opportunity opp = new Opportunity(Name='Apex - Test Opportunity',StageName='Suspect', CloseDate=System.today());
        insert opp;

        Deal_Approval__c da = new Deal_Approval__c(Name='Apex Test Deal Approval', Opportunity__c = opp.Id, Approval_Status__c = 'Not started', Approval_Ref__c='DEALSHEET 123');
        insert da;

        Opportunity resultOpp = [select id, Approval_Status__c from Opportunity where id = :opp.Id];
        System.assertNotEquals('Rejected', resultOpp.Approval_Status__c, 'Status should not be Rejected yet');

        da.Approval_Status__c = 'Rejected';
        update da;

        resultOpp = [select id, Approval_Status__c from Opportunity where id = :opp.Id];
        System.assertEquals('Rejected', resultOpp.Approval_Status__c, 'Status on opportunity should be updated to Rejected');
    }

    static testMethod void shouldSetOpportunityToApproved()
    {

        Opportunity opp = new Opportunity(Name='Apex - Test Opportunity',StageName='Suspect', CloseDate=System.today());
        insert opp;

        Deal_Approval__c da = new Deal_Approval__c(Name='Apex Test Deal Approval', Opportunity__c = opp.Id, Approval_Status__c = 'Not started', Approval_Ref__c='DEALSHEET 123');
        insert da;

        Deal_Approval__c da1 = new Deal_Approval__c(Name='Apex Test Deal Approval1', Opportunity__c = opp.Id, Approval_Status__c = 'Not started', Approval_Ref__c='DEALSHEET 123');
        insert da1;

        Opportunity resultOpp = [select id, Approval_Status__c from Opportunity where id = :opp.Id];
        System.assertNotEquals('Approved', resultOpp.Approval_Status__c, 'Status should not be Approved yet');

        da.Approval_Status__c = 'Approved';
        update da;

        resultOpp = [select id, Approval_Status__c from Opportunity where id = :opp.Id];
        System.assertNotEquals('Approved', resultOpp.Approval_Status__c, 'Status should not be Approved yet');

        da1.Approval_Status__c = 'Approved';
        update da1;

        resultOpp = [select id, Approval_Status__c from Opportunity where id = :opp.Id];
        System.assertEquals('Approved', resultOpp.Approval_Status__c, 'Status on opportunity should be updated to Approved');
    }

    static testMethod void shouldApproveQuoteStatus()
    {

        Opportunity opp = new Opportunity(Name='Apex - Test Opportunity',StageName='Suspect', CloseDate=System.today());
        insert opp;

        Deal_Approval__c da = new Deal_Approval__c(Name='Apex Test Deal Approval', Opportunity__c = opp.Id, CB_PS_Quote_Approval_Status__c = 'Pending', Approval_Ref__c='123');
        insert da;

        Deal_Approval__c da1 = new Deal_Approval__c(Name='Apex Test Deal Approval1', Opportunity__c = opp.Id, CB_PS_Quote_Approval_Status__c = 'Pending', Approval_Ref__c='123');
        insert da1;

        Opportunity resultOpp = [select id, PS_Quote_Approval_Status__c from Opportunity where id = :opp.Id];
        System.assertNotEquals('APPROVED', resultOpp.PS_Quote_Approval_Status__c, 'Status should not be Approved yet');

        da.CB_PS_Quote_Approval_Status__c = 'approved';
        update da;

        resultOpp = [select id, PS_Quote_Approval_Status__c from Opportunity where id = :opp.Id];
        System.assertNotEquals('APPROVED', resultOpp.PS_Quote_Approval_Status__c, 'Status should not be Approved yet');

        da1.CB_PS_Quote_Approval_Status__c = 'approved';
        update da1;

        resultOpp = [select id, PS_Quote_Approval_Status__c from Opportunity where id = :opp.Id];
        System.assertEquals('APPROVED', resultOpp.PS_Quote_Approval_Status__c, 'Status on opportunity should be updated to Approved');
    }

    static testMethod void shouldApproveQuoteStatus_Head_of_Academy()
    {

        Opportunity opp = new Opportunity(Name='Apex - Test Opportunity',StageName='Suspect', CloseDate=System.today(),Approval_Status__c ='');
        insert opp;

        Deal_Approval__c da = new Deal_Approval__c(Name='Apex Test Deal Approval', Opportunity__c = opp.Id, PS_Head_of_Academy_Approval_Status__c = 'Pending', Approval_Ref__c='123');
        insert da;

        Deal_Approval__c da1 = new Deal_Approval__c(Name='Apex Test Deal Approval1', Opportunity__c = opp.Id, PS_Head_of_Academy_Approval_Status__c = 'Pending', Approval_Ref__c='123');
        insert da1;

        Opportunity resultOpp = [select id, PS_Quote_Approval_Status__c from Opportunity where id = :opp.Id];
        System.assertNotEquals('APPROVED', resultOpp.PS_Quote_Approval_Status__c, 'Status should not be Approved yet');

        da.PS_Head_of_Academy_Approval_Status__c = 'approved';
        update da;

        resultOpp = [select id, PS_Quote_Approval_Status__c from Opportunity where id = :opp.Id];
        System.assertNotEquals('APPROVED', resultOpp.PS_Quote_Approval_Status__c, 'Status should not be Approved yet');

        da1.PS_Head_of_Academy_Approval_Status__c = 'approved';
        update da1;

        resultOpp = [select id, PS_Quote_Approval_Status__c from Opportunity where id = :opp.Id];
        System.assertEquals('APPROVED', resultOpp.PS_Quote_Approval_Status__c, 'Status on opportunity should be updated to Approved');
    }
}