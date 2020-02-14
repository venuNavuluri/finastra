@isTest
private class AwaitingClientActionController_test
{
    private static testmethod void AwaitingClientAction_testMethod()
    {
        
        Account newAcc =  TestUtils.getAccount('tests acc');
        newAcc.Site = 'Parent';
        insert newAcc;
        
        Contact portalContact1 = TestUtils.getContact(newAcc, 'PortalContac1t');
        insert portalContact1;
            
        User communityUser = TestUtils.getCustomerPortalUser('test.portal1@gmail.com', portalContact1);
        communityUser.Alias = 'por1user';
        communityUser.email='test@gmail.com';            
        
      System.runAs(communityUser)
      {
        AwaitingClientActionController aw1 = new AwaitingClientActionController();
        List<Account> lacc = aw1.getAccRecords();
        String sessionid = aw1.GetMySessionId();
        aw1.PutAccId();
        aw1.getAccId();
      }
    }
}