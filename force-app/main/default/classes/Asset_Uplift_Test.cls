/**
 * @author Konrad Marciniak konrad.marciniak@weare4c.com
 * Test class for the class Asset_Uplift
 */
@isTest
public class Asset_Uplift_Test {

	/**
     * this method prepares data for tests
     */
    @TestSetup
    static void setupTests() {
 //       Test.startTest();
        DataFactory data = getData();
//        Test.stopTest();
    }

	/**
     * Test of the getSize method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if the asset size is returned correctly
     */
    @IsTest
    static void testGetSizePositive() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            Test.startTest();
            // Query for FDIC NCUA data
            List<FDIC_NCUA_Data__c> fdic = [SELECT NCUA_Total_Assets__c, Loans_and_Leases__c, Loans_and_Leases_minus_Family_Residentia__c, Consumer_and_Commercial_Loans__c, Commercial_Loans__c, Total_Deposits__c, Member_Business_Loans__c FROM FDIC_NCUA_Data__c LIMIT 1];

            // Modify the Total Assets
            fdic.get(0).Loans_and_Leases__c = 100;
            fdic.get(0).NCUA_Total_Assets__c = 100;
            fdic.get(0).Loans_and_Leases_minus_Family_Residentia__c = 100;
            fdic.get(0).Consumer_and_Commercial_Loans__c = 100;
            fdic.get(0).Commercial_Loans__c = 100;
            fdic.get(0).Total_Deposits__c = 100;
            fdic.get(0).Member_Business_Loans__c = 100;
            update fdic.get(0);

            // Requery
            List<FDIC_NCUA_Data__c> fdicRequeried = [
                    SELECT NCUA_Total_Assets__c, Loans_and_Leases__c, Loans_and_Leases_minus_Family_Residentia__c,
                            Consumer_and_Commercial_Loans__c, Commercial_Loans__c, Total_Deposits__c, Member_Business_Loans__c, Total_Assets__c
                    FROM FDIC_NCUA_Data__c
                    WHERE Id = :fdic.get(0).Id
            ];

            // Call class method
            Decimal ret_Loans_and_Leases = Asset_Uplift.getSize(fdicRequeried.get(0), 'Loans and Leases');
            Decimal ret_NCUA_Total_Assets = Asset_Uplift.getSize(fdicRequeried.get(0), 'NCUA Total Assets');
            Decimal ret_Loans_and_Leases_minus_Family_Residentia = Asset_Uplift.getSize(fdicRequeried.get(0), 'Loans and Leases minus Family Residentia');
            Decimal ret_Consumer_and_Commercial_Loans = Asset_Uplift.getSize(fdicRequeried.get(0), 'Consumer and Commercial Loans');
            Decimal ret_Commercial_Loans = Asset_Uplift.getSize(fdicRequeried.get(0), 'Commercial Loans');
            Decimal ret_Total_Deposits = Asset_Uplift.getSize(fdicRequeried.get(0), 'Total Deposits');
            Decimal ret_Member_Business_Loans = Asset_Uplift.getSize(fdicRequeried.get(0), 'Member Business Loans');
            Decimal ret_Manual = Asset_Uplift.getSize(fdicRequeried.get(0), 'Manual');

