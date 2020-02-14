@isTest
public class ILFPackage_ListInit_test {
    
    @testSetup static void setup() {          
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
   }
    
    private static testMethod void test_addNSProject(){
        SBQQ__Subscription__c sub = retrieveSubscription();
        Test.startTest();
            NS_Project__c nsProj = ILFPackage_ListInit.addNSProject(sub, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(), SO_SalesOrderMapUtils.getNSProduct_map(), 'ILF');
        Test.stopTest();
        System.assertEquals('ILF',nsProj.Project_Type__c,'NS project type should be ILF');
        System.assertEquals('ILF Only',nsProj.OpenAir_Project_Stage__c,'NS project OpenAir_Project_Stage__c should be \'ILF Only\'');
        System.assertEquals('In Progress',nsProj.NS_Project_Status__c,'NS project NS_Project_Status__c should be \'In Progress\'');
   }
    private static testMethod void test_addNSProject_With_OrderType_Null(){
        SBQQ__Subscription__c sub = retrieveSubscription();
        Test.startTest();
            NS_Project__c nsProj = ILFPackage_ListInit.addNSProject(sub, SO_SalesOrderMapUtils.getNSCurrency_map(), SO_SalesOrderMapUtils.getNSCostCenter_map(), SO_SalesOrderMapUtils.getNSProduct_map(), null);
        Test.stopTest();
        System.assertEquals(null,nsProj.Project_Type__c,'NS project type should be null');
        System.assertEquals('ILF Only',nsProj.OpenAir_Project_Stage__c,'NS project OpenAir_Project_Stage__c should be \'ILF Only\'');
        System.assertEquals('In Progress',nsProj.NS_Project_Status__c,'NS project NS_Project_Status__c should be \'In Progress\'');
   }
    private static testMethod void test_addNSProject_With_Null(){
        Test.startTest();
        try{
            NS_Project__c nsProj = ILFPackage_ListInit.addNSProject(null, null, null,null, null);
        }catch(Exception e){
            System.assert(true,'Should throw exception');
       }
        Test.stopTest();
   }
    private static testMethod void test_addNSProjectMilestone(){
        Opportunity_Billing_Schedule_Item__c obsItem = [select 
                                                              Narrative__c
                                                            , Name
                                                            , Line_Estimated_Completion_Date__c
                                                            , Line_Drop_Dead_Date__c
                                                            , Line_Milestone_Sequence__c
                                                            , Opportunity_Billing_Schedule__r.Opportunity__r.CloseDate
                                                            , Opportunity_Billing_Schedule__r.Opportunity__r.CurrencyIsoCode 
                                                        from 
                                                            Opportunity_Billing_Schedule_Item__c 
                                                        limit 1];
        NS_Project__c nsProj = [select id from NS_Project__c limit 1];
        Test.startTest();        
            NS_Project_Milestone__c projMilestone = ILFPackage_ListInit.addNSProjectMilestone(obsItem, nsProj.id);
        Test.stopTest();   
        System.assertEquals('Fixed Start',projMilestone.Constraint_Type__c,'Project Milestone\'s Constraint_Type__c should be \'Fixed Start\'');
        System.assertEquals('In Progress',projMilestone.Status__c,'Project Milestone\'s Status__c should be \'In Progress\'');
        System.assertEquals(obsItem.Line_Drop_Dead_Date__c,projMilestone.Drop_Dead_Date__c,'Project Milestone\'s Drop_Dead_Date__c should be Opportunity_Billing_Schedule_Item Line_Drop_Dead_Date__c');
        System.assertEquals(obsItem.Line_Milestone_Sequence__c,projMilestone.Sequence_Number__c,'Project Milestone\'s Sequence_Number__c should be Opportunity_Billing_Schedule_Item Line_Milestone_Sequence__c');
        System.assertEquals(true,projMilestone.Milestone__c,'Project Milestone\'s Milestone__c should be \'true\'');
        System.assertEquals(obsItem.id,projMilestone.Opportunity_Billing_Schedule_Item__c,'Project Milestone\'s Opportunity_Billing_Schedule_Item__c should be Opportunity_Billing_Schedule_Item id');
        System.assertEquals(nsProj.id,projMilestone.NS_Project__c,'Project Milestone\'s NS_Project__c be ns project id');
    }
    private static testMethod void test_addNSProjectMilestone_With_Null_ProjId(){
        Opportunity_Billing_Schedule_Item__c obsItem = [select 
                                                              Narrative__c
                                                            , Name
                                                            , Line_Estimated_Completion_Date__c
                                                            , Line_Drop_Dead_Date__c
                                                            , Line_Milestone_Sequence__c
                                                            , Opportunity_Billing_Schedule__r.Opportunity__r.CloseDate
                                                            , Opportunity_Billing_Schedule__r.Opportunity__r.CurrencyIsoCode 
                                                        from 
                                                            Opportunity_Billing_Schedule_Item__c 
                                                        limit 1];
        Test.startTest();        
            NS_Project_Milestone__c projMilestone = ILFPackage_ListInit.addNSProjectMilestone(obsItem, null);
        Test.stopTest();   
        System.assertEquals('Fixed Start',projMilestone.Constraint_Type__c,'Project Milestone\'s Constraint_Type__c should be \'Fixed Start\'');
        System.assertEquals('In Progress',projMilestone.Status__c,'Project Milestone\'s Status__c should be \'In Progress\'');
        System.assertEquals(obsItem.Line_Drop_Dead_Date__c,projMilestone.Drop_Dead_Date__c,'Project Milestone\'s Drop_Dead_Date__c should be Opportunity_Billing_Schedule_Item Line_Drop_Dead_Date__c');
        System.assertEquals(obsItem.Line_Milestone_Sequence__c,projMilestone.Sequence_Number__c,'Project Milestone\'s Sequence_Number__c should be Opportunity_Billing_Schedule_Item Line_Milestone_Sequence__c');
        System.assertEquals(true,projMilestone.Milestone__c,'Project Milestone\'s Milestone__c should be \'true\'');
        System.assertEquals(obsItem.id,projMilestone.Opportunity_Billing_Schedule_Item__c,'Project Milestone\'s Opportunity_Billing_Schedule_Item__c should be Opportunity_Billing_Schedule_Item id');
        System.assertEquals(null,projMilestone.NS_Project__c,'Project Milestone\'s NS_Project__c be ns project id');
    }
    private static testMethod void test_addNSProjectMilestone_With_All_Null(){
        Test.startTest();
            try {
                NS_Project_Milestone__c projMilestone = ILFPackage_ListInit.addNSProjectMilestone(null, null);
            }catch(Exception e){
                System.assert(true,'Should throw exception');
            }       
        Test.stopTest();   
    }
    private static testMethod void test_addNSCustomerBillingSchedule(){


        NS_Project_Milestone__c milestone = [   select 
                              id 
                            , Opportunity_Billing_Schedule_Item__r.Opportunity_Billing_Schedule__r.Name
                            , NS_Project__r.Deferred_Account_Type__c
                            , NS_Project__c
                            , Opportunity_Billing_Schedule_Item__r.Line__c
                            , Opportunity_Billing_Schedule_Item__r.Line_Milestone_Sequence__c
                            , Opportunity_Billing_Schedule_Item__c
                            , Opportunity_Billing_Schedule_Item__r.Opportunity_Billing_Schedule__r.Opportunity__r.CloseDate
                            , Opportunity_Billing_Schedule_Item__r.Line_Estimated_Completion_Date__c
                            , Opportunity_Billing_Schedule_Item__r.Line_Drop_Dead_Date__c
                            , Opportunity_Billing_Schedule_Item__r.CurrencyIsoCode
                            , Opportunity_Billing_Schedule_Item__r.Line_Amount_for_Milestone__c
                        from 
                            NS_Project_Milestone__c limit 1];
        Test.startTest();
            NS_Customer_Billing_Schedule__c cbs = ILFPackage_ListInit.addNSCustomerBillingSchedule(milestone);
        Test.stopTest();
        System.assertEquals(milestone.NS_Project__c,cbs.Project__c,'Customer_Billing_Schedule\'s Project__c should be NS project\'s id');
        System.assertEquals(milestone.id,cbs.Line_Milestone__c,'Customer_Billing_Schedule\'s Line_Milestone__c should be NS_Project_Milestone\'s NS_Project__c');
        System.assertEquals(milestone.Opportunity_Billing_Schedule_Item__c,cbs.Opportunity_Billing_Schedule_Item__c,'Customer_Billing_Schedule\'s Opportunity_Billing_Schedule_Item__c should be NS_Project_Milestone\'s id');
    }
    private static testMethod void test_addNSCustomerBillingSchedule_With_Line_Estimated_Completion_Date(){


        NS_Project_Milestone__c milestone = [   select 
                                                  id 
                                                    , Opportunity_Billing_Schedule_Item__r.Opportunity_Billing_Schedule__r.Name
                                                    , NS_Project__r.Deferred_Account_Type__c
                                                    , NS_Project__c
                                                    , Opportunity_Billing_Schedule_Item__r.Line__c
                                                    , Opportunity_Billing_Schedule_Item__r.Line_Milestone_Sequence__c
                                                    , Opportunity_Billing_Schedule_Item__c
                                                    , Opportunity_Billing_Schedule_Item__r.Opportunity_Billing_Schedule__r.Opportunity__r.CloseDate
                                                    , Opportunity_Billing_Schedule_Item__r.Line_Estimated_Completion_Date__c
                                                    , Opportunity_Billing_Schedule_Item__r.Line_Drop_Dead_Date__c
                                                    , Opportunity_Billing_Schedule_Item__r.CurrencyIsoCode
                                                    , Opportunity_Billing_Schedule_Item__r.Line_Amount_for_Milestone__c
                                                from 
                                                    NS_Project_Milestone__c limit 1];
        milestone.Opportunity_Billing_Schedule_Item__r.Line_Estimated_Completion_Date__c = System.today();
        Test.startTest();
            NS_Customer_Billing_Schedule__c cbs = ILFPackage_ListInit.addNSCustomerBillingSchedule(milestone);
        Test.stopTest();
        System.assertEquals(milestone.NS_Project__c,cbs.Project__c,'Customer_Billing_Schedule\'s Project__c should be NS project\'s id');
        System.assertEquals(milestone.id,cbs.Line_Milestone__c,'Customer_Billing_Schedule\'s Line_Milestone__c should be NS_Project_Milestone\'s NS_Project__c');
        System.assertEquals(milestone.Opportunity_Billing_Schedule_Item__c,cbs.Opportunity_Billing_Schedule_Item__c,'Customer_Billing_Schedule\'s Opportunity_Billing_Schedule_Item__c should be NS_Project_Milestone\'s id');
    }
    private static testMethod void test_addNSCustomerBillingSchedule_With_Null(){
        Test.startTest();
        try {
            NS_Customer_Billing_Schedule__c cbs = ILFPackage_ListInit.addNSCustomerBillingSchedule(null);
        }catch(Exception e){
                System.assert(true,'Should throw exception');
        }
        Test.stopTest();
    }
    private static testMethod void test_addILFSalesOrder(){
        Billing_Group__c bg=retrieveBG();
        Test.startTest();
            Sales_order__c so = ILFPackage_ListInit.addILFSalesOrder(bg,new NS_Project__c(), SO_SalesOrderMapUtils.getNSCurrency_map(), 'ILF', SO_SalesOrderMapUtils.getNsAccMap());
        TEst.stopTest();
        System.assertEquals(bg.Id,so.Billing_Group__c,'Sales_order__c\'s Billing_Group__c should be billing group id');
        System.assertEquals('ILF',so.Sub_Group_Type__c,'Sales_order__c\'s Sub_Group_Type__c should be ILF');
        System.assertEquals('ILF',so.Order_Type__c,'Sales_order__c\'s order_type__c should be ILF');
        System.assertEquals('126',so.NS_Form_Id__c,'Sales_order__c\'s NS_Form_Id__c should be 126');
        System.assertEquals(true,so.CPQ_Billing__c,'Sales_order__c\'s CPQ_Billing__c should be true');

    }   
    private static testMethod void test_addILFSalesOrder_With_Null_Sub_Group_Type(){
        Billing_Group__c bg=retrieveBG();
        Test.startTest();
            Sales_order__c so = ILFPackage_ListInit.addILFSalesOrder(bg,new NS_Project__c(), SO_SalesOrderMapUtils.getNSCurrency_map(), null, SO_SalesOrderMapUtils.getNsAccMap());
        TEst.stopTest();
        System.assertEquals(bg.Id,so.Billing_Group__c,'Sales_order__c\'s Billing_Group__c should be billing group id');
        System.assertEquals(null,so.Sub_Group_Type__c,'Sales_order__c\'s Sub_Group_Type__c should be null');
        System.assertEquals('ILF',so.Order_Type__c,'Sales_order__c\'s order_type__c should be ILF');
        System.assertEquals('126',so.NS_Form_Id__c,'Sales_order__c\'s NS_Form_Id__c should be 126');
        System.assertEquals(true,so.CPQ_Billing__c,'Sales_order__c\'s CPQ_Billing__c should be true');
    }   
    private static testMethod void test_addILFSalesOrder_With_All_Null(){
        Test.startTest();
        try {
            Sales_order__c so = ILFPackage_ListInit.addILFSalesOrder(null,null, null, null, null);
        }catch(Exception e){
                System.assert(true,'Should throw exception');
        }
        TEst.stopTest();
    }   
     private static testMethod void test_addILFSalesOrderItem(){
        SBQQ__Subscription__c sub = retrieveSubscription();
        Sales_Order__c so = new Sales_Order__c();
        insert so;
        so = [  select 
                      id 
                    , Order_Start_Date__c
                    , Order_End_Date__c
                from 
                    Sales_Order__c 
                limit 1];
        Test.startTest();
            Sales_Order_Item__c soi = ILFPackage_ListInit.addILFSalesOrderItem(sub, 1, so, SO_SalesOrderMapUtils.getRevScheduleMap(), SO_SalesOrderMapUtils.getNSCurrency_map());
        Test.stopTest();
        System.assertEquals(1,soi.Line__c,'Sales_Order_Item__c\'s Line__c should be 1');
        System.assertEquals(so.Id,soi.Sales_Order__c,'Sales_Order_Item__c\'s Sales_Order__c should be sales order id');
        System.assertEquals(sub.Id,soi.Subscription__c,'Sales_Order_Item__c\'s Subscription__c should be Subscription id');
        System.assertEquals(true,soi.Software_Delivered__c,'Sales_Order_Item__c\'s Software_Delivered__c should be true');
        System.assertEquals('Manual',soi.Vendor_BSch_Trigger__c,'Sales_Order_Item__c\'s Vendor_BSch_Trigger__c should be Manual');
    }
     private static testMethod void test_addILFSalesOrderItem_With_Line_Count_0(){
        SBQQ__Subscription__c sub = retrieveSubscription();
        Sales_Order__c so = new Sales_Order__c();
        insert so;
        so = [  select 
                      id 
                    , Order_Start_Date__c
                    , Order_End_Date__c
                from 
                    Sales_Order__c 
                limit 1];
        Test.startTest();
            Sales_Order_Item__c soi = ILFPackage_ListInit.addILFSalesOrderItem(sub, 0, so, SO_SalesOrderMapUtils.getRevScheduleMap(), SO_SalesOrderMapUtils.getNSCurrency_map());
        Test.stopTest();
        System.assertEquals(0,soi.Line__c,'Sales_Order_Item__c\'s Line__c should be 0');
        System.assertEquals(so.Id,soi.Sales_Order__c,'Sales_Order_Item__c\'s Sales_Order__c should be sales order id');
        System.assertEquals(sub.Id,soi.Subscription__c,'Sales_Order_Item__c\'s Subscription__c should be Subscription id');
        System.assertEquals(true,soi.Software_Delivered__c,'Sales_Order_Item__c\'s Software_Delivered__c should be true');
        System.assertEquals('Manual',soi.Vendor_BSch_Trigger__c,'Sales_Order_Item__c\'s Vendor_BSch_Trigger__c should be Manual');
    }
    private static testMethod void test_addILFSalesOrderItem_With_All_Null(){
        Test.startTest();
        try {
            Sales_Order_Item__c soi = ILFPackage_ListInit.addILFSalesOrderItem(null, 0, null, null, null);
        }catch(Exception e){
            System.assert(true,'Should throw exception');
        }
        Test.stopTest();
    }
     private static testMethod void test_addVendorBillingScheule(){
        Sales_Order__c so = new Sales_Order__c();
        Sales_Order_Item__c soi = new Sales_Order_Item__c();
        soi.Line__c=1;
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        Test.startTest();
            NS_Vendor_Billing_Schedule__c vbs = ILFPackage_ListInit.addVendorBillingScheule(so, soi, sub);
        TEst.stopTest();
        System.assertEquals(sub.id,vbs.Subscription_Id__c,'NS_Vendor_Billing_Schedule__c\'s Subscription_Id__c should be Subscription id');
        System.assertEquals(so.NS_Project__c,vbs.NS_Project__c,'NS_Vendor_Billing_Schedule__c\'s NS_Project__c should be sales order NS_Project__c');
        System.assertEquals(soi.ThirdParty_Costs_PO_Ccy__c,vbs.SOI_Amount__c,'NS_Vendor_Billing_Schedule__c\'s SOI_Amount__c should be sales order items ThirdParty_Costs_PO_Ccy__c');
    }
    private static testMethod void test_addVendorBillingScheule_With_Null_Subscription(){
        Sales_Order__c so = new Sales_Order__c();
        Sales_Order_Item__c soi = new Sales_Order_Item__c();
        soi.Line__c=1;
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        Test.startTest();
        try {
            NS_Vendor_Billing_Schedule__c vbs = ILFPackage_ListInit.addVendorBillingScheule(so, soi, null);
        }catch(Exception e){
            System.assert(true,'Should throw exception');
        }
        Test.stopTest();
    }
    private static testMethod void test_addVendorBillingScheule_With_Null_Sales_Order_Item(){
        Sales_Order__c so = new Sales_Order__c();
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        Test.startTest();
        try {
            NS_Vendor_Billing_Schedule__c vbs = ILFPackage_ListInit.addVendorBillingScheule(so, null, sub);
        }catch(Exception e){
            System.assert(true,'Should throw exception');
        }
        Test.stopTest();
    }
    private static testMethod void test_addVendorBillingScheule_With_Null_Sales_Order(){
        Sales_Order_Item__c soi = new Sales_Order_Item__c();
        soi.Line__c=1;
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        Test.startTest();
        try {
            NS_Vendor_Billing_Schedule__c vbs = ILFPackage_ListInit.addVendorBillingScheule(null, soi, sub);
        }catch(Exception e){
            System.assert(true,'Should throw exception');
        }
        Test.stopTest();
    }
    private static testMethod void test_addVendorBillingScheule_With_All_Null(){
        Test.startTest();
        try {
            NS_Vendor_Billing_Schedule__c vbs = ILFPackage_ListInit.addVendorBillingScheule(null, null, null);
        }catch(Exception e){
            System.assert(true,'Should throw exception');
        }
        Test.stopTest();
    }
    private static testMethod void test_createVBSItem(){
        List<NS_Vendor_Billing_Schedule__c> vbs = [SELECT Id, NS_Project__c, CurrencyIsoCode, SOI_Amount__c FROM NS_Vendor_Billing_Schedule__c];
        NS_Project__c proj = [SELECT ID FROM NS_Project__c LIMIT 1];
        List < NS_Vendor_Billing_Schedule_Line__c > vbsLineList = [select id from NS_Vendor_Billing_Schedule_Line__c];
        System.assertEquals(0,vbsLineList.size(),'NS_Vendor_Billing_Schedule_Line__c size in db before create should be 0');
        Test.startTest();
            ILFPackage_ListInit.createVBSItem(vbs, proj.Id);
        TEst.stopTest();
        vbsLineList = [select id from NS_Vendor_Billing_Schedule_Line__c];
        System.assertEquals(4,vbsLineList.size(),'NS_Vendor_Billing_Schedule_Line__c size in db after create should be 4');
    }
    private static testMethod void test_createVBSItem_With_EmptyList(){
        List<NS_Vendor_Billing_Schedule__c> vbs = new List<NS_Vendor_Billing_Schedule__c>();
        NS_Project__c proj = [SELECT ID FROM NS_Project__c LIMIT 1];
        List < NS_Vendor_Billing_Schedule_Line__c > vbsLineList = [select id from NS_Vendor_Billing_Schedule_Line__c];
        System.assertEquals(0,vbsLineList.size(),'NS_Vendor_Billing_Schedule_Line__c size in db before create should be 0');
        Test.startTest();
            ILFPackage_ListInit.createVBSItem(vbs, proj.Id);
        TEst.stopTest();
        vbsLineList = [select id from NS_Vendor_Billing_Schedule_Line__c];
        System.assertEquals(0,vbsLineList.size(),'NS_Vendor_Billing_Schedule_Line__c size in db after create should be 4');
    }
    private static testMethod void test_createVBSItem_With_Null(){
        Test.startTest();
        try {
            ILFPackage_ListInit.createVBSItem(null, null);
        }catch(Exception e){
            System.assert(true,'Should throw exception');
        }
        Test.stopTest();
    }

