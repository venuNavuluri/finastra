/**
 * @File Name          : SyncSubscriptionsHandler_Test.cls
 * @Description        : 
 * @Author             : Peter Sabry
 * @Group              : 
 * @Last Modified By   : Peter Sabry
 * @Last Modified On   : 31/07/2019, 11:11:20
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    31/07/2019, 11:10:32   Peter Sabry     Initial Version
**/
@IsTest
private class SyncSubscriptionsHandler_Test {

    /**
     * Preparing data for tests
     */
    @TestSetup
    static void setup() {
        Account account = new Account(name = 'uplift test account');
        insert account;
        Contact c = new Contact(lastname = 'test', Legal_Notifications__c = true, Inactive_Contact__c = false,
            Left_Bank__c = false, Email = 'test@test.com', accountId = account.Id);
        insert c;
        Opportunity opp = new Opportunity(Name = 'uplift test opp', StageName = 'Suspect', CloseDate = Date.today());
        insert opp;
        Billing_Entity__c be = TestDataFactory.createBillingEntity();
        
        Billing_Group__c billingGroup = new Billing_Group__c(
            BG_Misys_Billing_Entity__c = be.Id,
            Billing_Day__c = 1,
            Billing_Month__c = 'January',
            Next_Billing_Date__c = date.today(),
            Billing_Type__c = 'Advance',
            Billing_Frequency__c = 'Monthly',
            SO_Advance_Date__c = 60,
            Next_SO_generation_Date__c = date.today());
        insert billingGroup;
        
        Contract contract1 = new Contract(accountId = account.Id, SBQQ__Opportunity__c = opp.Id, Uplift_Calc_Type__c = 'Pro-Rata', CPI_Uplift_Type__c='Calendar', Billing_Frequency__c = 'Annual',
                                        Hold_CPI_Uplift__c = false, Active__c = true, Uplift_Application_Date__c  = Date.today(), Next_Uplift_Date__c = Date.today(), status = 'Draft', ContractTerm = 12,
                                        Uplift_Annual_Effective_Date__c = date.today(), RLF_Earliest_review_Date__c = date.today(), Recurring_Fees_Start_Planned__c=date.today(), Fixed_Billing_Day__c=1, Fixed_Billing_Month__c='January');
        insert contract1;
        contract1.status = 'Is Active';
        update contract1;        
        
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Billing_Group__c = billingGroup.Id, Uplift_Calc_Type__c = 'Pro-Rata', SO_Generation_Advance__c=60, Varied_Licence__c = true,SBQQ__Contract__c = contract1.id, Uplift_Application_Date__c  = Date.today(),
                Transactions__c = 2, Sold_Value__c = 50, SBQQ__NetPrice__c = 1200, Contract_Term_In_Months__c=12, ProdType__c='RLF', CPI_Uplift_Review_Date__c = Date.Today(), SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', Uplift_Effective_Date__c  = Date.today());
        insert subscription; 
    }
    @IsTest
    static void testSyncSubsFromContract() {
        Contract contract = [SELECT Id FROM Contract LIMIT 1];
        contract.Fixed_Billing_Day__c = 2;
        contract.Fixed_Billing_Month__c = 'February'; 
        contract.Billing_Frequency__c = 'Quinquennial';  
        contract.Billing_Advance_Days__c = 59;  
        contract.Billing_Arrears_Days__c = 29;
        contract.Uplift_Calc_Type__c = 'Full Year';
        contract.Uplift_Application_Date__c = date.today().addMonths(3);
        contract.Uplift_Annual_Effective_Date__c = date.today().addMonths(3);
        contract.RLF_Earliest_review_Date__c = date.today().addMonths(3);
        contract.Recurring_Fees_Start_Planned__c = date.today().addMonths(3);
        update contract;
        
        Test.startTest();
        
        Set<Id> contractIds = new Set<Id>();
        contractIds.add(contract.Id);
        SyncSubscriptionsHandler.SyncSubsFromContract(contractIds);
        
        Test.stopTest();
        
        
        SBQQ__Subscription__c subscription = [Select Id,
                                              Billing_Group__c,
                                              Billing_Day__c,
                                              Billing_Month__c,
                                              Next_Billing_Date__c,
                                              SBQQ__BillingType__c,
                                              SBQQ__BillingFrequency__c,
                                              SO_Generation_Advance__c,
                                              Next_SO_generation_Date__c,
                                              Contract_Term_In_Months__c,
                                              SBQQ__NetPrice__c,
                                              Uplift_Calc_Type__c,
                                              Uplift_Application_Date__c,
                                              Uplift_Effective_Date__c,
                                              CPI_Uplift_Review_Date__c,
                                              RF_Start_Planned_Date__c,
                                              SO_Amount__c
                                              FROM SBQQ__Subscription__c];
        
        system.assertEquals(2, subscription.Billing_Day__c);
        system.assertEquals('February', subscription.Billing_Month__c);
        system.assertEquals('Quinquennial', subscription.SBQQ__BillingFrequency__c);
        system.assertEquals(59, subscription.SO_Generation_Advance__c);
        system.assertEquals(date.today().addMonths(3).addDays(-59), subscription.Next_SO_generation_Date__c);
        system.assertEquals('Full Year', subscription.Uplift_Calc_Type__c);
        system.assertEquals(date.today().addMonths(3), subscription.Uplift_Application_Date__c);
        system.assertEquals(date.today().addMonths(3), subscription.Uplift_Effective_Date__c);
        system.assertEquals(date.today().addMonths(3), subscription.CPI_Uplift_Review_Date__c);
        system.assertEquals(date.today().addMonths(3), subscription.RF_Start_Planned_Date__c);
        system.assertEquals(date.today().addMonths(3), subscription.Next_Billing_Date__c);
        system.assertEquals(6000.00, subscription.SO_Amount__c);
    }
    @IsTest
    static void testSyncSubsFromBillingGroup() {
        
        Billing_Group__c billingGroup = [SELECT Id FROM Billing_Group__c LIMIT 1];
        billingGroup.Billing_Day__c = 2;
        billingGroup.Billing_Month__c = 'February';
        billingGroup.Next_Billing_Date__c = date.today().addMonths(1);
        billingGroup.Billing_Type__c = 'Arrears';
        billingGroup.Billing_Frequency__c = 'Semiannual';
        billingGroup.SO_Advance_Date__c = 30;
        billingGroup.Next_SO_generation_Date__c = date.today().addMonths(3);
        
        update billingGroup;
        system.debug('billingGroup='+billingGroup);
        Test.startTest();
        
        Set<Id> bgIds = new Set<Id>();
        bgIds.add(billingGroup.Id);
        SyncSubscriptionsHandler.SyncSubsFromBillingGroup(bgIds);


        Test.stopTest();
        
        SBQQ__Subscription__c subscription = [Select Id,
                                              Billing_Group__c,
                                              Billing_Day__c,
                                              Billing_Month__c,
                                              Next_Billing_Date__c,
                                              SBQQ__BillingType__c,
                                              SBQQ__BillingFrequency__c,
                                              SO_Generation_Advance__c,
                                              Next_SO_generation_Date__c,
                                              Contract_Term_In_Months__c,
                                              SBQQ__NetPrice__c,
                                              SO_Amount__c
                                              FROM SBQQ__Subscription__c];
        system.debug('subscription='+subscription);
        system.assertEquals(2, subscription.Billing_Day__c);
        system.assertEquals('February', subscription.Billing_Month__c);
        system.assertEquals(date.today().addMonths(1), subscription.Next_Billing_Date__c);
        system.assertEquals('Arrears', subscription.SBQQ__BillingType__c);
        system.assertEquals('Semiannual', subscription.SBQQ__BillingFrequency__c);
        system.assertEquals(30, subscription.SO_Generation_Advance__c);
        system.assertEquals(date.today().addMonths(3), subscription.Next_SO_generation_Date__c);
        system.assertEquals(600.00, subscription.SO_Amount__c);
        
    }
}