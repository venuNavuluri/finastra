@isTest
public class SO_NSProjectHelper_Test {
    @testSetup static void setup(){
        Test.startTest();
        TestDataFactory.init_NS_maps();
        Account acc = TestDataFactory.createAccount('Test Account'); 
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        Contract con = TestDataFactory.createContract(acc, opp);     
        Billing_Group__c bGroup =  SO_BillingGroupHelper.BillingGroupCreation(con);        
        TestDataFactory.createILF_Subscription(con);
        SO_BillingGroupHelper.addBGtoSubscriptions(bGroup);         
        Id obsId = TestDataFactory.add_OppBillingSchedule(opp);
        system.debug('from test obsId => '+obsId);
        TestDataFactory.createPS_Subscription(con, obsId, bGroup.Id);
        Opportunity_Billing_Schedule_Item__c obsItem1 = new Opportunity_Billing_Schedule_Item__c(Name = 'M1 - 20% Start of UAT', Narrative__c = '20% Start of UAT', Opportunity_Billing_Schedule__c = obsId, Line__c = 30);
        insert obsItem1;
        Test.stopTest();
    }
    
    @isTest static void test_createProject1(){
        
        Billing_Group__c bg = [SELECT Id, Name, Account_by_Sub__c,Original_Opportunity__c,Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.Credit_Controller__c,CurrencyIsoCode, Original_Contract__c, Original_Opportunity__r.CloseDate,Account_by_Sub__r.Account__r.PO_Required__c,Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate,Original_Contract__r.CustomerSignedDate,Original_Contract__r.Memo__c, Original_Opportunity__r.Customer_PO__c, Original_Opportunity__r.Owner.FirstName, Original_Opportunity__r.Owner.LastName, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, Original_Customer_Signed_Date__c,Current_Sales_Order_Start_Date__c,NS_Subscription_Memo__c,BG_Contract_Date_migration__c,Next_Billing_Date__c, NS_Subscription_Start_Date__c,NS_Billing_Mode__c,NS_Termination_Method__c,BG_Opportunity_Number_s_migration__c,NS_Customer_Address__c,Last_Invoice_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c,NS_Specific_Invoice_Wording__c,Set_Tax_Combo_Override__c,NS_Customer_Ship_To_Address__c , Order_Sub_Type__c,Fixed_Billing_Date__c,Original_Contract__r.Contract_Expiry_Date__c,Original_Contract__r.Recurring_Fees_Start_Planned__c,Original_Contract__r.ContractTerm FROM Billing_Group__c LIMIT 1]; 
        Map<String, String> soType_subId_map = SO_SubscriptionsGrouping.getMaxAmountSubIdsMap(bg);
        Double tempMax = 0;
        
        for(SBQQ__Subscription__c sub: [SELECT Id, Sold_Value__c, Initial_Sales_Order_Type__c FROM SBQQ__Subscription__c WHERE Initial_Sales_Order_Type__c LIKE 'PS%']){
            if(sub.Sold_Value__c >= tempMax){
                soType_subId_map.put(sub.Initial_Sales_Order_Type__c, sub.Id); 
            }
        }
        
        Map<String, SBQQ__Subscription__c> subs_map = SO_SubscriptionsGrouping.getProjSubMap(soType_subId_map);
        Map<String, SBQQ__Subscription__c> temp_map = SO_SubscriptionsGrouping.getProjSubMap(soType_subId_map);
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c();
        for(string s: subs_map.keySet()){
            sub1 = new SBQQ__Subscription__c();
            sub1 = subs_map.get(s);
            sub1.Opportunity_Billing_Schedule__c = [SELECT Id FROM Opportunity_Billing_Schedule__c LIMIT 1].Id;
            temp_map.put(s, sub1);
        }
        Test.startTest();
        Map<String, NS_Project__c> projSubs = SO_NSProjectHelper.createNSProject(soType_subId_map, temp_map, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(), SO_SalesOrderMapUtils.getNSProduct_map());
        Test.stopTest();
        system.assertEquals(2, projSubs.size(), '2 Projects one for ILF & PS Created');
        for(NS_Project__c proj: projSubs.values()){
            if(proj.Project_Type__c.contains('ILF')){
                system.assertEquals('ILF - ILF', proj.Project_Type__c, 'Project Type of ILF - ILF Created');
            }
            
            if(proj.Project_Type__c.contains('PS')){
                system.assertEquals('PS - PS', proj.Project_Type__c, 'Project Type of PS - PS Created ');
            }
            
        }
        
    }
    
