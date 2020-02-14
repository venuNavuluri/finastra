/**
 * @author Konrad Marciniak konrad.marciniak@weare4c.com
 * Test class for the FDIC class
 */
@IsTest
private class FDIC_Test {

    /**
     * Preparing data for tests
     */
    @TestSetup
    static void setup() {

        Account testAcc = TestUtility.sampleAccount();
        insert testAcc;

        System__c firstSystem = new System__c();
        firstSystem.Account__c = testAcc.Id;
        firstSystem.Name = 'System Name 1';
        firstSystem.Environment2__c = 'PROD';
        insert firstSystem;

        List<FDIC_NCUA_Data__c> fdicncuaData2 = createFDICList(5, '1234');
        List<Account> accounts = createAccounts(5);

        FDIC_NCUA_Data__c fdicRec = new FDIC_NCUA_Data__c();

        fdicRec = new FDIC_NCUA_Data__c();
        fdicRec.Total_Assets__c = 200;
        fdicRec.Quarter__c = 1;
        fdicRec.Year__c = '2018';
        fdicRec.Certificate__c = '87654';
        fdicRec.Data_Source__c = 'FDIC';

        insert fdicRec;

        Account acc = new Account();
        acc.Name = 'Account';
        acc.DH_MSCRM_Hfs_fdic_num__c = '87654';
        acc.DH_MSCRM_Hfs_charter_num__c = '87654';
        acc.FDIC_NCUA_Data__c = null;
        insert acc;
    }

    /**
     * Test of the beforeUpdateFDIC method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if FDIC_NCUA_Data__c records have been processed correctly during update
     */
    @IsTest
    static void testBeforeUpdateFDIC() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            Test.startTest();

            List<FDIC_NCUA_Data__c> fdicncuaData = [SELECT Id, Data_Source__c, Certificate__c, Account__c, lnrecons__c, lnrenres__c, lnremult__c, lnci__c, lnlsnet__c, lnrersfm__c, Commercial_Loans__c, Consumer_and_Commercial_Loans__c, Loans_and_Leases_minus_Family_Residentia__c FROM FDIC_NCUA_Data__c WHERE Certificate__c LIKE '87654%'];
            System.assertEquals(1, fdicncuaData.size());
            System.assertEquals(0, fdicncuaData[0].Commercial_Loans__c);
            System.assertEquals(0, fdicncuaData[0].Consumer_and_Commercial_Loans__c);
            System.assertEquals(0, fdicncuaData[0].Loans_and_Leases_minus_Family_Residentia__c);
            System.assertEquals(null, fdicncuaData[0].lnrecons__c);
            System.assertEquals(null, fdicncuaData[0].lnrenres__c);
            System.assertEquals(null, fdicncuaData[0].lnremult__c);
            System.assertEquals(null, fdicncuaData[0].lnci__c);
            System.assertEquals(null, fdicncuaData[0].lnlsnet__c);
            System.assertEquals(null, fdicncuaData[0].lnrersfm__c);

            for(FDIC_NCUA_Data__c fdic : fdicncuaData) {
                fdic.lnrecons__c = 100;
                fdic.lnrenres__c = 100;
                fdic.lnremult__c = 100;
                fdic.lnci__c = 100;
                fdic.lnlsnet__c = 100;
                fdic.lnrersfm__c = 100;
                fdic.Data_Source__c = 'FDIC';
            }

            Database.SaveResult[] res = Database.update(fdicncuaData, false);

            for(Database.SaveResult sr : res) {
                System.assertEquals(true, sr.success);
            }

            fdicncuaData = [SELECT Id, lnrecons__c, lnrenres__c, lnremult__c, lnci__c, lnlsnet__c, lnrersfm__c, Commercial_Loans__c, Consumer_and_Commercial_Loans__c, Loans_and_Leases_minus_Family_Residentia__c FROM FDIC_NCUA_Data__c WHERE Certificate__c LIKE '87654%' ];

            System.assertEquals(400, fdicncuaData[0].Commercial_Loans__c);
            System.assertEquals(0, fdicncuaData[0].Consumer_and_Commercial_Loans__c);
            System.assertEquals(100, fdicncuaData[0].Loans_and_Leases_minus_Family_Residentia__c);
            System.assertEquals(100, fdicncuaData[0].lnrecons__c);
            System.assertEquals(100, fdicncuaData[0].lnrenres__c);
            System.assertEquals(100, fdicncuaData[0].lnremult__c);
            System.assertEquals(100, fdicncuaData[0].lnci__c);
            System.assertEquals(100, fdicncuaData[0].lnlsnet__c);
            System.assertEquals(100, fdicncuaData[0].lnrersfm__c);

