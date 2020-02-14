@isTest
public class SO_ExecuteProcess_test {
    
      @testSetup static void dataSetup() {
        insert TestUtility.createNSCurrency();
        insert TestUtility.createNSProduct();
        insert TestUtility.createNSFixedBillingDate();
        insert TestUtility.createNSCostCentre();
        insert TestUtility.createNSRevenueRecognitionTemplate();
        insert TestUtility.createNSOpenAirRevenueRules();
        insert TestUtility.createNSListTable();
        insert TestUtility.createNSAccount();

        TestDataFactory.init_NS_maps();
        
        Account acc = TestDataFactory.createAccount('Test Account'); // Inserts a 'Test Account' Account
        
        Opportunity opp = TestDataFactory.createOpportunity(acc); // Inserts a 'Test Opp' Opportunity
        
        Id bScheduleId = TestDataFactory.add_OppBillingSchedule(opp); // Adds Opp Billing Schedule and item (1) each return billing schedule Id
        System.assertEquals(bScheduleId, [SELECT Id FROM Opportunity_Billing_Schedule__c].Id, 'Verifying right billing schedule returned or not');
        system.assertEquals(1, [SELECT Count() FROM Opportunity_Billing_Schedule_Item__c], 'One Opp Billing Schedule Inserted');
        
        Billing_Entity__c billing1 = TestDataFactory.createBillingEntity();  // Inserts (1) Billing Entity
            
        Contract con = TestDataFactory.createContract(acc, opp); // Inserts Contract by linking Account + Opportunity
        con.Recurring_Fees_Start_Planned__c = system.today().addDays(3);
        update con;
        system.assertEquals(1, [SELECT COUNT() FROM Contract], 'Inserted (1) Contract');
        system.assertEquals(acc.Id, [SELECT AccountId FROM Contract].AccountId, 'Contract Inserted along + assigned Account');
        
        Billing_Group__c bGroup = TestDataFactory.createBillingGroup(con); // Inserts Billing Group with above Contract
        system.assertEquals(1, [SELECT COUNT() FROM Billing_Group__c], 'Inserted (1) Billing Group');
        system.assertEquals(con.Id, [SELECT Id, Original_Contract__c FROM Billing_Group__c WHERE Id =: bGroup.Id].Original_Contract__c, 'Billing Group, Contract linked');
        system.assertEquals('USD', [SELECT Id, CurrencyIsoCode FROM Billing_Group__c WHERE Id =: bGroup.Id].CurrencyIsoCode, 'Billing Group currency should be USD.');        
        
        TestDataFactory.createILF_Subscription(con); // Inserts (1) ILF Subscriptions
        system.assertEquals(con.Id, [SELECT Id, SBQQ__Contract__c FROM SBQQ__Subscription__c].SBQQ__Contract__c, 'Linking Contract Id to subscription');
        System.assertEquals('ILF - ILF', [SELECT Id, Initial_Sales_Order_Type__c FROM SBQQ__Subscription__c WHERE Initial_Sales_Order_Type__c = 'ILF - ILF'].Initial_Sales_Order_Type__c, 'Sub should be of type ILF-ILF');
        System.assertEquals(100.0, [SELECT Id, Sold_Value__c FROM SBQQ__Subscription__c].Sold_Value__c, 'Sub sold value should be 100.0');

        TestDataFactory.createRLF_Subscription(con, bGroup.Id); // Inserts (6) RLF Subscriptions
        System.assertEquals(7, [SELECT Count() FROM SBQQ__Subscription__c WHERE Recurring_Sales_Order_Type__c = 'RLF - RLF'], 'Subscriptions(7) inserted of RLF Type');
            
        TestDataFactory.createPS_Subscription(con, bScheduleId, bGroup.Id); // Insertes (2) PS Subscriptions
        system.assertEquals(5, [SELECT COUNT() FROM SBQQ__Subscription__c WHERE Initial_Sales_Order_Type__c  = 'PS - PS'], 'inserted one each sub for all PS Process Types');
    }
    private static testMethod void invokeILF1(){        
        Contract con = [select Recurring_Fees_Start_Planned__c,Contract_Expiry_Date__c,Ship_To__c,Bill_To__c,id,AccountId,Billing_Group_Entity__c,Misys_Opportunity__c,Opportunity_Currency_Code__c,StartDate,Memo__c,Misys_Entity__c from Contract where name='Test Con'];   
        Test.startTest(); 
            // Processing logic for single Contract
            SO_ExecuteProcess.createWithContract(con);
            System.assertEquals(4, [SELECT COUNT() FROM Sales_Order__c], 'Total 4 sales order 1 each for ILF, PS, RLF');
            system.assertEquals(13, [SELECT COUNT()  FROM Sales_Order_Item__c], 'Total 13 Sales order items need to be created');
        Test.stopTest();   
    }
    private static testMethod void invokeILF2(){        
        try {
            SO_ExecuteProcess.createWithContract(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
    }
    private static testMethod void invokeILF3(){        
        Contract con = [select Recurring_Fees_Start_Planned__c,Contract_Expiry_Date__c,Ship_To__c,Bill_To__c,id,AccountId,Billing_Group_Entity__c,Misys_Opportunity__c,Opportunity_Currency_Code__c,StartDate,Memo__c,Misys_Entity__c from Contract where name='Test Con'];   
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');

        System.runAs(u2) {
        Test.startTest(); 
            // Processing logic for single Contract
            SO_ExecuteProcess.createWithContract(con);
            System.assertEquals(4, [SELECT COUNT() FROM Sales_Order__c], 'Total 4 sales order 1 each for ILF, PS, RLF');
            system.assertEquals(13, [SELECT COUNT()  FROM Sales_Order_Item__c], 'Total 13 Sales order items need to be created');
        Test.stopTest();  
        }
    }
    private static testMethod void testCreateWithBG1() {
        Contract con = [select Recurring_Fees_Start_Planned__c,Contract_Expiry_Date__c,Ship_To__c,Bill_To__c,id,AccountId,Billing_Group_Entity__c,Misys_Opportunity__c,Opportunity_Currency_Code__c,StartDate,Memo__c,Misys_Entity__c from Contract where name='Test Con'];   
        Billing_Group__c bg = SO_BillingGroupHelper.BillingGroupCreation(con);
        Test.startTest(); 
            String sMsg = SO_ExecuteProcess.createWithBG(bg,'ILF',con);
        Test.stopTest();  
        System.assertEquals(true, sMsg.contains('Assigned Billing Group to Subscriptions'),'Should return Assigned Billing Group to Subscriptions success message');
        System.assertEquals(true, sMsg.contains('NS Project Created Successfully'),'Should return NS Project Created success message');
        System.assertEquals(4, [SELECT COUNT() FROM Sales_Order__c], 'Total 4 sales order 1 each for ILF, PS, RLF');
        System.assertEquals(13, [SELECT COUNT()  FROM Sales_Order_Item__c], 'Total 13 Sales order items need to be created');
    }
    private static testMethod void testCreateWithBG2() {
        Contract con = [select Recurring_Fees_Start_Planned__c,Contract_Expiry_Date__c,Ship_To__c,Bill_To__c,id,AccountId,Billing_Group_Entity__c,Misys_Opportunity__c,Opportunity_Currency_Code__c,StartDate,Memo__c,Misys_Entity__c from Contract where name='Test Con'];   
       
        Test.startTest(); 
         try {
            SO_ExecuteProcess.createWithBG(null,null,con);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
        Test.stopTest();  
        
    }
    private static testMethod void testCreateWithBG3() {
        Contract con = [select Recurring_Fees_Start_Planned__c,Contract_Expiry_Date__c,Ship_To__c,Bill_To__c,id,AccountId,Billing_Group_Entity__c,Misys_Opportunity__c,Opportunity_Currency_Code__c,StartDate,Memo__c,Misys_Entity__c from Contract where name='Test Con'];   
        Profile p = [SELECT Id FROM Profile WHERE Name='M B&RA profile + CS Sys Admin'];
        User u2 = new User(Alias = 'newUser1', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest1@testorg.com');

        System.runAs(u2) {
        Billing_Group__c bg = SO_BillingGroupHelper.BillingGroupCreation(con);
        Test.startTest(); 
            String sMsg = SO_ExecuteProcess.createWithBG(bg,'ILF',con);
        Test.stopTest();  
        System.assertEquals(true, sMsg.contains('Assigned Billing Group to Subscriptions'),'Should return Assigned Billing Group to Subscriptions success message');
        System.assertEquals(true, sMsg.contains('NS Project Created Successfully'),'Should return NS Project Created success message');
        System.assertEquals(4, [SELECT COUNT() FROM Sales_Order__c], 'Total 4 sales order 1 each for ILF, PS, RLF');
        System.assertEquals(13, [SELECT COUNT()  FROM Sales_Order_Item__c], 'Total 13 Sales order items need to be created');
        }
    }
   
}