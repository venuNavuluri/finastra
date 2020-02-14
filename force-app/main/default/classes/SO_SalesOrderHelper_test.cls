@isTest
public class SO_SalesOrderHelper_test {
    @testSetup static void setup(){
        TestDataFactory.init_NS_maps();
        Account acc = TestDataFactory.createAccount('Test Account'); 
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        Contract con = TestDataFactory.createContract(acc, opp); 
        Billing_Group__c bGroup =  SO_BillingGroupHelper.BillingGroupCreation(con);
        TestDataFactory.createILF_Subscription(con);
        SO_BillingGroupHelper.addBGtoSubscriptions(bGroup);
        TestDataFactory.createPS_Subscription(con, TestDataFactory.add_OppBillingSchedule(opp), bGroup.Id);
        TestDataFactory.createRLF_Subscription(con, bGroup.Id);
     }
    private static testMethod void test_createSalesOrder_With_Null(){
        Test.startTest();
            try {
                Sales_Order__c[] soList = SO_SalesOrderHelper.createSalesOrder(null, null, null, null, null, null, 'ILF', null, null);
            }catch(Exception e){
                System.assert(true, 'Should thorow exception');
            }
        Test.stopTest();               
    }
    private static testMethod void test_createSalesOrder_With_EmptyList(){
        Map<String, Integer> soType_counter_Map = new Map<String, Integer>();
        Test.startTest();
            Sales_Order__c[] soList = SO_SalesOrderHelper.createSalesOrder(null, soType_counter_Map, null, null, null, null, 'ILF', null, null);
        Test.stopTest();               
        System.assertEquals(0, soList.size(), 'Should not create any sales orders');
    }

