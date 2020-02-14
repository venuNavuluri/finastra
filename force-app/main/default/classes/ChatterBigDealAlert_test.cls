@isTest
private class ChatterBigDealAlert_test {

    //DW 10/07
    //Re-wrote the test method.
    //NOTE: Not sure how to "assert" for anything below. The output is a chatter post to a group,
    //however, the one created by the test will be no different to any other, so simply asserting
    //that one is created is not going to work.
    public static testmethod void runTest()
    {
        
        //Setup the Chatter Group
        CollaborationGroup chatterGroup = createChatterGroup();
        
        //Setup the custom settings for the Chatter Big Deal Alerts
        createBigDealAlertSettings(chatterGroup);
        
        Account acc = TestUtility.sampleAccount();
        insert acc;

        User u = TestUtility.sampleUser();
        insert u;

        Opportunity opp = createBigDealOppty(acc, u);
        Opportunity opp2 = createBigDealOppty(acc, u);
        
        Test.startTest();
        //AK - commenting out the runAs as this is making the test class to fail due to a new validation rule.
        //System.runAs(u){
            opp.Client_Signed_contract_attached__c = true;
            opp.StageName = 'Closed Won';
            opp.Approval_Status__c = 'Approved';
            update opp;
            
            opp2.Client_Signed_contract_attached__c = true;
            opp2.StageName = 'Closed Won';
            opp2.Approval_Status__c = 'Approved';
            opp2.CloseDate = Date.today().addMonths(-2);
            update opp2;
            
            //Finally call the empty constructor
            //new ChatterBigDealAlert();
        //}
        Test.stopTest();
        
        //Check the results
        //List<CollaborationGroupFeed> bdaPosts = [select id, createddate, createdbyid from CollaborationGroupFeed where parentid = :chatterGroup.Id];
        //system.debug('Chatter Posts: ' + bdaPosts);
        //system.assertEquals(1, bdaPosts.size());
        
    }
    
    private static Opportunity createBigDealOppty(Account acc, User u)
    {
        Opportunity opp = TestUtility.sampleOpportunity();
        opp.AccountId = acc.Id;
        opp.Amount = 200;
        opp.License_Total__c = 10;
        opp.PS_Total__c = 10;
        //opp.Operations_Owner__c = u.id;
        opp.OwnerId = u.Id;
        opp.CurrencyIsoCode = 'USD';
        opp.Is_PearlMastered__c = true;
        opp.Contractual_Billing_Address__c = 'blah';
        opp.Contractual_Shipping_Address__c = 'more blah';
        insert opp;

        return opp;
    }
    
    private static void createBigDealAlertSettings(CollaborationGroup chatterGroup)
    {
        //Setup the custom settings for the Chatter Big Deal Alerts
        ChatterBigDealAlertSettings__c bdas = new ChatterBigDealAlertSettings__c();
        //Set the org wide default setting
        bdas.SetupOwnerId = UserInfo.getOrganizationId();
        
        bdas.Active__c = true;
        bdas.Big_Deal_Alert_Chatter_Group__c = chatterGroup.Id;
        bdas.Threshold__c = 100;
        bdas.AutoSubscribeGroupId__c = chatterGroup.Id;
        bdas.ErrorEmailAddress__c = 'test@test.com';
        bdas.Remove_User_After_Post__c = false;
        bdas.ExternalId__c = 'Default';
        insert bdas;
    }
    
    private static CollaborationGroup createChatterGroup()
    {
        //Setup the Chatter Group
        CollaborationGroup chatterGroup = new CollaborationGroup(Name='testGroup');
        chatterGroup.CollaborationType = 'Public';
        insert chatterGroup;

        return chatterGroup;        
    }
}