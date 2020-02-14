@isTest
public class PSPackage_ListInit_test {
    
    @testSetup static void setup(){
        Test.startTest();
        TestDataFactory.init_NS_maps();
        Account acc = TestDataFactory.createAccount('Test Account'); 
        Opportunity opp = TestDataFactory.createOpportunity(acc);
        
        Id bScheduleId = TestDataFactory.add_OppBillingSchedule(opp); 
        
        Billing_Entity__c billing1 = TestDataFactory.createBillingEntity();  // Inserts (1) Billing Entity
        
        Contract con = TestDataFactory.createContract(acc, opp); // Inserts Contract by linking Account + Opportunity
        con.Recurring_Fees_Start_Planned__c = system.today();
        update con;
        
        Billing_Group__c bGroup = TestDataFactory.createBillingGroup(con); // Inserts Billing Group with above Contract
        Acct_By_Sub__c  asub = New Acct_By_Sub__c(Account__c = acc.Id,NS_Internal_Id__c='123');
        insert asub;
        
        bGroup.Account_by_Sub__c = asub.Id;
        update bGroup;
        TestDataFactory.createPS_Subscription(con, bScheduleId, bGroup.Id); // Insertes (2) PS Subscriptions
        Id projId = TestDataFactory.createNSProject(true).Id;
        TestDataFactory.createVBSList(projId);
        TestDataFactory.createMileStones(projId, [SELECT Id FROM Opportunity_Billing_Schedule_Item__c LIMIT 1].Id);
                list<T_And_E_Items__c> teItemList = new list<T_And_E_Items__c>();
        T_And_E_Items__c te1 = new T_And_E_Items__c(Name = 'Test-FED: Reimbursable Expenses', Sales_Order_Type__c = 'FED', UPID__c = '5909901', Quantity__c = 1000, Rate__c = 0.1, OA_Billing_Rule_Internal_Id__c = '1');
        teItemList.add(te1);
        //T_And_E_Items__c te2 = new T_And_E_Items__c(Name = 'Test-PS: Expense Markup', Sales_Order_Type__c = 'PS', UPID__c = '5909904', Quantity__c = 10000, Rate__c = 0.1, OA_Billing_Rule_Internal_Id__c = '1', Rev_Rec_Schedule_Internal_Id__c = '37', OA_Rev_Rec_Rule_Internal_Id__c = '2');
        //teItemList.add(te2);
        T_And_E_Items__c te3 = new T_And_E_Items__c(Name = 'Test-PS: Reimbursable Expenses', Sales_Order_Type__c = 'PS', UPID__c = '5909903', Quantity__c = 10000, Rate__c = 0.1, OA_Billing_Rule_Internal_Id__c = '1', Rev_Rec_Schedule_Internal_Id__c = '37', OA_Rev_Rec_Rule_Internal_Id__c = '2');
        teItemList.add(te3);
        T_And_E_Items__c te4 = new T_And_E_Items__c(Name = 'Test-PSS: Reimbursable Expenses', Sales_Order_Type__c = 'PSS', UPID__c = '5909902', Quantity__c = 1000, Rate__c = 0.1, OA_Billing_Rule_Internal_Id__c = '1');
        teItemList.add(te4);
        insert teItemList;

        Test.stopTest();
    }

    
    private static testMethod void test_addNSProject(){
        Billing_Group__c bg = [SELECT Id, Original_Opportunity__c FROM Billing_Group__c LIMIT 1];
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(Billing_Group__c = bg.Id, Initial_Sales_Order_Type__c = 'PS - PS');
        Test.startTest(); 
          NS_Project__c proj = PSPackage_ListInit.addNSProject(sub, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(), SO_SalesOrderMapUtils.getNSProduct_map(), 'ILF');
        Test.stopTest();  
        System.assertEquals('ILF', proj.Project_Type__c, 'NS Project type should be ILF');
        System.assertEquals(bg.id, proj.Billing_Group__c, 'NS Project\'s  Billing_Group__c should be billing group id');
        System.assertEquals('Pending - PM', proj.OpenAir_Project_Stage__c, 'NS Project\'s  OpenAir_Project_Stage__c should be \'Pending - PM\'');
        System.assertEquals('In Progress', proj.NS_Project_Status__c, 'NS Project\'s  NS_Project_Status__c should be \'In Progress\'');
    }  
    private static testMethod void test_addNSProject_With_Null_OrderType(){
        Billing_Group__c bg = [SELECT Id, Original_Opportunity__c FROM Billing_Group__c LIMIT 1];
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(Billing_Group__c = bg.Id, Initial_Sales_Order_Type__c = 'PS - PS');
        Test.startTest(); 
          NS_Project__c proj = PSPackage_ListInit.addNSProject(sub, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(), SO_SalesOrderMapUtils.getNSProduct_map(), null);
        Test.stopTest();  
        System.assertEquals(null, proj.Project_Type__c, 'NS Project type should be ILF');
        System.assertEquals(bg.id, proj.Billing_Group__c, 'NS Project\'s  Billing_Group__c should be billing group id');
        System.assertEquals('Pending - PM', proj.OpenAir_Project_Stage__c, 'NS Project\'s  OpenAir_Project_Stage__c should be \'Pending - PM\'');
        System.assertEquals('In Progress', proj.NS_Project_Status__c, 'NS Project\'s  NS_Project_Status__c should be \'In Progress\'');
    }                                   
    private static testMethod void test_addNSProject_With_All_Null(){
      Test.startTest(); 
        try{
          NS_Project__c proj = PSPackage_ListInit.addNSProject(null, null, null, null, null);
        }catch(Exception e){
          System.assert(true,'Should throw exception');
        }
      Test.stopTest();  
    }                                   
    private static testMethod void test_addPSSalesOrder(){
      Billing_Group__c bg = retrieveBG();
      NS_Project__c proj = [SELECT 
                              Id,
                              Project_Cost_Centre__c,
                              Project_Product__c,
                              NS_Deferred_Revenue_Account_Internal_Id__c,
                              Deferred_Account_Type__c,
                              PS_Practice_Name__c,
                              PS_Practice_Unique_Code__c 
                            FROM 
                              NS_Project__c];
      Test.startTest();
        Sales_Order__c so = PSPackage_ListInit.addPSSalesOrder( bg, 
                                                                proj, 
                                                                SO_SalesOrderMapUtils.getNSCurrency_map(), 
                                                                'PS - PS', 
                                                                SO_SalesOrderMapUtils.getNsAccMap()); 
      Test.stopTest();
      System.assertEquals(proj.id, so.NS_Project__c, 'PS SO Created with NS Project');
      System.assertEquals('PS', so.Order_Type__c, 'NS Project\'s Order_Type__c should be \'PS\'');
      System.assertEquals('125', so.NS_Form_Id__c, 'NS Project\'s NS_Form_Id__c should be  \'125\'');
      System.assertEquals(true, so.CPQ_Billing__c, 'NS Project\'s CPQ_Billing__c should be true');
      System.assertEquals('PS - PS', so.Sub_Group_Type__c, 'NS Project\'s Sub_Group_Type__c should be  \'PS - PS\'');
    }
    private static testMethod void test_addPSSalesOrder_With_Null_Sub_Group_Type(){
      Billing_Group__c bg = retrieveBG();
      NS_Project__c proj = [SELECT 
                              Id,
                              Project_Cost_Centre__c,
                              Project_Product__c,
                              NS_Deferred_Revenue_Account_Internal_Id__c,
                              Deferred_Account_Type__c,
                              PS_Practice_Name__c,
                              PS_Practice_Unique_Code__c 
                            FROM 
                              NS_Project__c];
      Test.startTest();
        Sales_Order__c so = PSPackage_ListInit.addPSSalesOrder( bg, 
                                                                proj, 
                                                                SO_SalesOrderMapUtils.getNSCurrency_map(), 
                                                                null, 
                                                                SO_SalesOrderMapUtils.getNsAccMap()); 
      Test.stopTest();
      System.assertEquals(proj.id, so.NS_Project__c, 'PS SO Created with NS Project');
      System.assertEquals('PS', so.Order_Type__c, 'NS Project\'s Order_Type__c should be \'PS\'');
      System.assertEquals('125', so.NS_Form_Id__c, 'NS Project\'s NS_Form_Id__c should be  \'125\'');
      System.assertEquals(true, so.CPQ_Billing__c, 'NS Project\'s CPQ_Billing__c should be true');
      System.assertEquals(null, so.Sub_Group_Type__c, 'NS Project\'s Sub_Group_Type__c should be  \'PS - PS\'');
    }
    private static testMethod void test_addPSSalesOrder_With_All_Null(){
      Test.startTest();
      try{
        Sales_Order__c so = PSPackage_ListInit.addPSSalesOrder( null, 
                                                                null, 
                                                                null, 
                                                                null, 
                                                                null); 
      }catch(Exception e){
        System.assert(true,'Should throw exception');
      }
      Test.stopTest();
    }
           