    private static testMethod void test_createSalesOrder(){
        Billing_Group__c bg = [SELECT Id, Name, Account_by_Sub__c,Original_Opportunity__c,Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.Credit_Controller__c,CurrencyIsoCode, Original_Contract__c, Original_Opportunity__r.CloseDate,Account_by_Sub__r.Account__r.PO_Required__c,Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate,Original_Contract__r.CustomerSignedDate,Original_Contract__r.Memo__c, Original_Opportunity__r.Customer_PO__c, Original_Opportunity__r.Owner.FirstName, Original_Opportunity__r.Owner.LastName, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, Original_Customer_Signed_Date__c,Current_Sales_Order_Start_Date__c,NS_Subscription_Memo__c,BG_Contract_Date_migration__c,Next_Billing_Date__c, NS_Subscription_Start_Date__c,NS_Billing_Mode__c,NS_Termination_Method__c,BG_Opportunity_Number_s_migration__c,NS_Customer_Address__c,Last_Invoice_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c,NS_Specific_Invoice_Wording__c,Set_Tax_Combo_Override__c,NS_Customer_Ship_To_Address__c , Order_Sub_Type__c,Fixed_Billing_Date__c,Original_Contract__r.Contract_Expiry_Date__c,Original_Contract__r.Recurring_Fees_Start_Planned__c,Original_Contract__r.ContractTerm FROM Billing_Group__c LIMIT 1]; 
        Map<String, Integer> soType_counter_Map = new Map<String, Integer>();
        Map<String, List<SBQQ__Subscription__c>> ps_subs_map = new Map<String, List<SBQQ__Subscription__c>>();        
        soType_counter_Map = SO_SubscriptionsGrouping.sortbyProcess(bg);       
        ps_subs_map = SO_SubscriptionsGrouping.getSubsByTypeForPs(bg);
        // adding PS values to map
        for(String soType: ps_subs_map.keySet()){
            soType_counter_Map.put(soType, ps_subs_map.get(soType).size());
        }
        
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
        Map < String, NS_Project__c > soType_proj_map = SO_NSProjectHelper.createNSProject(soType_subId_map, temp_map, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(), SO_SalesOrderMapUtils.getNSProduct_map());      
        system.assertEquals(2, soType_proj_map.size(), '2 Projects one for ILF & PS Created');
        for(NS_Project__c proj: soType_proj_map.values()){
            if(proj.Project_Type__c.contains('ILF')){
                system.assertEquals('ILF - ILF', proj.Project_Type__c, 'Project Type of ILF - ILF Created');
            }
            
            if(proj.Project_Type__c.contains('PS')){
                system.assertEquals('PS - PS', proj.Project_Type__c, 'Project Type of PS - PS Created');
            }           
        }
        Test.startTest();
            Sales_Order__c[] soList = SO_SalesOrderHelper.createSalesOrder(bg, soType_counter_Map, soType_proj_map, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSProduct_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(), 'ILF', temp_map, SO_SalesOrderMapUtils.getNsAccMap());
        Test.stopTest();               
        System.assertEquals(2, soList.size(), 'Should create 2 sales orders');
    }
    private static testMethod void test_createSalesOrder2(){
        Test.startTest();
        Billing_Group__c bg = [SELECT Id, Name, Account_by_Sub__c,Original_Opportunity__c,Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.Credit_Controller__c,CurrencyIsoCode, Original_Contract__c, Original_Opportunity__r.CloseDate,Account_by_Sub__r.Account__r.PO_Required__c,Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate,Original_Contract__r.CustomerSignedDate,Original_Contract__r.Memo__c, Original_Opportunity__r.Customer_PO__c, Original_Opportunity__r.Owner.FirstName, Original_Opportunity__r.Owner.LastName, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, Original_Customer_Signed_Date__c,Current_Sales_Order_Start_Date__c,NS_Subscription_Memo__c,BG_Contract_Date_migration__c,Next_Billing_Date__c, NS_Subscription_Start_Date__c,NS_Billing_Mode__c,NS_Termination_Method__c,BG_Opportunity_Number_s_migration__c,NS_Customer_Address__c,Last_Invoice_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c,NS_Specific_Invoice_Wording__c,Set_Tax_Combo_Override__c,NS_Customer_Ship_To_Address__c , Order_Sub_Type__c,Fixed_Billing_Date__c,Original_Contract__r.Contract_Expiry_Date__c,Original_Contract__r.Recurring_Fees_Start_Planned__c,Original_Contract__r.ContractTerm FROM Billing_Group__c LIMIT 1]; 
        Map<String, Integer> soType_counter_Map = new Map<String, Integer>();
        Map<String, List<SBQQ__Subscription__c>> ps_subs_map = new Map<String, List<SBQQ__Subscription__c>>();        
        soType_counter_Map = SO_SubscriptionsGrouping.sortbyProcess(bg);       
        ps_subs_map = SO_SubscriptionsGrouping.getSubsByTypeForPs(bg);
        // adding PS values to map
        for(String soType: ps_subs_map.keySet()){
            soType_counter_Map.put(soType, ps_subs_map.get(soType).size());
        }
        
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
        Map < String, NS_Project__c > soType_proj_map = SO_NSProjectHelper.createNSProject(soType_subId_map, temp_map, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(), SO_SalesOrderMapUtils.getNSProduct_map());      
        system.assertEquals(2, soType_proj_map.size(), '2 Projects one for ILF & PS Created');
        for(NS_Project__c proj: soType_proj_map.values()){
            if(proj.Project_Type__c.contains('ILF')){
                system.assertEquals('ILF - ILF', proj.Project_Type__c, 'Project Type of ILF - ILF Created');
            }
            
            if(proj.Project_Type__c.contains('PS')){
                system.assertEquals('PS - PS', proj.Project_Type__c, 'Project Type of PS - PS Created');
            }           
        }
        Sales_Order__c[] soList = SO_SalesOrderHelper.createSalesOrder(bg, soType_counter_Map, soType_proj_map, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSProduct_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(), 'ILF', temp_map, SO_SalesOrderMapUtils.getNsAccMap());
        
        SO_SalesOrderHelper.updateCustomerBillingSchedule(soList);
        //system.assertEquals('RLF', [SELECT Order_Type__c FROM Sales_Order__c].Order_Type__c, 'RLF Sales Order Created for given Billing Group');
        
        Map<String, List<SBQQ__Subscription__c>> soType_subs_map = new Map<String, List<SBQQ__Subscription__c>>();
        
        soType_subs_map =  SO_SubscriptionsGrouping.getSubsByType(soType_counter_Map, bg.Id);  
        // adding PS values to map
        for(String soType: ps_subs_map.keySet()){
            soType_subs_map.put(soType, ps_subs_map.get(soType));
        }
        Map<string, string> proj_obs_map = new Map<String, string>();
        for(NS_Project__c proj: soType_proj_map.values()){
            proj_obs_map.put(proj.Id, proj.Project_Type__c);
        }
        SO_SalesOrderHelper.createSalesOrderItems(soList, soType_subs_map, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getRevScheduleMap(), SO_SalesOrderMapUtils.getIntIdOARevRuleMap(), SO_SalesOrderMapUtils.getIntIdOABillingRuleMap(), proj_obs_map, SO_SalesOrderMapUtils.getUPID());
        system.assertEquals(4, [SELECT COUNT() FROM Sales_Order_Item__c], 'RLF Sales Order Item Created');
        
        Contract con = [SELECT Id, Name, Reccuring_Payment_Holiday__c, Recurring_Fees_Start_Planned__c FROM Contract LIMIT 1];
        con.Recurring_Fees_Start_Planned__c = system.today().addDays(7);
        update con;
        SO_SalesOrderHelper.updateHolidayPeriod(SO_SubscriptionsGrouping.getSubsByType_RLF(soType_counter_Map, bg.Id), con);
        
        con.Recurring_Fees_Start_Planned__c = system.today().addDays(-1);  
        SO_SalesOrderHelper.calculateProrata(SO_SubscriptionsGrouping.getSubsByType_RLF(soType_counter_Map, bg.Id), con);
        for(SBQQ__Subscription__c sub: [SELECT Id, Prorata_Days__c FROM SBQQ__Subscription__c]){
            system.assertNotEquals(0, sub.Prorata_Days__c, 'Prorata Days calculated which is greater than 0');
        }
        SO_SalesOrderHelper.updateProrataCalculatedCheckBox([SELECT Id, Name, Sales_Order__c FROM Sales_Order_Item__c]);        
        for (SBQQ__Subscription__c sub: [SELECT Id,  Pro_Rata_Calculated__c FROM SBQQ__Subscription__c WHERE Recurring_Sales_Order_Type__c LIKE 'RLF%' AND Pro_Rata_Calculated__c = true]) {
            system.assertEquals(true, sub.Pro_Rata_Calculated__c, 'Setting Pro_Rata_Calculated__c to TRUE');
        }
        Test.stopTest();               
    }
    private static testMethod void test_updateCustomerBillingSchedule(){
        Billing_Group__c bg = [SELECT Id, Name, Account_by_Sub__c,Original_Opportunity__c,Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.Credit_Controller__c,CurrencyIsoCode, Original_Contract__c, Original_Opportunity__r.CloseDate,Account_by_Sub__r.Account__r.PO_Required__c,Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate,Original_Contract__r.CustomerSignedDate,Original_Contract__r.Memo__c, Original_Opportunity__r.Customer_PO__c, Original_Opportunity__r.Owner.FirstName, Original_Opportunity__r.Owner.LastName, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, Original_Customer_Signed_Date__c,Current_Sales_Order_Start_Date__c,NS_Subscription_Memo__c,BG_Contract_Date_migration__c,Next_Billing_Date__c, NS_Subscription_Start_Date__c,NS_Billing_Mode__c,NS_Termination_Method__c,BG_Opportunity_Number_s_migration__c,NS_Customer_Address__c,Last_Invoice_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c,NS_Specific_Invoice_Wording__c,Set_Tax_Combo_Override__c,NS_Customer_Ship_To_Address__c , Order_Sub_Type__c,Fixed_Billing_Date__c,Original_Contract__r.Contract_Expiry_Date__c,Original_Contract__r.Recurring_Fees_Start_Planned__c,Original_Contract__r.ContractTerm FROM Billing_Group__c LIMIT 1]; 
        Map<String, Integer> soType_counter_Map = new Map<String, Integer>();
        Map<String, List<SBQQ__Subscription__c>> ps_subs_map = new Map<String, List<SBQQ__Subscription__c>>();        
        soType_counter_Map = SO_SubscriptionsGrouping.sortbyProcess(bg);       
        ps_subs_map = SO_SubscriptionsGrouping.getSubsByTypeForPs(bg);
        // adding PS values to map
        for(String soType: ps_subs_map.keySet()){
            soType_counter_Map.put(soType, ps_subs_map.get(soType).size());
        }
        
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
        Map < String, NS_Project__c > soType_proj_map = SO_NSProjectHelper.createNSProject(soType_subId_map, temp_map, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(), SO_SalesOrderMapUtils.getNSProduct_map());      
        system.assertEquals(2, soType_proj_map.size(), '2 Projects one for ILF & PS Created');
        for(NS_Project__c proj: soType_proj_map.values()){
            if(proj.Project_Type__c.contains('ILF')){
                system.assertEquals('ILF - ILF', proj.Project_Type__c, 'Project Type of ILF - ILF Created');
            }
            
            if(proj.Project_Type__c.contains('PS')){
                system.assertEquals('PS - PS', proj.Project_Type__c, 'Project Type of PS - PS Created');
            }           
        }
        Sales_Order__c[] soList = SO_SalesOrderHelper.createSalesOrder(bg, soType_counter_Map, soType_proj_map, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSProduct_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(), 'ILF', temp_map, SO_SalesOrderMapUtils.getNsAccMap());
        
        Test.startTest();
            SO_SalesOrderHelper.updateCustomerBillingSchedule(soList);
        Test.stopTest();               
        System.assertEquals(2, soList.size(), 'Should create 2 sales orders');
    }
    
