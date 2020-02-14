@isTest

private class Territory_AP_Controller_Test
{
    static testmethod void method1()
    {
        Account acc1 = TestUtility.sampleAccount();
        acc1.Type = 'Customer';
        insert acc1;
        
        Contact con = TestUtility.sampleContact();
        con.accountId = acc1.Id;
        insert con;
        
        PageReference pageRef = Page.CurrentSolutionOverview;
        Test.setCurrentPage(pageRef);
        Territory_AP_Controller controller = new Territory_AP_Controller();
        controller.acct = acc1;
        controller.acct.Account_Planning_Status_DC__c='No Go - Investigated';
        controller.acct.Comments_DC__c='Testing';
        controller.acct.Review_In_DC__c='1 Month';
        
        controller.acct.Account_Planning_Status_AM__c='No Go - Investigated';
        controller.acct.Comments_AM__c='Testing';
        controller.acct.Review_In_AM__c='1 Month';
        
        controller.acct.Account_Planning_Status_CB__c='No Go - Investigated';
        controller.acct.Comments_CB__c='Testing';
        controller.acct.Review_In_CB__c='1 Month';
        
        controller.acct.Account_Planning_Status_ER__c='No Go - Investigated';
        controller.acct.Comments_ER__c='Testing';
        controller.acct.Review_In_ER__c='1 Month';
        
        controller.acct.Account_Planning_Status_HF__c='No Go - Investigated';
        controller.acct.Comments_HF__c='Testing';
        controller.acct.Review_In_HF__c='1 Month';
        
        controller.acct.Account_Planning_Status_CMBO__c='No Go - Investigated';
        controller.acct.Comments_CMBO__c='Testing';
        controller.acct.Review_In_CMBO__c='1 Month';
        
        controller.acct.Account_Planning_Status_Lending__c='No Go - Investigated';
        controller.acct.Comments_Lending__c='Testing';
        controller.acct.Review_In_Lending__c='1 Month';
        
        controller.acct.Account_Planning_Status_PM__c='No Go - Investigated';
        controller.acct.Comments_PM__c='Testing';
        controller.acct.Review_In_PM__c='1 Month';
        
        controller.acct.Account_Planning_Status_TF__c='No Go - Investigated';
        controller.acct.Comments_TF__c='Testing';
        controller.acct.Review_In_TF__c='1 Month';
        controller.save();
        account acc = [Select Account_Planning_Status_DC__c from Account where ID=:controller.acct.Id];
        System.assertEquals(acc.Account_Planning_Status_DC__c,controller.acct.Account_Planning_Status_DC__c);
    }
    
    static testmethod void method2()
    {
        Account acc1 = TestUtility.sampleAccount();
        acc1.Type = 'Customer';
        insert acc1;
        
        Contact con = TestUtility.sampleContact();
        con.accountId = acc1.Id;
        insert con;
        
        PageReference pageRef = Page.CurrentSolutionOverview;
        Test.setCurrentPage(pageRef);
        Territory_AP_Controller controller = new Territory_AP_Controller();
        controller.acct = acc1;
        controller.acct.Account_Planning_Status_DC__c='No Go - Investigated';
        controller.acct.Comments_DC__c='';
        controller.acct.Review_In_DC__c='1 Month';
        
        controller.acct.Account_Planning_Status_AM__c='No Go - Investigated';
        controller.acct.Comments_AM__c='';
        controller.acct.Review_In_AM__c='1 Month';
        
        controller.acct.Account_Planning_Status_CB__c='No Go - Investigated';
        controller.acct.Comments_CB__c='';
        controller.acct.Review_In_CB__c='1 Month';
        
        controller.acct.Account_Planning_Status_ER__c='No Go - Investigated';
        controller.acct.Comments_ER__c='';
        controller.acct.Review_In_ER__c='1 Month';
        
        controller.acct.Account_Planning_Status_HF__c='No Go - Investigated';
        controller.acct.Comments_HF__c='';
        controller.acct.Review_In_HF__c='1 Month';
        
        controller.acct.Account_Planning_Status_CMBO__c='No Go - Investigated';
        controller.acct.Comments_CMBO__c='';
        controller.acct.Review_In_CMBO__c='1 Month';
        
        controller.acct.Account_Planning_Status_Lending__c='No Go - Investigated';
        controller.acct.Comments_Lending__c='';
        controller.acct.Review_In_Lending__c='1 Month';
        
        controller.acct.Account_Planning_Status_PM__c='No Go - Investigated';
        controller.acct.Comments_PM__c='';
        controller.acct.Review_In_PM__c='1 Month';
        
        controller.acct.Account_Planning_Status_TF__c='No Go - Investigated';
        controller.acct.Comments_TF__c='';
        controller.acct.Review_In_TF__c='1 Month';
        controller.save();
        account acc = [Select Account_Planning_Status_DC__c from Account where ID=:controller.acct.Id];
        System.assertEquals(acc.Account_Planning_Status_DC__c,Null);
    }
    
    static testmethod void method3()
    {
        Account acc1 = TestUtility.sampleAccount();
        acc1.Type = 'Customer';
        insert acc1;
        
        Contact con = TestUtility.sampleContact();
        con.accountId = acc1.Id;
        insert con;
        
        PageReference pageRef = Page.CurrentSolutionOverview;
        Test.setCurrentPage(pageRef);
        Territory_AP_Controller controller = new Territory_AP_Controller();
        controller.acct = acc1;
        controller.acct.Account_Planning_Status_DC__c='Investigating';
        controller.acct.Comments_DC__c='Testing';
        controller.acct.Review_In_DC__c='';
        
        controller.acct.Account_Planning_Status_AM__c='Investigating';
        controller.acct.Comments_AM__c='Testing';
        controller.acct.Review_In_AM__c='';
        
        controller.acct.Account_Planning_Status_CB__c='Investigating';
        controller.acct.Comments_CB__c='Testing';
        controller.acct.Review_In_CB__c='';
        
        controller.acct.Account_Planning_Status_ER__c='Investigating';
        controller.acct.Comments_ER__c='Testing';
        controller.acct.Review_In_ER__c='';
        
        controller.acct.Account_Planning_Status_HF__c='Investigating';
        controller.acct.Comments_HF__c='Testing';
        controller.acct.Review_In_HF__c='';
        
        controller.acct.Account_Planning_Status_CMBO__c='Investigating';
        controller.acct.Comments_CMBO__c='Testing';
        controller.acct.Review_In_CMBO__c='';
        
        controller.acct.Account_Planning_Status_Lending__c='Investigating';
        controller.acct.Comments_Lending__c='Testing';
        controller.acct.Review_In_Lending__c='';
        
        controller.acct.Account_Planning_Status_PM__c='Investigating';
        controller.acct.Comments_PM__c='Testing';
        controller.acct.Review_In_PM__c='';
        
        controller.acct.Account_Planning_Status_TF__c='Investigating';
        controller.acct.Comments_TF__c='Testing';
        controller.acct.Review_In_TF__c='';
        controller.save();
        account acc = [Select Account_Planning_Status_DC__c from Account where ID=:controller.acct.Id];
        System.assertEquals(acc.Account_Planning_Status_DC__c,controller.acct.Account_Planning_Status_TF__c);
    }
}