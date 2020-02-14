/**
 * @author Konrad Marciniak konrad.marciniak@weare4c.com
 * Test class for the class AssetUpliftCtrl
 */

@IsTest
private class AssetUpliftCtrl_Test {

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

        Contract contract = TestDataFactory.createContract(account, opportunity);
        contract.Asset_Size__c = 1006;
        contract.Manual_Asset_Size__c = 1200;
        contract.Manual_Uplift__c = true;
        update contract;

        Billing_Group__c billingGroup = TestDataFactory.createBillingGroup(contract);

        SBQQ__Subscription__c subManualUplift = TestDataFactory.createILF_Subscription(contract);
        subManualUplift.Billing_Method__c = 'Asset';
        subManualUplift.Uplift_Multiplier__c = 20;
        subManualUplift.RLF_Uplift_Multiplier_Percent__c = 20;
        //subManualUplift.Manual_Uplift__c = true;
        update subManualUplift;

        contract.Manual_Uplift__c = false;
        update contract;

        SBQQ__Subscription__c subAutoUplift = TestDataFactory.createILF_Subscription(contract);
        //subAutoUplift.ILF_Asset_Size__c = 1006;
        
        subAutoUplift.Billing_Group__c = billingGroup.Id;
        subAutoUplift.Billing_Method__c = 'Asset';
        subAutoUplift.Billing_Day__c = 1;
        subAutoUplift.Billing_Month__c = 'January';
        //subAutoUplift.Manual_Uplift__c = false;
        update subAutoUplift;

    }

    /**
     * Test of the execute method (positive and negative).
     * Test runs for the profile 'M B&RA / CAT profile'.
     * The positive test (for given Contract Id) returns AssetUpliftData object != null.
     * The negaitve test (for Id that is not a Contract) returns AssetUpliftData = null.
     */
    @IsTest
    static void testExecute() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            Contract contract = [SELECT Id FROM Contract LIMIT 1];

            Test.startTest();
            AssetUpliftCtrl.AssetUpliftData assetUpliftData = AssetUpliftCtrl.execute(contract.Id, false);
            System.assertNotEquals(null, assetUpliftData.contr);

            AssetUpliftCtrl.AssetUpliftData assetUpliftDataError = new AssetUpliftCtrl.AssetUpliftData();
            try {
                assetUpliftDataError = AssetUpliftCtrl.execute(Id.valueOf('0010D000007yIL6QAM'), false);
            } catch(Exception e) {
                System.assertEquals(null, assetUpliftDataError.contr);
            }

            Test.stopTest();
        }
    }

    /**
     * Test of the getInfo method (positive and negative).
     * Test runs for the profile 'M B&RA / CAT profile'.
     * The positive test (for given Contract Id) returns AssetUpliftData object != null.
     * The negaitve test (for Id that is not a Contract) returns AssetUpliftData = null.
     */
    @IsTest
    static void testGetInfo() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            Contract contract = [SELECT Id FROM Contract LIMIT 1];

            Test.startTest();

            AssetUpliftCtrl.AssetUpliftData assetUpliftData = AssetUpliftCtrl.getInfo(contract.Id);
            System.assertEquals(true, assetUpliftData.showConfirm);

            try {
                AssetUpliftCtrl.AssetUpliftData assetUpliftData1 = AssetUpliftCtrl.getInfo(Id.valueOf('0010D000007yIL6QAM'));
                System.assertEquals(false, assetUpliftData1.showConfirm);
            } catch(Exception e) {}


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
        fdic.Certificate__c='12345';

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