    private static testMethod void test_updateCustomerBillingSchedule_With_EmptyList(){
        List<Sales_Order__c> soList = new List<Sales_Order__c>();
        
        Test.startTest();
        try {
            SO_SalesOrderHelper.updateCustomerBillingSchedule(soList);
            System.assert(true,  'Should not throw exception');
        } catch (Exception e ){

        }
        Test.stopTest();               
    }
    private static testMethod void test_updateCustomerBillingSchedule_With_Null(){
        
        Test.startTest();
        try {
            SO_SalesOrderHelper.updateCustomerBillingSchedule(null);
            System.assert(true,  'Should not throw exception');
        } catch (Exception e ){

        }
        Test.stopTest();               
    }
    private static testMethod void test_createSalesOrderItems(){
        Billing_Group__c bg = [SELECT Id, Name, Account_by_Sub__c,Original_Opportunity__c,Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.Credit_Controller__c,CurrencyIsoCode, Original_Contract__c, Original_Opportunity__r.CloseDate,Account_by_Sub__r.Account__r.PO_Required__c,Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate,Original_Contract__r.CustomerSignedDate,Original_Contract__r.Memo__c, Original_Opportunity__r.Customer_PO__c, Original_Opportunity__r.Owner.FirstName, Original_Opportunity__r.Owner.LastName, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, Original_Customer_Signed_Date__c,Current_Sales_Order_Start_Date__c,NS_Subscription_Memo__c,BG_Contract_Date_migration__c,Next_Billing_Date__c, NS_Subscription_Start_Date__c,NS_Billing_Mode__c,NS_Termination_Method__c,BG_Opportunity_Number_s_migration__c,NS_Customer_Address__c,Last_Invoice_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c,NS_Specific_Invoice_Wording__c,Set_Tax_Combo_Override__c,NS_Customer_Ship_To_Address__c , Order_Sub_Type__c,Fixed_Billing_Date__c,Original_Contract__r.Contract_Expiry_Date__c,Original_Contract__r.Recurring_Fees_Start_Planned__c,Original_Contract__r.ContractTerm FROM Billing_Group__c LIMIT 1]; 
        Map<String, Integer> soType_counter_Map = new Map<String, Integer>();
        Map<String, List<SBQQ__Subscription__c>> ps_subs_map = new Map<String, List<SBQQ__Subscription__c>>();        
        soType_counter_Map = SO_SubscriptionsGrouping.sortbyProcess(bg);       
        ps_subs_map = SO_SubscriptionsGrouping.getSubsByTypeForPs(bg);
        // adding PS values to map
        for(String soType: ps_subs_map.keySet()){
            soType_counter_Map.put(soType, ps_subs_map.get(soType).size());
        }
        
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
        Map < String, NS_Project__c > soType_proj_map = SO_NSProjectHelper.createNSProject(soType_subId_map, temp_map, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(), SO_SalesOrderMapUtils.getNSProduct_map());      
        system.assertEquals(2, soType_proj_map.size(), '2 Projects one for ILF & PS Created');
        for(NS_Project__c proj: soType_proj_map.values()){
            if(proj.Project_Type__c.contains('ILF')){
                system.assertEquals('ILF - ILF', proj.Project_Type__c, 'Project Type of ILF - ILF Created');
            }
            
            if(proj.Project_Type__c.contains('PS')){
                system.assertEquals('PS - PS', proj.Project_Type__c, 'Project Type of PS - PS Created');
            }           
        }
        Sales_Order__c[] soList = SO_SalesOrderHelper.createSalesOrder(bg, soType_counter_Map, soType_proj_map, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSProduct_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(), 'ILF', temp_map, SO_SalesOrderMapUtils.getNsAccMap());
        
        SO_SalesOrderHelper.updateCustomerBillingSchedule(soList);
        //system.assertEquals('RLF', [SELECT Order_Type__c FROM Sales_Order__c].Order_Type__c, 'RLF Sales Order Created for given Billing Group');
        
        Map<String, List<SBQQ__Subscription__c>> soType_subs_map = new Map<String, List<SBQQ__Subscription__c>>();
        
        soType_subs_map =  SO_SubscriptionsGrouping.getSubsByType(soType_counter_Map, bg.Id);  
        // adding PS values to map
        for(String soType: ps_subs_map.keySet()){
            soType_subs_map.put(soType, ps_subs_map.get(soType));
        }
        Map<string, string> proj_obs_map = new Map<String, string>();
        for(NS_Project__c proj: soType_proj_map.values()){
            proj_obs_map.put(proj.Id, proj.Project_Type__c);
        }
        Test.startTest();
            SO_SalesOrderHelper.createSalesOrderItems(soList, soType_subs_map, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getRevScheduleMap(), SO_SalesOrderMapUtils.getIntIdOARevRuleMap(), SO_SalesOrderMapUtils.getIntIdOABillingRuleMap(), proj_obs_map, SO_SalesOrderMapUtils.getUPID());
        Test.stopTest();               
        System.assertEquals(4, [SELECT COUNT() FROM Sales_Order_Item__c], 'RLF Sales Order Item Created');
    }
    private static testMethod void test_createSalesOrderItems_With_EmptyList(){
        List<Sales_Order__c> soList = new List<Sales_Order__c>();
        Test.startTest();
        try {
            SO_SalesOrderHelper.createSalesOrderItems(soList, null, null, null, null, null, null, null);
        } catch( Exception e) {
            System.assert(true,  'Should throw exception');
        }
        Test.stopTest();               
    }
    private static testMethod void test_createSalesOrderItems_With_Null(){
        List<Sales_Order__c> soList = new List<Sales_Order__c>();
        Test.startTest();
        try {
            SO_SalesOrderHelper.createSalesOrderItems(null, null, null, null, null, null, null, null);
        } catch( Exception e) {
            System.assert(true,  'Should throw exception');
        }
        Test.stopTest();               
    }
    private static testMethod void test_updateHolidayPeriod(){
        Billing_Group__c bg = [SELECT Next_SO_generation_Date__c,Id, Name, Account_by_Sub__c,Original_Opportunity__c,Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.Credit_Controller__c,CurrencyIsoCode, Original_Contract__c, Original_Opportunity__r.CloseDate,Account_by_Sub__r.Account__r.PO_Required__c,Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate,Original_Contract__r.CustomerSignedDate,Original_Contract__r.Memo__c, Original_Opportunity__r.Customer_PO__c, Original_Opportunity__r.Owner.FirstName, Original_Opportunity__r.Owner.LastName, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, Original_Customer_Signed_Date__c,Current_Sales_Order_Start_Date__c,NS_Subscription_Memo__c,BG_Contract_Date_migration__c,Next_Billing_Date__c, NS_Subscription_Start_Date__c,NS_Billing_Mode__c,NS_Termination_Method__c,BG_Opportunity_Number_s_migration__c,NS_Customer_Address__c,Last_Invoice_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c,NS_Specific_Invoice_Wording__c,Set_Tax_Combo_Override__c,NS_Customer_Ship_To_Address__c , Order_Sub_Type__c,Fixed_Billing_Date__c,Original_Contract__r.Contract_Expiry_Date__c,Original_Contract__r.Recurring_Fees_Start_Planned__c,Original_Contract__r.ContractTerm FROM Billing_Group__c LIMIT 1]; 
        Map<String, Integer> soType_counter_Map = new Map<String, Integer>();
        Map<String, List<SBQQ__Subscription__c>> ps_subs_map = new Map<String, List<SBQQ__Subscription__c>>();        
        soType_counter_Map = SO_SubscriptionsGrouping.sortbyProcess(bg);       
        ps_subs_map = SO_SubscriptionsGrouping.getSubsByTypeForPs(bg);
        // adding PS values to map
        for(String soType: ps_subs_map.keySet()){
            soType_counter_Map.put(soType, 1);
        }
        Contract con = [SELECT Id, Name, Reccuring_Payment_Holiday__c, Recurring_Fees_Start_Planned__c FROM Contract LIMIT 1];
        con.Recurring_Fees_Start_Planned__c = system.today().addDays(7);
        update con;
        Map<String, List<SBQQ__Subscription__c>> subsByType_RLF =SO_SubscriptionsGrouping.getSubsByType_RLF(soType_counter_Map, bg.Id);
        System.assertEquals(null, bg.Next_Billing_Date__c,'Next_Billing_Date__c should be null');
        System.assertEquals(null, bg.Next_SO_generation_Date__c,'Next_Billing_Date__c should be null');
        System.assertEquals(null, bg.Last_Invoice_Date__c,'Last_Invoice_Date__c should be null');
        Test.startTest();
            SO_SalesOrderHelper.updateHolidayPeriod(subsByType_RLF, con);
        Test.stopTest(); 
        Billing_Group__c updatedBG = [select Last_Invoice_Date__c,Next_SO_generation_Date__c,Next_Billing_Date__c from Billing_Group__c where id =: bg.Id];
        System.assertNotEquals(null, updatedBG.Next_Billing_Date__c,'Next_Billing_Date__c should have been set');
        System.assertNotEquals(null, updatedBG.Next_SO_generation_Date__c,'Next_Billing_Date__c should have been set');
        System.assertNotEquals(null, updatedBG.Last_Invoice_Date__c,'Last_Invoice_Date__c should have been set');
    }
    private static testMethod void test_updateHolidayPeriod_With_EmptyList(){
        Billing_Group__c bg = [SELECT Next_SO_generation_Date__c,Id, Name, Account_by_Sub__c,Original_Opportunity__c,Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.Credit_Controller__c,CurrencyIsoCode, Original_Contract__c, Original_Opportunity__r.CloseDate,Account_by_Sub__r.Account__r.PO_Required__c,Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate,Original_Contract__r.CustomerSignedDate,Original_Contract__r.Memo__c, Original_Opportunity__r.Customer_PO__c, Original_Opportunity__r.Owner.FirstName, Original_Opportunity__r.Owner.LastName, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, Original_Customer_Signed_Date__c,Current_Sales_Order_Start_Date__c,NS_Subscription_Memo__c,BG_Contract_Date_migration__c,Next_Billing_Date__c, NS_Subscription_Start_Date__c,NS_Billing_Mode__c,NS_Termination_Method__c,BG_Opportunity_Number_s_migration__c,NS_Customer_Address__c,Last_Invoice_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c,NS_Specific_Invoice_Wording__c,Set_Tax_Combo_Override__c,NS_Customer_Ship_To_Address__c , Order_Sub_Type__c,Fixed_Billing_Date__c,Original_Contract__r.Contract_Expiry_Date__c,Original_Contract__r.Recurring_Fees_Start_Planned__c,Original_Contract__r.ContractTerm FROM Billing_Group__c LIMIT 1]; 
        Map<String, List<SBQQ__Subscription__c>> subsByType_RLF = new Map<String, List<SBQQ__Subscription__c>>();
        System.assertEquals(null, bg.Next_Billing_Date__c,'Next_Billing_Date__c should be null');
        System.assertEquals(null, bg.Next_SO_generation_Date__c,'Next_Billing_Date__c should be null');
        System.assertEquals(null, bg.Last_Invoice_Date__c,'Last_Invoice_Date__c should be null');
        Test.startTest();
            SO_SalesOrderHelper.updateHolidayPeriod(subsByType_RLF, null);
        Test.stopTest(); 
        Billing_Group__c updatedBG = [select Last_Invoice_Date__c,Next_SO_generation_Date__c,Next_Billing_Date__c from Billing_Group__c where id =: bg.Id];
        System.assertEquals(null, updatedBG.Next_Billing_Date__c,'Next_Billing_Date__c should be null');
        System.assertEquals(null, updatedBG.Next_SO_generation_Date__c,'Next_Billing_Date__c should be null');
        System.assertEquals(null, updatedBG.Last_Invoice_Date__c,'Last_Invoice_Date__c should be null');
    }
    private static testMethod void test_updateHolidayPeriod_With_Null(){
        Test.startTest();
        try {
            SO_SalesOrderHelper.updateHolidayPeriod(null, null);
        } catch (Exception e){
            System.assert(true,  'Should throw exception');
        }
        Test.stopTest(); 
    }

