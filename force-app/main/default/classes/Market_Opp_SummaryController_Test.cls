@isTest

private class Market_Opp_SummaryController_Test
{
    static testmethod void method1()
    {
        Account acc1 = TestUtility.sampleAccount();
        acc1.Type = 'Customer';
        insert acc1;
        
        Contact con = TestUtility.sampleContact();
        con.accountId = acc1.Id;
        insert con;
        
        Acct_Profile__c acctprof = new Acct_Profile__c();
        acctprof.Account__c = acc1.Id;
        acctprof.Next_Review_Date__c = Date.today();
        insert acctprof;
        
        PageReference pageRef = Page.Market_Opportunity_Summary;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',acctprof.id);
        Market_Opp_SummaryController controller = new Market_Opp_SummaryController(new ApexPages.StandardController(acctprof));
        controller.acctpro = acctprof;
        controller.recId = acctprof.Id;
        controller.setup();
        
        controller.acctpro.Upsell_Value_AM__c=1000;
        controller.acctpro.Xsell_Value_AM__c=2000;
        controller.acctpro.Suggested_Solution_AM__c='Testing...123';
        controller.save();
        Acct_Profile__c acc = [Select Upsell_Value_AM__c from Acct_Profile__c where ID=:controller.acctpro.Id];
        System.assertEquals(acc.Upsell_Value_AM__c,controller.acctpro.Upsell_Value_AM__c);
    }
    
    static testmethod void method2()
    {
        Account acc1 = TestUtility.sampleAccount();
        acc1.Type = 'Customer';
        insert acc1;
        
        Contact con = TestUtility.sampleContact();
        con.accountId = acc1.Id;
        insert con;
        
        Acct_Profile__c acctprof = new Acct_Profile__c();
        acctprof.Account__c = acc1.Id;
        acctprof.Next_Review_Date__c = Date.today();
        insert acctprof;
        
        PageReference pageRef = Page.Market_Opportunity_Summary;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',acctprof.id);
        Market_Opp_SummaryController controller = new Market_Opp_SummaryController(new ApexPages.StandardController(acctprof));
        controller.acctpro = acctprof;
        controller.recId = acctprof.Id;
        controller.setup();
        
        controller.acctpro.Upsell_Value_AM__c=1000;
        controller.acctpro.Xsell_Value_AM__c=2000;
        controller.acctpro.Suggested_Solution_AM__c='Testing...123';
        controller.cancel();
        Acct_Profile__c acc = [Select Upsell_Value_AM__c from Acct_Profile__c where ID=:controller.acctpro.Id];
        System.assertEquals(acc.Upsell_Value_AM__c,Null);
    }
    
    static testmethod void method3()
    {
        Account acc1 = TestUtility.sampleAccount();
        acc1.Type = 'Customer';
        insert acc1;
        
        Contact con = TestUtility.sampleContact();
        con.accountId = acc1.Id;
        insert con;
        
        Acct_Profile__c acctprof = new Acct_Profile__c();
        acctprof.Account__c = acc1.Id;
        acctprof.Next_Review_Date__c = Date.today();
        insert acctprof;
        
        PageReference pageRef = Page.Market_Opportunity_Summary;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',acctprof.id);
        Market_Opp_SummaryController controller = new Market_Opp_SummaryController(new ApexPages.StandardController(acctprof));
        controller.acctpro = acctprof;
        controller.recId = acctprof.Id;
        controller.setup();
        
        controller.acctpro.Upsell_Value_AM__c=1000;
        controller.acctpro.Xsell_Value_AM__c=2000;
        controller.acctpro.Suggested_Solution_AM__c='Testing...123';
        controller.edit();
        Acct_Profile__c acc = [Select Upsell_Value_AM__c from Acct_Profile__c where ID=:controller.acctpro.Id];
        System.assertEquals(acc.Upsell_Value_AM__c,Null);
    }
}