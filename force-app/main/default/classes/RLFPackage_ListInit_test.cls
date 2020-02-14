@isTest
public class RLFPackage_ListInit_test {
    
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
    
    private static testMethod  void test_addRLFSalesOrder_With_Current_Sales_Order_Start_Date(){
        Billing_Group__c bg = retrieveBG(); 
        SBQQ__Subscription__c sub = retrieveSubscription();
        Test.startTest();
            Sales_Order__c so = RLFPackage_ListInit.addRLFSalesOrder(bg, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSProduct_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(),'RLF', sub);
        Test.stopTest();
        System.assertEquals(bg.Original_Opportunity__c, so.Opportunity__c, 'Sales order opportunity should be populated with BG opportunity');
        System.assertEquals(bg.id, so.Billing_Group__c, 'Sales order billing group should be populated with BG');
        System.assertEquals(bg.Name, so.SFDC_Billing_Group__c, 'Sales SFDC_Billing_Group__c should be populated with BG Name');
        System.assertEquals(bg.Account_by_Sub__c, so.Bill_To_Customer__c, 'Sales order Bill_To_Customer__c should be populated with BG Account_by_Sub__c');
        System.assertEquals('Pending Approval', so.Order_Status__c, 'Sales order Order_Status__c should be \'Pending Approval\'');
        System.assertEquals('RLF', so.Order_Type__c, 'Sales order Order_Type__c should be  \'RLF\'');
        System.assertEquals(100, so.Contribution__c, 'Sales order Contribution__c should be \'100\'');
        System.assertEquals('Sales Rep', so.Sales_Role__c, 'Sales order Sales_Role__c should be \'Sales Rep\'');
        System.assertEquals('No', so.Fixed_price_associatd_with_this_contract__c, 'Sales order Fixed_price_associatd_with_this_contract__c should be \'No\'');
        System.assertEquals('Open', so.Subsription_Status__c, 'Sales order Subsription_Status__c should be \'Open\'');
        System.assertEquals('1', so.Time_Zone__c, 'Sales order Time_Zone__c should be \'1\'');
        System.assertEquals('RLF', so.Order_Sub_Type__c, 'Sales order Order_Sub_Type__c should be \'RLF\'');
        System.assertEquals('Invoice', so.Transaction_Type__c, 'Sales order Transaction_Type__c should be \'Invoice\'');
        System.assertEquals('154', so.NS_Form_Id__c, 'Sales order NS_Form_Id__c should be \'154\'');
        System.assertEquals('154', so.NS_Form_Id__c, 'Sales order NS_Form_Id__c should be \'154\'');
        System.assertEquals(bg.Current_Sales_Order_Start_Date__c, so.NS_Contract_Date__c, 'Sales order NS_Contract_Date__c should be Billing groupd\' Current_Sales_Order_Start_Date__c\'');
    }
    