    private static testMethod void test_updateNextBillingDate(){
        Test.startTest();        
        List<SBQQ__Subscription__c> subsList = new List<SBQQ__Subscription__c>(); 
        Id contracId;
        for(SBQQ__Subscription__c sub: [SELECT Id, SBQQ__Contract__c, SBQQ__Quantity__c, Recurring_Sales_Order_Type__c, Billing_Group__c, Billing_Day__c, Billing_Month__c, SBQQ__BillingFrequency__c, Name FROM SBQQ__Subscription__c WHERE Recurring_Sales_Order_Type__c LIKE 'RLF%']){            
            contracId = sub.SBQQ__Contract__c;
            sub.Prorata_Days__c = 0;
            subsList.add(sub);
        }
        update subsList;
        
        Contract con = [SELECT Id, Recurring_Fees_Start_Planned__c FROM Contract WHERE Id =: contracId];
        con.Recurring_Fees_Start_Planned__c = system.today();
        update con;
        
        SO_SalesOrderHelper.updateNextBillingDate([SELECT Id FROM Billing_Group__c].Id);
        for (SBQQ__Subscription__c sub: [SELECT Id, SBQQ__BillingFrequency__c, SO_Generation_Advance__c, Next_SO_generation_Date__c, Billing_Day__c, Billing_Month__c, Next_Billing_Date__c, Billing_Group__c
                                         FROM SBQQ__Subscription__c WHERE Recurring_Sales_Order_Type__c LIKE 'RLF%'
                                        ]) {
                                            system.assertNotEquals(system.today(), sub.Next_Billing_Date__c, 'NExt Billign Date must be greater than today');
                                        }        
        Test.stopTest();
    }
    private static testMethod void test_updateNextBillingDate_With_Billing_Day_GT_1(){
        Test.startTest();        
        List<SBQQ__Subscription__c> subsList = new List<SBQQ__Subscription__c>(); 
        Id contracId;
        for(SBQQ__Subscription__c sub: [SELECT Id, SBQQ__Contract__c, SBQQ__Quantity__c, Recurring_Sales_Order_Type__c, Billing_Group__c, Billing_Day__c, Billing_Month__c, SBQQ__BillingFrequency__c, Name FROM SBQQ__Subscription__c WHERE Recurring_Sales_Order_Type__c LIKE 'RLF%']){            
            contracId = sub.SBQQ__Contract__c;
            sub.Prorata_Days__c = 0;
            sub.Billing_Day__c=2;
            subsList.add(sub);
        }
        update subsList;
        
        Contract con = [SELECT Id, Recurring_Fees_Start_Planned__c FROM Contract WHERE Id =: contracId];
        con.Recurring_Fees_Start_Planned__c = system.today();
        update con;
        
        SO_SalesOrderHelper.updateNextBillingDate([SELECT Id FROM Billing_Group__c].Id);
        for (SBQQ__Subscription__c sub: [SELECT Id, SBQQ__BillingFrequency__c, SO_Generation_Advance__c, Next_SO_generation_Date__c, Billing_Day__c, Billing_Month__c, Next_Billing_Date__c, Billing_Group__c
                                         FROM SBQQ__Subscription__c WHERE Recurring_Sales_Order_Type__c LIKE 'RLF%'
                                        ]) {
                                            system.assertNotEquals(system.today(), sub.Next_Billing_Date__c, 'NExt Billign Date must be greater than today');
                                        }        
        Test.stopTest();
    }
    private static testMethod void test_updateNextBillingDate_With_Invalid_Id(){
        Test.startTest();
            try{        
                SO_SalesOrderHelper.updateNextBillingDate([SELECT Id FROM SBQQ__Subscription__c limit 1].Id);
            } catch(Exception e){
                System.assert(true, 'Should throw exception');
            }
        Test.stopTest();
    }
    private static testMethod void test_calculateProrata(){
        Billing_Group__c bg = [SELECT Next_SO_generation_Date__c,Id, Name, Account_by_Sub__c,Original_Opportunity__c,Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.Credit_Controller__c,CurrencyIsoCode, Original_Contract__c, Original_Opportunity__r.CloseDate,Account_by_Sub__r.Account__r.PO_Required__c,Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate,Original_Contract__r.CustomerSignedDate,Original_Contract__r.Memo__c, Original_Opportunity__r.Customer_PO__c, Original_Opportunity__r.Owner.FirstName, Original_Opportunity__r.Owner.LastName, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, Original_Customer_Signed_Date__c,Current_Sales_Order_Start_Date__c,NS_Subscription_Memo__c,BG_Contract_Date_migration__c,Next_Billing_Date__c, NS_Subscription_Start_Date__c,NS_Billing_Mode__c,NS_Termination_Method__c,BG_Opportunity_Number_s_migration__c,NS_Customer_Address__c,Last_Invoice_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c,NS_Specific_Invoice_Wording__c,Set_Tax_Combo_Override__c,NS_Customer_Ship_To_Address__c , Order_Sub_Type__c,Fixed_Billing_Date__c,Original_Contract__r.Contract_Expiry_Date__c,Original_Contract__r.Recurring_Fees_Start_Planned__c,Original_Contract__r.ContractTerm FROM Billing_Group__c LIMIT 1]; 
        Map<String, Integer> soType_counter_Map = new Map<String, Integer>();
        Map<String, List<SBQQ__Subscription__c>> ps_subs_map = new Map<String, List<SBQQ__Subscription__c>>();        
        soType_counter_Map = SO_SubscriptionsGrouping.sortbyProcess(bg);       
        
        Contract con = [SELECT Id, Name, Reccuring_Payment_Holiday__c, Recurring_Fees_Start_Planned__c FROM Contract LIMIT 1];
        con.Recurring_Fees_Start_Planned__c = system.today().addDays(7);
        update con;
        System.assertEquals(null, bg.Next_Billing_Date__c,'Next_Billing_Date__c should be null');
        System.assertEquals(null, bg.Next_SO_generation_Date__c,'Next_Billing_Date__c should be null');
        System.assertEquals(null, bg.Last_Invoice_Date__c,'Last_Invoice_Date__c should be null');
        Test.startTest();
            SO_SalesOrderHelper.calculateProrata(SO_SubscriptionsGrouping.getSubsByType_RLF(soType_counter_Map, bg.Id), con);
        Test.stopTest();               
        Billing_Group__c updatedBG = [select Last_Invoice_Date__c,Next_SO_generation_Date__c,Next_Billing_Date__c from Billing_Group__c where id =: bg.Id];
        System.assertNotEquals(null, updatedBG.Next_Billing_Date__c,'Next_Billing_Date__c should have been set');
        System.assertNotEquals(null, updatedBG.Next_SO_generation_Date__c,'Next_Billing_Date__c should have been set');
        System.assertNotEquals(null, updatedBG.Last_Invoice_Date__c,'Last_Invoice_Date__c should have been set');
    }
    private static testMethod void test_calculateProrata_With_EmptyList(){
        Billing_Group__c bg = [SELECT Next_SO_generation_Date__c,Id, Name, Account_by_Sub__c,Original_Opportunity__c,Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.Credit_Controller__c,CurrencyIsoCode, Original_Contract__c, Original_Opportunity__r.CloseDate,Account_by_Sub__r.Account__r.PO_Required__c,Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate,Original_Contract__r.CustomerSignedDate,Original_Contract__r.Memo__c, Original_Opportunity__r.Customer_PO__c, Original_Opportunity__r.Owner.FirstName, Original_Opportunity__r.Owner.LastName, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, Original_Customer_Signed_Date__c,Current_Sales_Order_Start_Date__c,NS_Subscription_Memo__c,BG_Contract_Date_migration__c,Next_Billing_Date__c, NS_Subscription_Start_Date__c,NS_Billing_Mode__c,NS_Termination_Method__c,BG_Opportunity_Number_s_migration__c,NS_Customer_Address__c,Last_Invoice_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c,NS_Specific_Invoice_Wording__c,Set_Tax_Combo_Override__c,NS_Customer_Ship_To_Address__c , Order_Sub_Type__c,Fixed_Billing_Date__c,Original_Contract__r.Contract_Expiry_Date__c,Original_Contract__r.Recurring_Fees_Start_Planned__c,Original_Contract__r.ContractTerm FROM Billing_Group__c LIMIT 1]; 
        Map<String, List<SBQQ__Subscription__c>> soType_subs_map = new Map<String, List<SBQQ__Subscription__c>>();
        System.assertEquals(null, bg.Next_Billing_Date__c,'Next_Billing_Date__c should be null');
        System.assertEquals(null, bg.Next_SO_generation_Date__c,'Next_Billing_Date__c should be null');
        System.assertEquals(null, bg.Last_Invoice_Date__c,'Last_Invoice_Date__c should be null');
        Test.startTest();
            SO_SalesOrderHelper.calculateProrata(soType_subs_map, null);
        Test.stopTest();               
        Billing_Group__c updatedBG = [select Last_Invoice_Date__c,Next_SO_generation_Date__c,Next_Billing_Date__c from Billing_Group__c where id =: bg.Id];
        System.assertEquals(null, bg.Next_Billing_Date__c,'Next_Billing_Date__c should be null');
        System.assertEquals(null, bg.Next_SO_generation_Date__c,'Next_Billing_Date__c should be null');
        System.assertEquals(null, bg.Last_Invoice_Date__c,'Last_Invoice_Date__c should be null');
    }
    private static testMethod void test_calculateProrata_With_Null(){
        Test.startTest();
            try {
                SO_SalesOrderHelper.calculateProrata(null, null);
            }catch(Exception e){
                System.assert(true, 'Should throw exception');
            }
        Test.stopTest();               
    }
    
