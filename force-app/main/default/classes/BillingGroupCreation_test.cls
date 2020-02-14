@isTest
public class BillingGroupCreation_test {
    
    @testSetup static void setUp(){
        Account acc = TestDataFactory.createAccount('Test Account'); 
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        Contract con = TestDataFactory.createContract(acc, opp);
    }
    
    @isTest static void createBG1(){
        Account acc = TestDataFactory.createAccount('Test Account');
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        CPQValidations__c cpqVal = new CPQValidations__c();
        cpqVal.Bypass__c = true; 
        insert cpqVal;
        opp.StageName = 'Closed Won'; update opp;
        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '1', BE_Active__c = true); insert misysEntity;
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att',Default_Billing__c = true, Account__c = acc.Id); insert btst;
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = acc.Id, Misys_Entity__c = misysEntity.Id, Ns_internal_Id__c = '123'); insert accBySub;
        accBySub.Synced_To_NS__c = true; update accBySub;
        NS_Customer_Address__c  cusAdd = [select id,Bill_To_Ship_To__c,Acct_By_Sub__c from NS_Customer_Address__c where Bill_To_Ship_To__c =: btst.id and  Acct_By_Sub__c =: accBySub.id];
        cusAdd.Synced_To_NS__c = true; update cusAdd;
        NS_Currency__c NSCur = new NS_Currency__c(name = 'USD'); insert NSCur;
        NS_Trading_Currency__c tradeCur = new NS_Trading_Currency__c ( NS_Currency__c = NSCur.id, Acct_By_Sub__c = accBySub.id, Synced_To_NS__c = true); insert tradeCur;
        contract con = TestDataFactory.createContract(acc, opp);
        //con.BG_Created__c = true;
        con.Misys_Entity__c = misysEntity.Id;
        con.Bill_To__c = btst.id;
        con.Ship_To__c = btst.id;
        con.Billing_Group_Entity__c = accBySub.id;
        con.Fixed_Billing_Day__c = 1;
        con.Contract_Status__c  = 'CAT Logging Complete';
        con.Recurring_Fees_Start_Planned__c = system.today();
        //con.NS_Customer_Address__c = cusAdd.Id;
        //con.NS_Customer_Ship_To_Address__c = cusAdd.Id;
        update con;
        test.startTest();
        BillingGroupCreation.BillingGroupCreation(con.id);
        system.assertEquals(1, [SELECT COUNT() FROM Billing_Group__c]);
        test.stopTest();
    }
    
    @isTest static void createBG2(){
        Billing_Entity__c be = new Billing_Entity__c();
        be.name = 'Test Entity';
        be.BE_Active__c = false;
        insert be;
        Contract con = [SELECT Id, BG_Created__c, Misys_Entity__c, NS_Customer_Ship_To_Address__c, NS_Customer_Ship_To_Address__r.Synced_To_NS__c FROM Contract];
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 1', Default_Billing__c = true, Account__c = [SELECT Id FROM ACCOUNT].Id);
        insert btst;
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = btst.Account__c, Misys_Entity__c = con.Misys_Entity__c, Ns_internal_Id__c = '123');
        insert accBySub;
        NS_Customer_Address__c  cusAdd = new NS_Customer_Address__c(Acct_By_Sub__c = accBySub.Id, Bill_To_Ship_To__c = btst.Id, Synced_To_NS__c = false);
        insert cusAdd;
        con.BG_Created__c = true;
        con.Misys_Entity__c = be.Id;
        con.NS_Customer_Ship_To_Address__c = cusAdd.Id;
        update con; 
        test.startTest();
        string response = BillingGroupCreation.BillingGroupCreation([SELECT Id FROM Contract].Id); 
        System.assertEquals(true, response.contains('<b>Contracting entity</b> is not active, Please check the details.'));
        System.assertEquals(true, response.contains('Fixed Billing Day</b> is mandatory, if it is not a monthly billing Fixed Billing Month also Mandatory. \n'));
        System.assertEquals(true, response.contains('We can create Billing Group and Sales Orders only at <b>CAT Logging Complete stage</b>. \n'));
        test.stopTest();
        
    }
    
    @isTest static void createBG3(){
        Account acc = TestDataFactory.createAccount('Test Account');
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        CPQValidations__c cpqVal = new CPQValidations__c();
        cpqVal.Bypass__c = true; 
        insert cpqVal;
        opp.StageName = 'Closed Won'; update opp;
        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '1', BE_Active__c = true); insert misysEntity;
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att',Default_Billing__c = true, Account__c = acc.Id); insert btst;
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = acc.Id, Misys_Entity__c = misysEntity.Id, Ns_internal_Id__c = '123'); insert accBySub;
        accBySub.Synced_To_NS__c = true; update accBySub;
        NS_Customer_Address__c  cusAdd = [select id,Bill_To_Ship_To__c,Acct_By_Sub__c from NS_Customer_Address__c where Bill_To_Ship_To__c =: btst.id and  Acct_By_Sub__c =: accBySub.id];
        cusAdd.Synced_To_NS__c = true; update cusAdd;
        NS_Currency__c NSCur = new NS_Currency__c(name = 'USD'); insert NSCur;
        NS_Trading_Currency__c tradeCur = new NS_Trading_Currency__c ( NS_Currency__c = NSCur.id, Acct_By_Sub__c = accBySub.id, Synced_To_NS__c = true); insert tradeCur;
        contract con = TestDataFactory.createContract(acc, opp);
        
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');
        
        System.runAs(u2) {
        con.Misys_Entity__c = misysEntity.Id;
        con.Bill_To__c = btst.id;
        con.Ship_To__c = btst.id;
        con.Billing_Group_Entity__c = accBySub.id;
        con.Fixed_Billing_Day__c = 1;
        con.Contract_Status__c  = 'CAT Logging Complete';
        con.Recurring_Fees_Start_Planned__c = system.today();
        //con.NS_Customer_Address__c = cusAdd.Id;
        //con.NS_Customer_Ship_To_Address__c = cusAdd.Id;
        update con;
        test.startTest();
        BillingGroupCreation.BillingGroupCreation(con.id);
        system.assertEquals(1, [SELECT COUNT() FROM Billing_Group__c]);
        test.stopTest();
        }
    }
    
    
}