@isTest
private class SO_SalesOrderMapUtils_Test {
    @testSetup static void dataSetup() {
        insert TestUtility.createNSCurrency();
        insert TestUtility.createNSProduct();
        insert TestUtility.createNSFixedBillingDate();
        insert TestUtility.createNSCostCentre();
        insert TestUtility.createNSRevenueRecognitionTemplate();
        insert TestUtility.createNSOpenAirRevenueRules();
        insert TestUtility.createNSListTable();
        insert TestUtility.createNSAccount();
        insert TestUtility.sampleProduct();
        insert TestUtility.createTE();
    }
    private static testmethod void testGetNSCurrency_map(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            NS_Currency__c ns = [select id, Name from NS_Currency__c];
            Test.startTest();
            System.assertEquals(ns.Id,SO_SalesOrderMapUtils.getNSCurrency_map().get(ns.Name).id);
            Test.stopTest();
        }
        
    }
    private static testmethod void testGetNSCurrency_map2(){
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            NS_Currency__c ns = [select id, Name from NS_Currency__c];
            Test.startTest();
            System.assertEquals(ns.Id,SO_SalesOrderMapUtils.getNSCurrency_map().get(ns.Name).id);
            Test.stopTest();
        }
    }
    private static testmethod void testGetNSCurrency_map3(){
        
         try {
            SO_SalesOrderMapUtils.getNSCurrency_map().get(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
    }
    private static testmethod void testgetUPID(){
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            Product2 prod = [select id, Name, UPID__c from Product2];
            Test.startTest();
            System.assertEquals(prod.id,SO_SalesOrderMapUtils.getUPID().get(prod.UPID__c).id);
            Test.stopTest();
        }
    }
    private static testmethod void testgetUPID2(){
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            Product2 prod = [select id, Name, UPID__c from Product2];
            Test.startTest();
            System.assertEquals(prod.id,SO_SalesOrderMapUtils.getUPID().get(prod.UPID__c).id);
            Test.stopTest();
        }
    }
    private static testmethod void testgetUPID3(){
        
         try {
            SO_SalesOrderMapUtils.getUPID().get(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
    }
    
    private static testmethod void testGetNSProduct_map1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            NS_Product__c ns= [SELECT Id, NS_Product_Internal_Id__c from NS_Product__c];
            Test.startTest();
            System.assertEquals(ns.Id,SO_SalesOrderMapUtils.getNSProduct_map().get(ns.NS_Product_Internal_Id__c));
            Test.stopTest();
        }
    }
    private static testmethod void testGetNSProduct_map2(){
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            NS_Product__c ns= [SELECT Id, NS_Product_Internal_Id__c from NS_Product__c];
            Test.startTest();
            System.assertEquals(ns.Id,SO_SalesOrderMapUtils.getNSProduct_map().get(ns.NS_Product_Internal_Id__c));
            Test.stopTest();
        }
    }
    private static testmethod void testGetNSProduct_map3(){
        try {
            SO_SalesOrderMapUtils.getNSProduct_map().get(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
    }
    private static testmethod void testGetFixedBillingDate_map1(){ 
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            NS_Fixed_Billing_Date__c fbd= [select id, name, NS_Internal_Id__c, Date__c from NS_Fixed_Billing_Date__c];
            Test.startTest();
            System.assertEquals(fbd.Id,SO_SalesOrderMapUtils.getFixedBillingDate_map().get(fbd.Date__c).id);
            Test.stopTest();
        }
    }
    private static testmethod void testGetFixedBillingDate_map2(){ 
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            NS_Fixed_Billing_Date__c fbd= [select id, name, NS_Internal_Id__c, Date__c from NS_Fixed_Billing_Date__c];
            Test.startTest();
            System.assertEquals(fbd.Id,SO_SalesOrderMapUtils.getFixedBillingDate_map().get(fbd.Date__c).id);
            Test.stopTest();
        }
    }
    private static testmethod void testGetFixedBillingDate_map3(){ 
        try {
            SO_SalesOrderMapUtils.getFixedBillingDate_map().get(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
    }
    private static testmethod void testGetNSCostCenter_map1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            NS_Cost_Centre__c cc = [select id, NS_Cost_Centre_Internal_Id__c from NS_Cost_Centre__c];
            Test.startTest();
            System.assertEquals(cc.Id,SO_SalesOrderMapUtils.getNSCostCenter_map().get(cc.NS_Cost_Centre_Internal_Id__c).id);
            Test.stopTest();
        }
    }
    private static testmethod void testGetNSCostCenter_map2(){
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            NS_Cost_Centre__c cc = [select id, NS_Cost_Centre_Internal_Id__c from NS_Cost_Centre__c];
            Test.startTest();
            System.assertEquals(cc.Id,SO_SalesOrderMapUtils.getNSCostCenter_map().get(cc.NS_Cost_Centre_Internal_Id__c).id);
            Test.stopTest();
        }
    }
    private static testmethod void testGetNSCostCenter_map3(){
        try {
            SO_SalesOrderMapUtils.getNSCostCenter_map().get(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
    }
    private static testmethod void testGetRevScheduleMap1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {        
            NS_Revenue_Recognition_Template__c revRecS = [select id, name, NS_Internal_Id__c from NS_Revenue_Recognition_Template__c];
            Test.startTest();
            System.assertEquals(revRecS.Id,SO_SalesOrderMapUtils.getRevScheduleMap().get(revRecS.NS_Internal_Id__c).id);
            Test.stopTest();
        }
    }  
    private static testmethod void testGetRevScheduleMap2(){
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {        
            NS_Revenue_Recognition_Template__c revRecS = [select id, name, NS_Internal_Id__c from NS_Revenue_Recognition_Template__c];
            Test.startTest();
            System.assertEquals(revRecS.Id,SO_SalesOrderMapUtils.getRevScheduleMap().get(revRecS.NS_Internal_Id__c).id);
            Test.stopTest();
        }
    }
    private static testmethod void testGetRevScheduleMap3(){
        try {
            SO_SalesOrderMapUtils.getRevScheduleMap().get(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
    }
    private static testmethod void testGetIntIdOARevRuleMap1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) { 
            NS_OpenAir_Revenue_Rules__c oaRevenueRule = [select id, name, NS_Internal_Id__c from NS_OpenAir_Revenue_Rules__c];
            Test.startTest();
            System.assertEquals(oaRevenueRule.Id,SO_SalesOrderMapUtils.getIntIdOARevRuleMap().get(oaRevenueRule.NS_Internal_Id__c).id);
            Test.stopTest();
        }
    }
    private static testmethod void testGetIntIdOARevRuleMap2(){
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            NS_OpenAir_Revenue_Rules__c oaRevenueRule = [select id, name, NS_Internal_Id__c from NS_OpenAir_Revenue_Rules__c];
            Test.startTest();
            System.assertEquals(oaRevenueRule.Id,SO_SalesOrderMapUtils.getIntIdOARevRuleMap().get(oaRevenueRule.NS_Internal_Id__c).id);
            Test.stopTest();
        }
    }
    private static testmethod void testGetIntIdOARevRuleMap3(){
        try {
            SO_SalesOrderMapUtils.getIntIdOARevRuleMap().get(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
    }
    private static testmethod void testGetIntIdOABillingRuleMap1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            NS_List_Table__c oaBillingRule = [select id, name, NS_Internal_Id__c from NS_List_Table__c];
            Test.startTest();
            System.assertEquals(oaBillingRule.Id,SO_SalesOrderMapUtils.getIntIdOABillingRuleMap().get(oaBillingRule.NS_Internal_Id__c).id);
            Test.stopTest();
        }
    }
    private static testmethod void testGetIntIdOABillingRuleMap2(){
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            NS_List_Table__c oaBillingRule = [select id, name, NS_Internal_Id__c from NS_List_Table__c];
            Test.startTest();
            System.assertEquals(oaBillingRule.Id,SO_SalesOrderMapUtils.getIntIdOABillingRuleMap().get(oaBillingRule.NS_Internal_Id__c).id);
            Test.stopTest();
        }
    }
    private static testmethod void testGetIntIdOABillingRuleMap3(){
        try {
            SO_SalesOrderMapUtils.getIntIdOABillingRuleMap().get(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
    }
    private static testmethod void testGetNsAccMap1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            NS_Account__c nsAccount = [SELECT id,NS_Account_Internal_Id__c FROM NS_Account__c];
            Test.startTest();
            System.assertEquals(nsAccount.Id,SO_SalesOrderMapUtils.getNsAccMap().get(nsAccount.NS_Account_Internal_Id__c).id);
            Test.stopTest();
        }
    }
    private static testmethod void testGetNsAccMap2(){
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            NS_Account__c nsAccount = [SELECT id,NS_Account_Internal_Id__c FROM NS_Account__c];
            Test.startTest();
            System.assertEquals(nsAccount.Id,SO_SalesOrderMapUtils.getNsAccMap().get(nsAccount.NS_Account_Internal_Id__c).id);
            Test.stopTest();
        }
    }
    private static testmethod void testGetNsAccMap3(){
        try {
            SO_SalesOrderMapUtils.getNsAccMap().get(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
    }
    
    private static testmethod void testGetMonth(){
        System.assertEquals(1,SO_SalesOrderMapUtils.getMonth('January'));
        System.assertEquals(2,SO_SalesOrderMapUtils.getMonth('February'));
        System.assertEquals(3,SO_SalesOrderMapUtils.getMonth('March'));
        System.assertEquals(4,SO_SalesOrderMapUtils.getMonth('April'));
        System.assertEquals(5,SO_SalesOrderMapUtils.getMonth('May'));
        System.assertEquals(6,SO_SalesOrderMapUtils.getMonth('June'));
        System.assertEquals(7,SO_SalesOrderMapUtils.getMonth('July'));
        System.assertEquals(8,SO_SalesOrderMapUtils.getMonth('August'));
        System.assertEquals(9,SO_SalesOrderMapUtils.getMonth('September'));
        System.assertEquals(10,SO_SalesOrderMapUtils.getMonth('October'));
        System.assertEquals(11,SO_SalesOrderMapUtils.getMonth('November'));
        System.assertEquals(12,SO_SalesOrderMapUtils.getMonth('December'));
    }
    
}