    private static testMethod  void test_addRLFSalesOrder_With_Original_Customer_Signed_Date(){
        Contract con = [select id from Contract ];
        con.CustomerSignedDate=System.today();
        update con;
        Billing_Group__c bg = retrieveBG(); 
                
        bg.Current_Sales_Order_Start_Date__c=null;
        update bg;

        SBQQ__Subscription__c sub = retrieveSubscription();
           Test.startTest();
        Sales_Order__c so = RLFPackage_ListInit.addRLFSalesOrder(bg, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSProduct_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(),'RLF', sub);
        Test.stopTest();
        System.assertEquals(bg.Original_Opportunity__c, so.Opportunity__c, 'Sales order opportunity should be populated with BG opportunity');
        System.assertEquals(bg.id, so.Billing_Group__c, 'Sales order billing group should be populated with BG');
        System.assertEquals(bg.Name, so.SFDC_Billing_Group__c, 'Sales SFDC_Billing_Group__c should be populated with BG Name');
        System.assertEquals(bg.Account_by_Sub__c, so.Bill_To_Customer__c, 'Sales order Bill_To_Customer__c should be populated with BG Account_by_Sub__c');
        System.assertEquals('Pending Approval', so.Order_Status__c, 'Sales order Order_Status__c should be \'Pending Approval\'');
        System.assertEquals('RLF', so.Order_Type__c, 'Sales order Order_Type__c should be  \'RLF\'');
        System.assertEquals(100, so.Contribution__c, 'Sales order Contribution__c should be \'100\'');
        System.assertEquals('Sales Rep', so.Sales_Role__c, 'Sales order Sales_Role__c should be \'Sales Rep\'');
        System.assertEquals('No', so.Fixed_price_associatd_with_this_contract__c, 'Sales order Fixed_price_associatd_with_this_contract__c should be \'No\'');
        System.assertEquals('Open', so.Subsription_Status__c, 'Sales order Subsription_Status__c should be \'Open\'');
        System.assertEquals('1', so.Time_Zone__c, 'Sales order Time_Zone__c should be \'1\'');
        System.assertEquals('RLF', so.Order_Sub_Type__c, 'Sales order Order_Sub_Type__c should be \'RLF\'');
        System.assertEquals('Invoice', so.Transaction_Type__c, 'Sales order Transaction_Type__c should be \'Invoice\'');
        System.assertEquals('154', so.NS_Form_Id__c, 'Sales order NS_Form_Id__c should be \'154\'');
        System.assertEquals(con.CustomerSignedDate, so.NS_Contract_Date__c, 'Sales order NS_Contract_Date__c should be Contract\' CustomerSignedDate\'');
    }
    private static testMethod  void test_addRLFSalesOrder_With_BG_Contract_Date_migration(){
Billing_Group__c bg = retrieveBG(); 
                
        bg.Current_Sales_Order_Start_Date__c=null;
        update bg;

        SBQQ__Subscription__c sub = retrieveSubscription();
        Test.startTest();
            Sales_Order__c so = RLFPackage_ListInit.addRLFSalesOrder(bg, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSProduct_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(),'RLF', sub);
        Test.stopTest();
        System.assertEquals(bg.Original_Opportunity__c, so.Opportunity__c, 'Sales order opportunity should be populated with BG opportunity');
        System.assertEquals(bg.id, so.Billing_Group__c, 'Sales order billing group should be populated with BG');
        System.assertEquals(bg.Name, so.SFDC_Billing_Group__c, 'Sales SFDC_Billing_Group__c should be populated with BG Name');
        System.assertEquals(bg.Account_by_Sub__c, so.Bill_To_Customer__c, 'Sales order Bill_To_Customer__c should be populated with BG Account_by_Sub__c');
        System.assertEquals('Pending Approval', so.Order_Status__c, 'Sales order Order_Status__c should be \'Pending Approval\'');
        System.assertEquals('RLF', so.Order_Type__c, 'Sales order Order_Type__c should be  \'RLF\'');
        System.assertEquals(100, so.Contribution__c, 'Sales order Contribution__c should be \'100\'');
        System.assertEquals('Sales Rep', so.Sales_Role__c, 'Sales order Sales_Role__c should be \'Sales Rep\'');
        System.assertEquals('No', so.Fixed_price_associatd_with_this_contract__c, 'Sales order Fixed_price_associatd_with_this_contract__c should be \'No\'');
        System.assertEquals('Open', so.Subsription_Status__c, 'Sales order Subsription_Status__c should be \'Open\'');
        System.assertEquals('1', so.Time_Zone__c, 'Sales order Time_Zone__c should be \'1\'');
        System.assertEquals('RLF', so.Order_Sub_Type__c, 'Sales order Order_Sub_Type__c should be \'RLF\'');
        System.assertEquals('Invoice', so.Transaction_Type__c, 'Sales order Transaction_Type__c should be \'Invoice\'');
        System.assertEquals('154', so.NS_Form_Id__c, 'Sales order NS_Form_Id__c should be \'154\'');
        System.assertEquals(bg.BG_Contract_Date_migration__c, so.NS_Contract_Date__c, 'Sales order NS_Contract_Date__c should be BG\' BG_Contract_Date_migration__c\'');
    }
    
    
    private static testMethod  void test_addRLFSalesOrderItem(){
        Billing_Group__c bg = retrieveBG(); 
        SBQQ__Subscription__c sub = retrieveSubscription();
        Sales_Order__c so = RLFPackage_ListInit.addRLFSalesOrder(bg, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSProduct_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(),'RLF', sub);
        insert so;
        
        System.assertEquals('RLF', [SELECT Order_Type__c FROM Sales_Order__c].Order_Type__c, 'RLF Sales Order Created for given Billing Group');
        Test.startTest();
            Sales_Order_Item__c soi = RLFPackage_ListInit.addRLFSalesOrderItem(sub, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getRevScheduleMap(), 1, so);    
        Test.stopTest();
        System.assertEquals(so.id, soi.Sales_Order__c, 'Sales order should be on Sales order item');
        System.assertEquals(sub.Recurring_Sovos_Code__c, soi.Tax_Code__c, 'Sales order item tax code should be on subscription Recurring_Sovos_Code__c');
        System.assertEquals(sub.id, soi.Subscription__c, 'Sales order item should have subscription');
        System.assertEquals(sub.Next_Billing_Date__c - 1, soi.End_Date__c, 'Sales order item End_Date__c should be set');
    }
    private static testMethod  void test_addRLFSalesOrderItem_With_BillingFrequency_Biennial(){
        Billing_Group__c bg = retrieveBG(); 
        SBQQ__Subscription__c sub = retrieveSubscription();
        Sales_Order__c so = RLFPackage_ListInit.addRLFSalesOrder(bg, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSProduct_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(),'RLF', sub);
        insert so;
        
        System.assertEquals('RLF', [SELECT Order_Type__c FROM Sales_Order__c].Order_Type__c, 'RLF Sales Order Created for given Billing Group');
        sub.SBQQ__BillingFrequency__c='Biennial';
        sub.Prorata_Days__c=0;
        Test.startTest();
            Sales_Order_Item__c soi = RLFPackage_ListInit.addRLFSalesOrderItem(sub, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getRevScheduleMap(), 1, so);    
        Test.stopTest();
        System.assertEquals(so.id, soi.Sales_Order__c, 'Sales order should be on Sales order item');
        System.assertEquals(sub.Recurring_Sovos_Code__c, soi.Tax_Code__c, 'Sales order item tax code should be on subscription Recurring_Sovos_Code__c');
        System.assertEquals(sub.id, soi.Subscription__c, 'Sales order item should have subscription');
        System.assertEquals(soi.Start_Date__c.addYears(2) -1, soi.End_Date__c, 'Sales order item End_Date__c should be set');
    }
    private static testMethod  void test_addRLFSalesOrderItem_With_BillingFrequency_Triennial(){
        Billing_Group__c bg = retrieveBG(); 
        SBQQ__Subscription__c sub = retrieveSubscription();
        Sales_Order__c so = RLFPackage_ListInit.addRLFSalesOrder(bg, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSProduct_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(),'RLF', sub);
        insert so;
        
        System.assertEquals('RLF', [SELECT Order_Type__c FROM Sales_Order__c].Order_Type__c, 'RLF Sales Order Created for given Billing Group');
        sub.SBQQ__BillingFrequency__c='Triennial';
        sub.Prorata_Days__c=0;
        Test.startTest();
            Sales_Order_Item__c soi = RLFPackage_ListInit.addRLFSalesOrderItem(sub, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getRevScheduleMap(), 1, so);    
        Test.stopTest();
        System.assertEquals(so.id, soi.Sales_Order__c, 'Sales order should be on Sales order item');
        System.assertEquals(sub.Recurring_Sovos_Code__c, soi.Tax_Code__c, 'Sales order item tax code should be on subscription Recurring_Sovos_Code__c');
        System.assertEquals(sub.id, soi.Subscription__c, 'Sales order item should have subscription');
        System.assertEquals(soi.Start_Date__c.addYears(3) -1, soi.End_Date__c, 'Sales order item End_Date__c should be set');
    }
    private static testMethod  void test_addRLFSalesOrderItem_With_BillingFrequency_Quinquennial(){
        Billing_Group__c bg = retrieveBG(); 
        SBQQ__Subscription__c sub = retrieveSubscription();
        Sales_Order__c so = RLFPackage_ListInit.addRLFSalesOrder(bg, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSProduct_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(),'RLF', sub);
        insert so;
        
        System.assertEquals('RLF', [SELECT Order_Type__c FROM Sales_Order__c].Order_Type__c, 'RLF Sales Order Created for given Billing Group');
        sub.SBQQ__BillingFrequency__c='Quinquennial';
        sub.Prorata_Days__c=0;
        Test.startTest();
            Sales_Order_Item__c soi = RLFPackage_ListInit.addRLFSalesOrderItem(sub, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getRevScheduleMap(), 1, so);    
        Test.stopTest();
        System.assertEquals(so.id, soi.Sales_Order__c, 'Sales order should be on Sales order item');
        System.assertEquals(sub.Recurring_Sovos_Code__c, soi.Tax_Code__c, 'Sales order item tax code should be on subscription Recurring_Sovos_Code__c');
        System.assertEquals(sub.id, soi.Subscription__c, 'Sales order item should have subscription');
        System.assertEquals(soi.Start_Date__c.addYears(5) -1, soi.End_Date__c, 'Sales order item End_Date__c should be set');
    }
   private static testMethod void test_addRLFSalesOrderItem_With_Pro_Rata_Calculated(){
        Billing_Group__c bg = retrieveBG(); 
        SBQQ__Subscription__c sub = retrieveSubscription();

        Sales_Order__c so = RLFPackage_ListInit.addRLFSalesOrder(bg, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSProduct_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(),'RLF', sub);
        insert so;
        sub.Pro_Rata_Calculated__c=true;
        System.assertEquals('RLF', [SELECT Order_Type__c FROM Sales_Order__c].Order_Type__c, 'RLF Sales Order Created for given Billing Group');
        Test.startTest();
            Sales_Order_Item__c soi = RLFPackage_ListInit.addRLFSalesOrderItem(sub, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getRevScheduleMap(), 1, so);    
        Test.stopTest();
        System.assertEquals(so.id, soi.Sales_Order__c, 'Sales order should be on Sales order item');
        System.assertEquals(sub.Recurring_Sovos_Code__c, soi.Tax_Code__c, 'Sales order item tax code should be on subscription Recurring_Sovos_Code__c');
        System.assertEquals(sub.id, soi.Subscription__c, 'Sales order item should have subscription');
        System.assertEquals(sub.SBQQ__Product__r.Name, soi.Name, 'Sales order  should have product name');
    }
    private static testMethod  void test_addRLFSalesOrderItem_With_Pro_Rata_Calculated_Biennial(){
        Billing_Group__c bg = retrieveBG(); 
        SBQQ__Subscription__c sub = retrieveSubscription();

        Sales_Order__c so = RLFPackage_ListInit.addRLFSalesOrder(bg, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSProduct_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(),'RLF', sub);
        insert so;
        sub.SBQQ__BillingFrequency__c='Biennial';
        sub.Prorata_Days__c=0;
        sub.Pro_Rata_Calculated__c=true;
        System.assertEquals('RLF', [SELECT Order_Type__c FROM Sales_Order__c].Order_Type__c, 'RLF Sales Order Created for given Billing Group');
        Test.startTest();
            Sales_Order_Item__c soi = RLFPackage_ListInit.addRLFSalesOrderItem(sub, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getRevScheduleMap(), 1, so);    
        Test.stopTest();
        System.assertEquals(so.id, soi.Sales_Order__c, 'Sales order should be on Sales order item');
        System.assertEquals(sub.Recurring_Sovos_Code__c, soi.Tax_Code__c, 'Sales order item tax code should be on subscription Recurring_Sovos_Code__c');
        System.assertEquals(sub.id, soi.Subscription__c, 'Sales order item should have subscription');
        System.assertEquals(sub.SBQQ__Product__r.Name, soi.Name, 'Sales order  should have product name');
        System.assertEquals(sub.Next_Billing_Date__c.addYears(2) -1, soi.End_Date__c, 'Sales order item End_Date__c should be set');
    }
    private static testMethod  void test_addRLFSalesOrderItem_With_Pro_Rata_Calculated_Triennial(){
        Billing_Group__c bg = retrieveBG(); 
        SBQQ__Subscription__c sub = retrieveSubscription();

        Sales_Order__c so = RLFPackage_ListInit.addRLFSalesOrder(bg, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSProduct_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(),'RLF', sub);
        insert so;
        sub.Pro_Rata_Calculated__c=true;
        sub.SBQQ__BillingFrequency__c='Triennial';
        sub.Prorata_Days__c=0;
        System.assertEquals('RLF', [SELECT Order_Type__c FROM Sales_Order__c].Order_Type__c, 'RLF Sales Order Created for given Billing Group');
        Test.startTest();
            Sales_Order_Item__c soi = RLFPackage_ListInit.addRLFSalesOrderItem(sub, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getRevScheduleMap(), 1, so);    
        Test.stopTest();
        System.assertEquals(so.id, soi.Sales_Order__c, 'Sales order should be on Sales order item');
        System.assertEquals(sub.Recurring_Sovos_Code__c, soi.Tax_Code__c, 'Sales order item tax code should be on subscription Recurring_Sovos_Code__c');
        System.assertEquals(sub.id, soi.Subscription__c, 'Sales order item should have subscription');
        System.assertEquals(sub.SBQQ__Product__r.Name, soi.Name, 'Sales order  should have product name');
        System.assertEquals(sub.Next_Billing_Date__c.addYears(3) -1, soi.End_Date__c, 'Sales order item End_Date__c should be set');
    }
    private static testMethod  void test_addRLFSalesOrderItem_With_Pro_Rata_Calculated_Quinquennial(){
        Billing_Group__c bg = retrieveBG(); 
        SBQQ__Subscription__c sub = retrieveSubscription();

        Sales_Order__c so = RLFPackage_ListInit.addRLFSalesOrder(bg, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSProduct_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(),'RLF', sub);
        insert so;
        sub.Pro_Rata_Calculated__c=true;
        sub.SBQQ__BillingFrequency__c='Quinquennial';
        sub.Prorata_Days__c=0;
        System.assertEquals('RLF', [SELECT Order_Type__c FROM Sales_Order__c].Order_Type__c, 'RLF Sales Order Created for given Billing Group');
        Test.startTest();
            Sales_Order_Item__c soi = RLFPackage_ListInit.addRLFSalesOrderItem(sub, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getRevScheduleMap(), 1, so);    
        Test.stopTest();
        System.assertEquals(so.id, soi.Sales_Order__c, 'Sales order should be on Sales order item');
        System.assertEquals(sub.Recurring_Sovos_Code__c, soi.Tax_Code__c, 'Sales order item tax code should be on subscription Recurring_Sovos_Code__c');
        System.assertEquals(sub.id, soi.Subscription__c, 'Sales order item should have subscription');
        System.assertEquals(sub.SBQQ__Product__r.Name, soi.Name, 'Sales order  should have product name');
        System.assertEquals(sub.Next_Billing_Date__c.addYears(5) -1, soi.End_Date__c, 'Sales order item End_Date__c should be set');
    }
    private static testMethod void testGetProrataFactor_Quinquennial() {
        SBQQ__Subscription__c sub = retrieveSubscription();
        sub.SBQQ__BillingFrequency__c='Quinquennial';
        Test.startTest();
            Double result = RLFPackage_ListInit.getProrataFactor(sub);
        Test.stopTest();
        System.assertEquals(0.0034223134839151265, result);
    }
    private static testMethod void testGetProrataFactor_Triennial() {
        SBQQ__Subscription__c sub = retrieveSubscription();
        sub.SBQQ__BillingFrequency__c='Triennial';
        Test.startTest();
            Double result = RLFPackage_ListInit.getProrataFactor(sub);
        Test.stopTest();
        System.assertEquals(0.004562043795620438, result);
    }
    private static testMethod void testGetProrataFactor_Biennial() {
        SBQQ__Subscription__c sub = retrieveSubscription();
        sub.SBQQ__BillingFrequency__c='Biennial';
        Test.startTest();
            Decimal result = RLFPackage_ListInit.getProrataFactor(sub);
        Test.stopTest();
        system.assert(result<0.007);
         system.assert(result>0.006);
    }
    private static testMethod void testGetProrataFactor_Annual() {
        SBQQ__Subscription__c sub = retrieveSubscription();
        sub.SBQQ__BillingFrequency__c='Annual';
        Test.startTest();
            Double result = RLFPackage_ListInit.getProrataFactor(sub);
        Test.stopTest();
        System.assertEquals(0.0136986301369863, result);
    }
    private static testMethod void testGetProrataFactor_Annual_With_Null_RF_Start_Planned_Date() {
        SBQQ__Subscription__c sub = retrieveSubscription();
        sub.SBQQ__BillingFrequency__c='Annual';
        sub.RF_Start_Planned_Date__c=null;
        Test.startTest();
            Double result = RLFPackage_ListInit.getProrataFactor(sub);
        Test.stopTest();
        System.assertEquals(0.0136986301369863, result);
    }
    private static testMethod void testGetProrataFactor_Annual_Pro_Rata_Calculated() {
        SBQQ__Subscription__c sub = retrieveSubscription();
        sub.SBQQ__BillingFrequency__c='Annual';
        sub.Pro_Rata_Calculated__c=true;
        Test.startTest();
            Double result = RLFPackage_ListInit.getProrataFactor(sub);
        Test.stopTest();
        System.assertEquals(0.0136986301369863, result);
    }
    private static testMethod void testGetProrataFactor_Semiannual() {
        SBQQ__Subscription__c sub = retrieveSubscription();
        sub.SBQQ__BillingFrequency__c='Semiannual';
        Test.startTest();
            decimal result = RLFPackage_ListInit.getProrataFactor(sub);
        Test.stopTest();
        system.assert(result<0.03);
         system.assert(result>0.02);
    }
    private static testMethod void testGetProrataFactor_Quarterly() {
        SBQQ__Subscription__c sub = retrieveSubscription();
        sub.SBQQ__BillingFrequency__c='Quarterly';
        Test.startTest();
            Double result = RLFPackage_ListInit.getProrataFactor(sub);
        Test.stopTest();
            system.assert(result<0.06);
         system.assert(result>0.05); 
    }
    private static testMethod void testGetProrataFactor_Monthly() {
        SBQQ__Subscription__c sub = retrieveSubscription();
        sub.SBQQ__BillingFrequency__c='Monthly';
        Test.startTest();
            decimal result = RLFPackage_ListInit.getProrataFactor(sub);
        Test.stopTest();
        system.assert(result.setscale(3)<0.2);
         system.assert(result.setscale(3)>0.15); 
    }
    
