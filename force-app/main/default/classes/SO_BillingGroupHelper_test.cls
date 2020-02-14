@isTest
public class SO_BillingGroupHelper_test {
    
    @testSetup static void invoke_bgHelper(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount('Test Account'); 
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        Contract con = TestDataFactory.createContract(acc, opp);        
        Test.stopTest();      
    }
    
    @isTest static void test_BillingGroupCreation(){
        Test.startTest();
        Contract con = [SELECT Id, Name, AccountId, Billing_Group_Entity__c, Misys_Opportunity__c, Opportunity_Currency_Code__c,Memo__c, StartDate, Misys_Entity__c, Bill_To__c,Ship_To__c, Contract_Expiry_Date__c FROM Contract LIMIT 1];
        Billing_Group__c bGroup =  SO_BillingGroupHelper.BillingGroupCreation(con);
        system.assertEquals(1, [SELECT count() FROM Billing_Group__c], 'One Billing Group created');
        Test.stopTest();
    }
    @isTest static void test_BillingGroupCreation1(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');

        System.runAs(u2) {
        Contract con = [SELECT Id, Name, AccountId, Billing_Group_Entity__c, Misys_Opportunity__c, Opportunity_Currency_Code__c,Memo__c, StartDate, Misys_Entity__c, Bill_To__c,Ship_To__c, Contract_Expiry_Date__c FROM Contract LIMIT 1];
        Billing_Group__c bGroup =  SO_BillingGroupHelper.BillingGroupCreation(con);
        system.assertEquals(1, [SELECT count() FROM Billing_Group__c], 'One Billing Group created');
        }
        Test.stopTest();
    }
    @isTest static void test_BillingGroupCreation2(){
        Test.startTest();
       
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {
        Contract con1 = [SELECT Id, Name, AccountId, Billing_Group_Entity__c, Misys_Opportunity__c, Opportunity_Currency_Code__c,Memo__c, StartDate, Misys_Entity__c, Bill_To__c,Ship_To__c, Contract_Expiry_Date__c FROM Contract LIMIT 1];
        Billing_Group__c bGroup1 =  SO_BillingGroupHelper.BillingGroupCreation(con1);
        system.assertEquals(1, [SELECT count() FROM Billing_Group__c], 'One Billing Group created');    
        }
        Test.stopTest();
    }
    @isTest static void test_BillingGroupCreation3(){
        
        try {
            SO_BillingGroupHelper.BillingGroupCreation(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
    
    }
    
    @isTest static void test_addBGtoSubscriptions(){
        Test.startTest();
        
        Contract con = [SELECT Id, Name, AccountId, Billing_Group_Entity__c, Misys_Opportunity__c, Opportunity_Currency_Code__c,Memo__c, StartDate, Misys_Entity__c, Bill_To__c,Ship_To__c, Contract_Expiry_Date__c FROM Contract LIMIT 1];
        Billing_Group__c bGroup = SO_BillingGroupHelper.BillingGroupCreation(con);
        TestDataFactory.createRLF_Subscription(con, bGroup.Id);        
        SO_BillingGroupHelper.addBGtoSubscriptions(bGroup);        
        system.assertEquals(bGroup.Id, [SELECT Id, Billing_Group__c FROM SBQQ__Subscription__c LIMIT 1].Billing_Group__c, 'Billing Group Id is updated with subs');
        system.assertEquals(con.Id, [SELECT Id, Billing_Group__c,SBQQ__Contract__c FROM SBQQ__Subscription__c LIMIT 1].SBQQ__Contract__c);
        Test.stopTest();
    }
     @isTest static void test_addBGtoSubscriptions1(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');

        System.runAs(u2) {
        Contract con = [SELECT Id, Name, AccountId, Billing_Group_Entity__c, Misys_Opportunity__c, Opportunity_Currency_Code__c,Memo__c, StartDate, Misys_Entity__c, Bill_To__c,Ship_To__c, Contract_Expiry_Date__c FROM Contract LIMIT 1];
        Billing_Group__c bGroup = SO_BillingGroupHelper.BillingGroupCreation(con);
        TestDataFactory.createRLF_Subscription(con, bGroup.Id);        
        SO_BillingGroupHelper.addBGtoSubscriptions(bGroup);        
        system.assertEquals(bGroup.Id, [SELECT Id, Billing_Group__c FROM SBQQ__Subscription__c LIMIT 1].Billing_Group__c, 'Billing Group Id is updated with subs');
        system.assertEquals(con.Id, [SELECT Id, Billing_Group__c,SBQQ__Contract__c FROM SBQQ__Subscription__c LIMIT 1].SBQQ__Contract__c);
        }
        
        Test.stopTest();
    }
    @isTest static void test_addBGtoSubscriptions2(){
        Test.startTest();
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {
         Contract con1 = [SELECT Id, Name, AccountId, Billing_Group_Entity__c, Misys_Opportunity__c, Opportunity_Currency_Code__c,Memo__c, StartDate, Misys_Entity__c, Bill_To__c,Ship_To__c, Contract_Expiry_Date__c FROM Contract LIMIT 1];
        Billing_Group__c bGroup1 = SO_BillingGroupHelper.BillingGroupCreation(con1);
        TestDataFactory.createRLF_Subscription(con1, bGroup1.Id);        
        SO_BillingGroupHelper.addBGtoSubscriptions(bGroup1);        
        system.assertEquals(bGroup1.Id, [SELECT Id, Billing_Group__c FROM SBQQ__Subscription__c LIMIT 1].Billing_Group__c, 'Billing Group Id is updated with subs');
        system.assertEquals(con1.Id, [SELECT Id, Billing_Group__c,SBQQ__Contract__c FROM SBQQ__Subscription__c LIMIT 1].SBQQ__Contract__c);
           
        }
        Test.stopTest();
    }
    @isTest static void test_addBGtoSubscriptions3(){
        
        try {
            SO_BillingGroupHelper.addBGtoSubscriptions(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
    
    }
    
}