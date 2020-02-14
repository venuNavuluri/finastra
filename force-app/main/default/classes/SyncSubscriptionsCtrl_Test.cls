@IsTest
private class SyncSubscriptionsCtrl_Test {

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
        
        Contract contract1 = new Contract(accountId = account.Id, SBQQ__Opportunity__c = opp.Id, Uplift_Calc_Type__c = 'Pro-Rata', CPI_Uplift_Type__c='Calendar', Billing_Frequency__c = 'Monthly',
                                            Hold_CPI_Uplift__c = false, Active__c = true, Uplift_Application_Date__c  = Date.today(), Next_Uplift_Date__c = Date.today(), status = 'Draft', ContractTerm = 12);
        insert contract1;
        contract1.status = 'Is Active';
        update contract1;        
        
        SBQQ__Subscription__c subscription = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1, Billing_Group__c = billingGroup.Id, Uplift_Calc_Type__c = 'Pro-Rata', SO_Generation_Advance__c=60, Varied_Licence__c = true,SBQQ__Contract__c = contract1.id, Uplift_Application_Date__c  = Date.today(),
                Transactions__c = 2, Sold_Value__c = 50, SBQQ__NetPrice__c = 100, CPI_Uplift_Review_Date__c = Date.Today(), SBQQ__BillingType__c = 'Advance', SBQQ__BillingFrequency__c = 'Monthly', Uplift_Effective_Date__c  = Date.today(), ProdType__c='RLF');
        insert subscription; 
        
    }

    @IsTest
    static void testExecute_Contract() {
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            Contract contract = [SELECT Id FROM Contract LIMIT 1];

            Test.startTest();
            
            SyncSubscriptionsCtrl.SyncSubscriptionData syncSubUpliftData = SyncSubscriptionsCtrl.execute(contract.Id, 'Contract');
            System.assertEquals(true, syncSubUpliftData.showSuccess);

            SyncSubscriptionsCtrl.SyncSubscriptionData syncSubUpliftDataError = new SyncSubscriptionsCtrl.SyncSubscriptionData();
            try {
                syncSubUpliftDataError = SyncSubscriptionsCtrl.execute(Id.valueOf('0010D000007yIL6QAM'), 'Contract');
            } catch(Exception e) {
                System.assertEquals(false, syncSubUpliftDataError.showSuccess);
            }

            Test.stopTest();
        }
    }
    @IsTest
    static void testExecute_BillingGroup() {
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            Billing_Group__c billingGroup = [SELECT Id FROM Billing_Group__c LIMIT 1];

            Test.startTest();
            
            SyncSubscriptionsCtrl.SyncSubscriptionData syncSubUpliftData = SyncSubscriptionsCtrl.execute(billingGroup.Id, 'BillingGroup');
            System.assertEquals(true, syncSubUpliftData.showSuccess);

            SyncSubscriptionsCtrl.SyncSubscriptionData syncSubUpliftDataError = new SyncSubscriptionsCtrl.SyncSubscriptionData();
            try {
                syncSubUpliftDataError = SyncSubscriptionsCtrl.execute(Id.valueOf('0010D000007yIL6QAM'), 'BillingGroup');
            } catch(Exception e) {
                System.assertEquals(false, syncSubUpliftDataError.showSuccess);
            }

            Test.stopTest();
        }
    }

    @IsTest
    static void testGetInfo_Contract() {
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            Contract contract = [SELECT Id FROM Contract LIMIT 1];

            Test.startTest();

            SyncSubscriptionsCtrl.SyncSubscriptionData syncSubUpliftData = SyncSubscriptionsCtrl.getInfo(contract.Id, 'Contract');
            System.assertEquals(true, syncSubUpliftData.showConfirm);

            try {
                SyncSubscriptionsCtrl.SyncSubscriptionData syncSubUpliftData1 = SyncSubscriptionsCtrl.getInfo(Id.valueOf('0010D000007yIL6QAM'), 'Contract1');
                System.assertEquals(false, syncSubUpliftData1.showConfirm);
            } catch(Exception e) {}


            Test.stopTest();
        }
    }
    @IsTest
    static void testGetInfo_BillingGroup() {
        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            Billing_Group__c billingGroup = [SELECT Id FROM Billing_Group__c LIMIT 1];

            Test.startTest();

            SyncSubscriptionsCtrl.SyncSubscriptionData syncSubUpliftData = SyncSubscriptionsCtrl.getInfo(billingGroup.Id, 'BillingGroup');
            System.assertEquals(true, syncSubUpliftData.showConfirm);

            try {
                SyncSubscriptionsCtrl.SyncSubscriptionData syncSubUpliftData1 = SyncSubscriptionsCtrl.getInfo(Id.valueOf('0010D000007yIL6QAM'), 'BillingGroup1');
                System.assertEquals(false, syncSubUpliftData1.showConfirm);
            } catch(Exception e) {}


            Test.stopTest();
        }
    }
}