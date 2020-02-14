@isTest
Private Class Test_AccountGovernance
{
    static testmethod void method1()
    {
        Account acc1 = new Account( Name = 'Test Account' );
        insert acc1;
        
        User usr = TestUtility.sampleUser();
        insert usr;
        
        AccountTeamMember acm = new AccountTeamMember();
        acm.AccountId = acc1.Id;
        acm.UserId = usr.Id;
        insert acm;
        
        Opportunity opp = TestUtility.sampleOpportunity();
        insert opp;
        
        Task tsk = new Task();
        tsk.Sales_Role__c = 'Account Governance';
        tsk.Status = 'Not Started';
        tsk.ActivityDate = Date.Today();
        insert tsk; 
        
        Event evt = new Event();
        evt.OwnerId = usr.Id;
        evt.Sales_Role__c = 'Account Governance';
        evt.DurationInMinutes = 90;
        evt.ActivityDateTime = datetime.newInstance(2016, 2, 2, 12, 30, 0);
        insert evt; 
        
        Case cse = TestUtility.sampleCase();
        insert cse;
        
        Acct_Profile__c accpr = new Acct_Profile__c();
        accpr.Account__c = acc1.Id;
        insert accpr;
        
        At_Risk__c arrisk = new At_Risk__c();
        arrisk.Account__c = acc1.Id;
        insert arrisk;
        
        roi__Reference_Nomination__c rfn = new roi__Reference_Nomination__c();
        rfn.roi__Account__c = acc1.Id;
        insert rfn;
        
        Test.startTest();

        Test.setCurrentPage(Page.Account_Governance);
        ApexPages.currentPage().getParameters().put('Id', acc1.Id);
        agcontrollertrial accgov = new agcontrollertrial(new Apexpages.StandardController(acc1));
        accgov.refresh();
        accgov.search();
        accgov.clear();
        Test.stopTest();
        
    }
}