@isTest
public class RLF_Utils_test {
    @testSetup static void setup(){
        Test.startTest();
        TestDataFactory.init_NS_maps();
        Account acc = TestDataFactory.createAccount('Test Account'); 
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        Contract con = TestDataFactory.createContract(acc, opp); 
        Billing_Group__c bGroup =  SO_BillingGroupHelper.BillingGroupCreation(con);
        TestDataFactory.createRLF_Subscription(con, bGroup.Id);
        Test.stopTest();
    }
    
    @isTest static void test_invoke1(){
        Test.startTest(); 
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        Billing_Group__c bg = [SELECT Id, Name, Account_by_Sub__c,Original_Opportunity__c,Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.Credit_Controller__c,CurrencyIsoCode, Original_Contract__c, Original_Opportunity__r.CloseDate,Account_by_Sub__r.Account__r.PO_Required__c,Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate,Original_Contract__r.CustomerSignedDate,Original_Contract__r.Memo__c, Original_Opportunity__r.Customer_PO__c, Original_Opportunity__r.Owner.FirstName, Original_Opportunity__r.Owner.LastName, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, Original_Customer_Signed_Date__c,Current_Sales_Order_Start_Date__c,NS_Subscription_Memo__c,BG_Contract_Date_migration__c,Next_Billing_Date__c, NS_Subscription_Start_Date__c,NS_Billing_Mode__c,NS_Termination_Method__c,BG_Opportunity_Number_s_migration__c,NS_Customer_Address__c,Last_Invoice_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c,NS_Specific_Invoice_Wording__c,Set_Tax_Combo_Override__c,NS_Customer_Ship_To_Address__c , Order_Sub_Type__c,Fixed_Billing_Date__c,Original_Contract__r.Contract_Expiry_Date__c,Original_Contract__r.Recurring_Fees_Start_Planned__c,Original_Contract__r.ContractTerm FROM Billing_Group__c LIMIT 1]; 
        List<SBQQ__Subscription__c> subs = [SELECT Id, Billing_Day__c, Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode, Billing_Group__r.CurrencyIsoCode, Billing_Month__c, Comm_Man_Price__c, Contractor_Hours_Total__c, Discount_premium__c, Expiry_Date__c, Fair_Value__c, Fair_Value_Adjustment__c, Initial_Sales_Order_Type__c, Internal_Costs__c, Last_Prorata_Calculated__c, Last_Prorata_required__c, Licence_Band__c, License_Metric__c, LineItem_Process_Type__c, List_Per_Diem_Value__c, Location__c, Next_Billing_Date__c, Next_SO_generation_Date__c, NonBillable_Hours_Total__c, NS_Deferred_Revenue_Acct_ID__c, Opportunity_Billing_Schedule__c, Pearl_Internal_Cost__c, Pro_Rata_Calculated__c, Prorata_Days__c, Recurring_NS_Item__c, Recurring_Sovos_Code__c, Recurring_NS_Item__r.GA__c, Recurring_NS_Item__r.NS_Cost_Centre_ID__c, Recurring_NS_Item__r.NS_Default_Delivered__c, Recurring_NS_Item__r.NS_Form_ID__c, Recurring_NS_Item__r.NS_Product_Dimension_ID__c, Recurring_NS_Item__r.NS_Rev_Rec_Template_ID__c, Recurring_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c, Recurring_Sales_Order_Type__c, Reimbursable_Costs_Estimate__c, Reimbursable_Costs_Recovery_Value__c, RF_Start_Planned__c, RF_Start_Planned_Date__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c, SBQQ__ListPrice__c, SBQQ__NetPrice__c, SBQQ__PartnerDiscount__c, SBQQ__Product__c, SBQQ__Product__r.GA__c, SBQQ__Product__r.Name, SBQQ__Product__r.NS_3PP_Vendor_ID__c, SBQQ__Product__r.NS_Create_3PP_Event__c, SBQQ__Product__r.NS_Default_OpenAir_Billing_Rule_Int_ID__c, SBQQ__Product__r.NS_Deferred_Revenue_Acct_ID__c, SBQQ__Product__r.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c, SBQQ__Product__r.NS_Rev_Rec_Template_ID__c, SBQQ__Product__r.Payaway__c, SBQQ__Product__r.UPID__c, SBQQ__Quantity__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__UnitCost__c, SO_Generation_Advance__c, Sold_Per_Diem_Value__c, Sold_Value__c, Ship_From_Code__c, ThirdParty_Contractor_Cost_Sold_Ccy__c, ThirdParty_Costs_PO_Ccy__c, ThirdParty_Costs_Sold_Ccy__c, ThirdParty_PO_Currency__c, ThirdParty_Recurring_Costs_PO_Ccy__c, Total_Chargeable_Hours__c, Travel_Hours_Total__c, Transactional__c , Transactions__c , unrecoverable_costs__c, X3PP_Currency__c, X3PP_Discount__c FROM SBQQ__Subscription__c ]; 
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        RLF_Utils.invoke(bg_subList_Map, bg);
        
        system.assertEquals('RLF', [SELECT Order_Type__c FROM Sales_Order__c].Order_Type__c, 'RLF Sales Order Created for given Billing Group');       
        system.assertEquals(7, [SELECT COUNT() FROM SBQQ__Subscription__c], 'Total 7 RLF Subs created');
        system.assertEquals(system.today().addyears(1), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where SBQQ__BillingFrequency__c = 'Annual' LIMIT 1].Next_Billing_Date__c, 'nbd');
        system.assertEquals(system.today().addYears(1).adddays(-60), [SELECT Next_SO_generation_Date__c FROM SBQQ__Subscription__c where SBQQ__BillingFrequency__c = 'Annual' LIMIT 1].Next_SO_generation_Date__c, 'nsogendate');
        
