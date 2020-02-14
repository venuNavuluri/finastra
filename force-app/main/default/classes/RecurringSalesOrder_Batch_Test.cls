@isTest
public class RecurringSalesOrder_Batch_Test {
    
    @testSetup static void setup() {        
        TestDataFactory.init_NS_maps(); 
        
        NS_Finance_Region__c region = new NS_Finance_Region__c(Name = 'US'); insert region;
        Account acc = TestDataFactory.createAccount('Test Account'); acc.NS_Finance_Region__c = region.id; update acc;    
        Opportunity opp = TestDataFactory.createOpportunity(acc);                        
        Contract con = TestDataFactory.createContract(acc, opp);  
        Billing_Group__c bGroup1 = TestDataFactory.createBillingGroup1(con); 
        Billing_Group__c bGroup2 = TestDataFactory.createBillingGroup1(con);
        Billing_Group__c bGroup3 = TestDataFactory.createBillingGroup1(con);
        Billing_Group__c bGroup4 = TestDataFactory.createBillingGroup1(con);
        Billing_Group__c bGroup5 = TestDataFactory.createBillingGroup1(con);
        TestDataFactory.createRLF_Subscription(con, bGroup1.Id); 
        TestDataFactory.createRLF_Subscription(con, bGroup2.Id);
        TestDataFactory.createRLF_Subscription(con, bGroup3.Id);  
        TestDataFactory.createRLF_Subscription(con, bGroup4.Id); 
        TestDataFactory.createRLF_Subscription(con, bGroup5.Id); 
        
        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '1'); insert misysEntity;
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 1', Default_Billing__c = true, Account__c = acc.Id); insert btst;
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = acc.Id, Misys_Entity__c = misysEntity.Id, Ns_internal_Id__c = '123'); insert accBySub;
        
        NS_Customer_Address__c  cusAdd = [select id,Bill_To_Ship_To__c,Acct_By_Sub__c from NS_Customer_Address__c where Bill_To_Ship_To__c =: btst.id and  Acct_By_Sub__c =: accBySub.id];
        cusAdd.Synced_To_NS__c = true; update cusAdd;
        
        
        bGroup1.Next_SO_generation_Date__c = System.today(); bGroup1.BG_Client_Bill_To__c = btst.id;  bGroup1.BG_Client_Ship_To__c = btst.id; bGroup1.Account_by_Sub__c = accBySub.id; bGroup1.NS_Customer_Ship_To_Address__c = cusAdd.id; bGroup1.NS_Customer_Address__c = cusAdd.id;  update bGroup1;
        bGroup2.Next_SO_generation_Date__c = System.today(); bGroup2.BG_Client_Bill_To__c = btst.id; bGroup2.NS_Customer_Address__c = cusAdd.id; bGroup2.NS_Customer_Ship_To_Address__c = cusAdd.id; bGroup2.BG_Client_Ship_To__c = btst.id; bGroup2.Account_by_Sub__c = accBySub.id; update bGroup2; 
        bGroup3.Next_SO_generation_Date__c = System.today(); bGroup3.BG_Client_Bill_To__c = btst.id; bGroup3.NS_Customer_Address__c = cusAdd.id; bGroup3.NS_Customer_Ship_To_Address__c = cusAdd.id; bGroup3.BG_Client_Ship_To__c = btst.id; bGroup3.Account_by_Sub__c = accBySub.id; update bGroup3; 
        bGroup4.Next_SO_generation_Date__c = System.today(); bGroup4.BG_Client_Bill_To__c = btst.id; bGroup4.NS_Customer_Address__c = cusAdd.id; bGroup4.NS_Customer_Ship_To_Address__c = cusAdd.id; bGroup4.BG_Client_Ship_To__c = btst.id; bGroup4.Account_by_Sub__c = accBySub.id; update bGroup4; 
        bGroup5.Next_SO_generation_Date__c = System.today(); update bGroup5; 
        accBySub.Synced_To_NS__c = true; update accBySub;
        
        List<SBQQ__Subscription__c> batchSubs = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub: [SELECT Id, Next_SO_generation_Date__c, SBQQ__NetPrice__c, Billing_Status__c, Expired_Subscription__c FROM SBQQ__Subscription__c WHERE Billing_Group__c =: bGroup1.Id and Recurring_Sales_Order_Type__c LIKE 'RLF%']){
            sub.Next_SO_generation_Date__c = system.today();
            sub.Next_Billing_Date__c = system.today();
            sub.SBQQ__NetPrice__c = 100;
            sub.Billing_Group__c = bGroup1.Id;
            sub.Billing_Status__c = 'Active billing';
            batchSubs.add(sub);
        }
        if(batchSubs.size() > 0){
            update batchSubs;
        }
        
        List<SBQQ__Subscription__c> batchSubs1 = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub1: [SELECT Id, Next_SO_generation_Date__c, SBQQ__NetPrice__c, Billing_Status__c, Expired_Subscription__c FROM SBQQ__Subscription__c WHERE Billing_Group__c =: bGroup2.Id and Recurring_Sales_Order_Type__c LIKE 'RLF%']){
            sub1.Next_SO_generation_Date__c = system.today();
            sub1.SBQQ__NetPrice__c = 100;
            sub1.Billing_Group__c = bGroup2.Id;
            sub1.Billing_Status__c = 'Active billing';
            batchSubs1.add(sub1);
        }
        if(batchSubs.size() > 0){
            update batchSubs1;
        }
        
        List<SBQQ__Subscription__c> batchSubs2 = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub2: [SELECT Id, Next_SO_generation_Date__c, SBQQ__NetPrice__c, Billing_Status__c, Expired_Subscription__c FROM SBQQ__Subscription__c WHERE Billing_Group__c =: bGroup3.Id and Recurring_Sales_Order_Type__c LIKE 'RLF%']){
            sub2.Next_SO_generation_Date__c = system.today();
            sub2.SBQQ__NetPrice__c = 100;
            sub2.Billing_Group__c = bGroup3.Id;
            sub2.Billing_Status__c = 'Active billing';
            sub2.Next_Billing_Date__c = system.today();
            batchSubs2.add(sub2);
        }
        if(batchSubs2.size() > 0){
            update batchSubs2;
        }
        List<SBQQ__Subscription__c> batchSubs3 = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub3: [SELECT Id, Next_SO_generation_Date__c, SBQQ__NetPrice__c, Billing_Status__c, Expired_Subscription__c FROM SBQQ__Subscription__c WHERE Billing_Group__c =: bGroup4.Id and Recurring_Sales_Order_Type__c LIKE 'RLF%']){
            sub3.Next_SO_generation_Date__c = system.today();
            sub3.SBQQ__NetPrice__c = 100;
            sub3.Billing_Group__c = bGroup4.Id;
            sub3.Billing_Status__c = 'Active billing';
            sub3.Next_Billing_Date__c = system.today();
            batchSubs3.add(sub3);
        }
        if(batchSubs3.size() > 0){
            update batchSubs3;
        }
        List<SBQQ__Subscription__c> batchSubs4 = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub4: [SELECT Id, Next_SO_generation_Date__c, SBQQ__NetPrice__c, Billing_Status__c, Expired_Subscription__c FROM SBQQ__Subscription__c WHERE Billing_Group__c =: bGroup5.Id and Recurring_Sales_Order_Type__c LIKE 'RLF%']){
            sub4.Next_SO_generation_Date__c = system.today();
            sub4.SBQQ__NetPrice__c = 100;
            sub4.Billing_Group__c = bGroup5.Id;
            sub4.Billing_Status__c = 'Active billing';
            sub4.Next_Billing_Date__c = system.today();
            batchSubs4.add(sub4);
        }
        
        if(batchSubs4.size() > 0){
            update batchSubs4;
        }
        
    }
    
    @isTest static void recurringBatch(){
        Test.startTest(); 
        RecurringSalesOrder_Batch RSB = new RecurringSalesOrder_Batch();
        Id batchId = Database.executeBatch(RSB);
        Test.stopTest();
        
        system.assertEquals(4,[SELECT COUNT() FROM Sales_Order__c],'4 RLF Sales Order Created');
        system.assertEquals(28,[SELECT COUNT() FROM Sales_Order_Item__c],'4*7 RLF Sales Order Items Created');
        system.assertEquals(0, [SELECT Prorata_Days__c FROM SBQQ__Subscription__c LIMIT 1].Prorata_Days__c, 'Zeroing prorata days for all subs');
        
    }
    
    
    @isTest
    public static void RecurringScheduleBatch(){        
        Test.startTest();
        String jobId = RecurringSalesOrder_Scheduler.scheduleBatchJob();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(RecurringSalesOrder_Scheduler.CRON_EXP, ct.CronExpression);        
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
    }
}