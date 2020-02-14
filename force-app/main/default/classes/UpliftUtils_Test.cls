/**
Purpose:    To test UpliftUtils class
 */
@isTest
private class UpliftUtils_Test {
    private static Uplift_TestUtils.BaseData baseData;
    private static List<Uplift__c> uplifts;
    
    @testSetup
    public static void createCPIUpliftData() {
        Account account = new Account(name = 'uplift test account');
        insert account;
        Contact c = new Contact(lastname = 'test', Legal_Notifications__c = true, Inactive_Contact__c = false,
            Left_Bank__c = false, Email = 'test@test.com', accountId = account.Id);
        insert c;
        Opportunity opp = new Opportunity(Name = 'uplift test opp', StageName = 'Suspect', CloseDate = Date.today());
        insert opp;
        List<Contract> contracts = new List<Contract>();
        Contract contract1 = new Contract(accountId = account.Id, SBQQ__Opportunity__c = opp.Id, Uplift_Calc_Type__c = 'Pro-Rata', CPI_Uplift_Type__c='Calendar', Billing_Frequency__c = 'Monthly',
                                            Hold_CPI_Uplift__c = false, Active__c = true, Uplift_Application_Date__c  = Date.today(), Next_Uplift_Date__c = Date.today(), status = 'Draft', ContractTerm = 12);
        contracts.add(contract1);
        Contract contract2 = new Contract(accountId = account.Id, SBQQ__Opportunity__c = opp.Id, Uplift_Calc_Type__c = 'Pro-Rata', CPI_Uplift_Type__c='Calendar', Billing_Frequency__c = 'Monthly',
                                            Hold_CPI_Uplift__c = false, Active__c = true, Uplift_Application_Date__c  = Date.today(), Next_Uplift_Date__c = Date.today(), status = 'Draft', ContractTerm = 12);
        contracts.add(contract2);
        Contract contract3 = new Contract(accountId = account.Id, SBQQ__Opportunity__c = opp.Id, Billing_Frequency__c = 'Monthly',
                                            Active__c = true, status = 'Draft', Recurring_Fees_Index_Type__c = Constants.RF_INDEX_TYPE_NO_INCREASE, ContractTerm = 12);
        contracts.add(contract3);
        insert contracts;
        contract1.status = 'Active';
        contract2.status = 'Active';
        contract3.status = 'Active';
        update contracts;
        
        RF_Index__c recIndex = new RF_Index__c();
        insert recIndex;
        
        List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub11 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract1.Id, SBQQ__Quantity__c = 1,
                Transactional__c = true, Fair_Value__c=30,Exclude__c = true,Billing_Status__c='Active billing',
                Uplift_Calc_Type__c = 'Interim', SO_Generation_Advance__c=60, Uplift_Application_Date__c  = Date.today(), Uplift_Factor__c=1,
            CPI_Uplift_Override__c = 10,  SO_Amount__c = 200, SBQQ__NetPrice__c = 100, CPI_Uplift_Review_Date__c = Date.Today(), 
            SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Quarterly', Uplift_Effective_Date__c  = Date.today().addYears(1)); //tiers, skipped because uplift not active
        SBQQ__Subscription__c sub12 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract1.Id, SBQQ__Quantity__c = 1,
                Transactional__c = true, Fair_Value__c=30, Exclude__c = false,Billing_Status__c='Active billing',
                Uplift_Calc_Type__c = 'Pro-Rata', SO_Generation_Advance__c=60, Uplift_Application_Date__c  = Date.today(),
            CPI_Uplift_Override__c = 15,  SO_Amount__c = 200, SBQQ__NetPrice__c = 100, CPI_Uplift_Review_Date__c = Date.Today(), 
            SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Semiannual', Uplift_Effective_Date__c  = Date.today().addYears(1)); // tiers
        SBQQ__Subscription__c sub21 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract2.Id, SBQQ__Quantity__c = 1,
                Transactional__c = false, Fair_Value__c=30,SBQQ__NetPrice__c = 300, Exclude__c = false,Billing_Status__c='Active billing',
                Uplift_Calc_Type__c = 'Full Year', SO_Generation_Advance__c=60, Uplift_Application_Date__c  = Date.today(),
            CPI_Uplift_Override__c = 20,  SO_Amount__c = 200, CPI_Uplift_Review_Date__c = Date.Today(), 
            SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', Uplift_Effective_Date__c  = Date.today());
        
        SBQQ__Subscription__c sub22 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract2.Id, SBQQ__Quantity__c = 1,
                Transactional__c = false,  Fair_Value__c=30, SBQQ__NetPrice__c = 400, Exclude__c = false,Billing_Status__c='Active billing',
                Uplift_Calc_Type__c = 'Interim', SO_Generation_Advance__c=60, Uplift_Application_Date__c  = Date.today(),Uplift_Factor__c=1,
            CPI_Uplift_Override__c = 25,  SO_Amount__c = 200, CPI_Uplift_Review_Date__c = Date.Today(), 
            SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Semiannual', Uplift_Effective_Date__c  = Date.today());
        
        SBQQ__Subscription__c sub23 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract2.Id, SBQQ__Quantity__c = 1,
                Transactional__c = false,  Fair_Value__c=30, SBQQ__NetPrice__c = 500, Exclude__c = false,Billing_Status__c='Active billing',
                Uplift_Calc_Type__c = 'Pro-Rata', SO_Generation_Advance__c=60, Uplift_Application_Date__c  = Date.today(),Uplift_Factor__c=1,
            CPI_Uplift_Override__c = 30,  SO_Amount__c = 200, CPI_Uplift_Review_Date__c = Date.Today(), 
            SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', Uplift_Effective_Date__c  = Date.today().addYears(1));
        SBQQ__Subscription__c sub24 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract2.Id, SBQQ__Quantity__c = 1,
                Transactional__c = false,  Fair_Value__c=30, SBQQ__NetPrice__c = 500, Exclude__c = true,Billing_Status__c='Active billing',
                Uplift_Calc_Type__c = 'Pro-Rata', SO_Generation_Advance__c=60, Uplift_Application_Date__c  = Date.today(),Uplift_Factor__c=1,
            CPI_Uplift_Override__c = 30,  SO_Amount__c = 200, CPI_Uplift_Review_Date__c = Date.Today(), 
            SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', Uplift_Effective_Date__c  = Date.today().addYears(1));
        SBQQ__Subscription__c sub31 = new SBQQ__Subscription__c(SBQQ__Contract__c = contract3.Id, SBQQ__Quantity__c = 1,
                Transactional__c = false,  Fair_Value__c=30, SBQQ__NetPrice__c = 500, Exclude__c = false,Billing_Status__c='Active billing',
                Uplift_Calc_Type__c = 'Pro-Rata', SO_Generation_Advance__c=60, Uplift_Application_Date__c  = Date.today(),Uplift_Factor__c=1,
            CPI_Uplift_Override__c = 30,  SO_Amount__c = 200, CPI_Uplift_Review_Date__c = Date.Today(), 
            SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Annual', Uplift_Effective_Date__c  = Date.today().addYears(1));
        subs.add(sub11);
        subs.add(sub12);
        subs.add(sub21);
        subs.add(sub22);
        subs.add(sub23);
        subs.add(sub24);
        subs.add(sub31);
        insert subs;

        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Account__c = account.Id, SBQQ__Opportunity2__c = opp.Id);
        insert quote;
        Product2 product = new Product2(Name = 'testProd', SO_Grouping__c = 'ILF-ILF',
                CY_Billing_Current_Amount__c = 10.00, CY_Billing_Previous_Amount__c = 12.00, UPID__c = '1234561');
        insert product;

        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c line111 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = product.Id);
        SBQQ__QuoteLine__c line112 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = product.Id);
        SBQQ__QuoteLine__c line121 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = product.Id);
        SBQQ__QuoteLine__c line122 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = product.Id);
        SBQQ__QuoteLine__c line123 = new SBQQ__QuoteLine__c(SBQQ__Quote__c = quote.Id, SBQQ__Product__c = product.Id);
        quoteLines.add(line111);
        quoteLines.add(line112);
        quoteLines.add(line121);
        quoteLines.add(line122);
        quoteLines.add(line123);
        insert quoteLines;

        List<Quote_Line_Transaction_Tier__c> tiers = new List<Quote_Line_Transaction_Tier__c>();
        Quote_Line_Transaction_Tier__c tier111 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub11.Id,
                Quote_Line__c = line111.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 100,Price__c=100,Minimum_Price__c=100);
        Quote_Line_Transaction_Tier__c tier112 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub11.Id,
                Quote_Line__c = line112.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 150,Price__c=100,Minimum_Price__c=100);
        Quote_Line_Transaction_Tier__c tier121 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub12.Id,
                Quote_Line__c = line121.Id, Start_Date__c = Date.today().addDays(5), Unit_Price__c = 200,Price__c=100,Minimum_Price__c=100); // not included in calc
        Quote_Line_Transaction_Tier__c tier122 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub12.Id,
                Quote_Line__c = line122.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 300,Price__c=100,Minimum_Price__c=100);
        Quote_Line_Transaction_Tier__c tier123 = new Quote_Line_Transaction_Tier__c(Subscription__c = sub12.Id,
                Quote_Line__c = line123.Id, Start_Date__c = Date.today().addDays(-15), Unit_Price__c = 400,Price__c=100,Minimum_Price__c=100);

        tiers.add(tier111);
        tiers.add(tier112);
        tiers.add(tier121);
        tiers.add(tier122);
        tiers.add(tier123);
        insert tiers;
    }
    
    public static void createUpliftData(){

        baseData = Uplift_TestUtils.SetupBasicScenario();

        /***********************************************************************************************************/
        // when
        uplifts = [select id, Name, Start_Date__c, Exclude__c, Percentage__c, Uplift_Application_Date__c ,NCU__c, Account__r.ownerId, Account__r.owner.Email, Account__r.name,  
                    (select Id, SBQQ__Contract__c, SBQQ__Quantity__c, Exclude__c,
                            SBQQ__NetPrice__c, Transactional__c, CPI_Uplift__c,
                            CPI_Uplift__r.Id, CPI_Uplift__r.NCU__c,
                            CPI_Uplift__r.Exclude__c, SBQQ__Contract__r.Skip_Uplift__c,
                            CPI_Uplift__r.Percentage__c from Subscriptions__r)
                    from Uplift__c
                    where Uplift_Application_Date__c  = :Date.today()];
        system.debug('===> UpliftUtils.createUplift :: uplift.Subscriptions__r: '+uplifts.get(0).Subscriptions__r);
    }
    

    private static testmethod void createUpliftTest(){
        //Process Uplift For Subscriptions
        createUpliftData();
        
        // having
        Test.startTest();
            UpliftUtils.createUplift(uplifts);
    
            /***********************************************************************************************************/
            // then
            Uplift_TestUtils.ResultData result = Uplift_TestUtils.queryCreatedArtifacts(baseData.uplift1Id);
    
            /*System.assertEquals(360, result.resultSubscriptions.get(baseData.sub21Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
            System.assertEquals(0, result.resultSubscriptions.get(baseData.sub22Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
            System.assertEquals(650, result.resultSubscriptions.get(baseData.sub23Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
            */// not changed because of exclude flag
            //System.assertEquals(500, result.resultSubscriptions.get(baseData.sub24Id).SBQQ__NetPrice__c, 'Net price on subscription should remain unchanged');
            System.assertEquals(true, result.resultSubscriptions.get(baseData.sub24Id).Exclude__c, 'Skip flag on subscription should be removed');
            // not changed because of skip flag on contract
            //System.assertEquals(500, result.resultSubscriptions.get(baseData.sub31Id).SBQQ__NetPrice__c, 'Net price on subscription should remain unchanged');
    
            // not changed because uplift not active
            System.assertEquals(100, result.resultQLineToTiers.get(baseData.line111Id).Unit_Price__c, 'Unit price on tier should remain unchanged');
            // not changed because uplift not active
            System.assertEquals(150, result.resultQLineToTiers.get(baseData.line112Id).Unit_Price__c, 'Unit price on tier should remain unchanged');
            // not changed because of the date condition
            System.assertEquals(200, result.resultQLineToTiers.get(baseData.line121Id).Unit_Price__c, 'Unit price on tier should remain unchanged');
    
            //System.assertEquals(345, result.resultQLineToTiers.get(baseData.line122Id).Unit_Price__c, 'Unit price on tier should be increased by uptick');
            //System.assertEquals(460, result.resultQLineToTiers.get(baseData.line123Id).Unit_Price__c, 'Unit price on tier should be increased by uptick');
    
            System.assertEquals(false, result.resultUplift.Exclude__c, 'Skip flag on uplift should be removed');
        Test.stopTest();
    }
    private static testmethod void createUpliftTest_2(){
        List<Contract> contractsList = new List<Contract>([Select Id from Contract]);
        Test.startTest();
        
        UpliftUtils.createUpliftFromContract(contractsList);
            
        Test.stopTest();
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>([Select Id from SBQQ__Subscription__c]);
    
    }
    private static testmethod void createUpliftTest_With_Null(){
        //-ve
        Test.startTest();
            UpliftUtils.createUplift(null);
    
            system.assert(UpliftUtils.subscriptionsToUpdate.isempty());
            system.assert(UpliftUtils.tiersToUpdate.isempty());
        Test.stopTest();
    }
    private static testmethod void createUpliftTest_With_Null_2(){
        //-ve
        Test.startTest();
            UpliftUtils.createUpliftFromContract(null);
    
            system.assert(UpliftUtils.subscriptionsToUpdate.isempty());
            system.assert(UpliftUtils.tiersToUpdate.isempty());
        Test.stopTest();
    }
    private static testmethod void createUpliftTest_With_EmptyList(){
        //-ve
        Test.startTest();
            UpliftUtils.createUplift(new List<Uplift__c>());
    
            system.assert(UpliftUtils.subscriptionsToUpdate.isempty());
            system.assert(UpliftUtils.tiersToUpdate.isempty());
        Test.stopTest();
    }
    private static testmethod void createUpliftTest_With_EmptyList_2(){
        //-ve
        Test.startTest();
            UpliftUtils.createUpliftFromContract(new List<Contract>());
    
            system.assert(UpliftUtils.subscriptionsToUpdate.isempty());
            system.assert(UpliftUtils.tiersToUpdate.isempty());
        Test.stopTest();
    }
    private static testMethod void testProcessUpliftForNonTransactionalSubs() {
        createUpliftData();
        
        List<SBQQ__Subscription__c> nonTransactionalSubs = [ select Id, SBQQ__Contract__c, SBQQ__Contract__r.Recurring_Fees_Index_Type__c, SBQQ__Contract__r.Skip_Uplift__c, SBQQ__Quantity__c, Exclude__c, Billing_group__r.Next_SO_generation_Date__c, Billing_group__r.Next_Billing_Date__c,
                    SBQQ__NetPrice__c,Fair_Value__c , Transactional__c, CPI_Uplift__c,Expired_Subscription__c, CPI_Uplift__r.Id, CPI_Uplift__r.Exclude__c, Quote_recurring_price__c, SO_Generation_Advance__c, 
                    CPI_Uplift__r.NCU__c, CPI_Uplift__r.Percentage__c,CPI_Uplift__r.Uplift_Application_Date__c,CPI_Uplift__r.Uplift_Effective_Date__c, CPI_Uplift__r.Billing_Type__c,CPI_Uplift__r.Billing_Frequency__c,CPI_Uplift__r.Uplift_Factor__c, CPI_Uplift__r.Status__c from SBQQ__Subscription__c where Billing_Status__c='Active billing' and Transactional__c = false];
        
        Test.startTest();
            UpliftUtils.processUpliftForNonTransactionalSubs(nonTransactionalSubs);
        Test.stopTest();

        Uplift_TestUtils.ResultData result = Uplift_TestUtils.queryCreatedArtifacts(baseData.uplift1Id);

        System.assertEquals(300, result.resultSubscriptions.get(baseData.sub21Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        System.assertEquals(400, result.resultSubscriptions.get(baseData.sub22Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub23Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        // not changed because of exclude flag
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub24Id).SBQQ__NetPrice__c, 'Net price on subscription should remain unchanged');
        System.assertEquals(true, result.resultSubscriptions.get(baseData.sub24Id).Exclude__c, 'Skip flag on subscription should be removed');
        // not changed because of skip flag on contract
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub31Id).SBQQ__NetPrice__c, 'Net price on subscription should remain unchanged');
    }
    private static testMethod void testProcessUpliftForNonTransactionalSubs_2() {
        
        List<SBQQ__Subscription__c> nonTransactionalSubs = [ select Id, SBQQ__Contract__c, SBQQ__Contract__r.Recurring_Fees_Index_Type__c, SBQQ__Contract__r.Hold_CPI_Uplift__c, SBQQ__Contract__r.Skip_Uplift__c, SBQQ__Quantity__c, Exclude__c, Billing_group__r.Next_SO_generation_Date__c, Billing_group__r.Next_Billing_Date__c,
                    SBQQ__NetPrice__c, Fair_Value__c, Transactional__c, Uplift_Effective_Date__c, Quote_recurring_price__c, SO_Generation_Advance__c, Uplift_Factor__c, SO_Amount__c, SBQQ__ProrateMultiplier__c, Uplift_Calc_Type__c
                    from SBQQ__Subscription__c where Billing_Status__c='Active billing' and Transactional__c = false and SBQQ__NetPrice__c = 400];
        
        Test.startTest();
            UpliftUtils.processCPIUpliftForNonTransactionalSubs(nonTransactionalSubs);
        Test.stopTest();

        nonTransactionalSubs = [ select Id, SBQQ__Contract__c, SBQQ__Contract__r.Recurring_Fees_Index_Type__c, SBQQ__Contract__r.Skip_Uplift__c, SBQQ__Quantity__c, Exclude__c, Billing_group__r.Next_SO_generation_Date__c, Billing_group__r.Next_Billing_Date__c,
                    SBQQ__NetPrice__c,Fair_Value__c , Transactional__c,  Quote_recurring_price__c, SO_Generation_Advance__c, Uplift_Factor__c, SO_Amount__c, SBQQ__ProrateMultiplier__c, Uplift_Calc_Type__c
                    from SBQQ__Subscription__c where Billing_Status__c='Active billing' and Transactional__c = false and Id = :nonTransactionalSubs[0].Id];
        
        System.assertEquals(400, nonTransactionalSubs[0].SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
    }
    private static testMethod void testPerformUpdate() {
        createUpliftData();
        List<SBQQ__Subscription__c> subs = [select id, Fair_Value__c from SBQQ__Subscription__c limit 1];
        subs[0].Fair_Value__c=99.99;
        Test.startTest();
            UpliftUtils.performUpdate(subs);
        Test.stopTest();

        SBQQ__Subscription__c sub = [select id, Fair_Value__c from SBQQ__Subscription__c where id=:subs[0].id];
        System.assertEquals(99.99, sub.Fair_Value__c, 'Fair_Value__ c should have been updated');
        

    }
    private static testMethod void testPerformUpdate_With_EmptyList() {
        Test.startTest();
        try {
            UpliftUtils.performUpdate(new List<SBQQ__Subscription__c> ());
            System.assert(true,'Should not throw exception');
        } catch (Exception e){
        }
        Test.stopTest();
    }
    private static testMethod void testPerformUpdate_With_Null() {
        Test.startTest();
        try {
            UpliftUtils.performUpdate(null);
        } catch (Exception e){
            System.assert(true,'Should throw exception');
        }
        Test.stopTest();
    }
    private static testMethod void testProcessUpliftForNonTransactionalSubs_With_TransactionalSubs() {
        createUpliftData();
        
        List<SBQQ__Subscription__c> nonTransactionalSubs = [ select Id, SBQQ__Contract__c, SBQQ__Contract__r.Recurring_Fees_Index_Type__c, SBQQ__Contract__r.Skip_Uplift__c, SBQQ__Quantity__c, Exclude__c, Billing_group__r.Next_SO_generation_Date__c, Billing_group__r.Next_Billing_Date__c,
                    SBQQ__NetPrice__c,Fair_Value__c , Transactional__c, CPI_Uplift__c,Expired_Subscription__c, CPI_Uplift__r.Id, CPI_Uplift__r.Exclude__c, Quote_recurring_price__c, SO_Generation_Advance__c, 
                    CPI_Uplift__r.NCU__c, CPI_Uplift__r.Percentage__c,CPI_Uplift__r.Uplift_Application_Date__c,CPI_Uplift__r.Uplift_Effective_Date__c, CPI_Uplift__r.Billing_Type__c,CPI_Uplift__r.Billing_Frequency__c,CPI_Uplift__r.Uplift_Factor__c, CPI_Uplift__r.Status__c from SBQQ__Subscription__c where Billing_Status__c='Active billing' and Transactional__c = true];
        
        Test.startTest();
            UpliftUtils.processUpliftForNonTransactionalSubs(nonTransactionalSubs);
        Test.stopTest();
        
        Uplift_TestUtils.ResultData result = Uplift_TestUtils.queryCreatedArtifacts(baseData.uplift1Id);

        System.assertEquals(300, result.resultSubscriptions.get(baseData.sub21Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        System.assertEquals(400, result.resultSubscriptions.get(baseData.sub22Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub23Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        // not changed because of exclude flag
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub24Id).SBQQ__NetPrice__c, 'Net price on subscription should remain unchanged');
        System.assertEquals(true, result.resultSubscriptions.get(baseData.sub24Id).Exclude__c, 'Skip flag on subscription should be removed');
        // not changed because of skip flag on contract
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub31Id).SBQQ__NetPrice__c, 'Net price on subscription should remain unchanged');
    }
    private static testMethod void testProcessUpliftForNonTransactionalSubs_With_InactiveBilling() {
        createUpliftData();
        
        List<SBQQ__Subscription__c> nonTransactionalSubs = [ select Id, SBQQ__Contract__c, SBQQ__Contract__r.Recurring_Fees_Index_Type__c, SBQQ__Contract__r.Skip_Uplift__c, SBQQ__Quantity__c, Exclude__c, Billing_group__r.Next_SO_generation_Date__c, Billing_group__r.Next_Billing_Date__c,
                    SBQQ__NetPrice__c,Fair_Value__c , Transactional__c, CPI_Uplift__c,Expired_Subscription__c, CPI_Uplift__r.Id, CPI_Uplift__r.Exclude__c, Quote_recurring_price__c, SO_Generation_Advance__c, 
                    CPI_Uplift__r.NCU__c, CPI_Uplift__r.Percentage__c,CPI_Uplift__r.Uplift_Application_Date__c,CPI_Uplift__r.Uplift_Effective_Date__c, CPI_Uplift__r.Billing_Type__c,CPI_Uplift__r.Billing_Frequency__c,CPI_Uplift__r.Uplift_Factor__c, CPI_Uplift__r.Status__c from SBQQ__Subscription__c where Billing_Status__c!='Active billing' and Transactional__c = true];
        
        Test.startTest();
            UpliftUtils.processUpliftForNonTransactionalSubs(nonTransactionalSubs);
        Test.stopTest();

        Uplift_TestUtils.ResultData result = Uplift_TestUtils.queryCreatedArtifacts(baseData.uplift1Id);

        System.assertEquals(300, result.resultSubscriptions.get(baseData.sub21Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        System.assertEquals(400, result.resultSubscriptions.get(baseData.sub22Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub23Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        // not changed because of exclude flag
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub24Id).SBQQ__NetPrice__c, 'Net price on subscription should remain unchanged');
        System.assertEquals(true, result.resultSubscriptions.get(baseData.sub24Id).Exclude__c, 'Skip flag on subscription should be removed');
        // not changed because of skip flag on contract
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub31Id).SBQQ__NetPrice__c, 'Net price on subscription should remain unchanged');
    }
    private static testMethod void testProcessUpliftForTransactionalSubs() {
        createUpliftData();
        
        List<SBQQ__Subscription__c> nonTransactionalSubs = [ select Id, SBQQ__Contract__c, SBQQ__Contract__r.Recurring_Fees_Index_Type__c, SBQQ__Contract__r.Skip_Uplift__c, SBQQ__Quantity__c, Exclude__c, Billing_group__r.Next_SO_generation_Date__c, Billing_group__r.Next_Billing_Date__c,
                    SBQQ__NetPrice__c,Fair_Value__c , Transactional__c, CPI_Uplift__c,Expired_Subscription__c, CPI_Uplift__r.Id, CPI_Uplift__r.Exclude__c, Quote_recurring_price__c, SO_Generation_Advance__c, 
                    CPI_Uplift__r.NCU__c, CPI_Uplift__r.Percentage__c,CPI_Uplift__r.Uplift_Application_Date__c,CPI_Uplift__r.Uplift_Effective_Date__c, CPI_Uplift__r.Billing_Type__c,CPI_Uplift__r.Billing_Frequency__c,CPI_Uplift__r.Uplift_Factor__c, CPI_Uplift__r.Status__c from SBQQ__Subscription__c where Billing_Status__c='Active billing' and Transactional__c = true];
        
        Test.startTest();
            UpliftUtils.processUpliftForTransactionalSubs(nonTransactionalSubs);
        Test.stopTest();

        Uplift_TestUtils.ResultData result = Uplift_TestUtils.queryCreatedArtifacts(baseData.uplift1Id);

        System.assertEquals(300, result.resultSubscriptions.get(baseData.sub21Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        System.assertEquals(400, result.resultSubscriptions.get(baseData.sub22Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub23Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        // not changed because of exclude flag
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub24Id).SBQQ__NetPrice__c, 'Net price on subscription should remain unchanged');
        System.assertEquals(true, result.resultSubscriptions.get(baseData.sub24Id).Exclude__c, 'Skip flag on subscription should be removed');
        // not changed because of skip flag on contract
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub31Id).SBQQ__NetPrice__c, 'Net price on subscription should remain unchanged');
    }
    private static testMethod void testProcessUpliftForTransactionalSubs_With_NonTransactionalSubs() {
        createUpliftData();
        
        List<SBQQ__Subscription__c> nonTransactionalSubs = [ select Id, SBQQ__Contract__c, SBQQ__Contract__r.Recurring_Fees_Index_Type__c, SBQQ__Contract__r.Skip_Uplift__c, SBQQ__Quantity__c, Exclude__c, Billing_group__r.Next_SO_generation_Date__c, Billing_group__r.Next_Billing_Date__c,
                    SBQQ__NetPrice__c,Fair_Value__c , Transactional__c, CPI_Uplift__c,Expired_Subscription__c, CPI_Uplift__r.Id, CPI_Uplift__r.Exclude__c, Quote_recurring_price__c, SO_Generation_Advance__c, 
                    CPI_Uplift__r.NCU__c, CPI_Uplift__r.Percentage__c,CPI_Uplift__r.Uplift_Application_Date__c,CPI_Uplift__r.Uplift_Effective_Date__c, CPI_Uplift__r.Billing_Type__c,CPI_Uplift__r.Billing_Frequency__c,CPI_Uplift__r.Uplift_Factor__c, CPI_Uplift__r.Status__c from SBQQ__Subscription__c where Billing_Status__c='Active billing' and Transactional__c = false];
        
        Test.startTest();
            UpliftUtils.processUpliftForTransactionalSubs(nonTransactionalSubs);
        Test.stopTest();

        Uplift_TestUtils.ResultData result = Uplift_TestUtils.queryCreatedArtifacts(baseData.uplift1Id);

        System.assertEquals(300, result.resultSubscriptions.get(baseData.sub21Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        System.assertEquals(400, result.resultSubscriptions.get(baseData.sub22Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub23Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        // not changed because of exclude flag
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub24Id).SBQQ__NetPrice__c, 'Net price on subscription should remain unchanged');
        System.assertEquals(true, result.resultSubscriptions.get(baseData.sub24Id).Exclude__c, 'Skip flag on subscription should be removed');
        // not changed because of skip flag on contract
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub31Id).SBQQ__NetPrice__c, 'Net price on subscription should remain unchanged');
    }
    private static testMethod void testProcessUpliftForTransactionalSubs_With_InactiveBilling() {
        createUpliftData();
        
        List<SBQQ__Subscription__c> nonTransactionalSubs = [ select Id, SBQQ__Contract__c, SBQQ__Contract__r.Recurring_Fees_Index_Type__c, SBQQ__Contract__r.Skip_Uplift__c, SBQQ__Quantity__c, Exclude__c, Billing_group__r.Next_SO_generation_Date__c, Billing_group__r.Next_Billing_Date__c,
                    SBQQ__NetPrice__c,Fair_Value__c , Transactional__c, CPI_Uplift__c,Expired_Subscription__c, CPI_Uplift__r.Id, CPI_Uplift__r.Exclude__c, Quote_recurring_price__c, SO_Generation_Advance__c, 
                    CPI_Uplift__r.NCU__c, CPI_Uplift__r.Percentage__c,CPI_Uplift__r.Uplift_Application_Date__c,CPI_Uplift__r.Uplift_Effective_Date__c, CPI_Uplift__r.Billing_Type__c,CPI_Uplift__r.Billing_Frequency__c,CPI_Uplift__r.Uplift_Factor__c, CPI_Uplift__r.Status__c from SBQQ__Subscription__c where Billing_Status__c!='Active billing' and Transactional__c = true];
        
        Test.startTest();
            UpliftUtils.processUpliftForTransactionalSubs(nonTransactionalSubs);
        Test.stopTest();

        Uplift_TestUtils.ResultData result = Uplift_TestUtils.queryCreatedArtifacts(baseData.uplift1Id);

        System.assertEquals(300, result.resultSubscriptions.get(baseData.sub21Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        System.assertEquals(400, result.resultSubscriptions.get(baseData.sub22Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub23Id).SBQQ__NetPrice__c, 'Net price on subscription should be increased by uptick');
        // not changed because of exclude flag
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub24Id).SBQQ__NetPrice__c, 'Net price on subscription should remain unchanged');
        System.assertEquals(true, result.resultSubscriptions.get(baseData.sub24Id).Exclude__c, 'Skip flag on subscription should be removed');
        // not changed because of skip flag on contract
        System.assertEquals(500, result.resultSubscriptions.get(baseData.sub31Id).SBQQ__NetPrice__c, 'Net price on subscription should remain unchanged');
    }
}