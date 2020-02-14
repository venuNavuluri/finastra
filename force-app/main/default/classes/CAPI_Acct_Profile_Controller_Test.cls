@isTest
private class CAPI_Acct_Profile_Controller_Test {

    static testmethod void testSaveMethod()
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
        
        PageReference pageRef = Page.CAPI_Acct_Profile_Details_page;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',acctprof.id);
        CAPI_Acct_Profile_Controller controller = new CAPI_Acct_Profile_Controller(new ApexPages.StandardController(acctprof));
        controller.acctpro = acctprof;
        controller.acctProfilePage = pageRef;
        controller.acctpro.YoY_Number_of_employees__c=1000;
        controller.acctpro.Yr_1_Number_of_employees__c=2000;
        controller.acctpro.Number_of_employees__c=5000;
        controller.save();
        Acct_Profile__c acc = [Select YoY_Number_of_employees__c,Yr_1_Number_of_employees__c,Number_of_employees__c from Acct_Profile__c where ID=:controller.acctpro.Id];
        System.assertEquals(acc.YoY_Number_of_employees__c,controller.acctpro.YoY_Number_of_employees__c);
    }
    
    static testmethod void testEditMethod()
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
        acctprof.YoY_Number_of_employees__c=1000;
        acctprof.Yr_1_Number_of_employees__c=2000;
        acctprof.Number_of_employees__c=5000;
        insert acctprof;
        
        PageReference pageRef = Page.CAPI_Acct_Profile_Details_page;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',acctprof.id);
        CAPI_Acct_Profile_Controller controller = new CAPI_Acct_Profile_Controller(new ApexPages.StandardController(acctprof));
     
        controller.edit();
     }
    
      static testmethod void testCancelMethod()
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
        acctprof.YoY_Number_of_employees__c=1000;
        acctprof.Yr_1_Number_of_employees__c=2000;
        acctprof.Number_of_employees__c=5000;
        insert acctprof;
        
        PageReference pageRef = Page.CAPI_Acct_Profile_Details_page;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',acctprof.id);
        CAPI_Acct_Profile_Controller controller = new CAPI_Acct_Profile_Controller(new ApexPages.StandardController(acctprof));
     
        controller.cancel();
     }

}