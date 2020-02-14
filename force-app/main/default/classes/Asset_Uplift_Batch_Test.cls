/**
 * @author Konrad Marciniak konrad.marciniak@weare4c.com
 * Test class for the Asset_Uplift_Batch
 */
@IsTest
public class Asset_Uplift_Batch_Test {

    /**
     * Preparing data for tests
     */
    @TestSetup
    static void setup() {

        Account account = TestDataFactory.createAccount('Test Account');

        FDIC_NCUA_Data__c fdic = createFDIC(account);

        account.DH_MSCRM_Hfs_fdic_num__c = '12345';
        account.DH_MSCRM_Hfs_charter_num__c = '12345';
        account.FDIC_NCUA_Data__c = fdic.Id;
        update account;

        Opportunity opportunity = TestDataFactory.createOpportunity(account);

        List<Contract> contracts = new List<Contract>();
        for (Integer i = 0; i < 10; i++) {
            contracts.add(Asset_Uplift_Batch_Test.createContract('Test Con ' + i, account, opportunity, false));
        }
        insert contracts;

        List<SBQQ__Subscription__c> subAutoUplifts = new List<SBQQ__Subscription__c>();
        for (Contract contract : contracts) {
            subAutoUplifts.add(TestDataFactory.createILF_Subscription(contract, false));
        }
        insert subAutoUplifts;

        for (SBQQ__Subscription__c sub : subAutoUplifts) {
            //sub.ILF_Asset_Size__c = 1006;
            sub.Uplift_Multiplier__c = 20;
            sub.RLF_Uplift_Multiplier_Percent__c = 20;
            sub.Billing_Method__c = 'Asset';
            sub.Billing_Day__c = 1;
            sub.Billing_Month__c = 'January';
            //sub.Manual_Uplift__c = false;
        }
        update subAutoUplifts;
    }

    /**
     * Test of the start method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks is the start method returns a correct query.
     */
    @IsTest
    static void testBatchStart() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email = 'newuser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p2.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'misystest2@testorg.com');

        System.runAs(u3) {

            Test.startTest();
            Asset_Uplift_Batch myBatchObject = new Asset_Uplift_Batch();
            Database.QueryLocator queryLocator = myBatchObject.start(null);
            Test.stopTest();

            System.assertEquals(queryLocator.getQuery(), Database.getQueryLocator('select id,Next_Asset_Uplift_Date__c from contract where Next_Asset_Uplift_Date__c <=TODAY LIMIT 1').getQuery());
        }
    }

    /**
     * Test of the batch execute method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if the execute method returns a batch Id and the Id != null.
     */
    @IsTest
    static void testBatchExecute() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email = 'newuser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p2.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'misystest2@testorg.com');

        System.runAs(u3) {

            Test.startTest();
            Asset_Uplift_Batch myBatchObject = new Asset_Uplift_Batch();
            Id batchId = Database.executeBatch(myBatchObject);
            Test.stopTest();

            System.assertNotEquals(null, batchId);
        }
    }

    /**
     * Test of the schedule execute method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if the execute method returns ajob Id and the Id != null
     */
    @IsTest
    static void testScheduleExecute() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email = 'newuser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p2.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'misystest2@testorg.com');

        System.runAs(u3) {

            String CRON_EXP = '0 0 0 15 3 ? *';

            Test.StartTest();

            String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new Asset_Uplift_Batch());

            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

            Test.stopTest();
        }
    }

    /**
     * The auxiliary method for creating a new FDIC_NCUA_Data__c for a given account.
     *
     * @param account - Account object
     *
     * @return FDIC_NCUA_Data__c object
     */
    static private FDIC_NCUA_Data__c createFDIC(Account account) {
        FDIC_NCUA_Data__c fdic = new FDIC_NCUA_Data__c();
        fdic.Account__c = account.Id;
        fdic.Total_Assets__c = 1001;
        fdic.NCUA_Total_Assets__c = 1002;
        fdic.Loans_and_Leases__c = 1006;
        fdic.Loans_and_Leases_minus_Family_Residentia__c = 0;
        fdic.Consumer_and_Commercial_Loans__c = 0;
        fdic.Commercial_Loans__c = 0;
        fdic.Total_Deposits__c = 1003;
        fdic.Member_Business_Loans__c = 1005;
        fdic.Quarter__c = getQuarter(System.today());
        fdic.Year__c = String.valueOf(System.today().year());
        fdic.Certificate__c = '12345';

        insert fdic;
        return fdic;
    }

    /**
     * The auxiliary method returning the quarter number for a given date.
     *
     * @param givenDate - date
     *
     * @return Number of quarter
     */
    static private Integer getQuarter(Date givenDate) {
        Set<Integer> Q1 = new Set<Integer>{
                1, 2, 3
        };
        Set<Integer> Q2 = new Set<Integer>{
                4, 5, 6
        };
        Set<Integer> Q3 = new Set<Integer>{
                7, 8, 9
        };
        Set<Integer> Q4 = new Set<Integer>{
                10, 11, 12
        };

        Integer month = givenDate.month();
        Integer quarter;

        if (Q1.contains(month)) {
            quarter = 1;
        }
        if (Q2.contains(month)) {
            quarter = 2;
        }
        if (Q3.contains(month)) {
            quarter = 3;
        }
        if (Q4.contains(month)) {
            quarter = 4;
        }

        return quarter;
    }

    /**
     * The auxiliary method for creating a new Contract for a given contract name, account and opportunity.
     *
     * @param conName - contract name
     * @param acc - account object
     * @param opp - opportunity object
     * @param dbInsert - true (insert into database); false (don't)
     *
     * @return - contract object
     */
    private static Contract createContract(String conName, Account acc, Opportunity opp, Boolean dbInsert) {

        Billing_Entity__c be = TestDataFactory.createBillingEntity();

        Contract con = new Contract();

        con.Name = String.isEmpty(conName) ? 'Test Con' : conName;
        con.AccountId = acc.Id;
        con.Misys_Entity__c = be.Id;
        con.CurrencyIsoCode = 'USD';
        con.Misys_Opportunity__c = opp.Id;
        con.Recurring_Fees_Start_Planned__c = system.today() + 10;
        con.Next_Asset_Uplift_Date__c = system.today() - 10;
        con.StartDate = System.today();
        con.Asset_Size__c = 1006; 
        con.Manual_Uplift__c = false;
        
        if (dbInsert) {
            insert con;
        }

        return con;
    }

}