    private static testMethod void test_updateProrataCalculatedCheckBox(){
        SBQQ__Subscription__c sub = [select id from SBQQ__Subscription__c limit 1];
        Product2 prod = TestUtility.sampleProduct();
        prod.Product_Set__c = 'ARIS';
        insert prod;
        Sales_Order__c so = TestUtility.sampleSalesOrder();
        insert so;
        Sales_Order_Item__c soi = TestUtility.sampleSalesOrderItem(so.Id);
        soi.Subscription__c=sub.id;
        soi.NS_Item__c = prod.Id;
        soi.Name = 'test soi';
        soi.Description__c = 'test soi';
        insert soi;
        Test.startTest();
            SO_SalesOrderHelper.updateProrataCalculatedCheckBox([SELECT Id, Name, Sales_Order__c FROM Sales_Order_Item__c]);        
        Test.stopTest();
        SBQQ__Subscription__c dbSub= [SELECT Id,  Pro_Rata_Calculated__c FROM SBQQ__Subscription__c WHERE  id=:sub.id];
        System.assertEquals(true, dbSub.Pro_Rata_Calculated__c, 'Setting Pro_Rata_Calculated__c to TRUE');
    }

    private static testMethod void test_updateProrataCalculatedCheckBox_With_EmptyList(){
        Test.startTest();
            try {
                SO_SalesOrderHelper.updateProrataCalculatedCheckBox([SELECT Id, Name, Sales_Order__c FROM Sales_Order_Item__c]);        
                System.assert(true, 'Should NOT throw exception');
            } catch(Exception e){
            }
        Test.stopTest();               
    }
    private static testMethod void test_updateProrataCalculatedCheckBox_With_Null(){
        Test.startTest();
            try {
                SO_SalesOrderHelper.updateProrataCalculatedCheckBox(null);        
                System.assert(true, 'Should NOT throw exception');
            } catch(Exception e){
            }
        Test.stopTest();               
    }
    
