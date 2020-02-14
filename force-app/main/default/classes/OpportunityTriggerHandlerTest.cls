/**
 * Test coverage class for the OpportunityTriggerHandler
 */
@IsTest
public with sharing class OpportunityTriggerHandlerTest {

    public static testMethod void testOpportunityLineItemScheduleUpdate()
    {
        //Set up test data
        //Account testAccount = TestUtility.sampleAccount();
        //insert testAccount;
        List<Opportunity> opps = new List<Opportunity>();
        Opportunity testOpp1 = TestUtility.sampleOpportunity();
        testOpp1.CloseDate = System.today();
        opps.add(testOpp1);
        Opportunity testOpp2 = TestUtility.sampleOpportunity();
        testOpp2.CloseDate = System.today();
        opps.add(testOpp2);
        insert opps;
        OpportunityLineItem testProduct = TestUtility.sampleOpportunityLineItem(testOpp1, 'PS (T)');
        insert testProduct;
        OpportunityLineItemSchedule testProductSchedule = TestUtility.sampleOpportunityLineItemSchedule(testOpp1, testProduct);
        insert testProductSchedule;

        //Run the actions to test the update
        test.startTest();
        //Test the update on an opportunity with line items that have a schedule
        testOpp1.CloseDate = System.today().addMonths(2);
        //Test the update on an opportunity with no line items and no schedule
        testOpp2.CloseDate = System.today().addMonths(2);
        update opps;
        test.stopTest();

        //Verify the test results
        OpportunityLineItemSchedule updatedProductSchedule = [select id, ScheduleDate from OpportunityLineItemSchedule where OpportunityLineItemId = :testProduct.Id];
        System.debug('Updated OppLineItemSchedule: '+updatedProductSchedule);
        //System.assertEquals(testOpp1.CloseDate,updatedProductSchedule.ScheduleDate);
    }

    public static testMethod void testDeleteChangeOrderOLIsForParentOpportunity() {
        List<Opportunity> opps = new List<Opportunity>();

        Account anAccount = TestUtility.createAccount('Test Account 1');

        Contact aContact = TestUtility.createContact();

        Opportunity testOpp1 = TestUtility.sampleOpportunity();
        testOpp1.CloseDate = System.today();
        insert testOpp1;

        Test.startTest();
        Opportunity testOpp2 = TestUtility.sampleOpportunity();
        testOpp2.CloseDate = System.today();
        testOpp2.RecordTypeId = Label.RecType_Opportunity_ChangeReq;
        testOpp2.Original_Opportunity__c = testOpp1.Id;
        testOpp2.OLIs_Pushed_To_Parent__c = true;
        insert testOpp2;

        OpportunityLineItem testProduct2 = TestUtility.sampleOpportunityLineItem(testOpp2, 'PS (T)');
        testProduct2.CR_Line_Item_Added_To_Parent__c = true;
        testProduct2.Added_by_Change_Order__c = true;
        //testProduct2.Original_OLI_Id__c = testProduct1.Id;
        insert testProduct2;

        OpportunityLineItem testProduct1 = TestUtility.sampleOpportunityLineItem(testOpp1, 'PS (T)');
        testProduct1.CR_Line_Item_Added_To_Parent__c = true;
        testProduct1.Added_by_Change_Order__c = true;
        testProduct1.Original_OLI_Id__c = testProduct2.Id;
        insert testProduct1;

        SBQQ__Quote__c aQuote = TestUtility.createQuote(testOpp2, anAccount, aContact);

        aQuote.ApprovalStatus__c = 'Approved';
        aQuote.Bypass_Approval__c = 'Accepted';
        aQuote.Request_Bypass_Approval__c = true;
        aQuote.Request_Bypass_Approval_Reason__c = 'Test';
        aQuote.Bypass_Approval_Accepted_Sent__c = true;
        aQuote.Bypass_Approval_Request_Sent__c = true;
        update aQuote;
        Test.stopTest();

        List<OpportunityLineItem> lineItems2 = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(2, lineItems2.size());

        testOpp2.StageName = 'Closed Lost';
        update testOpp2;

        List<OpportunityLineItem> lineItems1 = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(1, lineItems1.size());
    }

    public static testMethod void shouldDeleteOpportunity()
    {
        Opportunity testOpp1 = TestUtility.sampleOpportunity();
        testOpp1.CloseDate = System.today();
        testOpp1.OLIs_Pushed_To_Parent__c = true;
        insert testOpp1;
        OpportunityLineItem testProduct = TestUtility.sampleOpportunityLineItem(testOpp1, 'PS (T)');
        insert testProduct;

        delete testOpp1;

        List<OpportunityLineItem> result = [select id from OpportunityLineItem where id = :testProduct.id];
        System.assert(result.isEmpty(), 'opportunity line items should be deleted after opportunity deletion');
    }


    public static testMethod void testCreateQuotaCredits()
    {
        //Set up test data
        Account testAcc = new Account(Name='testAcct');
        insert testAcc;
        testAcc.NumberOfEmployees = 1;
        update testAcc;
        Opportunity testTrigOpp = new Opportunity(AccountId=testAcc.id, Name='test - Opp', StageName='Prove', CloseDate=date.valueOf('2010-01-01'));
        testTrigOpp.OwnerId = Userinfo.getUserId();

        List<Com_Splits__c> result1 = new List<Com_Splits__c>();
        Id result1OppOwner = null;
        List<Com_Splits__c> result2 = new List<Com_Splits__c>();

        //User testUser = [SELECT u.id FROM user u WHERE u.name = 'Cheryl Abreu' LIMIT 1];
        User testUser = TestUtility.sampleUser();
        insert testUser;

        //Run the test
        Test.startTest();
        insert testTrigOpp;
        result1OppOwner = testTrigOpp.OwnerId;
        result1 = [select id, Employee_Name__c, Opportunity__c from Com_Splits__c where Opportunity__c = :testTrigOpp.Id];
        testTrigOpp.OwnerId = testUser.id;
        update testTrigOpp;
        result2 = [select id, Employee_Name__c, Opportunity__c from Com_Splits__c where Opportunity__c = :testTrigOpp.Id];
        Test.stopTest();

        //Verify the results
        System.assert(result1.size() > 0);
        System.assertEquals(result1OppOwner,result1[0].Employee_Name__c);
        System.assert(result2.size() > 0);
        System.assertEquals(testTrigOpp.OwnerId,result2[0].Employee_Name__c);

    }

    public static testMethod void testOpportunityWinLossReport_CE()
    {
        //Set up test data
        Account testAccount = TestUtility.sampleAccount();
        insert testAccount;
        Opportunity testOpp1 = TestUtility.sampleOpportunity();
        testOpp1.CloseDate = System.today();
        insert testOpp1;
        Opportunity testOpp2 = TestUtility.sampleOpportunity();
        testOpp2.CloseDate = System.today();
        insert testOpp2;
        User u1 = TestUtility.sampleUser();
        u1.LastName = 'User1';
        insert u1;
        User u2 = TestUtility.sampleUser();
        u2.LastName = 'User2';
        u2.UserName = 'testuser'+datetime.now().millisecond()+'@d.com';
        insert u2;

        //Add Sales Team Members to testOpp2
        List<OpportunityTeamMember> lOppTeam = new List<OpportunityTeamMember>();
        OpportunityTeamMember tm1 = new OpportunityTeamMember();
        tm1.OpportunityId = testOpp2.Id;
        tm1.TeamMemberRole = 'PS Rep';
        tm1.UserId = u1.Id;
        lOppTeam.add(tm1);
        OpportunityTeamMember tm2 = new OpportunityTeamMember();
        tm2.OpportunityId = testOpp2.Id;
        tm2.TeamMemberRole = 'PS Rep';
        tm2.UserId = u2.Id;
        lOppTeam.add(tm2);
        insert lOppTeam;

        Test.startTest();
        //Test with no Sales Team members
        Test.setCurrentPage(Page.OpportunityWinLossReport);
        OpportunityWinLossReport_CE controller1 = new OpportunityWinLossReport_CE(new ApexPages.StandardController(testOpp1));
        System.debug('testOpp1 Team List: '+controller1.TeamList);

        //Test with 2 Sales Team members
        OpportunityWinLossReport_CE controller2 = new OpportunityWinLossReport_CE(new ApexPages.StandardController(testOpp2));
        System.debug('testOpp2 Team List: '+controller2.TeamList);

        Test.stopTest();

        //Verify results
        System.assertEquals(controller1.TeamList,'');
        System.assert(controller2.TeamList.contains(', User2'));
    }

    public static testMethod void testCreateProjectFromOpportunity()
    {
        Account a = TestUtils.getAccount('ut1 Acc');
        insert a;
        //Opportunity oppty1 = TestUtils.getOpportunity(a, 'UT - oppty1');
        Opportunity oppty1 = TestUtility.sampleOpportunity(a);
        oppty1.name = 'UT - oppty1';
        insert oppty1;
        System.assertEquals(0, [Select id from Project__c where Account__c =: a.id and Opportunity__c =: oppty1.id].size());

        oppty1.SF_Project_Already_Created__c = true;
        update oppty1;
        oppty1.Pushed_to_OpenAir__c = true;
        oppty1.PS_Review__c = 'Approved';
        oppty1.StageName = '7. Committed';
        oppty1.Project_Template__c = '12345';
        oppty1.Is_PearlMastered__c = true;
        update oppty1;
        System.assertEquals(0, [Select id from Project__c where Account__c =: a.id and Opportunity__c =: oppty1.id].size());

        oppty1.Pushed_To_OpenAir__c = false;
        update oppty1;
        oppty1.SF_Project_Already_Created__c = false;
        update oppty1;
        oppty1.Pushed_to_OpenAir__c = true;
        update oppty1;
        System.assertEquals(1, [Select id from Project__c where Account__c =: a.id and Opportunity__c =: oppty1.id].size());
    }

    static testMethod void testUpdateContactRoles() {
        Account account = TestUtility.sampleAccount();
        insert account;

        Contact contact1 = TestUtility.sampleContact();
        contact1.AccountId = account.Id;
        insert contact1;
        Contact contact2 = TestUtility.sampleContact();
        contact2.LastName = 'TestCon2';
        contact2.AccountId = account.Id;
        insert contact2;
        Contact contact3 = TestUtility.sampleContact();
        contact3.LastName = 'TestCon3';
        contact3.AccountId = account.Id;
        insert contact3;
        Contact contact4 = TestUtility.sampleContact();
        contact4.LastName = 'TestCon4';
        contact4.AccountId = account.Id;
        insert contact4;
        Contact contact5 = TestUtility.sampleContact();
        contact5.LastName = 'TestCon5';
        contact5.AccountId = account.Id;
        insert contact5;

        Contact contact6 = TestUtility.sampleContact();
        contact6.LastName = 'TestCon6';
        contact6.AccountId = account.Id;
        insert contact6;
        Contact contact7 = TestUtility.sampleContact();
        contact7.LastName = 'TestCon7';
        contact7.AccountId = account.Id;
        insert contact7;
        Contact contact8 = TestUtility.sampleContact();
        contact8.LastName = 'TestCon8';
        contact8.AccountId = account.Id;
        insert contact8;
        Contact contact9 = TestUtility.sampleContact();
        contact9.LastName = 'TestCon9';
        contact9.AccountId = account.Id;
        insert contact9;
        Contact contact10 = TestUtility.sampleContact();
        contact10.LastName = 'TestCon10';
        contact10.AccountId = account.Id;
        insert contact10;

        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', Entity_Status__c = 'Contracting Entity',
            Primary_signatory__c = contact1.Id, Preferred_signatory_1__c = contact2.Id, Preferred_signatory_2__c = contact3.Id,
            Preferred_signatory_3__c = contact4.Id, Preferred_signatory_4__c = contact5.Id, Second_signatory__c = contact6.Id,
            Alternative_signatory_1__c = contact7.Id, Alternative_signatory_2__c = contact8.Id, Alternative_signatory_3__c = contact9.Id,
            Alternative_signatory_4__c = contact10.Id);
        insert misysEntity;

        Opportunity testOpp1 = TestUtility.sampleOpportunity();
        testOpp1.Entity__c = misysEntity.Id;

        test.startTest();
        insert testOpp1;
        system.debug('Opp = ' + [select entity__c from opportunity where id = :testOpp1.id]);
        OpportunityContactRole ocr = [select id, ContactId from OpportunityContactRole where OpportunityId = :testOpp1.Id and Role = 'Primary signatory'];
        system.assertEquals(contact1.Id, ocr.ContactId);

        Billing_Entity__c misysEntity2 = new Billing_Entity__c(Name = 'Test1', Entity_Status__c = 'Contracting Entity',
            Primary_signatory__c = contact10.Id, Preferred_signatory_1__c = contact9.Id, Preferred_signatory_2__c = contact8.Id,
            Preferred_signatory_3__c = contact7.Id, Preferred_signatory_4__c = contact6.Id, Second_signatory__c = contact5.Id,
            Alternative_signatory_1__c = contact4.Id, Alternative_signatory_2__c = contact3.Id, Alternative_signatory_3__c = contact2.Id,
            Alternative_signatory_4__c = contact1.Id);
        insert misysEntity2;

        testOpp1.Entity__c = misysEntity2.Id;
        OpportunityTriggerHandler.firstRun = true;
        update testOpp1;
        system.debug('Opp after update = ' + [select entity__c from opportunity where id = :testOpp1.id]);
        OpportunityContactRole ocr1 = [select id, ContactId from OpportunityContactRole where OpportunityId = :testOpp1.Id and Role = 'Primary signatory'];
        system.assertEquals(contact10.Id, ocr1.ContactId);

        Billing_Entity__c misysEntity3 = new Billing_Entity__c(Name = 'Test1', Entity_Status__c = 'Contracting Entity',
            Primary_signatory__c = null, Preferred_signatory_1__c = contact9.Id, Preferred_signatory_2__c = contact8.Id,
            Preferred_signatory_3__c = contact7.Id, Preferred_signatory_4__c = contact6.Id, Second_signatory__c = contact5.Id,
            Alternative_signatory_1__c = contact4.Id, Alternative_signatory_2__c = contact3.Id, Alternative_signatory_3__c = contact2.Id,
            Alternative_signatory_4__c = contact1.Id);
        insert misysEntity3;

        testOpp1.Entity__c = null;
        OpportunityTriggerHandler.firstRun = true;
        update testOpp1;

        test.stopTest();
        list<OpportunityContactRole> ocrList = [select id, ContactId from OpportunityContactRole where OpportunityId = :testOpp1.Id and Role = 'Primary signatory'];
        system.assertEquals(0, ocrList.size());
    }

    static testmethod void testSendOppDetailsToPartnerPathOnOppCreateUpdate(){
        Opportunity testOpp =  TestUtility.sampleOpportunity();
        Account partnerAccount = TestUtility.sampleAccount();
        partnerAccount.type='Prospective Partner';
        insert partnerAccount;

        testOpp.PartnerPath_ID__c='1';
        testOpp.RecordTypeId = IdManager.OPP_LicensesWithWithoutPSRecTypeId;
        testOpp.Probability=0;
        testOpp.CloseDate=system.TODAY();
        testOpp.Partner_Originated__c='Yes';
        testOpp.Partner_Role_s__c='Reseller';
        testOpp.Opportunity_Partner__c=partnerAccount.id;
        // Call Test.startTest before performing callout but after setting test data.
        Test.startTest();
        // Set mock callout class to get the fake http response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_Test());
        //To create a partner opportunity
        insert testOpp;

        //To fetch the opportunity and update the opp details to be send to partnerpath
        Opportunity oppUpdateObj = [Select id, name,account.name,StageName,ForecastCategoryName, probability, Order_Number__c, PartnerPath_ID__c,CloseDate,Sales_Region_FY07__c,MainProduct__c,
            Pricing_Country__c,Opportunity_Partner__c,Partner_Role_s__c,Partner_Originated__c,Partner_Advisory_Manager_Comment__c, NextStep, Next_Step_Due_Date__c, Owner.name,Proposed_Solution__c,
            Why_Misys_Unique_Selling_Point__c, SDA_3_Vision_Roadmap__c, Why_do_something__c, Installed_Supplier__c,MainCompetitor__c,Other_Competition__c,Competitive_Differentiators__c,Key_Dependencies__c,
            ARIS_product_included__c,MAPS_product_included__c From Opportunity where id =: testOpp.id limit 1];
        //To update the fields on opportunity and send the update to PartnerPath
        oppUpdateObj.Sales_Region_FY07__c='Test PP Sales region';
        oppUpdateObj.MainProduct__c='BankFusion Equation';
        oppUpdateObj.Pricing_Country__c='Belgium';
        oppUpdateObj.Partner_Advisory_Manager_Comment__c='Test PP manager comment';
        oppUpdateObj.NextStep='Test PP next step';
        oppUpdateObj.Next_Step_Due_Date__c=System.TODAY();
        oppUpdateObj.Proposed_Solution__c='Test Partnerpath SDA 1 field';
        oppUpdateObj.Why_Misys_Unique_Selling_Point__c  ='Test Partnerpath SDA #2 field';
        oppUpdateObj.SDA_3_Vision_Roadmap__c='Test Partnerpath SDA #3 field';
        oppUpdateObj.Why_do_something__c='Test Partnerpath summery of pain';
        oppUpdateObj.Challenger_Overview__c ='Test Partnerpath challenege overview';
        oppUpdateObj.Installed_Supplier__c='Asseco SEE';
        oppUpdateObj.MainCompetitor__c  ='Microlink Systems';
        oppUpdateObj.Other_Competition__c='Advent Software; Algorithmics';
        oppUpdateObj.Competitive_Differentiators__c='Test Partnerpath competitive diff field';
        oppUpdateObj.Key_Dependencies__c ='Test Partnerpath key dependencies field';
        oppUpdateObj.ARIS_product_included__c =True;
        oppUpdateObj.MAPS_product_included__c =True;
        // Set mock callout class to get the fake http response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator_Test());
        //To create a partner opportunity
        update oppUpdateObj;
        Test.stopTest();
    }
    
    static testmethod void testcpiFieldUpdateOnAmendmentContracted() {
        //Set up test data
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opp';
        testOpp.AccountId = testAccount.Id;
        testOpp.StageName = 'Suspect';
        testOpp.CurrencyIsoCode = 'GBP';
        testOpp.CloseDate = system.today()+7;
        testOpp.ContractID__c = '1234';
        testOpp.Term_Estimate_Months__c = 30;
        testOpp.Deliver_Contracts__c = datetime.now().dateGmt();
        testOpp.SBQQ__Contracted__c = false;
        insert testOpp;

        //Create a different quote for the amendment.
        //This needs to be insert first so the Contract trigger doesn't fill in these values.
        SBQQ__Quote__c testQuote2 = new SBQQ__Quote__c();
        testQuote2.SBQQ__Primary__c = true;
        testQuote2.SBQQ__Type__c = 'Quote';
        testQuote2.SBQQ__Status__c = 'Draft';
        testQuote2.SBQQ__Account__c = testAccount.Id;
        testQuote2.SBQQ__ExpirationDate__c = testOpp.CloseDate;
        testQuote2.SBQQ__Opportunity2__c = testOpp.Id;
        testQuote2.SBQQ__StartDate__c = Date.today();
        testQuote2.SBQQ__SubscriptionTerm__c = 12;
        testQuote2.Standard_Index__c = '';
        testQuote2.Additional_Increase__c = 4;
        testQuote2.CPI__c = 'US CPI-U G&S';
        testQuote2.CPI_Index_Type__c = 'FIX';
        testQuote2.Maximum_Rate__c = 7 ;
        testQuote2.Minimum_Rate__c = 2;
        testQuote2.No_CPI__c = false;
        testQuote2.Use_Existing_CPI__c = false;
        testQuote2.Apply_Standard_CPI__c= true;
        insert testQuote2;

        //Create Quote
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote.SBQQ__Primary__c = true;
        testQuote.SBQQ__Type__c = 'Quote';
        testQuote.SBQQ__Status__c = 'Draft';
        testQuote.SBQQ__Account__c = testAccount.Id;
        testQuote.SBQQ__ExpirationDate__c = testOpp.CloseDate;
        testQuote.SBQQ__Opportunity2__c = testOpp.Id;
        testQuote.SBQQ__StartDate__c = Date.today();
        testQuote.SBQQ__SubscriptionTerm__c = 12;
        testQuote.Standard_Index__c = 'Standard Rate';
        testQuote.Additional_Increase__c = 5;
        testQuote.CPI__c = 'US CPI-U';
        testQuote.CPI_Index_Type__c = 'CAP';
        testQuote.Maximum_Rate__c = 6 ;
        testQuote.Minimum_Rate__c = 1;
        testQuote.No_CPI__c = false;
        testQuote.Use_Existing_CPI__c = true;
        testQuote.Apply_Standard_CPI__c= false;
        insert testQuote;

        //Create Contract
        Contract testContract = new Contract();
        testContract.SBQQ__Opportunity__c = testOpp.Id;
        testContract.AccountId = testAccount.Id;
        insert testContract;

        //Set Up the Opportunity like an Amendment Opportunity.
        testOpp.SBQQ__AmendedContract__c = testContract.Id;
        testOpp.SBQQ__PrimaryQuote__c = testQuote.Id;
        update testOpp;

        Contract contractBefore = [select id, Standard_Index__c, Additional_Increase__c, CPI__c, CPI_Index_Type__c, Maximum_Rate__c, Minimum_Rate__c, No_CPI__c, Use_Existing_CPI__c, Apply_Standard_CPI__c from Contract where Id = :testContract.Id];
        System.assertEquals(contractBefore.Standard_Index__c, 'Standard Rate');
        System.assertEquals(contractBefore.Additional_Increase__c, 5);
        System.assertEquals(contractBefore.CPI__c, 'US CPI-U');
        System.assertEquals(contractBefore.CPI_Index_Type__c, 'CAP');
        System.assertEquals(contractBefore.Maximum_Rate__c, 6);
        System.assertEquals(contractBefore.Minimum_Rate__c, 1);
        System.assertEquals(contractBefore.No_CPI__c, false);
        System.assertEquals(contractBefore.Use_Existing_CPI__c, true);
        System.assertEquals(contractBefore.Apply_Standard_CPI__c, false); 
       
        //Update the Contracted field to test the after Update trigger
        testOpp.SBQQ__PrimaryQuote__c = testQuote2.Id;
        testOpp.SBQQ__Contracted__c = true;
        update testOpp;
 
        //Verify the test results
        Contract contractAfter = [select id, Standard_Index__c, Additional_Increase__c, CPI__c, CPI_Index_Type__c, Maximum_Rate__c, Minimum_Rate__c, No_CPI__c, Use_Existing_CPI__c, Apply_Standard_CPI__c from Contract where Id = :testContract.Id];
        System.assertEquals(contractAfter.Standard_Index__c, null);
        System.assertEquals(contractAfter.Additional_Increase__c, 4);
        System.assertEquals(contractAfter.CPI__c, 'US CPI-U G&S');
        System.assertEquals(contractAfter.CPI_Index_Type__c, 'FIX');
        System.assertEquals(contractAfter.Maximum_Rate__c, 7);
        System.assertEquals(contractAfter.Minimum_Rate__c, 2);
        System.assertEquals(contractAfter.No_CPI__c, false);
        System.assertEquals(contractAfter.Use_Existing_CPI__c, false);
        System.assertEquals(contractAfter.Apply_Standard_CPI__c, true); 
    }
}