   private static testMethod void testGetDaysInYear_With_LeapYear() {
        Date dt = System.today();
        Integer i = 0;
        while(true) {
            if(Date.isLeapYear(dt.year())){
                break;
            }
            dt = dt.addYears(i);
            i++;
        }
        Test.startTest();
            Double result = RLFPackage_ListInit.getDaysInYear(dt);
        Test.stopTest();
         System.assertEquals(366, result);
    }
    private static testMethod void testGetDaysInYear() {
        Date dt = System.today();
        Integer i = 0;
        while(true) {
            if(Date.isLeapYear(dt.year())){
                break;
            }
            dt = dt.addYears(i);
            i++;
        }
        dt = dt.addYears(1);
        Test.startTest();
            Double result = RLFPackage_ListInit.getDaysInYear(dt);
        Test.stopTest();
         System.assertEquals(365, result);
    }
    private static testMethod void test_calculateProrata(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        SBQQ__Subscription__c[] subs = [SELECT Id, Name, Pro_Rata_Calculated__c, Last_Prorata_required__c, RF_Start_Planned_Date__c, SBQQ__BillingFrequency__c, SBQQ__StartDate__c, Billing_Day__c, Billing_Month__c,SBQQ__BillingType__c, Next_SO_generation_Date__c, SO_Generation_Advance__c, Next_Billing_Date__c FROM SBQQ__Subscription__c];
        subs[3].RF_Start_Planned_Date__c = null;
        update subs[3]; 
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        Test.startTest();
            RLFPackage_ListInit.calculateProrata(bg_subList_Map);
        Test.stopTest();
        System.assertEquals(100, [SELECT SBQQ__NetPrice__c FROM SBQQ__Subscription__c LIMIT 1].SBQQ__NetPrice__c, 'Calculate Prorata amount');
    }

    
    private static testMethod  void test_calculateProrata_With_Empty_Map(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        Test.startTest();
            RLFPackage_ListInit.calculateProrata(bg_subList_Map);
        Test.stopTest();
        System.assertEquals(100, [SELECT SBQQ__NetPrice__c FROM SBQQ__Subscription__c LIMIT 1].SBQQ__NetPrice__c, 'Calculate Prorata amount');
    }
    private static testMethod  void test_calculateProrata_With_Null(){
        Test.startTest();
            try {
            RLFPackage_ListInit.calculateProrata(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
        Test.stopTest();
    }
    
    
    private static testMethod  void test_zeroProrataDays(){
        SBQQ__Subscription__c[] subslist = new list<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub: [SELECT Id, Pro_Rata_Calculated__c,Expiry_Date__c,Next_SO_generation_Date__c,Exclude__c,Next_Billing_Date__c, Prorata_Days__c FROM SBQQ__Subscription__c]){
            sub.Next_Billing_Date__c = System.today().addYears(2);  
            sub.SBQQ__TerminatedDate__c = System.today();            
            subslist.add(sub);
        }
        
        update subslist;
        Test.startTest();
            RLFPackage_ListInit.zeroProrataDays(subslist);
        Test.stopTest();
        System.assertEquals(0, [SELECT Prorata_Days__c FROM SBQQ__Subscription__c LIMIT 1].Prorata_Days__c, 'Zeroing prorata days for all subs');
        System.assertEquals(true, [SELECT Pro_Rata_Calculated__c FROM SBQQ__Subscription__c LIMIT 1].Pro_Rata_Calculated__c, 'Setting prorata calcualted to true for all subs');        
    }
    private static testMethod  void test_zeroProrataDays_With_EmptySubs(){
        SBQQ__Subscription__c[] subslist = new list<SBQQ__Subscription__c>();
        Test.startTest();
            RLFPackage_ListInit.zeroProrataDays(subslist);
        Test.stopTest();
        System.assertEquals(5, [SELECT Prorata_Days__c FROM SBQQ__Subscription__c LIMIT 1].Prorata_Days__c, 'Setting 5 days for all subs');
        System.assertEquals(false, [SELECT Pro_Rata_Calculated__c FROM SBQQ__Subscription__c LIMIT 1].Pro_Rata_Calculated__c, 'Setting prorata calcualted to false for all subs');        
    }
    private static testMethod  void test_zeroProrataDays_With_Null(){
        Test.startTest();
            try {
            RLFPackage_ListInit.zeroProrataDays(null);
            } catch( Exception e) {
                System.assert(true, 'Should throw exception');
            }
        Test.stopTest();
    }
    
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Monthly(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Monthly' limit 1];
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(System.today().addMonths(1), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Monthly_And_Billing_Day_GT_1(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Monthly' limit 1];
        subs[0].Billing_Day__c=2;
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(System.today().addMonths(1).toStartOfMonth().addDays((Integer) subs[0].Billing_Day__c - 1), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Monthly_And_Pro_Rata_Calculated(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Monthly' limit 1];
        subs[0].Pro_Rata_Calculated__c=true;
        Date tmpNBD = subs[0].Next_Billing_Date__c;
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(tmpNBD.addMonths(1), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Quarterly(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Quarterly' limit 1];
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(System.today().addMonths(3), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Quarterly_And_Billing_Day_GT_1(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Quarterly' limit 1];
        subs[0].Billing_Day__c=2;
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(subs[0].Next_Billing_Date__c, [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
   
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Quarterly_And_Pro_Rata_Calculated(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Quarterly' limit 1];
        subs[0].Pro_Rata_Calculated__c=true;
        Date tmpNBD = subs[0].Next_Billing_Date__c;
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(tmpNBD.addMonths(3), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
     private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Semiannual(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Semiannual' limit 1];
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(System.today().addMonths(6), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Semiannual_And_Billing_Day_GT_1(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Semiannual' limit 1];
        subs[0].Billing_Day__c=2;
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(subs[0].Next_Billing_Date__c, [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
   
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Semiannual_And_Pro_Rata_Calculated(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Semiannual' limit 1];
        subs[0].Pro_Rata_Calculated__c=true;
        Date tmpNBD = subs[0].Next_Billing_Date__c;
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(tmpNBD.addMonths(6), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
     private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Annual(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Annual' limit 1];
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(System.today().addYears(1), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Annual_And_Billing_Day_GT_1(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Annual' limit 1];
        subs[0].Billing_Day__c=2;
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(subs[0].Next_Billing_Date__c, [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
   
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Annual_And_Pro_Rata_Calculated(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Annual' limit 1];
        subs[0].Pro_Rata_Calculated__c=true;
        Date tmpNBD = subs[0].Next_Billing_Date__c;
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(tmpNBD.addYears(1), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
     private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Biennial(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Biennial' limit 1];
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(System.today().addYears(2), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Biennial_And_Billing_Day_GT_1(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Biennial' limit 1];
        subs[0].Billing_Day__c=2;
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(subs[0].Next_Billing_Date__c, [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
   
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Biennial_And_Pro_Rata_Calculated(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Biennial' limit 1];
        subs[0].Pro_Rata_Calculated__c=true;
        Date tmpNBD = subs[0].Next_Billing_Date__c;
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(tmpNBD.addYears(2), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }

     private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Triennial(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Triennial' limit 1];
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(System.today().addYears(3), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Triennial_And_Billing_Day_GT_1(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Biennial' limit 1];
        subs[0].Billing_Day__c=2;
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(subs[0].Next_Billing_Date__c, [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
   
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Triennial_And_Pro_Rata_Calculated(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Triennial' limit 1];
        subs[0].Pro_Rata_Calculated__c=true;
        Date tmpNBD = subs[0].Next_Billing_Date__c;
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(tmpNBD.addYears(3), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Quinquennial(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Quinquennial' limit 1];
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(System.today().addYears(5), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Quinquennial_And_Billing_Day_GT_1(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Quinquennial' limit 1];
        subs[0].Billing_Day__c=2;
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(subs[0].Next_Billing_Date__c, [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
   
    private static testMethod  void test_updateNextBillingDate_With_BillingFrequency_Quinquennial_And_Pro_Rata_Calculated(){
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT 
                                                Id, 
                                                Name, 
                                                Pro_Rata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__StartDate__c, 
                                                Billing_Day__c, 
                                                Billing_Month__c,
                                                SBQQ__BillingType__c, 
                                                Next_SO_generation_Date__c, 
                                                SO_Generation_Advance__c, 
                                                Next_Billing_Date__c 
                                            FROM 
                                                SBQQ__Subscription__c
                                            WHERE 
                                                SBQQ__BillingFrequency__c='Quinquennial' limit 1];
        subs[0].Pro_Rata_Calculated__c=true;
        Date tmpNBD = subs[0].Next_Billing_Date__c;
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        Test.startTest();
            RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        Test.stopTest();
        System.assertEquals(tmpNBD.addYears(5), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c where id=:subs[0].id].Next_Billing_Date__c, 'next bill date updated');
    }
   
    private static testMethod  void test_updateNextBillingDate(){
        Test.startTest();
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subs = [SELECT Id, Name, Pro_Rata_Calculated__c, Last_Prorata_required__c, RF_Start_Planned_Date__c, SBQQ__BillingFrequency__c, SBQQ__StartDate__c, Billing_Day__c, Billing_Month__c,SBQQ__BillingType__c, Next_SO_generation_Date__c, SO_Generation_Advance__c, Next_Billing_Date__c FROM SBQQ__Subscription__c];
        bg_subList_Map.put([SELECT Id FROM Billing_Group__c].Id, subs);
        
        List<SBQQ__Subscription__c> tempList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c ss: subs){
            ss.SBQQ__TerminatedDate__c = system.today();
            tempList.add(ss);
        }
        
        update tempList;
        Set<SBQQ__Subscription__c> tempset = new Set<SBQQ__Subscription__c>();
        tempset.addAll(tempList);
        RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, tempSet);
        system.assertEquals(system.today().addyears(1), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c LIMIT 1].Next_Billing_Date__c, 'next bill date updated');
        Test.stopTest();
    }
    
  
    
    private static testMethod  void test_updateDates(){
        SBQQ__Subscription__c[] subs = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub: [SELECT Id, Name, Next_Billing_Date__c, Next_SO_generation_Date__c FROM SBQQ__Subscription__c]){
            sub.Next_Billing_Date__c = system.today();
            sub.Next_SO_generation_Date__c = system.today().addYears(1);
            subs.add(sub);
        }
        update subs;
        Test.startTest();        
            RLFPackage_ListInit.updateDates([SELECT Id FROM Billing_Group__c].Id, subs);
        Test.stopTest();
        system.assertEquals(system.today(), [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c LIMIT 1].Next_Billing_Date__c, 'nbd');
        system.assertEquals(system.today().addYears(1), [SELECT Next_SO_generation_Date__c FROM SBQQ__Subscription__c LIMIT 1].Next_SO_generation_Date__c, 'nsogendate');
    }
    private static testMethod  void test_updateDates_With_Null_Dates(){
        SBQQ__Subscription__c[] subs = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub: [SELECT Id, Name, Next_Billing_Date__c, Next_SO_generation_Date__c FROM SBQQ__Subscription__c]){
            sub.Next_Billing_Date__c = null;
            sub.Next_SO_generation_Date__c = null;
            subs.add(sub);
        }
        update subs;
        Test.startTest();        
            RLFPackage_ListInit.updateDates([SELECT Id FROM Billing_Group__c].Id, subs);
        Test.stopTest();
        system.assertEquals(null, [SELECT Next_Billing_Date__c FROM SBQQ__Subscription__c LIMIT 1].Next_Billing_Date__c, 'nbd');
        system.assertEquals(null, [SELECT Next_SO_generation_Date__c FROM SBQQ__Subscription__c LIMIT 1].Next_SO_generation_Date__c, 'nsogendate');
    }
    
    private static SBQQ__Subscription__c retrieveSubscription() {
                SBQQ__Subscription__c sub = [SELECT 
                                                Id, 
                                                Billing_Day__c, 
                                                Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode, 
                                                Billing_Group__r.CurrencyIsoCode, 
                                                Billing_Month__c, Comm_Man_Price__c, 
                                                Contractor_Hours_Total__c, Discount_premium__c, 
                                                Expiry_Date__c, Fair_Value__c, 
                                                Fair_Value_Adjustment__c, 
                                                Initial_Sales_Order_Type__c, 
                                                Internal_Costs__c, 
                                                Last_Prorata_Calculated__c, 
                                                Last_Prorata_required__c, 
                                                Licence_Band__c, 
                                                License_Metric__c, 
                                                LineItem_Process_Type__c, 
                                                List_Per_Diem_Value__c, 
                                                Location__c, 
                                                Next_Billing_Date__c, 
                                                Next_SO_generation_Date__c, 
                                                NonBillable_Hours_Total__c, 
                                                NS_Deferred_Revenue_Acct_ID__c, 
                                                Opportunity_Billing_Schedule__c, 
                                                Pearl_Internal_Cost__c, 
                                                Pro_Rata_Calculated__c, 
                                                Prorata_Days__c, 
                                                Recurring_NS_Item__c, 
                                                Recurring_Sovos_Code__c, 
                                                Recurring_NS_Item__r.GA__c, 
                                                Recurring_NS_Item__r.NS_Cost_Centre_ID__c, 
                                                Recurring_NS_Item__r.NS_Default_Delivered__c, 
                                                Recurring_NS_Item__r.NS_Form_ID__c, 
                                                Recurring_NS_Item__r.NS_Product_Dimension_ID__c, 
                                                Recurring_NS_Item__r.NS_Rev_Rec_Template_ID__c, 
                                                Recurring_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c, 
                                                Recurring_Sales_Order_Type__c, 
                                                Reimbursable_Costs_Estimate__c, 
                                                Reimbursable_Costs_Recovery_Value__c, 
                                                RF_Start_Planned__c, 
                                                RF_Start_Planned_Date__c, 
                                                SBQQ__BillingFrequency__c, 
                                                SBQQ__BillingType__c, 
                                                SBQQ__ListPrice__c, 
                                                SBQQ__NetPrice__c, 
                                                SBQQ__PartnerDiscount__c, 
                                                SBQQ__Product__c, 
                                                SBQQ__Product__r.GA__c, 
                                                SBQQ__Product__r.Name, 
                                                SBQQ__Product__r.NS_3PP_Vendor_ID__c, 
                                                SBQQ__Product__r.NS_Create_3PP_Event__c, 
                                                SBQQ__Product__r.NS_Default_OpenAir_Billing_Rule_Int_ID__c, 
                                                SBQQ__Product__r.NS_Deferred_Revenue_Acct_ID__c, 
                                                SBQQ__Product__r.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c, 
                                                SBQQ__Product__r.NS_Rev_Rec_Template_ID__c, 
                                                SBQQ__Product__r.Payaway__c, 
                                                SBQQ__Product__r.UPID__c, 
                                                SBQQ__Quantity__c, 
                                                SBQQ__StartDate__c, 
                                                SBQQ__EndDate__c, 
                                                SBQQ__UnitCost__c, 
                                                SO_Generation_Advance__c, 
                                                Sold_Per_Diem_Value__c, 
                                                Sold_Value__c, 
                                                Ship_From_Code__c, 
                                                ThirdParty_Contractor_Cost_Sold_Ccy__c, 
                                                ThirdParty_Costs_PO_Ccy__c, 
                                                ThirdParty_Costs_Sold_Ccy__c, 
                                                ThirdParty_PO_Currency__c, 
                                                ThirdParty_Recurring_Costs_PO_Ccy__c, 
                                                Total_Chargeable_Hours__c, 
                                                Travel_Hours_Total__c, 
                                                Transactional__c , 
                                                Transactions__c , 
                                                unrecoverable_costs__c, 
                                                X3PP_Currency__c, 
                                                X3PP_Discount__c 
                                            FROM 
                                                SBQQ__Subscription__c limit 1 ]; 
return sub;
    }
    
    private static Billing_Group__c retrieveBG() {
                Billing_Group__c bg = [SELECT 
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
                            LIMIT 1]; 
return bg;
    }
    
}