    private static testMethod void test_updateBG_billingDate(){
        Billing_Group__c bg = [SELECT Next_SO_generation_Date__c,Id, Name, Account_by_Sub__c,Original_Opportunity__c,Original_Opportunity__r.CurrencyIsoCode, Account_by_Sub__r.Account__r.NS_Term__c, Account_by_Sub__r.Account__r.Credit_Controller__c,CurrencyIsoCode, Original_Contract__c, Original_Opportunity__r.CloseDate,Account_by_Sub__r.Account__r.PO_Required__c,Account_by_Sub__r.Invoice_Delivery_Post__c, Account_by_Sub__r.Invoice_Delivery_Email__c,Original_Opportunity__r.OwnerId, Original_Contract__r.StartDate,Original_Contract__r.CustomerSignedDate,Original_Contract__r.Memo__c, Original_Opportunity__r.Customer_PO__c, Original_Opportunity__r.Owner.FirstName, Original_Opportunity__r.Owner.LastName, Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, Customer_PO_Number__c, Original_Customer_Signed_Date__c,Current_Sales_Order_Start_Date__c,NS_Subscription_Memo__c,BG_Contract_Date_migration__c,Next_Billing_Date__c, NS_Subscription_Start_Date__c,NS_Billing_Mode__c,NS_Termination_Method__c,BG_Opportunity_Number_s_migration__c,NS_Customer_Address__c,Last_Invoice_Date__c, Reset_Next_Bill_Date__c,BG_Next_Invoice_Due_Date__c,NS_Specific_Invoice_Wording__c,Set_Tax_Combo_Override__c,NS_Customer_Ship_To_Address__c , Order_Sub_Type__c,Fixed_Billing_Date__c,Original_Contract__r.Contract_Expiry_Date__c,Original_Contract__r.Recurring_Fees_Start_Planned__c,Original_Contract__r.ContractTerm FROM Billing_Group__c LIMIT 1]; 
        System.assertEquals(null, bg.Next_Billing_Date__c,'Next_Billing_Date__c should be null');
        System.assertEquals(null, bg.Next_SO_generation_Date__c,'Next_Billing_Date__c should be null');
        System.assertEquals(null, bg.Last_Invoice_Date__c,'Last_Invoice_Date__c should be null');
        Test.startTest();
            SO_SalesOrderHelper.updateBG_billingDate(system.today().addMonths(3), system.today().addDays(-1), [SELECT ID From Billing_Group__c LIMIT 1].Id);
        Test.stopTest();               
        Billing_Group__c updatedBG = [select Last_Invoice_Date__c,Next_SO_generation_Date__c,Next_Billing_Date__c from Billing_Group__c where id =: bg.Id];
        System.assertNotEquals(null, updatedBG.Next_Billing_Date__c,'Next_Billing_Date__c should have been set');
        System.assertNotEquals(null, updatedBG.Next_SO_generation_Date__c,'Next_Billing_Date__c should have been set');
        System.assertNotEquals(null, updatedBG.Last_Invoice_Date__c,'Last_Invoice_Date__c should have been set');
    }
    private static testMethod void test_updateBG_billingDate_With_Invalid_Id(){
        Test.startTest();
        try{
            SO_SalesOrderHelper.updateBG_billingDate(system.today().addMonths(3), system.today().addDays(-1), [SELECT ID From SBQQ__Subscription__c LIMIT 1].Id);
        }catch(Exception e){
            System.assert(true, 'Should throw exception');
        }
        Test.stopTest();               
    }
    
    private static testMethod void test_updateBG_billingDate_With_Null(){
        Test.startTest();
        try{
            SO_SalesOrderHelper.updateBG_billingDate(null, null, null);
        }catch(Exception e){
            System.assert(true, 'Should throw exception');
        }
        Test.stopTest();               
    }
    
}