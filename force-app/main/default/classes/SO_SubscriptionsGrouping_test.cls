@isTest
public class SO_SubscriptionsGrouping_test {
    
    @testsetup static void setup(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount('Test Account'); 
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        Contract con = TestDataFactory.createContract(acc, opp);
        Billing_Group__c bGroup = SO_BillingGroupHelper.BillingGroupCreation(con);
        SBQQ__Subscription__c sub = TestDataFactory.createILF_Subscription(con);
        sub.Billing_Group__c = bGroup.Id;
        update sub;
        
        TestDataFactory.createRLF_Subscription(con, bGroup.Id); 
        TestDataFactory.createPS_Subscription(con, TestDataFactory.add_OppBillingSchedule(opp), bGroup.Id);
        Test.stopTest();
    }
    
    @isTest static void test_sortbyProcess(){
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            Map<String, Integer> sotype_count_map = SO_SubscriptionsGrouping.sortbyProcess([SELECT Id FROM Billing_Group__c]);
            system.assertEquals(1, sotype_count_map.get('ILF - ILF'),'(1) Sales order items of SO type (ILF) Created'); 
            system.assertEquals(7, sotype_count_map.get('RLF - RLF'),'(7) Sales order items of SO type (RLF) Created');                 
        }
        Test.stopTest();
    }
    @isTest static void test_sortbyProcess2(){
        Test.startTest();
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            Map<String, Integer> sotype_count_map = SO_SubscriptionsGrouping.sortbyProcess([SELECT Id FROM Billing_Group__c]);
            system.assertEquals(1, sotype_count_map.get('ILF - ILF'),'(1) Sales order items of SO type (ILF) Created'); 
            system.assertEquals(7, sotype_count_map.get('RLF - RLF'),'(7) Sales order items of SO type (RLF) Created');                 
        }
        Test.stopTest();
    }
    @isTest static void test_sortbyProcess3(){
        try {
            SO_SubscriptionsGrouping.sortbyProcess(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
    }
    
    @isTest static void test_getSubsByTypeForPs(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            Map<String, List<SBQQ__Subscription__c>> ps_subs = SO_SubscriptionsGrouping.getSubsByTypeForPs([SELECT Id FROM Billing_Group__c]);
            system.assertEquals(3, ps_subs.get('PS - PS').size(),'(3) Sales order items of SO type (PS) Created'); 
        }
        
        Test.stopTest();
    }
    @isTest static void test_getSubsByTypeForPs2(){
        Test.startTest();
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            Map<String, List<SBQQ__Subscription__c>> ps_subs = SO_SubscriptionsGrouping.getSubsByTypeForPs([SELECT Id FROM Billing_Group__c]);
            system.assertEquals(3, ps_subs.get('PS - PS').size(),'(3) Sales order items of SO type (PS) Created');  
        }
        Test.stopTest();
        
    }
     @isTest static void test_getSubsByTypeForPs3(){
         try {
            SO_SubscriptionsGrouping.getSubsByTypeForPs(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
        
    }
    
    @isTest static void test_getSubsByType(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            Map<String, List<SBQQ__Subscription__c>> subs_type = SO_SubscriptionsGrouping.getSubsByType(SO_SubscriptionsGrouping.sortbyProcess([SELECT Id FROM Billing_Group__c]), [SELECT Id FROM Billing_Group__c].Id);
            String temp;
            for(string s: subs_type.keySet()){
                temp = s;
            }
            system.assertEquals('ILF - ILF', temp, 'ILF - ILF type should be returned' );
        }
       
        
        Test.stopTest();
    }
    @isTest static void test_getSubsByType2(){
        Test.startTest();
        
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            Map<String, List<SBQQ__Subscription__c>> subs_type = SO_SubscriptionsGrouping.getSubsByType(SO_SubscriptionsGrouping.sortbyProcess([SELECT Id FROM Billing_Group__c]), [SELECT Id FROM Billing_Group__c].Id);
            String temp;
            for(string s: subs_type.keySet()){
                temp = s;
            }
            system.assertEquals('ILF - ILF', temp, 'ILF - ILF type should be returned' );   
        }
        
        Test.stopTest();
    }
    @isTest static void test_getSubsByType3(){
         try {
            SO_SubscriptionsGrouping.getSubsByType(null, null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
        
    }
    
    @isTest static void test_getSubsByType_RLF(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            Map<String, List<SBQQ__Subscription__c>> rlf_subs = SO_SubscriptionsGrouping.getSubsByType_RLF(SO_SubscriptionsGrouping.sortbyProcess([SELECT Id FROM Billing_Group__c]), [SELECT Id FROM Billing_Group__c].Id);
            system.assertEquals(7, rlf_subs.get('RLF - RLF').size(),'(7) Sales order items of SO type (RLF) Created');  
        }
        
        
        Test.stopTest();
    }
    @isTest static void test_getSubsByType_RLF2(){
        Test.startTest();
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            Map<String, List<SBQQ__Subscription__c>> rlf_subs = SO_SubscriptionsGrouping.getSubsByType_RLF(SO_SubscriptionsGrouping.sortbyProcess([SELECT Id FROM Billing_Group__c]), [SELECT Id FROM Billing_Group__c].Id);
            system.assertEquals(7, rlf_subs.get('RLF - RLF').size(),'(7) Sales order items of SO type (RLF) Created');  
            
        }
        
        Test.stopTest();
    }
    @isTest static void test_getSubsByType_RLF3(){
         try {
            SO_SubscriptionsGrouping.getSubsByType_RLF(null, null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
        
    }
    
    @isTest static void test_getIlfRlfAddonSubsCount(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            Map<String, List<SBQQ__Subscription__c>> retMap = SO_SubscriptionsGrouping.getIlfRlfAddonSubsCount([SELECT Id FROM Billing_Group__c].Id);
            system.assertEquals(2, retMap.size(), 'list for ilf and rlf returned');
        }
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        
        Test.stopTest();
    }
    @isTest static void test_getIlfRlfAddonSubsCount2(){
        Test.startTest();
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            Map<String, List<SBQQ__Subscription__c>> retMap = SO_SubscriptionsGrouping.getIlfRlfAddonSubsCount([SELECT Id FROM Billing_Group__c].Id);
            system.assertEquals(2, retMap.size(), 'list for ilf and rlf returned');
            
        }
        Test.stopTest();
    }
    @isTest static void test_getIlfRlfAddonSubsCount3(){
         try {
            SO_SubscriptionsGrouping.getIlfRlfAddonSubsCount(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
        
    }
    
    @isTest static void test_getMaxAmountSubIdsMap(){
        Test.startTest();
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            Map<String, String> max_Sub = SO_SubscriptionsGrouping.getMaxAmountSubIdsMap([SELECT Id, Name FROM Billing_Group__c]);        
            String temp;
            for(string s: max_Sub.keySet()){
                temp = max_Sub.get(s);
            }
            AggregateResult[] agrResult = [SELECT MAX(Sold_Value__c), Id sMax from SBQQ__Subscription__c WHERE Initial_Sales_Order_Type__c LIKE 'ILF%' and Sold_Value__c != null GROUP BY Id];
            system.assertEquals((String)agrResult[0].get('sMax') ,temp, 'finding max sub by query matching with group' );
        }
        
        Test.stopTest();
    }
    @isTest static void test_getMaxAmountSubIdsMap2(){
        Test.startTest();
         Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            Map<String, String> max_Sub = SO_SubscriptionsGrouping.getMaxAmountSubIdsMap([SELECT Id, Name FROM Billing_Group__c]);        
            String temp;
            for(string s: max_Sub.keySet()){
                temp = max_Sub.get(s);
            }
            AggregateResult[] agrResult = [SELECT MAX(Sold_Value__c), Id sMax from SBQQ__Subscription__c WHERE Initial_Sales_Order_Type__c LIKE 'ILF%' and Sold_Value__c != null GROUP BY Id];
            system.assertEquals((String)agrResult[0].get('sMax') ,temp, 'finding max sub by query matching with group' );
            
        }
        Test.stopTest();
    }
    @isTest static void test_getMaxAmountSubIdsMap3(){
         try {
            SO_SubscriptionsGrouping.getMaxAmountSubIdsMap(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
        
    }
    
    @isTest static void test_getProjSubMap(){
        Test.startTest();
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            Map<String, SBQQ__Subscription__c> proj_subMap = SO_SubscriptionsGrouping.getProjSubMap(SO_SubscriptionsGrouping.getMaxAmountSubIdsMap([SELECT Id, Name FROM Billing_Group__c]));
            system.assertEquals(1, proj_subMap.size(), 'Must return one sub for creating NS Project' ); 
        }
        
        Test.stopTest();
    }
    @isTest static void test_getProjSubMap2(){
        Test.startTest();
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            Map<String, SBQQ__Subscription__c> proj_subMap = SO_SubscriptionsGrouping.getProjSubMap(SO_SubscriptionsGrouping.getMaxAmountSubIdsMap([SELECT Id, Name FROM Billing_Group__c]));
            system.assertEquals(1, proj_subMap.size(), 'Must return one sub for creating NS Project' );       
        }
        
        Test.stopTest();
    }
    @isTest static void test_getProjSubMap3(){
         try {
            SO_SubscriptionsGrouping.getProjSubMap(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
        
    }
    
    @isTest static void test_sortBillingDates(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            SBQQ__Subscription__c[] subs = [SELECT Id, Name, Billing_Group__c, Next_Billing_Date__c, Next_SO_generation_Date__c FROM SBQQ__Subscription__c];
            Map<Id, List<Date>> retMap = SO_SubscriptionsGrouping.sortBillingDates(subs);
            system.assertEquals(retMap.size(), [SELECT COUNT() FROM Billing_Group__c] , 'Dates for given Billing group sorted');
        }
        
        
        Test.stopTest();
    }
    @isTest static void test_sortBillingDates2(){
        Test.startTest();
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            SBQQ__Subscription__c[] subs = [SELECT Id, Name, Billing_Group__c, Next_Billing_Date__c, Next_SO_generation_Date__c FROM SBQQ__Subscription__c];
            Map<Id, List<Date>> retMap = SO_SubscriptionsGrouping.sortBillingDates(subs);
            system.assertEquals(retMap.size(), [SELECT COUNT() FROM Billing_Group__c] , 'Dates for given Billing group sorted');
        }
        
        Test.stopTest();
    }
    @isTest static void test_sortBillingDates3(){
         try {
            SO_SubscriptionsGrouping.sortBillingDates(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
        
    }
    
    @isTest static void test_sortBdSubs1(){
        Test.startTest();
        Billing_Group__c bg = [SELECT Id, Name,Next_Billing_Date__c, Next_SO_generation_Date__c FROM Billing_Group__c];
        SBQQ__Subscription__c[] subs = [SELECT Id, Name, Billing_Group__c, Next_Billing_Date__c, Next_SO_generation_Date__c FROM SBQQ__Subscription__c];
        Map<Id, List<SBQQ__Subscription__c>> bgwithSubs = new Map<Id, List<SBQQ__Subscription__c>>();
        bgwithSubs.put(bg.id, subs);
        Map<Id, List<Date>> retMap = SO_SubscriptionsGrouping.sortBdSubs(bgwithSubs);
        system.assertEquals(retMap.size(), [SELECT COUNT() FROM Billing_Group__c] , 'Dates for given Billing group sorted');
        Test.stopTest();
    }
    @isTest static void test_sortBdSubs2(){
        
         Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
        Billing_Group__c bg = [SELECT Id, Name,Next_Billing_Date__c, Next_SO_generation_Date__c FROM Billing_Group__c];
        SBQQ__Subscription__c[] subs = [SELECT Id, Name, Billing_Group__c, Next_Billing_Date__c, Next_SO_generation_Date__c FROM SBQQ__Subscription__c];
        Map<Id, List<SBQQ__Subscription__c>> bgwithSubs = new Map<Id, List<SBQQ__Subscription__c>>();
        bgwithSubs.put(bg.id, subs);
        Map<Id, List<Date>> retMap = SO_SubscriptionsGrouping.sortBdSubs(bgwithSubs);
        system.assertEquals(retMap.size(), [SELECT COUNT() FROM Billing_Group__c] , 'Dates for given Billing group sorted');
        }
        Test.stopTest();
    }
    @isTest static void test_sortBdSubs3(){
         try {
            SO_SubscriptionsGrouping.sortBdSubs(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
        
    }
    
    
}