       /* for(SBQQ__Subscription__c sub: [SELECT Next_Billing_Date__c, Next_SO_generation_Date__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c, SO_Generation_Advance__c FROM SBQQ__Subscription__c]){
            system.debug('xoxoxo'+sub);
        }*/
        
        Test.stopTest();
    }
    @isTest static void test_invoke2(){
      
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

       System.runAs(u3) {
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        Billing_Group__c bg = [SELECT Id, Name, Account_by_Sub__c,Original_Opportunity__c,Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.Credit_Controller__c,CurrencyIsoCode, Original_Contract__c, Original_Opportunity__r.CloseDate,Account_by_Sub__r.Account__r.PO_Required__c,Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate,Original_Contract__r.CustomerSignedDate,Original_Contract__r.Memo__c, Original_Opportunity__r.Customer_PO__c, Original_Opportunity__r.Owner.FirstName, Original_Opportunity__r.Owner.LastName, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, Original_Customer_Signed_Date__c,Current_Sales_Order_Start_Date__c,NS_Subscription_Memo__c,BG_Contract_Date_migration__c,Next_Billing_Date__c, NS_Subscription_Start_Date__c,NS_Billing_Mode__c,NS_Termination_Method__c,BG_Opportunity_Number_s_migration__c,NS_Customer_Address__c,Last_Invoice_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c,NS_Specific_Invoice_Wording__c,Set_Tax_Combo_Override__c,NS_Customer_Ship_To_Address__c , Order_Sub_Type__c,Fixed_Billing_Date__c,Original_Contract__r.Contract_Expiry_Date__c,Original_Contract__r.Recurring_Fees_Start_Planned__c,Original_Contract__r.ContractTerm FROM Billing_Group__c LIMIT 1]; 
        List<SBQQ__Subscription__c> subs = [SELECT Id, Billing_Day__c, Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode, Billing_Group__r.CurrencyIsoCode, Billing_Month__c, Comm_Man_Price__c, Contractor_Hours_Total__c, Discount_premium__c, Expiry_Date__c, Fair_Value__c, Fair_Value_Adjustment__c, Initial_Sales_Order_Type__c, Internal_Costs__c, Last_Prorata_Calculated__c, Last_Prorata_required__c, Licence_Band__c, License_Metric__c, LineItem_Process_Type__c, List_Per_Diem_Value__c, Location__c, Next_Billing_Date__c, Next_SO_generation_Date__c, NonBillable_Hours_Total__c, NS_Deferred_Revenue_Acct_ID__c, Opportunity_Billing_Schedule__c, Pearl_Internal_Cost__c, Pro_Rata_Calculated__c, Prorata_Days__c, Recurring_NS_Item__c, Recurring_Sovos_Code__c, Recurring_NS_Item__r.GA__c, Recurring_NS_Item__r.NS_Cost_Centre_ID__c, Recurring_NS_Item__r.NS_Default_Delivered__c, Recurring_NS_Item__r.NS_Form_ID__c, Recurring_NS_Item__r.NS_Product_Dimension_ID__c, Recurring_NS_Item__r.NS_Rev_Rec_Template_ID__c, Recurring_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c, Recurring_Sales_Order_Type__c, Reimbursable_Costs_Estimate__c, Reimbursable_Costs_Recovery_Value__c, RF_Start_Planned__c, RF_Start_Planned_Date__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c, SBQQ__ListPrice__c, SBQQ__NetPrice__c, SBQQ__PartnerDiscount__c, SBQQ__Product__c, SBQQ__Product__r.GA__c, SBQQ__Product__r.Name, SBQQ__Product__r.NS_3PP_Vendor_ID__c, SBQQ__Product__r.NS_Create_3PP_Event__c, SBQQ__Product__r.NS_Default_OpenAir_Billing_Rule_Int_ID__c, SBQQ__Product__r.NS_Deferred_Revenue_Acct_ID__c, SBQQ__Product__r.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c, SBQQ__Product__r.NS_Rev_Rec_Template_ID__c, SBQQ__Product__r.Payaway__c, SBQQ__Product__r.UPID__c, SBQQ__Quantity__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__UnitCost__c, SO_Generation_Advance__c, Sold_Per_Diem_Value__c, Sold_Value__c, Ship_From_Code__c, ThirdParty_Contractor_Cost_Sold_Ccy__c, ThirdParty_Costs_PO_Ccy__c, ThirdParty_Costs_Sold_Ccy__c, ThirdParty_PO_Currency__c, ThirdParty_Recurring_Costs_PO_Ccy__c, Total_Chargeable_Hours__c, Travel_Hours_Total__c, Transactional__c , Transactions__c , unrecoverable_costs__c, X3PP_Currency__c, X3PP_Discount__c FROM SBQQ__Subscription__c ]; 
        Test.startTest();
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        RLF_Utils.invoke(bg_subList_Map, bg);
        Test.stopTest();
        system.assertEquals('RLF', [SELECT Order_Type__c FROM Sales_Order__c].Order_Type__c, 'RLF Sales Order Created for given Billing Group');       
        system.assertEquals(7, [SELECT COUNT() FROM SBQQ__Subscription__c], 'Total 7 RLF Subs created');
        system.assertEquals(system.today().addyears(1), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where SBQQ__BillingFrequency__c = 'Annual' LIMIT 1].Next_Billing_Date__c, 'nbd');
        system.assertEquals(system.today().addYears(1).adddays(-60), [SELECT Next_SO_generation_Date__c FROM SBQQ__Subscription__c where SBQQ__BillingFrequency__c = 'Annual' LIMIT 1].Next_SO_generation_Date__c, 'nsogendate');
        
    }
    } 
    @isTest static void test_invoke3(){
      
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        Billing_Group__c bg = [SELECT Id, Name, Account_by_Sub__c,Original_Opportunity__c,Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.Credit_Controller__c,CurrencyIsoCode, Original_Contract__c, Original_Opportunity__r.CloseDate,Account_by_Sub__r.Account__r.PO_Required__c,Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate,Original_Contract__r.CustomerSignedDate,Original_Contract__r.Memo__c, Original_Opportunity__r.Customer_PO__c, Original_Opportunity__r.Owner.FirstName, Original_Opportunity__r.Owner.LastName, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, Original_Customer_Signed_Date__c,Current_Sales_Order_Start_Date__c,NS_Subscription_Memo__c,BG_Contract_Date_migration__c,Next_Billing_Date__c, NS_Subscription_Start_Date__c,NS_Billing_Mode__c,NS_Termination_Method__c,BG_Opportunity_Number_s_migration__c,NS_Customer_Address__c,Last_Invoice_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c,NS_Specific_Invoice_Wording__c,Set_Tax_Combo_Override__c,NS_Customer_Ship_To_Address__c , Order_Sub_Type__c,Fixed_Billing_Date__c,Original_Contract__r.Contract_Expiry_Date__c,Original_Contract__r.Recurring_Fees_Start_Planned__c,Original_Contract__r.ContractTerm FROM Billing_Group__c LIMIT 1]; 
        List<SBQQ__Subscription__c> subs = [SELECT Id, Billing_Day__c, Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode, Billing_Group__r.CurrencyIsoCode, Billing_Month__c, Comm_Man_Price__c, Contractor_Hours_Total__c, Discount_premium__c, Expiry_Date__c, Fair_Value__c, Fair_Value_Adjustment__c, Initial_Sales_Order_Type__c, Internal_Costs__c, Last_Prorata_Calculated__c, Last_Prorata_required__c, Licence_Band__c, License_Metric__c, LineItem_Process_Type__c, List_Per_Diem_Value__c, Location__c, Next_Billing_Date__c, Next_SO_generation_Date__c, NonBillable_Hours_Total__c, NS_Deferred_Revenue_Acct_ID__c, Opportunity_Billing_Schedule__c, Pearl_Internal_Cost__c, Pro_Rata_Calculated__c, Prorata_Days__c, Recurring_NS_Item__c, Recurring_Sovos_Code__c, Recurring_NS_Item__r.GA__c, Recurring_NS_Item__r.NS_Cost_Centre_ID__c, Recurring_NS_Item__r.NS_Default_Delivered__c, Recurring_NS_Item__r.NS_Form_ID__c, Recurring_NS_Item__r.NS_Product_Dimension_ID__c, Recurring_NS_Item__r.NS_Rev_Rec_Template_ID__c, Recurring_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c, Recurring_Sales_Order_Type__c, Reimbursable_Costs_Estimate__c, Reimbursable_Costs_Recovery_Value__c, RF_Start_Planned__c, RF_Start_Planned_Date__c, SBQQ__BillingFrequency__c, SBQQ__BillingType__c, SBQQ__ListPrice__c, SBQQ__NetPrice__c, SBQQ__PartnerDiscount__c, SBQQ__Product__c, SBQQ__Product__r.GA__c, SBQQ__Product__r.Name, SBQQ__Product__r.NS_3PP_Vendor_ID__c, SBQQ__Product__r.NS_Create_3PP_Event__c, SBQQ__Product__r.NS_Default_OpenAir_Billing_Rule_Int_ID__c, SBQQ__Product__r.NS_Deferred_Revenue_Acct_ID__c, SBQQ__Product__r.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c, SBQQ__Product__r.NS_Rev_Rec_Template_ID__c, SBQQ__Product__r.Payaway__c, SBQQ__Product__r.UPID__c, SBQQ__Quantity__c, SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__UnitCost__c, SO_Generation_Advance__c, Sold_Per_Diem_Value__c, Sold_Value__c, Ship_From_Code__c, ThirdParty_Contractor_Cost_Sold_Ccy__c, ThirdParty_Costs_PO_Ccy__c, ThirdParty_Costs_Sold_Ccy__c, ThirdParty_PO_Currency__c, ThirdParty_Recurring_Costs_PO_Ccy__c, Total_Chargeable_Hours__c, Travel_Hours_Total__c, Transactional__c , Transactions__c , unrecoverable_costs__c, X3PP_Currency__c, X3PP_Discount__c FROM SBQQ__Subscription__c ]; 
        Test.startTest();
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
           try {
            RLF_Utils.invoke(bg_subList_Map, null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
        Test.stopTest();
        
        
    }
    @isTest static void test_bgDatesUpdate1(){
        ID bg = [select id from Billing_Group__c].id; 
        List<Id> bgIdList = new List<Id>();
        bgIdList.add(bg);
        SBQQ__Subscription__c[] subs = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub: [SELECT Id, Name, Next_Billing_Date__c,Billing_Status__c, Next_SO_generation_Date__c FROM SBQQ__Subscription__c where Billing_Group__c =: bgIdList]){
            sub.Next_Billing_Date__c = system.today();
            sub.Next_SO_generation_Date__c = system.today();
            sub.Billing_Status__c = 'Active billing';
            subs.add(sub);
        }
        update subs;
        Test.startTest();        
            RLF_Utils.bgDatesUpdate(bgIdList);
        Test.stopTest();
        system.assertEquals(system.today(), [SELECT Next_Billing_Date__c FROM Billing_Group__c LIMIT 1].Next_Billing_Date__c, 'nbd');
        system.assertEquals(system.today(), [SELECT Next_SO_generation_Date__c FROM Billing_Group__c LIMIT 1].Next_SO_generation_Date__c, 'nsogendate');
        
    }
    @isTest static void test_bgDatesUpdate2(){
        ID bg = [select id from Billing_Group__c].id; 
        List<Id> bgIdList = new List<Id>();
        bgIdList.add(bg);
        SBQQ__Subscription__c[] subs = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub: [SELECT Id, Name, Next_Billing_Date__c, Next_SO_generation_Date__c FROM SBQQ__Subscription__c where Billing_Group__c =: bgIdList]){
            sub.Next_Billing_Date__c = null;
            sub.Next_SO_generation_Date__c = null;
            subs.add(sub);
        }
        update subs;
        Test.startTest();        
            RLF_Utils.bgDatesUpdate(bgIdList);
        Test.stopTest();
        system.assertEquals(null, [SELECT Next_Billing_Date__c FROM Billing_Group__c LIMIT 1].Next_Billing_Date__c, 'nbd');
        system.assertEquals(null, [SELECT Next_SO_generation_Date__c FROM Billing_Group__c LIMIT 1].Next_SO_generation_Date__c, 'nsogendate');
        
    }
    @isTest static void test_bgDatesUpdate3(){
        
        try {
            RLF_Utils.bgDatesUpdate(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
        
    }
    
       
}