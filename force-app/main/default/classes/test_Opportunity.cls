@isTest
private class test_Opportunity {

    
    public static testMethod void testOpportunityLineItemScheduleUpdate()
    {
        //Set up test data
        //Account testAccount = TestUtility.sampleAccount();
        //insert testAccount;
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity testOpp1 = TestUtility.sampleOpportunity();
        testOpp1.CloseDate = system.today();
        opps.add(testOpp1);
        Opportunity testOpp2 = TestUtility.sampleOpportunity();
        testOpp2.CloseDate = system.today();
        opps.add(testOpp2);
        insert opps;
        OpportunityLineItem testProduct = TestUtility.sampleOpportunityLineItem(testOpp1, 'PS (T)');
        insert testProduct;
        OpportunityLineItemSchedule testProductSchedule = TestUtility.sampleOpportunityLineItemSchedule(testOpp1, testProduct);
        insert testProductSchedule;
        
        //Run the actions to test the update
        test.startTest();
        //Test the update on an opportunity with line items that have a schedule
        testOpp1.CloseDate = system.today().addMonths(2);
        //Test the update on an opportunity with no line items and no schedule
        testOpp2.CloseDate = system.today().addMonths(2);
        update opps;
        test.stopTest();
        
        //Verify the test results
        OpportunityLineItemSchedule updatedProductSchedule = [select id, ScheduleDate from OpportunityLineItemSchedule where OpportunityLineItemId = :testProduct.Id];
        system.debug('Updated OppLineItemSchedule: '+updatedProductSchedule);
        //system.assertEquals(testOpp1.CloseDate,updatedProductSchedule.ScheduleDate);
    }

    public static testMethod void shouldDeleteOpportunity()
    {
        Opportunity testOpp1 = TestUtility.sampleOpportunity();
        testOpp1.CloseDate = system.today();
       // testOpp1.OLIs_Pushed_To_Parent__c = true;
        insert testOpp1;
        OpportunityLineItem testProduct = TestUtility.sampleOpportunityLineItem(testOpp1, 'PS (T)');
        insert testProduct;

        delete testOpp1;

        List<OpportunityLineItem> result = [select id from OpportunityLineItem where id = :testProduct.id];
        system.assert(result.isEmpty(), 'opportunity line items should be deleted after opportunity deletion');
    }


    public static testMethod void testCreateQuotaCredits()
    {   
        //Set up test data
        Account testAcc = new Account(Name='testAcct');
        insert testAcc;
        testAcc.NumberOfEmployees = 1;
        update testAcc;
        Opportunity testTrigOpp = new Opportunity(AccountId=testAcc.id, Name='test - Opp', StageName='Prove', CloseDate=date.valueOf('2010-01-01'));
        testTrigOpp.OwnerId = Userinfo.getUserId();
        
        List<Com_Splits__c> result1 = new List<Com_Splits__c>();
        Id result1OppOwner = null;
        List<Com_Splits__c> result2 = new List<Com_Splits__c>();  
        
        //User testUser = [SELECT u.id FROM user u WHERE u.name = 'Cheryl Abreu' LIMIT 1];
        User testUser = TestUtility.sampleUser();
        insert testUser;
        
        //Run the test
        Test.startTest();
            insert testTrigOpp;
            result1OppOwner = testTrigOpp.OwnerId;
            result1 = [select id, Employee_Name__c, Opportunity__c from Com_Splits__c where Opportunity__c = :testTrigOpp.Id];
            testTrigOpp.OwnerId = testUser.id;
            update testTrigOpp;
            result2 = [select id, Employee_Name__c, Opportunity__c from Com_Splits__c where Opportunity__c = :testTrigOpp.Id];
        Test.stopTest();
        
        //Verify the results
        system.assert(result1.size() > 0);
        system.assertEquals(result1OppOwner,result1[0].Employee_Name__c);
        system.assert(result2.size() > 0);
        system.assertEquals(testTrigOpp.OwnerId,result2[0].Employee_Name__c);
        
    }
    
