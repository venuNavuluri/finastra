@isTest
public class Initial_RLF_Buttons_test {
    
    @testSetup static void setup(){
        Test.startTest();
        Account acc = TestDataFactory.createAccount('Test Account'); 
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        Contract con = TestDataFactory.createContract(acc, opp);
        Billing_Group__c bGroup =  SO_BillingGroupHelper.BillingGroupCreation(con);
        NS_Revenue_Recognition_Template__c tempRec = new NS_Revenue_Recognition_Template__c(Name = 'POC');
        insert tempRec;
        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '1');
        insert misysEntity;
        NS_Product__c product = new NS_Product__c(name = 'test_prod');
        insert product;
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 1', Default_Billing__c = true, Account__c = acc.Id);
        insert btst;
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = acc.Id, Misys_Entity__c = misysEntity.Id, Ns_internal_Id__c = '123');
        insert accBySub;
        NS_Project__c project = new NS_Project__c(Project_Product__c = product.id, Project_Name__c = 'Test Proj', Customer__c = accBySub.Id, OpenAir_Project_Stage__c = 'Pipeline', SFDC_Opportunity_Category__c = 'Omitted', OA_Project_Template__c = 'TEMPLATE - Pre-Sales Project', Project_Category__c = 'Training');
        insert project;
        NS_Customer_Address__c  cusAdd = new NS_Customer_Address__c(Acct_By_Sub__c = accBySub.Id, Bill_To_Ship_To__c = btst.Id, Synced_To_NS__c = true);
        insert cusAdd;
        Sales_Order__c so = New Sales_order__c(Order_type__c = 'ILF', NS_Billing_Address__c= cusAdd.Id, NS_Shipping_Address__c = cusAdd.Id, NS_Project__c = project.id );
        insert so;
        Test.stopTest(); 
    }
    
    
    @isTest static void test_Sync2NS_noBill(){
        Test.startTest();
        Sales_Order__c so = [SELECT Id,NS_Billing_Address__c, NS_Shipping_Address__c FROM Sales_Order__c LIMIT 1];
        so.NS_Billing_Address__c = null; 
        update so;
        Initial_RLF_Buttons.Sync2NS(so.Id); 
        system.assertEquals(false, [SELECT Id,Ready_For_Export_To_NS__c FROM Sales_Order__c].Ready_For_Export_To_NS__c); 
        Test.stopTest();        
    }
    @isTest static void test_Sync2NS_noShip(){
        Test.startTest();
        Sales_Order__c so = [SELECT Id,NS_Billing_Address__c, NS_Shipping_Address__c FROM Sales_Order__c LIMIT 1];
        so.NS_Shipping_Address__c = null; 
        update so;
        Initial_RLF_Buttons.Sync2NS(so.Id); 
        system.assertEquals(false, [SELECT Id,Ready_For_Export_To_NS__c FROM Sales_Order__c].Ready_For_Export_To_NS__c); 
        Test.stopTest();        
    }
    
    @isTest static void test_Sync2NS_syncbill(){
        Test.startTest();
        NS_Customer_Address__c  cusAdd = new NS_Customer_Address__c(Synced_To_NS__c = false);
        insert cusAdd;
        Sales_Order__c so = [SELECT Id, Name, NS_Billing_Address__c FROM Sales_Order__c LIMIT 1];
        so.NS_Billing_Address__c = cusAdd.id;
        update so;
        Initial_RLF_Buttons.Sync2NS(so.Id);
        system.assertEquals(false, [SELECT Id,Ready_For_Export_To_NS__c FROM Sales_Order__c].Ready_For_Export_To_NS__c); 
        Test.stopTest();
    }  
    
    @isTest static void test_Sync2NS_syncship(){
        Test.startTest();
        NS_Customer_Address__c  cusAdd = new NS_Customer_Address__c(Synced_To_NS__c = false);
        insert cusAdd;
        Sales_Order__c so = [SELECT Id, Name, NS_Shipping_Address__c FROM Sales_Order__c LIMIT 1];
        so.NS_Shipping_Address__c = cusAdd.id;
        update so;
        Initial_RLF_Buttons.Sync2NS(so.Id);
        system.assertEquals(false, [SELECT Id,Ready_For_Export_To_NS__c FROM Sales_Order__c].Ready_For_Export_To_NS__c); 
        Test.stopTest();
    }  
    
    @isTest static void test_Sync2NS1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            Test.startTest();
            
            Sales_Order__c so = [SELECT Id, Name, NS_Billing_Address__c, NS_Shipping_Address__c FROM Sales_Order__c LIMIT 1];
            Initial_RLF_Buttons.Sync2NS(so.Id);   
            system.assertEquals(true, [SELECT Id,Ready_For_Export_To_NS__c FROM Sales_Order__c].Ready_For_Export_To_NS__c);     
            system.assertEquals(true, [SELECT Id,NS_Project__r.Ready_For_Export_To_NS__c FROM Sales_Order__c].NS_Project__r.Ready_For_Export_To_NS__c);  
            Test.stopTest();    
        }   
    }
    @isTest static void test_Sync2NS2(){
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M Finance User - NS'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            Test.startTest();
            Sales_Order__c so = [SELECT Id, Name, NS_Billing_Address__c, NS_Shipping_Address__c FROM Sales_Order__c LIMIT 1];
            Initial_RLF_Buttons.Sync2NS(so.Id);   
            system.assertEquals(true, [SELECT Id,Ready_For_Export_To_NS__c FROM Sales_Order__c].Ready_For_Export_To_NS__c);  
            Test.stopTest(); 
        }
    }
    
    @isTest static void test_createRLF1(){
        
            
            TestDataFactory.init_NS_maps();       
            Account acc = TestDataFactory.createAccount('Test Account');        
            Opportunity opp = TestDataFactory.createOpportunity(acc);                        
            Contract con = TestDataFactory.createContract(acc, opp);  
            Billing_Group__c bGroup1 = TestDataFactory.createBillingGroup(con);
            TestDataFactory.createRLF_Subscription(con, bGroup1.Id); 
            bGroup1.Next_SO_generation_Date__c = System.today();bGroup1.BG_Billing_Group_Active__c = true; bGroup1.Hold_Billing__c  = false; update bGroup1; 
            List<SBQQ__Subscription__c> batchSubs = new List<SBQQ__Subscription__c>();
            
            for(SBQQ__Subscription__c sub: [SELECT Id, Next_SO_generation_Date__c, SBQQ__NetPrice__c, Billing_Status__c, Expired_Subscription__c FROM SBQQ__Subscription__c WHERE Billing_Group__c =: bGroup1.Id and Recurring_Sales_Order_Type__c LIKE 'RLF%']){
                sub.Next_SO_generation_Date__c = system.today();
                sub.SBQQ__NetPrice__c = 100;
                sub.Billing_Group__c = bGroup1.Id;
                sub.Billing_Status__c = 'Active billing';
                batchSubs.add(sub);
            }
            if(batchSubs.size() > 0){
                update batchSubs;
            }
        test.startTest();
            Initial_RLF_Buttons.createRLF(bGroup1.Id);
            system.assertEquals(1, [SELECT COUNT() FROM Sales_Order__c limit 1 ], 'RLF Sales Order Created for given Billing Group');
            Test.stopTest();
        
    }
    @isTest static void test_createRLF2(){
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            Test.startTest();
            TestDataFactory.init_NS_maps();       
            Account acc = TestDataFactory.createAccount('Test Account');        
            Opportunity opp = TestDataFactory.createOpportunity(acc);                        
            Contract con = TestDataFactory.createContract(acc, opp);  
            Billing_Group__c bGroup1 = TestDataFactory.createBillingGroup(con);
            TestDataFactory.createRLF_Subscription(con, bGroup1.Id); 
            bGroup1.Next_SO_generation_Date__c = System.today();bGroup1.BG_Billing_Group_Active__c = true; bGroup1.Hold_Billing__c  = false; update bGroup1; 
            List<SBQQ__Subscription__c> batchSubs = new List<SBQQ__Subscription__c>();
            
            for(SBQQ__Subscription__c sub: [SELECT Id, Next_SO_generation_Date__c, SBQQ__NetPrice__c, Billing_Status__c, Expired_Subscription__c FROM SBQQ__Subscription__c WHERE Billing_Group__c =: bGroup1.Id and Recurring_Sales_Order_Type__c LIKE 'RLF%']){
                sub.Next_SO_generation_Date__c = system.today();
                sub.SBQQ__NetPrice__c = 100;
                sub.Billing_Group__c = bGroup1.Id;
                sub.Billing_Status__c = 'Active billing';
                batchSubs.add(sub);
            }
            if(batchSubs.size() > 0){
                update batchSubs;
            }
            Initial_RLF_Buttons.createRLF(bGroup1.Id);
            system.assertEquals(1, [SELECT COUNT() FROM Sales_Order__c limit 1 ], 'RLF Sales Order Created for given Billing Group');
            Test.stopTest();
        }
    }
    @isTest static void test_createRLF_Account_by_Sub_Failure(){
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            Test.startTest();
            TestDataFactory.init_NS_maps();       
            Account acc = TestDataFactory.createAccount('Test Account');        
            Opportunity opp = TestDataFactory.createOpportunity(acc);                        
            Contract con = TestDataFactory.createContract(acc, opp);  
            Billing_Group__c bGroup1 = TestDataFactory.createBillingGroup(con,false);
            bGroup1.Next_SO_generation_Date__c = System.today();
            bGroup1.BG_Billing_Group_Active__c = true; 
            bGroup1.Hold_Billing__c  = false; 
            bGroup1.Account_by_Sub__c=null;
            insert bGroup1; 
            TestDataFactory.createRLF_Subscription(con, bGroup1.Id); 
            List<SBQQ__Subscription__c> batchSubs = new List<SBQQ__Subscription__c>();
            
            for(SBQQ__Subscription__c sub: [SELECT Id, Next_SO_generation_Date__c, SBQQ__NetPrice__c, Billing_Status__c, Expired_Subscription__c FROM SBQQ__Subscription__c WHERE Billing_Group__c =: bGroup1.Id and Recurring_Sales_Order_Type__c LIKE 'RLF%']){
                sub.Next_SO_generation_Date__c = system.today();
                sub.SBQQ__NetPrice__c = 100;
                sub.Billing_Group__c = bGroup1.Id;
                sub.Billing_Status__c = 'Active billing';
                batchSubs.add(sub);
            }
            if(batchSubs.size() > 0){
                update batchSubs;
            }
            String result = Initial_RLF_Buttons.createRLF(bGroup1.Id);
            System.assert(result.contains('Account By Sub is not in Netsuite, please check Acc By Sub details.'), 'RLF Sales Order Created for given Billing Group');
            System.assertEquals(1, [SELECT COUNT() FROM Sales_Order__c limit 1 ], 'RLF Sales Order Created for given Billing Group');
            Test.stopTest();
        }
    }
    @isTest static void test_createRLF_NS_Customer_Address_Failure(){
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            Test.startTest();
            TestDataFactory.init_NS_maps();       
            Account acc = TestDataFactory.createAccount('Test Account');        
            Opportunity opp = TestDataFactory.createOpportunity(acc);                        
            Contract con = TestDataFactory.createContract(acc, opp);  
            Billing_Group__c bGroup1 = TestDataFactory.createBillingGroup(con,false);
            bGroup1.Next_SO_generation_Date__c = System.today();
            bGroup1.BG_Billing_Group_Active__c = true; 
            bGroup1.Hold_Billing__c  = false; 
            bGroup1.NS_Customer_Address__c=null;
            insert bGroup1; 
            TestDataFactory.createRLF_Subscription(con, bGroup1.Id); 
            List<SBQQ__Subscription__c> batchSubs = new List<SBQQ__Subscription__c>();
            
            for(SBQQ__Subscription__c sub: [SELECT Id, Next_SO_generation_Date__c, SBQQ__NetPrice__c, Billing_Status__c, Expired_Subscription__c FROM SBQQ__Subscription__c WHERE Billing_Group__c =: bGroup1.Id and Recurring_Sales_Order_Type__c LIKE 'RLF%']){
                sub.Next_SO_generation_Date__c = system.today();
                sub.SBQQ__NetPrice__c = 100;
                sub.Billing_Group__c = bGroup1.Id;
                sub.Billing_Status__c = 'Active billing';
                batchSubs.add(sub);
            }
            if(batchSubs.size() > 0){
                update batchSubs;
            }
            String result = Initial_RLF_Buttons.createRLF(bGroup1.Id);
            System.assert(result.contains('NS Customer Address is empty or  not in Netsuite, please check NS Customer Address details.'), 'RLF Sales Order Created for given Billing Group');
            System.assertEquals(1, [SELECT COUNT() FROM Sales_Order__c limit 1 ], 'RLF Sales Order Created for given Billing Group');
            Test.stopTest();
        }
    }
    @isTest static void test_createRLF_NS_Customer_Ship_To_Address_Failure(){
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            Test.startTest();
            TestDataFactory.init_NS_maps();       
            Account acc = TestDataFactory.createAccount('Test Account');        
            Opportunity opp = TestDataFactory.createOpportunity(acc);                        
            Contract con = TestDataFactory.createContract(acc, opp);  
            Billing_Group__c bGroup1 = TestDataFactory.createBillingGroup(con,false);
            bGroup1.Next_SO_generation_Date__c = System.today();
            bGroup1.BG_Billing_Group_Active__c = true; 
            bGroup1.Hold_Billing__c  = false; 
            bGroup1.NS_Customer_Ship_To_Address__c=null;
            insert bGroup1; 
            TestDataFactory.createRLF_Subscription(con, bGroup1.Id); 
            List<SBQQ__Subscription__c> batchSubs = new List<SBQQ__Subscription__c>();
            
            for(SBQQ__Subscription__c sub: [SELECT Id, Next_SO_generation_Date__c, SBQQ__NetPrice__c, Billing_Status__c, Expired_Subscription__c FROM SBQQ__Subscription__c WHERE Billing_Group__c =: bGroup1.Id and Recurring_Sales_Order_Type__c LIKE 'RLF%']){
                sub.Next_SO_generation_Date__c = system.today();
                sub.SBQQ__NetPrice__c = 100;
                sub.Billing_Group__c = bGroup1.Id;
                sub.Billing_Status__c = 'Active billing';
                batchSubs.add(sub);
            }
            if(batchSubs.size() > 0){
                update batchSubs;
            }
            String result = Initial_RLF_Buttons.createRLF(bGroup1.Id);
            System.assert(result.contains('NS Customer Address is empty or  not in Netsuite, please check NS Customer Address details.'), 'RLF Sales Order Created for given Billing Group');
            System.assertEquals(1, [SELECT COUNT() FROM Sales_Order__c limit 1 ], 'RLF Sales Order Created for given Billing Group');
            Test.stopTest();
        }
    }
    @isTest static void test_invokeUplitUtils1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
            Test.startTest();
            Uplift__c uplift1 = new Uplift__c(Status__c = 'Pro-Rata',Uplift_Advance__c = 61,Billing_Frequency__c = 'Monthly',
                                              Hold_Billing__c = false, Active__c = true,Override__c = 4.00, 
                                              Uplift_Application_Date__c  = Date.today(),Start_Date__c  = Date.today(), Uplift_Effective_Date__c  = Date.today());
            insert uplift1;
            SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Billing_Status__c = 'Active billing',CPI_Uplift__c = uplift1.id,
                                                                           Transactions__c = 2, Sold_Value__c = 50, SBQQ__NetPrice__c = 100, SBQQ__BillingType__c = 'Advance');
            insert subscription; 
            Initial_RLF_Buttons.invokeUplitUtils(uplift1.id);
            system.assertEquals(system.today().toStartOfMonth().addmonths(1), [SELECT id,Uplift_Effective_Date__c FROM Uplift__c].Uplift_Effective_Date__c);
            Test.stopTest();
        }
    }
    @isTest static void test_invokeUplitUtils2(){
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');
        
        System.runAs(u3) {
            Test.startTest();
            Uplift__c uplift1 = new Uplift__c( Status__c = 'Pro-Rata',Uplift_Advance__c = 61,Billing_Frequency__c = 'Monthly',
                                              Hold_Billing__c = false, Active__c = true, Override__c = 4.00,Uplift_Factor__c = 1.0400,Exclude__c=false,
                                              Uplift_Application_Date__c  = Date.today(),Start_Date__c  = Date.today(), Uplift_Effective_Date__c  = Date.today());
            insert uplift1;
            SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Billing_Status__c = 'Active billing',CPI_Uplift__c = uplift1.id,
                                                                           Transactions__c = 2, Sold_Value__c = 50, SBQQ__NetPrice__c = 100, SBQQ__BillingType__c = 'Advance');
            insert subscription; 
            Initial_RLF_Buttons.invokeUplitUtils(uplift1.id);
            system.assertEquals(104.00,[SELECT id,SBQQ__NetPrice__c FROM SBQQ__Subscription__c].SBQQ__NetPrice__c );
            Test.stopTest();
        }
    }
    
    
}