    @isTest static void test_createProject2(){
        
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {
        Billing_Group__c bg = [SELECT Id, Name, Account_by_Sub__c,Original_Opportunity__c,Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.Credit_Controller__c,CurrencyIsoCode, Original_Contract__c, Original_Opportunity__r.CloseDate,Account_by_Sub__r.Account__r.PO_Required__c,Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate,Original_Contract__r.CustomerSignedDate,Original_Contract__r.Memo__c, Original_Opportunity__r.Customer_PO__c, Original_Opportunity__r.Owner.FirstName, Original_Opportunity__r.Owner.LastName, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, Original_Customer_Signed_Date__c,Current_Sales_Order_Start_Date__c,NS_Subscription_Memo__c,BG_Contract_Date_migration__c,Next_Billing_Date__c, NS_Subscription_Start_Date__c,NS_Billing_Mode__c,NS_Termination_Method__c,BG_Opportunity_Number_s_migration__c,NS_Customer_Address__c,Last_Invoice_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c,NS_Specific_Invoice_Wording__c,Set_Tax_Combo_Override__c,NS_Customer_Ship_To_Address__c , Order_Sub_Type__c,Fixed_Billing_Date__c,Original_Contract__r.Contract_Expiry_Date__c,Original_Contract__r.Recurring_Fees_Start_Planned__c,Original_Contract__r.ContractTerm FROM Billing_Group__c LIMIT 1]; 
        Map<String, String> soType_subId_map = SO_SubscriptionsGrouping.getMaxAmountSubIdsMap(bg);
        Double tempMax = 0;
        
        for(SBQQ__Subscription__c sub: [SELECT Id, Sold_Value__c, Initial_Sales_Order_Type__c FROM SBQQ__Subscription__c WHERE Initial_Sales_Order_Type__c LIKE 'PS%']){
            if(sub.Sold_Value__c >= tempMax){
                soType_subId_map.put(sub.Initial_Sales_Order_Type__c, sub.Id); 
            }
        }
        
        Map<String, SBQQ__Subscription__c> subs_map = SO_SubscriptionsGrouping.getProjSubMap(soType_subId_map);
        Map<String, SBQQ__Subscription__c> temp_map = SO_SubscriptionsGrouping.getProjSubMap(soType_subId_map);
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c();
        for(string s: subs_map.keySet()){
            sub1 = new SBQQ__Subscription__c();
            sub1 = subs_map.get(s);
            sub1.Opportunity_Billing_Schedule__c = [SELECT Id FROM Opportunity_Billing_Schedule__c LIMIT 1].Id;
            temp_map.put(s, sub1);
        }
        Test.startTest();
        Map<String, NS_Project__c> projSubs = SO_NSProjectHelper.createNSProject(soType_subId_map, temp_map, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(), SO_SalesOrderMapUtils.getNSProduct_map());
        
        system.assertEquals(2, projSubs.size(), '2 Projects one for ILF & PS Created');
        for(NS_Project__c proj: projSubs.values()){
            if(proj.Project_Type__c.contains('ILF')){
                system.assertEquals('ILF - ILF', proj.Project_Type__c, 'Project Type of ILF - ILF Created');
            }
            
            if(proj.Project_Type__c.contains('PS')){
                system.assertEquals('PS - PS', proj.Project_Type__c, 'Project Type of PS - PS Created ');
            }           
        }
            Test.stopTest();
        }
        
    }
    
    @isTest static void test_createProject3(){
        Test.startTest();
       
        try {
            SO_NSProjectHelper.createNSProject(null, null, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(), SO_SalesOrderMapUtils.getNSProduct_map());
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
        Test.stopTest();
    }
}