    private static testMethod void test_addPSSalesOrderItem_With_LineItem_Process_Type_SVFP(){
        Billing_Group__c bg = retrieveBG();
        Sales_Order__c so = PSPackage_ListInit.addPSSalesOrder(bg,new NS_Project__c(), SO_SalesOrderMapUtils.getNSCurrency_map(), 'PS - PS', SO_SalesOrderMapUtils.getNsAccMap());          
        so.Order_Sub_Type__c='PS';
        Test.startTest();
          List<Sales_Order_Item__c> soItemList = PSPackage_ListInit.addPSSalesOrderItem(  new SBQQ__Subscription__c(LineItem_Process_Type__c = 'SVFP', 
                                                                                                                    Opportunity_Billing_Schedule__c = [seLect Id from Opportunity_Billing_Schedule__c LIMIT 1].Id,
                                                                                                                    ThirdParty_Costs_PO_Ccy__c = 10,Sold_Value__c = 10,Fair_Value__c = 10,
                                                                                                                    Reimbursable_Costs_Recovery_Value__c = 15,
                                                                                                                    Reimbursable_Costs_Estimate__c  = 10,
                                                                                                                    ThirdParty_Contractor_Cost_Sold_Ccy__c = 10,
                                                                                                                    ThirdParty_Costs_Sold_Ccy__c = 10,
                                                                                                                    Unrecoverable_Costs__c = 10,
                                                                                                                    Internal_Costs__c = 10, 
                                                                                                                    Comm_Man_Price__c = 10,
                                                                                                                    SBQQ__UnitCost__c = 10,
                                                                                                                    Contractor_Hours_Total__c = 10,
                                                                                                                    NonBillable_Hours_Total__c = 10,
                                                                                                                    Travel_Hours_Total__c = 10,
                                                                                                                    Total_Chargeable_Hours__c = 10),
                                                                                          1, 
                                                                                          so, 
                                                                                          SO_SalesOrderMapUtils.getRevScheduleMap(), 
                                                                                          SO_SalesOrderMapUtils.getIntIdOARevRuleMap(), 
                                                                                          SO_SalesOrderMapUtils.getIntIdOABillingRuleMap(), 
                                                                                          SO_SalesOrderMapUtils.getUPID() );
        
        Test.stopTest();
        System.assertEquals(2, soItemList.size(), 'Should create Sales_Order_Item__c list');
    }
    private static testMethod void test_addPSSalesOrderItem_With_LineItem_Process_Type_SVTM(){
        Billing_Group__c bg = retrieveBG();
        Sales_Order__c so = PSPackage_ListInit.addPSSalesOrder(bg,new NS_Project__c(), SO_SalesOrderMapUtils.getNSCurrency_map(), 'PS - PS', SO_SalesOrderMapUtils.getNsAccMap());          
        Test.startTest();
          List<Sales_Order_Item__c> soItemList = PSPackage_ListInit.addPSSalesOrderItem(  new SBQQ__Subscription__c(LineItem_Process_Type__c = 'SVTM', 
                                                                                                                    Opportunity_Billing_Schedule__c = [seLect Id from Opportunity_Billing_Schedule__c LIMIT 1].Id,
                                                                                                                    ThirdParty_Costs_PO_Ccy__c = 10,Sold_Value__c = 10,Fair_Value__c = 10,
                                                                                                                    Reimbursable_Costs_Recovery_Value__c = 15,
                                                                                                                    Reimbursable_Costs_Estimate__c  = 10,
                                                                                                                    ThirdParty_Contractor_Cost_Sold_Ccy__c = 10,
                                                                                                                    ThirdParty_Costs_Sold_Ccy__c = 10,
                                                                                                                    Unrecoverable_Costs__c = 10,
                                                                                                                    Internal_Costs__c = 10, 
                                                                                                                    Comm_Man_Price__c = 10,
                                                                                                                    SBQQ__UnitCost__c = 10,
                                                                                                                    Contractor_Hours_Total__c = 10,
                                                                                                                    NonBillable_Hours_Total__c = 10,
                                                                                                                    Travel_Hours_Total__c = 10,
                                                                                                                    Total_Chargeable_Hours__c = 10),
                                                                                          2, 
                                                                                          so, 
                                                                                          SO_SalesOrderMapUtils.getRevScheduleMap(), 
                                                                                          SO_SalesOrderMapUtils.getIntIdOARevRuleMap(), 
                                                                                          SO_SalesOrderMapUtils.getIntIdOABillingRuleMap(), 
                                                                                          SO_SalesOrderMapUtils.getUPID() );
        Test.stopTest();
        System.assertEquals(1, soItemList.size(), 'Should create Sales_Order_Item__c list');
    }