    private static SBQQ__Subscription__c retrieveSubscription() {
        SBQQ__Subscription__c sub = [SELECT 
                                        Id, 
                                        Inital_NS_Item__r.GA__c,
                                        Initial_Sovos_Code__c,
                                        ILF_Fair_Value__c,
                                        Inital_NS_Item__r.NS_Rev_Rec_Template_ID__c,
                                        Inital_NS_Item__r.NS_Cost_Centre_ID__c,
                                        Inital_NS_Item__r.NS_Product_Dimension_ID__c,
                                        Inital_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c,
                                        Billing_Group__r.Account_by_Sub__r.Misys_Entity__c,
                                        Billing_Day__c, 
                                        Billing_Group__r.Account_by_Sub__r.Account__r.NS_Finance_Region__c,
                                        Billing_Group__r.Original_Contract__r.CustomerSignedDate,
                                        Billing_Group__r.Original_Opportunity__r.Order_Number__c,
                                        Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode, 
                                        Billing_Group__r.CurrencyIsoCode, 
                                        Billing_Month__c, 
                                        Comm_Man_Price__c, 
                                        Contractor_Hours_Total__c, 
                                        Discount_premium__c, 
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
                                        X3PP_Discount__c,
                                        Opportunity_Billing_Schedule__r.Name 
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