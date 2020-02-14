@isTest
private class UpdateOppMarketingDetails_Test {

   // CRON expression: midnight on March 15.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 15 3 ? 2022';

   private static void scheduleUpdateOppMarketingDetails(){
      Test.startTest();
      // Schedule the test job
      String jobId = System.schedule('UpdateOppMarketingDetailsTest',CRON_EXP,new UpdateOppMarketingDetails());
     // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered,NextFireTime FROM CronTrigger WHERE id = :jobId];
      // Verify the expressions are the same
      System.assertEquals(CRON_EXP,ct.CronExpression);
      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);
      // Verify the next time the job will run
      System.assertEquals('2022-03-15 00:00:00',String.valueOf(ct.NextFireTime));
      // Verify the scheduled job hasn't run yet.
      Test.stopTest();
   }
   
    static testmethod void TestCreateOpportunityFromContact(){
        //To create test Account 
        Account testAccount1 = TestUtility.sampleAccount();
        insert testAccount1;
        //To create test contact
        Contact testContact1 = TestUtility.sampleContact();
        testContact1.AccountId = testAccount1.Id;
        testContact1.Inactive_Contact__c = false;
        testContact1.Marketing_Involved_Program__c='Test Update Opp Marketing Involved Program on Contact Updation 1';
        testContact1.MQL_Program__c = 'Test Schedule Apex when Opportunity is created from Contact';
        insert testContact1;
         //To create test opportunity 1
        Opportunity testOpp1= TestUtility.sampleOpportunity(testContact1);
        testOpp1.stageName='2. Create';
        Database.SaveResult srOpp1 = Database.insert(testOpp1, true);
        System.assert(srOpp1.isSuccess());
         //To create test opportunity 2
        Opportunity testOpp2= TestUtility.sampleOpportunity(testContact1);
        testOpp2.stageName='4. Develop';
        Database.SaveResult srOpp2 = Database.insert(testOpp2, true);
        System.assert(srOpp2.isSuccess());
        //To add the contact to opportunities as contact Role
        List<OpportunityContactRole> oppConList = new List<OpportunityContactRole>();
        OpportunityContactRole testOppRoleCon1=(new OpportunityContactRole (ContactId=testContact1.Id, OpportunityId=testOpp1.Id, Role='Decision Maker',IsPrimary=TRUE));
        oppConList.add(testOppRoleCon1);
        OpportunityContactRole testOppRoleCon2=(new OpportunityContactRole (ContactId=testContact1.Id, OpportunityId=testOpp2.Id, Role='Decision Maker',IsPrimary=TRUE));
        oppConList.add(testOppRoleCon2);
        insert oppConList;
      
        
        UpdateOppMarketingDetails_Test.scheduleUpdateOppMarketingDetails();
        List<Opportunity> updatedOppList = [select id,Marketing_Involved_Program__c,Marketing_Generated_Program__c from Opportunity where id in (:testOpp1.Id, :testOpp2.Id)];
        for(Opportunity oppObj: updatedOppList){
            // System.assertEquals('Test Schedule Apex when Opportunity is created from Contact', oppObj.Marketing_Generated_Program__c);
        }
    
    }
    
     
     static testmethod void TestAddContactToOpportunity(){
        //To create test Account 
        Account testAccount1 = TestUtility.sampleAccount();
        insert testAccount1;
        //To create test contact
        Contact testContact1 = TestUtility.sampleContact();
        testContact1.AccountId = testAccount1.Id;
        testContact1.Inactive_Contact__c = false;
        testContact1.Marketing_Involved_Program__c='Test Update Opp Marketing Involved Program on Contact Updation 1';
        testContact1.MQL_Program__c = 'Test Schedule Apex when Opportunity is created from Contact';
        insert testContact1;
        
        Contact testContact2 = TestUtility.sampleContact();
        testContact2.AccountId = testAccount1.Id;
        testContact2.Inactive_Contact__c = false;
        testContact2.Marketing_Involved_Program__c='Test Update Opp Marketing Involved Program on Contact Updation 2';
        insert testContact2;
        
        //Opportunity updatedOpp = [select id,Marketing_Involved_Program__c,Marketing_Generated_Program__c,StageName from Opportunity where stageName NOT in('Closed Won','Closed Lost','Closed Qualified Out') limit 1];

        Opportunity updatedOpp = TestUtility.sampleOpportunity(testContact1);
        updatedOpp.stageName='2. Create';
        Database.SaveResult srOpp1 = Database.insert(updatedOpp, true);
        
        //To add the contact to opportunities as contact Role
        List<OpportunityContactRole> oppConList = new List<OpportunityContactRole>();
        OpportunityContactRole testOppRoleCon1=(new OpportunityContactRole (ContactId=testContact1.Id, OpportunityId=updatedOpp.Id, Role='Decision Maker',IsPrimary=FALSE));
        oppConList.add(testOppRoleCon1);
        OpportunityContactRole testOppRoleCon2=(new OpportunityContactRole (ContactId=testContact2.Id, OpportunityId=updatedOpp.Id, Role='Decision Maker',IsPrimary=TRUE));
        oppConList.add(testOppRoleCon2);
        insert oppConList;
    
        UpdateOppMarketingDetails_Test.scheduleUpdateOppMarketingDetails();
        updatedOpp = [select id,Marketing_Involved_Program__c from Opportunity where id = :updatedOpp.id limit 1];
        System.assertEquals('Test Update Opp Marketing Involved Program on Contact Updation 2', updatedOpp.Marketing_Involved_Program__c);
     
    }
}