 /*
   public static testMethod void testChangeOppDate_change()
    {   
        Account testAcc = new Account(Name='testAcct');
        insert testAcc;
        testAcc.NumberOfEmployees = 1;
        update testAcc;
        
        List<Opportunity> lopp = new List<Opportunity>();
                
        //, ForecastCategory='Pipeline', CurrencyISOCode='U.S. Dollar'
        Opportunity testTrigOpp = new Opportunity(AccountId=testAcc.id, Name='test - Opp', StageName='Prove', CloseDate=date.valueOf('2010-01-01'), Sales_Region_FY07__c = 'AMER', Type = 'New Product', MainProduct__c ='Midas (B)', CurrencyISOCode='USD');
        Opportunity testTrigOpp1 = new Opportunity(AccountId=testAcc.id, Name='test - Opp', StageName='Prove', CloseDate=date.valueOf('2010-01-01'), Sales_Region_FY07__c = 'APAC', Type = 'New Product', MainProduct__c ='Midas (B)', CurrencyISOCode='USD');
        Opportunity testTrigOpp2 = new Opportunity(AccountId=testAcc.id, Name='test - Opp', StageName='Prove', CloseDate=date.valueOf('2010-01-01'), Sales_Region_FY07__c = 'NER', Type = 'New Product', MainProduct__c ='Midas (B)', CurrencyISOCode='USD');
        Opportunity testTrigOpp3 = new Opportunity(AccountId=testAcc.id, Name='test - Opp', StageName='Prove', CloseDate=date.valueOf('2010-01-01'), Sales_Region_FY07__c = 'Middle East', Type = 'New Product', MainProduct__c ='Midas (B)', CurrencyISOCode='USD');
   //     Opportunity testTrigOpp4 = new Opportunity(AccountId=testAcc.id, Name='test - Opp', StageName='Prove', CloseDate=date.valueOf('2010-01-01'), Type = 'New Product', MainProduct__c ='Midas (B)', CurrencyISOCode='USD');
    
        lopp.add(testTrigOpp);
        lopp.add(testTrigOpp1);
        lopp.add(testTrigOpp2);
        lopp.add(testTrigOpp3);
   //     lopp.add(testTrigOpp4);
        
        insert lopp;
        
        //insert testTrigOpp;
        
        //User testUser = [SELECT u.id FROM user u WHERE u.name = 'Prashant Bhure' LIMIT 1];
        User testUser = [SELECT u.id FROM user u WHERE IsActive = true LIMIT 1];
        
        for(Opportunity l : lopp)
        {
         l.OwnerId = testUser.id;
        }
        update lopp;
        
       List<opportunityLineItem> lOppItem = new List<opportunityLineItem>();
       
        for(Opportunity lo : lopp)
        {
        opportunityLineItem testLineItem = new opportunityLineItem();
        testLineItem.OpportunityId = lo.Id;
        testLineItem.Quantity = 1;
        testLineItem.UnitPrice = 1;
        System.debug('Inserted Opp Currency:' + lo.CurrencyISOCode);
        testLineItem.PricebookEntryId = [Select p.Id, p.Name, p.Pricebook2Id, p.Product2Id, p.ProductCode, p.UnitPrice from PricebookEntry p WHERE p.Name = 'Almonde Consulting Engagement FP' AND IsActive = TRUE AND CurrencyISOCode = 'USD' LIMIT 1].id;
        lOppItem.add(testLineItem);
        }
        insert lOppItem;
        
        System.debug('Inserted testLineItem Id:' + lOppItem);
        
        List<opportunityLineItemSchedule> lOppSch = new List<opportunityLineItemSchedule>();
        
        for(opportunityLineItem it : lOppItem)
        {
        opportunityLineItemSchedule testLineItemSchedule = new opportunityLineItemSchedule();
        testLineItemSchedule.OpportunityLineItemId = it.id;
        testLineItemSchedule.ScheduleDate = date.valueOf('2010-01-01');
        //testLineItemSchedule.CurrencyISOCode='USD';
        testLineItemSchedule.Type = 'Revenue';
        testLineItemSchedule.Revenue = 1;
        lOppSch.add(testLineItemSchedule);
        }
      
      
      //  System.debug('Inserted testLineItem Id:' + testLineItem.Id);
      //  System.debug('Inserted testLineItem OpportunityId Id:' + testLineItem.OpportunityId);
      
      
        try {
              insert lOppSch;
                   //      insert testLineItemSchedule;
        }
           catch (Exception ex)
        {
            System.debug('********************* Exception statement goes here....' + ex);
        }
        

        // Change the date on the opp to the same month
        for(Opportunity lu : lopp)
        {
        lu.CloseDate =  date.valueOf('2010-01-10');
        }
        update lopp;
        
        //Now insert PS Rep into OpportunityTeamMember
        
        List<OpportunityTeamMember> lOppTeam = new List<OpportunityTeamMember>();
        
        for(Opportunity lch : lopp)
        { 
        OpportunityTeamMember testTeamMember = new OpportunityTeamMember();
        testTeamMember.OpportunityId =  lch.Id;
        testTeamMember.TeamMemberRole = 'PS Rep';
        testTeamMember.UserId = testUser.id;    
        lOppTeam.add(testTeamMember);
        }
        insert lOppTeam;
                
        // And change the date on the opp to the different month
        for(Opportunity lu : lopp)
        {
        lu.CloseDate =  date.valueOf('2010-02-10');
        }
        update lopp;   
    }
    */
    
