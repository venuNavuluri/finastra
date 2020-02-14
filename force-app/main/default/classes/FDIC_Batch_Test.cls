/**
 * @author Konrad Marciniak konrad.marciniak@weare4c.com
 * Test class for the FDIC_Batch class
 */
@isTest
public class FDIC_Batch_Test {

    /**
     * Preparing data for tests
     */
    @TestSetup
    static void setup() {

        Account account = TestUtility.createAccount('Test Account');
        FDIC_NCUA_Data__c fdicncuaData = createFDIC(account);
    }

    /**
     * Test of the start method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if created by the method object QueryLocator is not null.
     */
    @IsTest
    static void testFDICBatchStart() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email = 'newuser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p2.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'misystest2@testorg.com');

        System.runAs(u3) {

            Test.startTest();
            FDIC_Batch myBatchObject = new FDIC_Batch();
            Database.QueryLocator ql = myBatchObject.start(null);
            System.assertNotEquals(null, ql);
            Test.stopTest();
        }
    }

    /**
     * Test of the batch execute method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if the execute method returns a batch Id and the Id != null.
     */
    @IsTest
    static void testFDICBatchExecute() {
		FDIC_NCUA_Data__c data = new FDIC_NCUA_Data__c();
        data.Certificate__c = '555222';
        data.Quarter__c = 1;
        data.Year__c = '2018';
        insert data;
        system.assert(data.Account__c == null,'account__c is not empty');
        Profile p2 = [SELECT Id FROM Profile WHERE Name = 'M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email = 'newuser@testorg.com', EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p2.Id, TimeZoneSidKey = 'America/Los_Angeles', UserName = 'misystest2@testorg.com');

        System.runAs(u3) {

            Test.startTest();
            FDIC_Batch myBatchObject = new FDIC_Batch();
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

            String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new FDIC_Batch());

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
     * @return - FDIC_NCUA_Data__c object
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
}