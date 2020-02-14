@isTest

private class Account_Planning_Summ_Controller_Test
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
        PageReference pageRef = Page.Account_Planning_Summary;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',acc1.id);
        Account_Planning_Summ_Controller controller= new Account_Planning_Summ_Controller(new ApexPages.StandardController(acc1));
        controller.acct = acc1;
        controller.recId = acc1.Id;        
        controller.acct.Account_Planning_Status_AM__c ='Investigating';
        controller.acct.Account_Planning_Status_CB__c ='Investigating';
        controller.acct.Account_Planning_Status_CMBO__c ='Investigating';
        controller.acct.Account_Planning_Status_CMFO__c ='Investigating';
        controller.acct.Account_Planning_Status_DC__c ='Investigating';
        controller.acct.Account_Planning_Status_ER__c ='Investigating';
        controller.acct.Account_Planning_Status_HF__c ='Investigating';
        controller.acct.Account_Planning_Status_Lending__c ='Investigating';
        controller.acct.Account_Planning_Status_PM__c ='Investigating';
        controller.acct.Account_Planning_Status_TF__c ='Investigating';
        controller.save();
        Account acc = [Select Account_Planning_Status_AM__c from Account where ID=:controller.acct.Id];
        System.assertnotEquals(acc.Account_Planning_Status_AM__c,controller.acct.Account_Planning_Status_AM__c);
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
        PageReference pageRef = Page.Account_Planning_Summary;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',acc1.id);
        Account_Planning_Summ_Controller controller = new Account_Planning_Summ_Controller(new ApexPages.StandardController(acc1));
        controller.acct = acc1;
        controller.recId = acc1.Id;        
        controller.acct.Account_Planning_Status_AM__c ='Investigating';
        controller.cancel();
        Account acc = [Select Account_Planning_Status_AM__c from Account where ID=:controller.acct.Id];
        System.assertEquals(acc.Account_Planning_Status_AM__c,null);
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
        
        PageReference pageRef = Page.Account_Planning_Summary;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',acc1.id);
        Account_Planning_Summ_Controller controller = new Account_Planning_Summ_Controller(new ApexPages.StandardController(acc1));
        //controller.acct = acc1;
        //controller.recId = acc1.Id;        
        //controller.acct.Account_Planning_Status_AM__c ='Investigating';
        controller.edit();
        Account acc = [Select Account_Planning_Status_AM__c from Account where ID=:controller.acct.Id];
        System.assertEquals(acc.Account_Planning_Status_AM__c,null);
    }
    
    static testmethod void method4()
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
        PageReference pageRef = Page.Account_Planning_Summary;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',acc1.id);
        Account_Planning_Summ_Controller controller= new Account_Planning_Summ_Controller(new ApexPages.StandardController(acc1));
        controller.acct = acc1;
        controller.recId = acc1.Id;        
        controller.acct.Account_Planning_Status_AM__c ='Investigating';
        controller.acct.Comments_AM__c='Testing';
        controller.acct.Review_In_AM__c='1 Month';
        controller.save();
        Account acc = [Select Account_Planning_Status_AM__c from Account where ID=:controller.acct.Id];
        System.assertEquals(acc.Account_Planning_Status_AM__c,controller.acct.Account_Planning_Status_AM__c);
    }
    
    static testmethod void method5()
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
        PageReference pageRef = Page.Account_Planning_Summary;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',acc1.id);
        Account_Planning_Summ_Controller controller= new Account_Planning_Summ_Controller(new ApexPages.StandardController(acc1));
        controller.acct = acc1;
        controller.recId = acc1.Id;        
        controller.acct.Account_Planning_Status_AM__c ='No Go - Investigated';
        controller.acct.Account_Planning_Status_CB__c ='No Go - Investigated';
        controller.acct.Account_Planning_Status_CMBO__c ='No Go - Investigated';
        controller.acct.Account_Planning_Status_CMFO__c ='No Go - Investigated';
        controller.acct.Account_Planning_Status_DC__c ='No Go - Investigated';
        controller.acct.Account_Planning_Status_ER__c ='No Go - Investigated';
        controller.acct.Account_Planning_Status_HF__c ='No Go - Investigated';
        controller.acct.Account_Planning_Status_Lending__c ='No Go - Investigated';
        controller.acct.Account_Planning_Status_PM__c ='No Go - Investigated';
        controller.acct.Account_Planning_Status_TF__c ='No Go - Investigated';
        controller.save();
        Account acc = [Select Account_Planning_Status_AM__c from Account where ID=:controller.acct.Id];
        System.assertnotEquals(acc.Account_Planning_Status_AM__c,controller.acct.Account_Planning_Status_AM__c);
    }
}