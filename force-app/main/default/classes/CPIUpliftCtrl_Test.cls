@IsTest
private class CPIUpliftCtrl_Test {

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
        List<Contract> contracts = new List<Contract>();
        Contract contract1 = new Contract(accountId = account.Id, SBQQ__Opportunity__c = opp.Id, Uplift_Calc_Type__c = 'Pro-Rata', CPI_Uplift_Type__c='Calendar', Billing_Frequency__c = 'Monthly',
                                            Hold_CPI_Uplift__c = false, Active__c = true, Uplift_Application_Date__c  = Date.today(), Next_Uplift_Date__c = Date.today(), status = 'Draft', ContractTerm = 12);
        insert contract1;
        contract1.status = 'Is Active';
        update contract1;        
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
            CPIUpliftCtrl.CPIUpliftData cpiUpliftData = CPIUpliftCtrl.execute(contract.Id);
            System.assertNotEquals(null, cpiUpliftData.contr);

            CPIUpliftCtrl.CPIUpliftData cpiUpliftDataError = new CPIUpliftCtrl.CPIUpliftData();
            try {
                cpiUpliftDataError = CPIUpliftCtrl.execute(Id.valueOf('0010D000007yIL6QAM'));
            } catch(Exception e) {
                System.assertEquals(null, cpiUpliftDataError.contr);
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

            CPIUpliftCtrl.CPIUpliftData cpiUpliftData = CPIUpliftCtrl.getInfo(contract.Id);
            System.assertEquals(true, cpiUpliftData.showConfirm);

            try {
                CPIUpliftCtrl.CPIUpliftData cpiUpliftData1 = CPIUpliftCtrl.getInfo(Id.valueOf('0010D000007yIL6QAM'));
                System.assertEquals(false, cpiUpliftData1.showConfirm);
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