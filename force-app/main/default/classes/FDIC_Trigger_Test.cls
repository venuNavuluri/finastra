/**
 * @author Konrad Marciniak  konrad.marciniak@weare4c.com
 * Test class for the FDIC trigger.
 * TODO: add Konrad's email
 */
@IsTest
private class FDIC_Trigger_Test {

    /**
     * Positive test of the insert FDIC_NCUA_Data__c objects.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if 200 of new FDIC_NCUA_Data__c have been inserted.
     */
    @IsTest
    static void testInsertPositive() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {
            Test.startTest();

            List<FDIC_NCUA_Data__c> fdicncuaData = createFDICList(200);
            Database.SaveResult[] saveResults = Database.insert(fdicncuaData, false);

            System.assertEquals(200, saveResults.size()); //checks if 200 of new FDIC_NCUA_Data__c have been inserted.

            for(Database.SaveResult sr : saveResults) {
                System.assertEquals(true, sr.success);
            }

            Test.stopTest();
        }
    }

    /**
     * Negative test of the insert FDIC_NCUA_Data__c objects.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if 200 of new FDIC_NCUA_Data__c have not been inserted.
     */
    @IsTest
    static void testInsertNegative() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {
            Test.startTest();

            List<FDIC_NCUA_Data__c> fdicncuaData = createFDICList(200);

            for(FDIC_NCUA_Data__c fdic : fdicncuaData) {
                fdic.Data_Source__c = null;
            }

            Database.SaveResult[] saveResults = Database.insert(fdicncuaData, false);

            System.assertEquals(200, saveResults.size()); //checks if 200 of new FDIC_NCUA_Data__c have not been inserted.

            for(Database.SaveResult sr : saveResults) {
                System.assertEquals(false, sr.success);
            }

            Test.stopTest();
        }
    }

    /**
     * Positive test of the update FDIC_NCUA_Data__c objects.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if 200 of new FDIC_NCUA_Data__c have been updated.
     */
    @IsTest
    static void testUpdatePositive() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {
            List<FDIC_NCUA_Data__c> fdicncuaData = createFDICList(200);
            insert  fdicncuaData;

            Test.startTest();

            for(Integer i = 0; i<fdicncuaData.size(); i++) {
                fdicncuaData[i].Total_Assets__c = i*100;
            }

            Database.SaveResult[] saveResults = Database.update(fdicncuaData, false);

            System.assertEquals(200, saveResults.size());

            for(Database.SaveResult sr : saveResults) {
                System.assertEquals(true, sr.success);
            }

            Test.stopTest();
        }
    }

    /**
     * Negative test of the update FDIC_NCUA_Data__c objects.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if 200 of new FDIC_NCUA_Data__c have not been updated.
     */
    @IsTest
    static void testUpdateNegative() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {
            List<FDIC_NCUA_Data__c> fdicncuaData = createFDICList(200);
            insert  fdicncuaData;

            Test.startTest();

            for(Integer i = 0; i<fdicncuaData.size(); i++) {
                fdicncuaData[i].Data_Source__c = null;
            }

            Database.SaveResult[] saveResults = Database.update(fdicncuaData, false);

            System.assertEquals(200, saveResults.size());

            for(Database.SaveResult sr : saveResults) {
                System.assertEquals(false, sr.success);
            }

            Test.stopTest();
        }
    }

    /**
     * The auxiliary method returning a list of FDIC_NCUA_Data__c.
     *
     * @param numberFDIC - number of FDIC_NCUA_Data__c to be created
     *
     * @return - a lits of FDIC_NCUA_Data__c
     */
    private static List<FDIC_NCUA_Data__c> createFDICList(Integer numberFDIC) {

        List<FDIC_NCUA_Data__c> fdicncuaData = new List<FDIC_NCUA_Data__c>();

        for(Integer i = 0; i<numberFDIC; i++) {
            FDIC_NCUA_Data__c fdic = new FDIC_NCUA_Data__c();
            fdic = new FDIC_NCUA_Data__c();
            fdic.Total_Assets__c = i*200;
            fdic.Quarter__c = math.mod(i, 3) + 1;
            fdic.Year__c = '2018';
            fdic.Certificate__c = '01234' + i;
            fdic.Data_Source__c = (math.mod(i, 2) == 0) ? 'FDIC' : 'NCUA';

            fdicncuaData.add(fdic);
        }

        return fdicncuaData;
    }
}