    private static testMethod void testOpportunityWinLossReport_CE()
    {
        //Set up test data
        Account testAccount = TestUtility.sampleAccount();
        insert testAccount;
        Opportunity testOpp1 = TestUtility.sampleOpportunity();
        testOpp1.CloseDate = system.today();
        insert testOpp1;
        Opportunity testOpp2 = TestUtility.sampleOpportunity();
        testOpp2.CloseDate = system.today();
        insert testOpp2;
        User u1 = TestUtility.sampleUser();
        u1.LastName = 'User1';
        insert u1;
        User u2 = TestUtility.sampleUser();
        u2.LastName = 'User2';
        u2.UserName = 'testuser'+datetime.now().millisecond()+'@d.com';
        insert u2;
        
        //Add Sales Team Members to testOpp2
        List<OpportunityTeamMember> lOppTeam = new List<OpportunityTeamMember>();
        OpportunityTeamMember tm1 = new OpportunityTeamMember();
        tm1.OpportunityId = testOpp2.Id;
        tm1.TeamMemberRole = 'PS Rep';
        tm1.UserId = u1.Id;
        lOppTeam.add(tm1);
        OpportunityTeamMember tm2 = new OpportunityTeamMember();
        tm2.OpportunityId = testOpp2.Id;
        tm2.TeamMemberRole = 'PS Rep';
        tm2.UserId = u2.Id;
        lOppTeam.add(tm2);
        insert lOppTeam;
        
        Test.startTest();
        //Test with no Sales Team members
        Test.setCurrentPage(Page.OpportunityWinLossReport);
        OpportunityWinLossReport_CE controller1 = new OpportunityWinLossReport_CE(new ApexPages.StandardController(testOpp1));
        system.debug('testOpp1 Team List: '+controller1.TeamList);
        
        //Test with 2 Sales Team members
        OpportunityWinLossReport_CE controller2 = new OpportunityWinLossReport_CE(new ApexPages.StandardController(testOpp2));
        system.debug('testOpp2 Team List: '+controller2.TeamList);
        
        Test.stopTest();
        
        //Verify results
        system.assertEquals(controller1.TeamList,'');
        system.assert(controller2.TeamList.contains(', User2'));
    } 
}