            Test.stopTest();
			//checks if the asset size is returned correctly
            System.assertEquals(fdicRequeried.get(0).Loans_and_Leases__c, ret_Loans_and_Leases, 'The value returned does not match the value on the FDIC_NCUA_Data__c record');
            System.assertEquals(fdicRequeried.get(0).NCUA_Total_Assets__c, ret_NCUA_Total_Assets, 'The value returned does not match the value on the FDIC_NCUA_Data__c record');
            System.assertEquals(fdicRequeried.get(0).Loans_and_Leases_minus_Family_Residentia__c, ret_Loans_and_Leases_minus_Family_Residentia, 'The value returned does not match the value on the FDIC_NCUA_Data__c record');
            System.assertEquals(fdicRequeried.get(0).Consumer_and_Commercial_Loans__c, ret_Consumer_and_Commercial_Loans, 'The value returned does not match the value on the FDIC_NCUA_Data__c record');
            System.assertEquals(fdicRequeried.get(0).Commercial_Loans__c, ret_Commercial_Loans, 'The value returned does not match the value on the FDIC_NCUA_Data__c record');
            System.assertEquals(fdicRequeried.get(0).Total_Deposits__c, ret_Total_Deposits, 'The value returned does not match the value on the FDIC_NCUA_Data__c record');
            System.assertEquals(fdicRequeried.get(0).Member_Business_Loans__c, ret_Member_Business_Loans, 'The value returned does not match the value on the FDIC_NCUA_Data__c record');
            System.assertEquals(null, ret_Manual);
        }
    }

	/**
     * Test of the getSize method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if the asset size is NOT returned correctly
     */
    @IsTest
    static void testGetSizeNegative() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            Test.startTest();
            // Query for FDIC NCUA data
            List<FDIC_NCUA_Data__c> fdic = [SELECT Total_Assets__c FROM FDIC_NCUA_Data__c LIMIT 1];

            // Modify the Total Assets
            fdic.get(0).Total_Assets__c = 100;
            update fdic.get(0);

            // Requery
            List<FDIC_NCUA_Data__c> fdicRequeried = [
                    SELECT NCUA_Total_Assets__c, Loans_and_Leases__c, Loans_and_Leases_minus_Family_Residentia__c,
                            Consumer_and_Commercial_Loans__c, Commercial_Loans__c, Total_Deposits__c, Member_Business_Loans__c, Total_Assets__c
                    FROM FDIC_NCUA_Data__c
                    WHERE Id = :fdic.get(0).Id
            ];

            // Call class method
            Decimal returnedVal = Asset_Uplift.getSize(fdicRequeried.get(0), 'Testing');
            Test.stopTest();
			//checks if the asset size is NOT returned correctly
            System.assertEquals(fdicRequeried.get(0).Total_Assets__c, returnedVal, 'The value returned does not match the value on the FDIC_NCUA_Data__c record');
        }
    }
	/**
     * Test of the execute method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if new asset size has been applied
     */
    @IsTest
    static void testExecutePositive() {

            // Get account
            List<Account> acc = [SELECT Id FROM Account LIMIT 1];

            // Query for FDIC NCUA data
            List<FDIC_NCUA_Data__c> fdic = [SELECT NCUA_Total_Assets__c FROM FDIC_NCUA_Data__c LIMIT 1];
            // Modify the Total Assets
            fdic.get(0).NCUA_Total_Assets__c = 500;
            update fdic.get(0);

            acc.get(0).FDIC_NCUA_Data__c = fdic.get(0).Id;
            update acc.get(0);

            // Get opportunity
            List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
            // Create Billing Frequency
            NS_Billing_Frequency__c bgFreq = new NS_Billing_Frequency__c(Name = 'Yearly');
            insert bgFreq;
            // Create Billing entity
            Billing_Entity__c be = new Billing_Entity__c();
            insert be;
            // Create Billing Group
            Billing_Group__c bg = new Billing_Group__c();
            bg.Fixed_Billing_Date__c = System.today();
            bg.NS_Billing_Frequency__c = bgFreq.id;
            bg.BG_Misys_Billing_Entity__c = be.id;
            bg.BG_Client_Contracting_Name__c = acc.get(0).Id;
            bg.NS_Subscription_Billing_Method__c = 'Advance';
            bg.Original_Opportunity__c = opp.get(0).id;
            insert bg;

            // Create rec index
            RF_Index__c recIndex = new RF_Index__c();
            insert recIndex;

            // Create uplift
            Uplift__c uplift = new Uplift__c(
                    Exclude__c = false,
                    Override__c = 15,
                    Account__c = acc.get(0).Id,
                    Billing_Frequency__c = 'Semiannual',
                    Status__c = 'Pro-Rata',
                    Uplift_Application_Date__c = Date.today(),
                    Type__c = 'Custom',
                    Start_Date__c = Date.today(),
                    Uplift_Effective_Date__c = Date.today().addYears(1),
                    Base_Index__c = recIndex.Id);
            insert uplift;

            Date pastUpliftReviewDate = Date.today() - 365;
            Date presentUpliftReviewDate = Date.today();
            
            Decimal manualAssetSize = 500;

            // Create contracts
            List<Contract> contractsToInsert = new List<Contract>();
            for (Integer i = 0; i <= 200; i++) {
                Contract contract = new Contract(
                        AccountId = acc.get(0).Id,
                        SBQQ__Opportunity__c = opp.get(0).Id,
                        Next_Asset_Uplift_Date__c = Date.today() - 300,
                        Next_Uplift_Date__c = Date.today(),
                        Status = 'Draft',
                        ContractTerm = 12,
                    	Asset_Uplift_Source__c = 'NCUA Total Assets',
                        Asset_Size__c = 200,
                        Manual_Asset_Size__c = manualAssetSize,
                        Manual_Uplift__c = false
                        );
                contractsToInsert.add(contract);
            }
            insert contractsToInsert;

            List<NS_Item__c> ncsitems = [SELECT Id, Legacy_SKU__c, NS_Item_Name__c, NS_Product_Dimension_ID__c FROM NS_Item__c];
            // Create subscriptions
            List<SBQQ__Subscription__c> subsToInsert = new List<SBQQ__Subscription__c>();
            for (Integer i = 0; i <= 200; i++) {
                SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
                        SBQQ__Contract__c = contractsToInsert.get(i).Id,
                        SBQQ__Quantity__c = 1,
                        Billing_Group__c = bg.Id,
                        Transactional__c = true,
                        CPI_Uplift__c = uplift.Id,
                        Exclude__c = false,
                        Billing_Method__c = 'Asset',
                        Uplift_Multiplier__c = 200,
                        RLF_Uplift_Multiplier_Percent__c = 0.01,
                        Sold_Value__c = 100,
                        Inital_NS_Item__c = ncsitems[0].Id);
                subsToInsert.add(sub);
            }
            insert subsToInsert;

            List<SBQQ__Subscription__c> subs = [SELECT Id, Inital_NS_Item__c FROM SBQQ__Subscription__c WHERE Inital_NS_Item__c != null];
            List<SBQQ__Subscription__c> subsAll = [SELECT Id, Inital_NS_Item__c FROM SBQQ__Subscription__c];
            System.debug('>KM');
            System.debug('Size: ' + subs.size());
            System.debug('Size All: ' + subsAll.size());
            System.debug('NS_Item__c');
            System.debug(ncsitems);
            //System.debug(JSON.serializePretty(subs));

            // Add all contract IDs to a set
            Set<Id> contractIds = new Set<Id>();
            for (Contract con : contractsToInsert) {
                contractIds.add(con.Id);
            }

            // Add all subs IDs to a set
            Set<Id> subsIds = new Set<Id>();
            for (SBQQ__Subscription__c sub : subsToInsert) {
                subsIds.add(sub.Id);
            }

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            Test.startTest();
            // Call class method
            Asset_Uplift.AssetUpliftReturn returnedVal = Asset_Uplift.execute(contractIds);
            //List<SBQQ__Subscription__c> subsRequeried = [SELECT ILF_Asset_Size__c, ILF_New_Asset_Size__c FROM SBQQ__Subscription__c WHERE Id IN :subsIds];
            //system.debug('**subsRequeried=' + subsRequeried);
            List<FDIC_NCUA_Data__c> fdicRequeried = [SELECT NCUA_Total_Assets__c FROM FDIC_NCUA_Data__c WHERE Account__c = :acc.get(0).Id];
            system.debug('**fdicRequeried=' + fdicRequeried);
            //List<Contract> contractsRequeried = [SELECT Asset_Uplift_Review_Date__c FROM Contract WHERE Id IN :contractIds];
            Test.stopTest();

            // Check that values are not null
            System.assertNotEquals(returnedVal, null, 'No contracts found');
            // Check if new asset size has been applied
            /*for (SBQQ__Subscription__c sub : subsRequeried) {
                System.assertEquals(fdicRequeried.get(0).NCUA_Total_Assets__c, sub.ILF_New_Asset_Size__c, 'ILF New Asset size is wrong');
            }*/

            // Check if new asset uplift date has been applied
            /*for (Contract con : contractsRequeried) {
                System.assertEquals(presentUpliftReviewDate, con.Asset_Uplift_Review_Date__c, 'Asset uplift review date is wrong');
            }*/
        }
    }
	/**
     * Test of the execute method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if the contact has not be proceded
     */
    @IsTest
    static void testExecuteNegative() {
        // Get account
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];

        // Query for FDIC NCUA data
        List<FDIC_NCUA_Data__c> fdic = [SELECT NCUA_Total_Assets__c FROM FDIC_NCUA_Data__c LIMIT 1];
        // Modify the Total Assets
        fdic.get(0).NCUA_Total_Assets__c = 500;
        update fdic.get(0);

        acc.get(0).FDIC_NCUA_Data__c = fdic.get(0).Id;
        update acc.get(0);

        // Get opportunity
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        // Create Billing Frequency
        NS_Billing_Frequency__c bgFreq = new NS_Billing_Frequency__c(Name = 'Yearly');
        insert bgFreq;
        // Create Billing entity
        Billing_Entity__c be = new Billing_Entity__c();
        insert be;
        // Create Billing Group
        Billing_Group__c bg = new Billing_Group__c();
        bg.Fixed_Billing_Date__c = System.today();
        bg.NS_Billing_Frequency__c = bgFreq.id;
        bg.BG_Misys_Billing_Entity__c = be.id;
        bg.BG_Client_Contracting_Name__c = acc.get(0).Id;
        bg.NS_Subscription_Billing_Method__c = 'Advance';
        bg.Original_Opportunity__c = opp.get(0).id;
        insert bg;

        // Create rec index
        RF_Index__c recIndex = new RF_Index__c();
        insert recIndex;

        // Create uplift
        Uplift__c uplift = new Uplift__c(
                Exclude__c = false,
                Override__c = 15,
                Account__c = acc.get(0).Id,
                Billing_Frequency__c = 'Semiannual',
                Status__c = 'Pro-Rata',
                Uplift_Application_Date__c = Date.today(),
                Type__c = 'Custom',
                Start_Date__c = Date.today(),
                Uplift_Effective_Date__c = Date.today().addYears(1),
                Base_Index__c = recIndex.Id);
        insert uplift;

        Date pastUpliftReviewDate = Date.today() - 365;
        Date presentUpliftReviewDate = Date.today();

        Decimal manualAssetSize = 500;

        // Create contracts
        List<Contract> contractsToInsert = new List<Contract>();
        for (Integer i = 0; i <= 200; i++) {
            Contract contract = new Contract(
                    AccountId = acc.get(0).Id,
                    SBQQ__Opportunity__c = opp.get(0).Id,
                    Next_Asset_Uplift_Date__c = Date.today() - 300,
                    Next_Uplift_Date__c = Date.today(),
                    Asset_Uplift_Source__c = 'NCUA Total Assets',
                    Asset_Size__c = 300,
                    Status = 'Draft',
                    Manual_Asset_Size__c = manualAssetSize,
                    Manual_Uplift__c = false,
                    ContractTerm = 12);
            contractsToInsert.add(contract);
        }
        insert contractsToInsert;

        List<NS_Item__c> ncsitems = [SELECT Id, Legacy_SKU__c, NS_Item_Name__c, NS_Product_Dimension_ID__c FROM NS_Item__c];

        // Create subscriptions
        List<SBQQ__Subscription__c> subsToInsert = new List<SBQQ__Subscription__c>();
        for (Integer i = 0; i <= 200; i++) {
            SBQQ__Subscription__c sub = new SBQQ__Subscription__c(
                    SBQQ__Contract__c = contractsToInsert.get(i).Id,
                    SBQQ__Quantity__c = 1,
                    Billing_Group__c = bg.Id,
                    Transactional__c = true,
                    CPI_Uplift__c = uplift.Id,
                    Exclude__c = false,
                    Billing_Method__c = 'Asset',
                    Uplift_Multiplier__c = 200,
                    RLF_Uplift_Multiplier_Percent__c = 0.01,
                    Sold_Value__c = 100,
                    Inital_NS_Item__c = ncsitems[0].Id);
            subsToInsert.add(sub);
        }
        insert subsToInsert;

        // Add all contract IDs to a set
        Set<Id> contractIds = new Set<Id>();
        for (Contract con : contractsToInsert) {
            contractIds.add(con.Id);
        }

        // Add all subs IDs to a set
        Set<Id> subsIds = new Set<Id>();
        for (SBQQ__Subscription__c sub : subsToInsert) {
            subsIds.add(sub.Id);
        }

        Test.startTest();
        // Call class method
        Asset_Uplift.AssetUpliftReturn returnedVal = Asset_Uplift.execute(contractIds);
        //List<SBQQ__Subscription__c> subsRequeried = [SELECT ILF_Asset_Size__c, ILF_New_Asset_Size__c FROM SBQQ__Subscription__c WHERE Id IN :subsIds];
        List<FDIC_NCUA_Data__c> fdicRequeried = [SELECT NCUA_Total_Assets__c FROM FDIC_NCUA_Data__c WHERE Account__c = :acc.get(0).Id];
        //List<Contract> contractsRequeried = [SELECT Asset_Uplift_Review_Date__c FROM Contract WHERE Id IN :contractIds];
        Test.stopTest();

        // Check that values are not null
        System.assertNotEquals(returnedVal, null, 'No contracts found');
        // Check if new asset size has been applied
        /*for (SBQQ__Subscription__c sub : subsRequeried) {
            //System.assertEquals(fdicRequeried.get(0).NCUA_Total_Assets__c, sub.ILF_New_Asset_Size__c, 'ILF New Asset size is wrong');
        }*/

        // Check if new asset uplift date has been applied
        //for (Contract con : contractsRequeried) {
            //System.assertEquals(presentUpliftReviewDate, con.Asset_Uplift_Review_Date__c, 'Asset uplift review date is wrong');
        //}
    }
	/**
     * Test of the execute method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if sales orders were created
     */
    @IsTest
    public static void testCreateOrders() {

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {

            System.assertEquals(0, [SELECT Id FROM Sales_Order__c].size());

            Test.startTest();

            Map<Id, Billing_Group__c> billingGroupMap = new Map<Id, Billing_Group__c>([SELECT Id FROM Billing_Group__c]);

            List<SBQQ__Subscription__c> subscriptions = [SELECT Id, Licence_Band__c, ThirdParty_PO_Currency__c, ThirdParty_Recurring_Costs_PO_Ccy__c, SBQQ__PartnerDiscount__c, License_Metric__c, Location__c, Inital_NS_Item__r.NS_Rev_Rec_Template_ID__c, ThirdParty_Costs_PO_Ccy__c, ILF_Fair_Value__c, /*ILF_Asset_Size__c, ILF_New_Asset_Size__c,*/ SBQQ__Quantity__c, Pearl_Internal_Cost__c, Initial_Sovos_Code__c, Inital_NS_Item__r.GA__c, Ship_From_Code__c, SBQQ__Product__r.Name, Inital_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c, Inital_NS_Item__r.NS_Cost_Centre_ID__c, Billing_Group__r.Account_by_Sub__c, Billing_Group__r.Original_Contract__r.CustomerSignedDate, Billing_Group__r.Original_Opportunity__r.PS_Forecast_Probability__c, Billing_Group__r.Original_Opportunity__r.PS_Top_Opportunity__c, Billing_Group__r.Original_Opportunity__r.Probability, Billing_Group__r.Original_Opportunity__r.ForecastCategoryName, Billing_Group__r.Original_Opportunity__r.CloseDate, Billing_Group__r.Original_Opportunity__r.StageName, Billing_Group__r.Account_by_Sub__r.Account__r.NS_Finance_Region__c, Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode, Opportunity_Billing_Schedule__r.Name, Billing_Group__r.Original_Opportunity__r.Order_Number__c, Billing_Group__c, Sold_Value__c, Initial_Sales_Order_Type__c, Billing_Group__r.CurrencyIsoCode, 
                                                         //Original_Contract__r.Rebate_Amount__c,Original_Contract__r.Rebate_reimbursed_by_3rd_Party_Vendor__c,Original_Contract__r.Rebate_Amount_Reimbursed__c,Original_Contract__r.Rebate_Currency__c,Original_Contract__r.Rebate_Payment_Term__c,Original_Contract__r.X3rd_Party_Vendor__r.NS_Internal_ID__c,Original_Contract__r.X3rd_Party_Vendor__r.Name,
                                                         SBQQ__Contract__r.Asset_Size__c, SBQQ__Contract__r.New_Asset_Size__c, Uplift_Multiplier__c,  SBQQ__NetPrice__c,
                                                         Inital_NS_Item__r.NS_Product_Dimension_ID__c FROM SBQQ__Subscription__c WHERE Billing_Group__c in :billingGroupMap.keySet()];

            Map<Id, List<SBQQ__Subscription__c>> subscriptionsMap = new Map<Id, List<SBQQ__Subscription__c>>();

            for(SBQQ__Subscription__c sub : subscriptions) {
                List<SBQQ__Subscription__c> lSub = subscriptionsMap.get(sub.Billing_Group__c);
                if (lSub == null) {
                    subscriptionsMap.put(sub.Billing_Group__c, new List<SBQQ__Subscription__c>());
                }
                subscriptionsMap.get(sub.Billing_Group__c).add(sub);
            }

            List<Sales_Order__c> salesOrders = Asset_Uplift.createOrders(subscriptionsMap, new map < id, decimal >());

            Test.stopTest();

            System.assertEquals(6, [SELECT Id FROM Sales_Order__c].size());
        }
    }
    
	/**
     * Test of the execute method.
     * Test runs for the profile 'M B&RA / CAT profile'.
     * Test checks if sales orders items  were added
     */
    @IsTest
    static void testAddILFSalesOrderItem() {

        List<Billing_Group__c> groups = [SELECT Id, Original_Opportunity__r.OwnerId FROM Billing_Group__c];
        SBQQ__Subscription__c sub = [SELECT Id, Licence_Band__c, ThirdParty_PO_Currency__c, ThirdParty_Recurring_Costs_PO_Ccy__c, SBQQ__Contract__r.Asset_Size__c, SBQQ__Contract__r.New_Asset_Size__c, Uplift_Multiplier__c, SBQQ__PartnerDiscount__c, License_Metric__c, Location__c, Inital_NS_Item__r.NS_Rev_Rec_Template_ID__c, ThirdParty_Costs_PO_Ccy__c, ILF_Fair_Value__c, /*ILF_Asset_Size__c, ILF_New_Asset_Size__c,*/ SBQQ__Quantity__c, Pearl_Internal_Cost__c, Initial_Sovos_Code__c, Inital_NS_Item__r.GA__c, Ship_From_Code__c, SBQQ__Product__r.Name, Inital_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c, Inital_NS_Item__r.NS_Cost_Centre_ID__c, Billing_Group__r.Account_by_Sub__c, Billing_Group__r.Original_Contract__r.CustomerSignedDate, Billing_Group__r.Original_Opportunity__r.PS_Forecast_Probability__c, Billing_Group__r.Original_Opportunity__r.PS_Top_Opportunity__c, Billing_Group__r.Original_Opportunity__r.Probability, Billing_Group__r.Original_Opportunity__r.ForecastCategoryName, Billing_Group__r.Original_Opportunity__r.CloseDate, Billing_Group__r.Original_Opportunity__r.StageName, Billing_Group__r.Account_by_Sub__r.Account__r.NS_Finance_Region__c, Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode, Opportunity_Billing_Schedule__r.Name, Billing_Group__r.Original_Opportunity__r.Order_Number__c, Billing_Group__c, Sold_Value__c, Initial_Sales_Order_Type__c, Billing_Group__r.CurrencyIsoCode, Inital_NS_Item__r.NS_Product_Dimension_ID__c FROM SBQQ__Subscription__c WHERE Billing_Group__c IN :groups][0];
        Billing_Group__c bgroup = [SELECT Id, Original_Contract__r.Memo__c, NS_Customer_Address__c,
                                   //Original_Contract__r.Rebate_Amount__c,Original_Contract__r.Rebate_reimbursed_by_3rd_Party_Vendor__c,Original_Contract__r.Rebate_Amount_Reimbursed__c,Original_Contract__r.Rebate_Currency__c,Original_Contract__r.Rebate_Payment_Term__c,Original_Contract__r.X3rd_Party_Vendor__r.NS_Internal_ID__c,Original_Contract__r.X3rd_Party_Vendor__r.Name, 
                                   NS_Customer_Ship_To_Address__c, Original_Contract__r.CustomerSignedDate, Original_Contract__r.StartDate, Original_Opportunity__r.CloseDate, Original_Contract__c, Original_Opportunity__r.OwnerId, CurrencyIsoCode, Account_by_Sub__c, Account_by_Sub__r.Account__r.NS_Term__c FROM Billing_Group__c WHERE Id = :sub.Billing_Group__c][0];
        Integer counter = 1;

        Map <String, String > nsProductMap = SO_SalesOrderMapUtils.getNSProduct_map();
        Map <String, NS_Cost_Centre__c > nsCostCenterMap = SO_SalesOrderMapUtils.getNSCostCenter_map();
        Map <String, NS_Currency__c > nsCurrencyMap = SO_SalesOrderMapUtils.getNSCurrency_map();
        Map<String, NS_Account__c>  NsAccountMap = SO_SalesOrderMapUtils.getNsAccMap();
        Map<String, NS_Revenue_Recognition_Template__c> revRecScheduleMap = SO_SalesOrderMapUtils.getRevScheduleMap();
        NS_Project__c project = ILFPackage_ListInit.addNSProject(sub, nsCurrencyMap, nsCostCenterMap, nsProductMap, sub.Initial_Sales_Order_Type__c);

        Sales_Order__c order = ILFPackage_ListInit.addILFSalesOrder(bgroup, project, nsCurrencyMap, project.Project_Type__c, NsAccountMap);
        insert order;

        System.assertEquals(0, [SELECT Id FROM Sales_Order_Item__c].size());

        Profile p2 = [SELECT Id FROM Profile WHERE Name='M B&RA / CAT profile'];
        User u3 = new User(Alias = 'newUser2', Email='newuser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p2.Id, TimeZoneSidKey='America/Los_Angeles', UserName='misystest2@testorg.com');

        System.runAs(u3) {
            
            Test.startTest();

            Sales_Order_Item__c soiItem = Asset_Uplift.addILFSalesOrderItem(sub, counter, order, revRecScheduleMap, new map <id, decimal>());
            System.assertNotEquals(null, soiItem);

            insert soiItem;

            Test.stopTest();
        }

        System.assertEquals(1, [SELECT Id FROM Sales_Order_Item__c].size());
    }
    
    /**
     * The returns set of data which are necessary to run Asset Uplift tests
     * @TODO: add context of data preparing: i am preparing account, associating it with FDIC record etc...
     * @TODO: provide DataFactory
     * @return - DataFactory object
     */
     @TestVisible
    private static DataFactory getData() {
        DataFactory data = new DataFactory();
        data.acc.FDIC_NCUA_Data__c = data.fdic.Id;
        update data.acc;

        for(SBQQ__Subscription__c sub : data.subs) {

            //sub.ILF_New_Asset_Size__c = 40;
            //sub.ILF_Asset_Size__c = 20;
            //sub.Uplift_Multiplier__c = 1;
        }
        update data.subs;

        return data;
    }
}