            Test.stopTest();
        }
    }

    /**
     * Test of the updateFDIC method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if FDIC_NCUA_Data__c records have been updated correctly during update
     */
    @IsTest
    static void testUpdateFDIC() {


        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            System.assertEquals(5, [SELECT Id, Data_Source__c, Certificate__c, Account__c FROM FDIC_NCUA_Data__c WHERE Certificate__c LIKE '1234%'].size());
            System.assertEquals(1, [SELECT Id, Data_Source__c, Certificate__c, Account__c FROM FDIC_NCUA_Data__c WHERE Certificate__c LIKE '87654%'].size());

            Test.startTest();

            List<FDIC_NCUA_Data__c> fdicncuaData = [SELECT Id, Data_Source__c, Certificate__c, Account__c FROM FDIC_NCUA_Data__c WHERE Certificate__c LIKE '1234%'];

            for(FDIC_NCUA_Data__c fdic : fdicncuaData) {
                fdic.Certificate__c = '87654';
            }
            update fdicncuaData;

            System.assertEquals(6, [SELECT Id, Data_Source__c, Certificate__c, Account__c FROM FDIC_NCUA_Data__c WHERE Certificate__c LIKE '87654'].size());

            Test.stopTest();
        }
    }

    /**
     * Positive test of the isChanged method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if the method detects if the value of the field has been changed.
     * The isChanged method returns true if the the value of the field has been changed.
     */
    @IsTest
    static void testIsChangedPositive() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            List<System__c> systems = [SELECT Id, Account__c, Name, Environment2__c FROM System__c];

            System__c sys1 = systems[0];
            System__c sys2 = sys1.clone(false);
            sys2.Environment2__c = 'DEV';

            Test.startTest();
            Boolean isChanged = FDIC.isChanged(sys2, 'Environment2__c', sys1);
            Test.stopTest();

            System.assertEquals(true, isChanged);

        }
    }

    /**
     * Negative test of the isChanged method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if the method detects if the value of the field has been changed.
     * The isChanged method returns false if the the value of the field has not been changed.
     */
    @IsTest
    static void testIsChangedNegative() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            List<System__c> systems = [SELECT Id, Account__c, Name, Environment2__c FROM System__c];

            System__c sys1 = systems[0];
            System__c sys2 = sys1.clone(false);

            Test.startTest();
            Boolean isChanged = FDIC.isChanged(sys2, 'Environment2__c', sys1);
            Test.stopTest();

            System.assertEquals(false, isChanged);
        }
    }

    /**
     * Positive test of the gindAccount method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if the Account__c field has been populated for FDIC_NCUA_Data__c.
     */
    @IsTest
    static void testFindAccount() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            Test.startTest();

            List<FDIC_NCUA_Data__c> lSFIC = [SELECT Id, Data_Source__c, Certificate__c, Account__c, Year__c, Quarter__c, Report_Date__c FROM FDIC_NCUA_Data__c WHERE Certificate__c LIKE '1234%'];
            System.assertEquals(5, lSFIC.size());

            List<FDIC_NCUA_Data__c> fdicncuaData = FDIC.findAccountBefore(lSFIC);

            System.assertEquals(5, fdicncuaData.size());

            Test.stopTest();
        }
    }

    /**
     * Negative test of the gindAccount method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if the Account__c field has not been populated for FDIC_NCUA_Data__c.
     */
    @IsTest
    static void testFindAccountNegative() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            List<FDIC_NCUA_Data__c> fdicncuaData = createFDICList(1, '01024');

            Test.startTest();

            List<FDIC_NCUA_Data__c> lSFIC = [SELECT Id, Data_Source__c, Certificate__c, Account__c, Year__c, Quarter__c, Report_Date__c FROM FDIC_NCUA_Data__c WHERE Certificate__c LIKE '01024%'];
            System.assertEquals(1, lSFIC.size());

            fdicncuaData = FDIC.findAccountBefore(lSFIC);

            System.assertEquals(0, fdicncuaData.size());

            Test.stopTest();
        }
    }

    /**
     * The auxiliary method for creating a new FDIC_NCUA_Data__c list for a given Certification names.
     *
     * @param numberFDIC - number of FDIC_NCUA_Data__c to be created
     * @param cert - certification prefix
     *
     * @return list of FDIC_NCUA_Data__c
     */
    private static List<FDIC_NCUA_Data__c> createFDICList(Integer numberFDIC, String cert) {

        List<FDIC_NCUA_Data__c> fdicncuaData = new List<FDIC_NCUA_Data__c>();

        for(Integer i = 0; i<numberFDIC; i++) {
            FDIC_NCUA_Data__c fdic = new FDIC_NCUA_Data__c();
            fdic = new FDIC_NCUA_Data__c();
            fdic.Total_Assets__c = i*200;
            fdic.Quarter__c = math.mod(i, 3) + 1;
            fdic.Year__c = '2018';
            fdic.Certificate__c = cert + i;
            fdic.Data_Source__c = (math.mod(i, 2) == 0) ? 'FDIC' : 'NCUA';

            fdicncuaData.add(fdic);
        }

        insert fdicncuaData;
        return fdicncuaData;
    }

    /**
     * The auxiliary method for creating a new Account list.
     *
     * @param numberOfAccounts - number of Accounts to be created
     *
     * @return - list of Accounts
     */
    private static List<Account> createAccounts(Integer numberOfAccounts) {

        List<Account> accounts = new List<Account>();

        for(Integer i = 0; i < numberOfAccounts; i++) {
            Account acc = new Account();
            acc.Name = 'Account ' + i;
            acc.DH_MSCRM_Hfs_fdic_num__c = (math.mod(i, 2) == 0) ? '1234' + i : null;
            acc.DH_MSCRM_Hfs_charter_num__c = (math.mod(i, 2) != 0) ? '1234' + i : null;
            acc.FDIC_NCUA_Data__c = null;

            accounts.add(acc);
        }
        insert accounts;
        return accounts;

    }
}