    private static testMethod void test_addPSSalesOrderItem_With_All_Null(){
        Test.startTest();
          try{
            List<Sales_Order_Item__c> soItemList = PSPackage_ListInit.addPSSalesOrderItem(  null,
                                                                                            null, 
                                                                                            null, 
                                                                                            null, 
                                                                                            null, 
                                                                                            null, 
                                                                                            null);
          }catch(Exception e){
            System.assert(true,'Should throw exception');
          }
        Test.stopTest();
    }
    private static Billing_Group__c retrieveBG() {
        Billing_Group__c bg = [ SELECT 
                                  Id, 
                                  Name, 
                                  Account_by_Sub__c,
                                  Original_Opportunity__c,
                                  Original_Opportunity__r.CurrencyIsoCode, 
                                  Account_by_Sub__r.Account__r.NS_Term__c, 
                                  Account_by_Sub__r.Account__r.Credit_Controller__c,
                                  CurrencyIsoCode, Original_Contract__c, 
                                  Original_Opportunity__r.CloseDate,Account_by_Sub__r.Account__r.PO_Required__c,
                                  Account_by_Sub__r.Invoice_Delivery_Post__c, 
                                  Account_by_Sub__r.Invoice_Delivery_Email__c,
                                  Original_Opportunity__r.OwnerId, 
                                  Original_Contract__r.StartDate,
                                  Original_Contract__r.CustomerSignedDate,
                                  Original_Contract__r.Memo__c, 
                                  Original_Opportunity__r.Customer_PO__c, 
                                  Original_Opportunity__r.Owner.FirstName, 
                                  Original_Opportunity__r.Owner.LastName, 
                                  Original_Opportunity__r.Owner.NS_Employee_Internal_Id__c, 
                                  Customer_PO_Number__c, 
                                  Original_Customer_Signed_Date__c,
                                  Current_Sales_Order_Start_Date__c,
                                  NS_Subscription_Memo__c,
                                  BG_Contract_Date_migration__c,
                                  Next_Billing_Date__c, 
                                  NS_Subscription_Start_Date__c,
                                  NS_Billing_Mode__c,
                                  NS_Termination_Method__c,
                                  BG_Opportunity_Number_s_migration__c,
                                  NS_Customer_Address__c,
                                  Last_Invoice_Date__c, 
                                  Reset_Next_Bill_Date__c,
                                  BG_Next_Invoice_Due_Date__c,
                                  NS_Specific_Invoice_Wording__c,
                                  Set_Tax_Combo_Override__c,
                                  NS_Customer_Ship_To_Address__c , 
                                  Order_Sub_Type__c,Fixed_Billing_Date__c,
                                  Original_Contract__r.Contract_Expiry_Date__c,
                                  Original_Contract__r.Recurring_Fees_Start_Planned__c,
                                  Original_Contract__r.ContractTerm 
                                FROM 
                                  Billing_Group__c 
                                LIMIT 1 ]; 
        return bg;
    }

}