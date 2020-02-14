@isTest()
public class Community_Level1CaseCapturePage1V2_Test {
    
    static testmethod void Community_Level1CaseCapturePage1V2_Test (){
        
        Account testAccount1 = TestUtility.sampleAccount();
        insert testAccount1;
        
        Account testAccount2 = TestUtility.sampleAccount();
        testAccount2.Name = 'Test Account2';
        insert testAccount2;
        
        Contact testContact1 = TestUtility.sampleContact();
        testContact1.AccountId = testAccount1.Id;
        testContact1.Inactive_Contact__c = false;
        insert testContact1;
        
        Case testCase1 = TestUtility.sampleCase();
        testCase1.AccountId = testAccount1.Id;
        testCase1.ContactId = testContact1.Id;
        insert testCase1;
        
        Accounts_Supported__c accountSupported1 = TestUtility.sampleAccountsSupported(testContact1, testAccount2);
        insert accountSupported1;
        
        User standardUser = TestUtility.sampleUser();
        insert standardUser;
        
        //System.runAs(standardUser){
            CommunityLevel1CaseCaptureControllerV2 cont = new CommunityLevel1CaseCaptureControllerV2(new ApexPages.Standardcontroller(testCase1));

            //Simulate nothing being entered into the search
            cont.CustomerSearch = '';
            cont.ContactSearch = '';
            PageReference pr = cont.SearchCustomers();
            System.assertEquals(pr, null);
            System.assert(cont.NoSearchAlertDisplay);
            
            cont.CustomerSearch = 'Test Account';
            cont.ContactSearch = '';
            cont.SearchCustomers();
            System.assert(cont.SearchContacts.size() > 0);
            
            cont.getNextPage();
            cont.getPreviousPage();
            
            pr = cont.LogCase();
            System.assert(cont.NoCustSelectAlertDisplay);
            System.assert(!cont.TooManySelectAlertDisplay);
            
            cont.CurrentPageDataSet[0].Selected = true;
            cont.ContactSelected();
            //System.assert(cont.existingCustomerCases.size() > 0);
            
            pr = cont.LogCase();
            System.assert(!cont.NoCustSelectAlertDisplay);
            System.assert(!cont.TooManySelectAlertDisplay);
            
            //pr = cont.EditSelectedCase();
            //System.assertEquals(pr, null);
            //System.assert(cont.NoCaseSelectAlertDisplay);
            
            //cont.existingCustomerCases[0].Selected = true;
            //pr = cont.EditSelectedCase();
            //System.assert(!cont.NoCaseSelectAlertDisplay);
            //System.assert(!cont.TooManyCaseSelectAlertDisplay);
            
            cont.ContactSearch = 'Last';
            cont.SearchCustomers();
            System.assert(cont.SearchContacts.size() > 0);
            
            cont.CustomerSearch = '';
            cont.SearchCustomers();
            System.assert(cont.SearchContacts.size() > 0);
            
            PageReference testPR = Page.Community_Level1_Case_CaptureV2;
            testPR.getParameters().put('def_contact_id', testContact1.Id);
            Test.setCurrentPage(testPR);
            CommunityLevel1CaseCaptureControllerV2 cont2 = new CommunityLevel1CaseCaptureControllerV2();
            cont2.SearchCustomers();
            System.assert(cont2.SearchContacts.size() > 0);
            
            PageReference testPR2 = Page.Community_Level1_Case_CaptureV2;
            testPR2.getParameters().put('def_account_id', testAccount1.Id);
            Test.setCurrentPage(testPR2);
            CommunityLevel1CaseCaptureControllerV2 cont3 = new CommunityLevel1CaseCaptureControllerV2();
            cont3.SearchCustomers();
            System.assert(cont3.SearchContacts.size() > 0);
        //}
    }
    
    static testmethod void testLogACase_LocationsOfUse()
    {
        //Set up test data
        Account mainAccount = TestUtility.sampleAccount();
        mainAccount.Name = 'Main Account';
        mainAccount.Type = 'Customer';
        mainAccount.Sub_Type__c = 'Primary Location';
        insert mainAccount;
        
        Account supportAccount = TestUtility.sampleAccount();
        supportAccount.Name = 'Support Account';
        supportAccount.Type = 'Customer';
        supportAccount.Sub_Type__c = 'Support Location';
        insert supportAccount;

        Contact supportContact = TestUtility.sampleContact();
        supportContact.AccountId = supportAccount.Id;
        supportContact.Inactive_Contact__c = false;
        insert supportContact;
                
        System__c testSystem1 = new System__c();
        testSystem1.Account__c = mainAccount.Id;
        testSystem1.Environment2__c = 'PROD';
        testSystem1.Name = 'TS1';
        insert testSystem1;
        
        CCRT__c mainCCRT = new CCRT__c();
        mainCCRT.Account__c = mainAccount.Id;
        mainCCRT.Client_Site_Number__c = '1234567';
        insert mainCCRT;
        
        CCRT__c supportCCRT = new CCRT__c();
        supportCCRT.Account__c = supportAccount.Id;
        supportCCRT.Client_Site_Number__c = '7654321';
        insert supportCCRT;
        
        Product_Set__c testPS1 = new Product_Set__c();
        testPS1.Account__c = mainAccount.Id;
        testPS1.Business_Group__c = 'BG1';
        testPS1.Production__c = true;
        insert testPS1;
        
        Entitlement__c testEnt1 = new Entitlement__c();
        testEnt1.Account__c = mainAccount.Id;
        testEnt1.Product_Set__c = testPS1.Id;
        testEnt1.System__c = testSystem1.Id;
        testEnt1.Status__c = 'Active';
        insert testEnt1;
        
        Client_Asset__c testCA1 = new Client_Asset__c();
        testCA1.Product_Set__c = testPS1.Id;
        testCA1.Account__c = mainAccount.Id;
        insert testCA1;
        
        Contract_Asset__c testTA1 = new Contract_Asset__c();
        testTA1.Client_Asset__c = testCA1.Id;
        testTA1.System__c = testSystem1.Id;
        testTA1.Account__c = mainAccount.Id;
        insert testTA1;
        
        Location_of_Use__c testLOU1 = new Location_of_Use__c();
        testLOU1.CCRT__c = supportCCRT.Id;
        testLOU1.Contract_Asset__c = testTA1.Id;
        insert testLOU1;
        
        List<Constants__c> custSettings = TestUtility.loadConstants();
        insert custSettings;
        
        Account resultChosenAccount;
        Contact resultChosenContact;
        string resultProductSetChosen;
        string resultSystemChosen;
        string resultEntitlementChosen;
        
        //Run the tests
        Test.startTest();
            
            //Start on page 2 with the account and contact selected.  Capture the account and contact selected to verify later.
            PageReference testPR = Page.Community_Level1_Case_Capture_Page2;
            testPR.getParameters().put('accountid', supportAccount.Id);
            testPR.getParameters().put('contactid', supportContact.Id); 
            Test.setCurrentPage(testPR);

            //Instantiate the controller and capture the account and contact selected to verify later.
            Community_Level1CaseCaptPage2Controller cont = new Community_Level1CaseCaptPage2Controller();
            resultChosenAccount = cont.chosenAccount;
            resultChosenContact = cont.chosenContact;
            resultProductSetChosen = cont.productSetChosen;
            resultSystemChosen = cont.newCase.System__c;
            resultEntitlementChosen = cont.newCase.Support_Entitlement__c;
            //oe:gen tests to increase code coverage - 23.01.16
          Boolean showTypeField = cont.showTypeField;
          Boolean isCaseTypeProject = cont.isCaseTypeProject;
          Boolean IsINDCase = cont.IsINDCase;
          Boolean showSystemStatusField = cont.showSystemStatusField;
          Boolean showProductFields = cont.showProductFields;
          Boolean requireProductFields = cont.requireProductFields;
          Boolean showSophisFields = cont.showSophisFields;
        
        Test.stopTest();
        
        //Verify the results
        system.assertEquals(supportAccount.Id,resultChosenAccount.Id);
        system.assertEquals(supportContact.Id,resultChosenContact.Id);
        //oe:gen fix for single Product Set means the following two assertions are no longer valid
        //system.assertEquals(testSystem1.Id,resultSystemChosen);
        //system.assertEquals(testEnt1.Id,resultEntitlementChosen);
        
    }

    static testmethod void Community_Level1CaseCapturePage2Controller_Test (){
        
        //Set up the test data
        Account testAccount1 = TestUtility.sampleAccount();
        insert testAccount1;
        
        Account testAccount2 = TestUtility.sampleAccount();
        testAccount2.Name = 'Test Account2';
        insert testAccount2;
        
        Contact testContact1 = TestUtility.sampleContact();
        testContact1.AccountId = testAccount1.Id;
        testContact1.Inactive_Contact__c = false;
        insert testContact1;
        
        Case testCase1 = TestUtility.sampleCase();
        testCase1.AccountId = testAccount1.Id;
        testCase1.ContactId = testContact1.Id;
        insert testCase1;
        
        Accounts_Supported__c accountSupported1 = TestUtility.sampleAccountsSupported(testContact1, testAccount2);
        insert accountSupported1;
        
        System__c testSystem1 = new System__c();
        testSystem1.Account__c = testAccount1.Id;
        testSystem1.Environment2__c = 'PROD';
        testSystem1.Name = 'TS1';
        insert testSystem1;
        
        CCRT__c testCCRT1 = new CCRT__c();
        testCCRT1.Account__c = testAccount1.Id;
        testCCRT1.Client_Site_Number__c = '1234567';
        insert testCCRT1;
        
        Product_Set__c testPS1 = new Product_Set__c();
        testPS1.Account__c = testAccount1.Id;
        testPS1.Name = 'PS1';
        testPS1.Business_Group__c = 'BG1';
        testPS1.Production__c = true;
        insert testPS1;
        
        Entitlement__c testEnt1 = new Entitlement__c();
        testEnt1.Account__c = testAccount1.Id;
        testEnt1.Product_Set__c = testPS1.Id;
        testEnt1.System__c = testSystem1.Id;
        testEnt1.Status__c = 'Active';
        insert testEnt1;
        
        Client_Asset__c testCA1 = new Client_Asset__c();
        testCA1.Product_Set__c = testPS1.Id;
        testCA1.Account__c = testAccount1.Id;
        insert testCA1;
        
        Contract_Asset__c testTA1 = new Contract_Asset__c();
        testTA1.Client_Asset__c = testCA1.Id;
        testTA1.System__c = testSystem1.Id;
        testTA1.Account__c = testAccount1.Id;
        insert testTA1;
        
        Location_of_Use__c testLOU1 = new Location_of_Use__c();
        testLOU1.CCRT__c = testCCRT1.Id;
        testLOU1.Contract_Asset__c = testTA1.Id;
        insert testLOU1;
        
        RecordType rt = [select Id from RecordType where sObjectType = 'Case' LIMIT 1];
        
        List<Constants__c> custSettings = new List<Constants__c>();
        custSettings.add(new Constants__c(Name='DEFAULT_INTERNAL_SEVERITY', ExternalId__c='DEFAULT_INTERNAL_SEVERITY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN', ExternalId__c='DEFAULT_ORIGIN', Value__c='Email'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN_PORTAL', ExternalId__c='DEFAULT_ORIGIN_PORTAL', Value__c='Web'));
        custSettings.add(new Constants__c(Name='DEFAULT_URGENCY', ExternalId__c='DEFAULT_URGENCY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_SEVERITY', ExternalId__c='DEFAULT_SEVERITY', Value__c='Medium'));
        custSettings.add(new Constants__c(Name='DEFAULT_STATUS', ExternalId__c='DEFAULT_STATUS', Value__c='New'));
        custSettings.add(new Constants__c(Name='DEFAULT_TYPE', ExternalId__c='DEFAULT_TYPE', Value__c='Technical'));
        custSettings.add(new Constants__c(Name='DUMMY PRODUCT SET ID', ExternalId__c='DUMMY PRODUCT SET ID', Value__c=testPS1.Id));
        custSettings.add(new Constants__c(Name='DEFAULT_CASE_RECORDTYPE_ID', ExternalId__c='DEFAULT_CASE_RECORDTYPE_ID', Value__c=rt.Id));
        insert custSettings;
        
        List<ProductSetToRecordTypeId__c> prodsetSettings = TestUtility.loadPSSettings();
        insert prodsetSettings;
        
        PageReference testPR = Page.Community_Level1_Case_Capture_Page2;
        testPR.getParameters().put('accountid', testAccount1.Id);
        testPR.getParameters().put('contactid', testContact1.Id);
        Test.setCurrentPage(testPR);
        
        Community_Level1CaseCaptPage2Controller cont = new Community_Level1CaseCaptPage2Controller();
        PageReference retPR = cont.Cancel();
        System.AssertEquals(retPR.getUrl(), '/SupportCommunity/500/o');
        
        testPR.getParameters().put('retURL', 'testpage');
        Test.setCurrentPage(testPR);
        retPR = cont.Cancel();
        System.AssertEquals(retPR.getUrl(), 'testpage');

        testPR.getParameters().put('severityParam', '1 - Critical');
        Test.setCurrentPage(testPR);
        
        retPR = cont.SaveAndAttach();
        System.assertEquals(retPR, null);
        System.assert(cont.displayValidationMessage);
        
        testPR.getParameters().put('typeParam', 'Software Order');
        cont.typeUpdated();
        
        testPR.getParameters().put('typeParam', 'Suspected Defect');
        cont.typeUpdated();
        
        testPR.getParameters().put('typeParam', 'Documentation');
        cont.typeUpdated();
        
        cont.newCase.System_Status__c='Live';
        cont.newCase.Type='';
        cont.newCase.Severity__c='';
        cont.productSetChosen='Please Select';
        cont.validate(); 
        
        /*
        cont.newCase.Product_Set__c = testPS1.Id;
        cont.newCase.System__c = testSystem1.Id;
        cont.newCase.Support_Entitlement__c = testEnt1.Id;
        cont.newCase.Severity__c = '3 - Medium';
        cont.newCase.Internal_Severity__c = '3';
        cont.newCase.Priority = '3';
        cont.newCase.Subject = 'sub';
        cont.newCase.Description = 'desc';
        cont.newCase.Time_spent_on_issue__c = 30;
        cont.useDefaultAssignmentRules = true;
        cont.sendEmailToContact = true;
        cont.caseComment.CommentBody = 'Testing comment';
        cont.newCase.Client_Asset__c = testCA1.Id;
        cont.newCase.Self_Service_Product__c = 'Honda';
        cont.newCase.Product_Version__c = '1997';
        cont.newCase.System_Status__c = 'Live';
        //New lines - oe:gen - 10/08/15
        cont.newCase.Number_of_users_affected__c = '10';
        cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
        cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
        cont.newCase.First_Occurrence__c = 'Yes';
        cont.newCase.Product_document_used_for_analysis__c = 'document';
        
        retPR = cont.SaveOnly();
        system.debug('Save attempt validation errors: '+cont.validationMessage);
        system.assert(retPR.getURL().contains('/500'));
                
        cont.newCase.Product_Set__c = null;
        cont.newCase.System__c = null;
        cont.newCase.Support_Entitlement__c = null;
        cont.newCase.Severity__c = null;
        cont.newCase.Internal_Severity__c = null;
        cont.newCase.Priority = null;
        cont.newCase.Subject = null;
        cont.newCase.Description = null;
        cont.newCase.Time_spent_on_issue__c = null;
        cont.newCase.Number_of_users_affected__c = null;
        cont.newCase.Details_when_error_occurred_reproduced__c = null;
        cont.newCase.Actions_done_to_do_workaround_or_resolve__c = null;
        cont.newCase.First_Occurrence__c = null;
        cont.newCase.Product_document_used_for_analysis__c = null;
        retPR = cont.SaveOnly();
        
        system.assert(retPR == null);
    */

    }
    
    static testmethod void testLogACase_MissingAssets()
    {
        //Set up the test data
        Account testAccount1 = TestUtility.sampleAccount();
        insert testAccount1;
        
        Account testAccount2 = TestUtility.sampleAccount();
        testAccount2.Name = 'Test Account2';
        insert testAccount2;
        
        Contact testContact1 = TestUtility.sampleContact();
        testContact1.AccountId = testAccount1.Id;
        testContact1.Inactive_Contact__c = false;
        insert testContact1;
        
        System__c testSystem1 = new System__c();
        testSystem1.Account__c = testAccount1.Id;
        testSystem1.Environment2__c = 'PROD';
        testSystem1.Name = 'TS1';
        insert testSystem1;
        
        CCRT__c testCCRT1 = new CCRT__c();
        testCCRT1.Account__c = testAccount1.Id;
        testCCRT1.Client_Site_Number__c = '1234567';
        insert testCCRT1;
        
        Product_Set__c testPS1 = new Product_Set__c();
        testPS1.Account__c = testAccount1.Id;
        testPS1.Business_Group__c = 'BG1';
        testPS1.Production__c = true;
        insert testPS1;
        
        Entitlement__c testEnt1 = new Entitlement__c();
        testEnt1.Account__c = testAccount1.Id;
        testEnt1.Product_Set__c = testPS1.Id;
        testEnt1.System__c = testSystem1.Id;
        testEnt1.Status__c = 'Active';
        insert testEnt1;
        
        //No Client Assets for this test
        
        //No Contract Assets for this test  
        
        RecordType rt = [select Id from RecordType where sObjectType = 'Case' LIMIT 1];
        
        List<Constants__c> custSettings = new List<Constants__c>();
        custSettings.add(new Constants__c(Name='DEFAULT_INTERNAL_SEVERITY', ExternalId__c='DEFAULT_INTERNAL_SEVERITY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN', ExternalId__c='DEFAULT_ORIGIN', Value__c='Email'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN_PORTAL', ExternalId__c='DEFAULT_ORIGIN_PORTAL', Value__c='Web'));
        custSettings.add(new Constants__c(Name='DEFAULT_URGENCY', ExternalId__c='DEFAULT_URGENCY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_SEVERITY', ExternalId__c='DEFAULT_SEVERITY', Value__c='Medium'));
        custSettings.add(new Constants__c(Name='DEFAULT_STATUS', ExternalId__c='DEFAULT_STATUS', Value__c='New'));
        custSettings.add(new Constants__c(Name='DEFAULT_TYPE', ExternalId__c='DEFAULT_TYPE', Value__c='Technical'));
        custSettings.add(new Constants__c(Name='DUMMY PRODUCT SET ID', ExternalId__c='DUMMY PRODUCT SET ID', Value__c=testPS1.Id));
        custSettings.add(new Constants__c(Name='DEFAULT_CASE_RECORDTYPE_ID', ExternalId__c='DEFAULT_CASE_RECORDTYPE_ID', Value__c=rt.Id));
        insert custSettings;
        
        //Run the tests
       
        Test.startTest();
            Community_Level1CaseCaptPage2Controller cont = new Community_Level1CaseCaptPage2Controller();
          PageReference testPR1 = Page.Community_Level1_Case_Capture_Page1;
            testPR1.getParameters().put('accountid',testAccount1.Id);
            testPR1.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR1);

            PageReference testPR2 = Page.Community_Level1_Case_Capture_Page2;
            testPR2.getParameters().put('accountid',testAccount1.Id);
            testPR2.getParameters().put('contactid',testContact1.Id);
            testPR2.getParameters().put('severityParam', '1 - Critical');
            //cont.getstatusItems();
            //cont.getTypeItems();

            testPR2.getParameters().put('typeParam', 'Documentation');
            cont.typeUpdated();

            //testPR2.getParameters().put('typeParam','Software Order');
            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','Single User');
            testPR2.getParameters().put('typeParam', 'Suspected Defect');
            cont.typeUpdated();
            //cont.caseStatus = 'Live';
            //cont.newCase.Number_of_users_affected__c = 'Single User';
            //cont.caseType = 'Suspected Defect';
            Test.setCurrentPage(testPR2);
            cont.newCase.Number_of_users_affected__c = 'Single User';
            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
            //cont.caseStatus = 'Live';
            //cont.caseType = 'Question';
            cont.typeUpdated();
            cont.returnSearchResults();
            cont.severityUpdated();


            //Attempt to add a new case with missing client and contract assets
            cont.newCase.Product_Set__c = testPS1.Id;
            cont.newCase.System__c = testSystem1.Id;
            cont.newCase.Support_Entitlement__c = testEnt1.Id;
            cont.newCase.Severity__c = 'Medium';
            cont.newCase.Internal_Severity__c = '3';
            cont.newCase.Priority = '3';
            cont.newCase.Subject = 'sub';
            cont.newCase.Description = 'desc';
            cont.newCase.Time_spent_on_issue__c = 30;
            cont.useDefaultAssignmentRules = true;
            cont.sendEmailToContact = true;
            cont.caseComment.CommentBody = 'Testing comment';
            //New lines - oe:gen - 10/08/15
            cont.newCase.Number_of_users_affected__c = '10';
            cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
            cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
            cont.newCase.First_Occurrence__c = 'Yes';
            cont.newCase.Product_document_used_for_analysis__c = 'document';
            cont.newCase.System_Status__c = 'Live';
            
            //cont.newCase.Client_Asset__c = testCA1.Id;
             cont.returnSearchResults();
            
            PageReference retPR = cont.SaveOnly();
            cont.typeUpdated();
            cont.startPage();
            cont.NextPage();
            cont.firstOccurrenceUpdated();
            cont.PrevPage();
            cont.ContinueNextPage();
            cont.redirect();
                
        Test.stopTest();

        //test various severity drop downs
        
        //Verify the results
        //system.assert(retPR.getURL().contains('/500'));
        
    }

    static testmethod void testLogACase_Dropdowns() {
        //Set up the test data
        Account testAccount1 = TestUtility.sampleAccount();
        insert testAccount1;
        
        Account testAccount2 = TestUtility.sampleAccount();
        testAccount2.Name = 'Test Account2';
        insert testAccount2;
        
        Contact testContact1 = TestUtility.sampleContact();
        testContact1.AccountId = testAccount1.Id;
        testContact1.Inactive_Contact__c = false;
        insert testContact1;
        
        System__c testSystem1 = new System__c();
        testSystem1.Account__c = testAccount1.Id;
        testSystem1.Environment2__c = 'PROD';
        testSystem1.Name = 'TS1';
        insert testSystem1;
        
        CCRT__c testCCRT1 = new CCRT__c();
        testCCRT1.Account__c = testAccount1.Id;
        testCCRT1.Client_Site_Number__c = '1234567';
        insert testCCRT1;
        
        Product_Set__c testPS1 = new Product_Set__c();
        testPS1.Account__c = testAccount1.Id;
        testPS1.Business_Group__c = 'BG1';
        testPS1.Production__c = true;
        insert testPS1;
        
        Entitlement__c testEnt1 = new Entitlement__c();
        testEnt1.Account__c = testAccount1.Id;
        testEnt1.Product_Set__c = testPS1.Id;
        testEnt1.System__c = testSystem1.Id;
        testEnt1.Status__c = 'Active';
        insert testEnt1;
        
        //No Client Assets for this test
        
        //No Contract Assets for this test  
        
        RecordType rt = [select Id from RecordType where sObjectType = 'Case' LIMIT 1];
        
        List<Constants__c> custSettings = new List<Constants__c>();
        custSettings.add(new Constants__c(Name='DEFAULT_INTERNAL_SEVERITY', ExternalId__c='DEFAULT_INTERNAL_SEVERITY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN', ExternalId__c='DEFAULT_ORIGIN', Value__c='Email'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN_PORTAL', ExternalId__c='DEFAULT_ORIGIN_PORTAL', Value__c='Web'));
        custSettings.add(new Constants__c(Name='DEFAULT_URGENCY', ExternalId__c='DEFAULT_URGENCY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_SEVERITY', ExternalId__c='DEFAULT_SEVERITY', Value__c='Medium'));
        custSettings.add(new Constants__c(Name='DEFAULT_STATUS', ExternalId__c='DEFAULT_STATUS', Value__c='New'));
        custSettings.add(new Constants__c(Name='DEFAULT_TYPE', ExternalId__c='DEFAULT_TYPE', Value__c='Technical'));
        custSettings.add(new Constants__c(Name='DUMMY PRODUCT SET ID', ExternalId__c='DUMMY PRODUCT SET ID', Value__c=testPS1.Id));
        custSettings.add(new Constants__c(Name='DEFAULT_CASE_RECORDTYPE_ID', ExternalId__c='DEFAULT_CASE_RECORDTYPE_ID', Value__c=rt.Id));
        insert custSettings;
        
        //Run the tests
       
        Test.startTest();
            Community_Level1CaseCaptPage2Controller cont = new Community_Level1CaseCaptPage2Controller();
            PageReference testPR1 = Page.Community_Level1_Case_Capture_Page1;
            testPR1.getParameters().put('accountid',testAccount1.Id);
            testPR1.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR1);

            PageReference testPR2 = Page.Community_Level1_Case_Capture_Page2;
            testPR2.getParameters().put('accountid',testAccount1.Id);
            testPR2.getParameters().put('contactid',testContact1.Id);
            testPR2.getParameters().put('severityParam', '1 - Critical');
      //      cont.getstatusItems();
      //      cont.getTypeItems();

            testPR2.getParameters().put('typeParam', 'Documentation');
            cont.typeUpdated();

            //testPR2.getParameters().put('typeParam','Software Order');
            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','Single User');
            cont.newCase.Number_of_users_affected__c = 'Single User';
           // cont.caseStatus = 'Implementation';
            cont.newCase.Number_of_users_affected__c = 'Single User';
        //    cont.caseType = 'Suspected Defect';
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
       //     cont.caseStatus = 'Implementation';
       //     cont.caseType = 'Suspected Defect';
            cont.returnSearchResults();
            cont.severityUpdated();

            //Attempt to add a new case with missing client and contract assets
            cont.newCase.Product_Set__c = testPS1.Id;
            cont.newCase.System__c = testSystem1.Id;
            cont.newCase.Support_Entitlement__c = testEnt1.Id;
            cont.newCase.Severity__c = 'Medium';
            cont.newCase.Internal_Severity__c = '3';
            cont.newCase.Priority = '3';
            cont.newCase.Subject = 'sub';
            cont.newCase.Description = 'desc';
            cont.newCase.Time_spent_on_issue__c = 30;
            cont.useDefaultAssignmentRules = true;
            cont.sendEmailToContact = true;
            cont.caseComment.CommentBody = 'Testing comment';
            //New lines - oe:gen - 10/08/15
            //cont.newCase.Number_of_users_affected__c = '10';
            cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
            cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
            cont.newCase.First_Occurrence__c = 'Yes';
            cont.newCase.Product_document_used_for_analysis__c = 'document';
            cont.newCase.System_Status__c = 'Live';
            
            //cont.newCase.Client_Asset__c = testCA1.Id;
             cont.returnSearchResults();
            
            PageReference retPR = cont.SaveOnly();
            cont.typeUpdated();
            cont.startPage();
            cont.NextPage();
            cont.firstOccurrenceUpdated();
            cont.PrevPage();
            cont.ContinueNextPage();
            cont.redirect();
                
        Test.stopTest();

    }

    static testmethod void testLogACase_Dropdowns2() {
        //Set up the test data
        Account testAccount1 = TestUtility.sampleAccount();
        insert testAccount1;
        
        Account testAccount2 = TestUtility.sampleAccount();
        testAccount2.Name = 'Test Account2';
        insert testAccount2;
        
        Contact testContact1 = TestUtility.sampleContact();
        testContact1.AccountId = testAccount1.Id;
        testContact1.Inactive_Contact__c = false;
        insert testContact1;
        
        System__c testSystem1 = new System__c();
        testSystem1.Account__c = testAccount1.Id;
        testSystem1.Environment2__c = 'PROD';
        testSystem1.Name = 'TS1';
        insert testSystem1;
        
        CCRT__c testCCRT1 = new CCRT__c();
        testCCRT1.Account__c = testAccount1.Id;
        testCCRT1.Client_Site_Number__c = '1234567';
        insert testCCRT1;
        
        Product_Set__c testPS1 = new Product_Set__c();
        testPS1.Account__c = testAccount1.Id;
        testPS1.Business_Group__c = 'BG1';
        testPS1.Production__c = true;
        insert testPS1;
        
        Entitlement__c testEnt1 = new Entitlement__c();
        testEnt1.Account__c = testAccount1.Id;
        testEnt1.Product_Set__c = testPS1.Id;
        testEnt1.System__c = testSystem1.Id;
        testEnt1.Status__c = 'Active';
        insert testEnt1;
        
        //No Client Assets for this test
        
        //No Contract Assets for this test  
        
        RecordType rt = [select Id from RecordType where sObjectType = 'Case' LIMIT 1];
        
        List<Constants__c> custSettings = new List<Constants__c>();
        custSettings.add(new Constants__c(Name='DEFAULT_INTERNAL_SEVERITY', ExternalId__c='DEFAULT_INTERNAL_SEVERITY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN', ExternalId__c='DEFAULT_ORIGIN', Value__c='Email'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN_PORTAL', ExternalId__c='DEFAULT_ORIGIN_PORTAL', Value__c='Web'));
        custSettings.add(new Constants__c(Name='DEFAULT_URGENCY', ExternalId__c='DEFAULT_URGENCY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_SEVERITY', ExternalId__c='DEFAULT_SEVERITY', Value__c='Medium'));
        custSettings.add(new Constants__c(Name='DEFAULT_STATUS', ExternalId__c='DEFAULT_STATUS', Value__c='New'));
        custSettings.add(new Constants__c(Name='DEFAULT_TYPE', ExternalId__c='DEFAULT_TYPE', Value__c='Technical'));
        custSettings.add(new Constants__c(Name='DUMMY PRODUCT SET ID', ExternalId__c='DUMMY PRODUCT SET ID', Value__c=testPS1.Id));
        custSettings.add(new Constants__c(Name='DEFAULT_CASE_RECORDTYPE_ID', ExternalId__c='DEFAULT_CASE_RECORDTYPE_ID', Value__c=rt.Id));
        insert custSettings;
        
        //Run the tests
       
        Test.startTest();
            Community_Level1CaseCaptPage2Controller cont = new Community_Level1CaseCaptPage2Controller();
            PageReference testPR1 = Page.Community_Level1_Case_Capture_Page1;
            testPR1.getParameters().put('accountid',testAccount1.Id);
            testPR1.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR1);

            PageReference testPR2 = Page.Community_Level1_Case_Capture_Page2;
            testPR2.getParameters().put('accountid',testAccount1.Id);
            testPR2.getParameters().put('contactid',testContact1.Id);
            testPR2.getParameters().put('severityParam', '1 - Critical');
           // cont.getstatusItems();
            //cont.getTypeItems();

            testPR2.getParameters().put('typeParam', 'Documentation');
            cont.typeUpdated();

            //testPR2.getParameters().put('typeParam','Software Order');
            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','Single User');
            cont.newCase.Number_of_users_affected__c = 'Single User';
            //cont.caseStatus = 'Implementation';
            //cont.newCase.Number_of_users_affected__c = 'Single User';
        //    cont.caseType = 'Suspected Defect';
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
           // cont.caseStatus = 'Implementation';
           //cont.caseType = 'Suspected Defect';
            cont.returnSearchResults();
            cont.severityUpdated();

            
            //Attempt to add a new case with missing client and contract assets
            cont.newCase.Product_Set__c = testPS1.Id;
            cont.newCase.System__c = testSystem1.Id;
            cont.newCase.Support_Entitlement__c = testEnt1.Id;
            cont.newCase.Severity__c = 'Medium';
            cont.newCase.Internal_Severity__c = '3';
            cont.newCase.Priority = '3';
            cont.newCase.Subject = 'sub';
            cont.newCase.Description = 'desc';
            cont.newCase.Time_spent_on_issue__c = 30;
            cont.useDefaultAssignmentRules = true;
            cont.sendEmailToContact = true;
            cont.caseComment.CommentBody = 'Testing comment';
            //New lines - oe:gen - 10/08/15
            //cont.newCase.Number_of_users_affected__c = '10';
            cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
            cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
            cont.newCase.First_Occurrence__c = 'Yes';
            cont.newCase.Product_document_used_for_analysis__c = 'document';
            cont.newCase.System_Status__c = 'Live';
            
            //cont.newCase.Client_Asset__c = testCA1.Id;
             cont.returnSearchResults();
            
            PageReference retPR = cont.SaveOnly();
            cont.typeUpdated();
            cont.startPage();
            cont.NextPage();
            cont.firstOccurrenceUpdated();
            cont.PrevPage();
            cont.ContinueNextPage();
            cont.redirect();
                
        Test.stopTest();

    }

    static testmethod void testLogACase_Dropdowns3() {
        //Set up the test data
        Account testAccount1 = TestUtility.sampleAccount();
        insert testAccount1;
        
        Account testAccount2 = TestUtility.sampleAccount();
        testAccount2.Name = 'Test Account2';
        insert testAccount2;
        
        Contact testContact1 = TestUtility.sampleContact();
        testContact1.AccountId = testAccount1.Id;
        testContact1.Inactive_Contact__c = false;
        insert testContact1;
        
        System__c testSystem1 = new System__c();
        testSystem1.Account__c = testAccount1.Id;
        testSystem1.Environment2__c = 'PROD';
        testSystem1.Name = 'TS1';
        insert testSystem1;
        
        CCRT__c testCCRT1 = new CCRT__c();
        testCCRT1.Account__c = testAccount1.Id;
        testCCRT1.Client_Site_Number__c = '1234567';
        insert testCCRT1;
        
        Product_Set__c testPS1 = new Product_Set__c();
        testPS1.Account__c = testAccount1.Id;
        testPS1.Business_Group__c = 'BG1';
        testPS1.Production__c = true;
        insert testPS1;
        
        Entitlement__c testEnt1 = new Entitlement__c();
        testEnt1.Account__c = testAccount1.Id;
        testEnt1.Product_Set__c = testPS1.Id;
        testEnt1.System__c = testSystem1.Id;
        testEnt1.Status__c = 'Active';
        insert testEnt1;
        
        //No Client Assets for this test
        
        //No Contract Assets for this test  
        
        RecordType rt = [select Id from RecordType where sObjectType = 'Case' LIMIT 1];
        
        List<Constants__c> custSettings = new List<Constants__c>();
        custSettings.add(new Constants__c(Name='DEFAULT_INTERNAL_SEVERITY', ExternalId__c='DEFAULT_INTERNAL_SEVERITY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN', ExternalId__c='DEFAULT_ORIGIN', Value__c='Email'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN_PORTAL', ExternalId__c='DEFAULT_ORIGIN_PORTAL', Value__c='Web'));
        custSettings.add(new Constants__c(Name='DEFAULT_URGENCY', ExternalId__c='DEFAULT_URGENCY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_SEVERITY', ExternalId__c='DEFAULT_SEVERITY', Value__c='Medium'));
        custSettings.add(new Constants__c(Name='DEFAULT_STATUS', ExternalId__c='DEFAULT_STATUS', Value__c='New'));
        custSettings.add(new Constants__c(Name='DEFAULT_TYPE', ExternalId__c='DEFAULT_TYPE', Value__c='Technical'));
        custSettings.add(new Constants__c(Name='DUMMY PRODUCT SET ID', ExternalId__c='DUMMY PRODUCT SET ID', Value__c=testPS1.Id));
        custSettings.add(new Constants__c(Name='DEFAULT_CASE_RECORDTYPE_ID', ExternalId__c='DEFAULT_CASE_RECORDTYPE_ID', Value__c=rt.Id));
        insert custSettings;
        
        //Run the tests
       
        Test.startTest();
            Community_Level1CaseCaptPage2Controller cont = new Community_Level1CaseCaptPage2Controller();
            PageReference testPR1 = Page.Community_Level1_Case_Capture_Page1;
            testPR1.getParameters().put('accountid',testAccount1.Id);
            testPR1.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR1);

            PageReference testPR2 = Page.Community_Level1_Case_Capture_Page2;
            testPR2.getParameters().put('accountid',testAccount1.Id);
            testPR2.getParameters().put('contactid',testContact1.Id);
            testPR2.getParameters().put('severityParam', '1 - Critical');
         //   cont.getstatusItems();
         //   cont.getTypeItems();

            testPR2.getParameters().put('typeParam', 'Documentation');
            cont.typeUpdated();

            //testPR2.getParameters().put('typeParam','Software Order');
            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','All Users');
            cont.newCase.Number_of_users_affected__c = 'All Users';
       //     cont.caseStatus = 'Implementation';
            //cont.newCase.Number_of_users_affected__c = 'Single User';
            //cont.caseType = 'Suspected Defect';
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
         //   cont.caseStatus = 'Implementation';
         //   cont.caseType = 'Configuration / Set-up Issue';
            cont.returnSearchResults();
            cont.severityUpdated();

            
            //Attempt to add a new case with missing client and contract assets
            cont.newCase.Product_Set__c = testPS1.Id;
            cont.newCase.System__c = testSystem1.Id;
            cont.newCase.Support_Entitlement__c = testEnt1.Id;
            cont.newCase.Severity__c = 'Medium';
            cont.newCase.Internal_Severity__c = '3';
            cont.newCase.Priority = '3';
            cont.newCase.Subject = 'sub';
            cont.newCase.Description = 'desc';
            cont.newCase.Time_spent_on_issue__c = 30;
            cont.useDefaultAssignmentRules = true;
            cont.sendEmailToContact = true;
            cont.caseComment.CommentBody = 'Testing comment';
            //New lines - oe:gen - 10/08/15
            //cont.newCase.Number_of_users_affected__c = '10';
            cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
            cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
            cont.newCase.First_Occurrence__c = 'Yes';
            cont.newCase.Product_document_used_for_analysis__c = 'document';
            cont.newCase.System_Status__c = 'Live';
            
            //cont.newCase.Client_Asset__c = testCA1.Id;
             cont.returnSearchResults();
            
            PageReference retPR = cont.SaveOnly();
            cont.typeUpdated();
            cont.startPage();
            cont.NextPage();
            cont.firstOccurrenceUpdated();
            cont.PrevPage();
            cont.ContinueNextPage();
            cont.redirect();
                
        Test.stopTest();

    }

    static testmethod void testLogACase_Dropdowns4() {
        //Set up the test data
        Account testAccount1 = TestUtility.sampleAccount();
        insert testAccount1;
        
        Account testAccount2 = TestUtility.sampleAccount();
        testAccount2.Name = 'Test Account2';
        insert testAccount2;
        
        Contact testContact1 = TestUtility.sampleContact();
        testContact1.AccountId = testAccount1.Id;
        testContact1.Inactive_Contact__c = false;
        insert testContact1;
        
        System__c testSystem1 = new System__c();
        testSystem1.Account__c = testAccount1.Id;
        testSystem1.Environment2__c = 'PROD';
        testSystem1.Name = 'TS1';
        insert testSystem1;
        
        CCRT__c testCCRT1 = new CCRT__c();
        testCCRT1.Account__c = testAccount1.Id;
        testCCRT1.Client_Site_Number__c = '1234567';
        insert testCCRT1;
        
        Product_Set__c testPS1 = new Product_Set__c();
        testPS1.Account__c = testAccount1.Id;
        testPS1.Business_Group__c = 'BG1';
        testPS1.Production__c = true;
        insert testPS1;
        
        Entitlement__c testEnt1 = new Entitlement__c();
        testEnt1.Account__c = testAccount1.Id;
        testEnt1.Product_Set__c = testPS1.Id;
        testEnt1.System__c = testSystem1.Id;
        testEnt1.Status__c = 'Active';
        insert testEnt1;
        
        //No Client Assets for this test
        
        //No Contract Assets for this test  
        
        RecordType rt = [select Id from RecordType where sObjectType = 'Case' LIMIT 1];
        
        List<Constants__c> custSettings = new List<Constants__c>();
        custSettings.add(new Constants__c(Name='DEFAULT_INTERNAL_SEVERITY', ExternalId__c='DEFAULT_INTERNAL_SEVERITY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN', ExternalId__c='DEFAULT_ORIGIN', Value__c='Email'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN_PORTAL', ExternalId__c='DEFAULT_ORIGIN_PORTAL', Value__c='Web'));
        custSettings.add(new Constants__c(Name='DEFAULT_URGENCY', ExternalId__c='DEFAULT_URGENCY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_SEVERITY', ExternalId__c='DEFAULT_SEVERITY', Value__c='Medium'));
        custSettings.add(new Constants__c(Name='DEFAULT_STATUS', ExternalId__c='DEFAULT_STATUS', Value__c='New'));
        custSettings.add(new Constants__c(Name='DEFAULT_TYPE', ExternalId__c='DEFAULT_TYPE', Value__c='Technical'));
        custSettings.add(new Constants__c(Name='DUMMY PRODUCT SET ID', ExternalId__c='DUMMY PRODUCT SET ID', Value__c=testPS1.Id));
        custSettings.add(new Constants__c(Name='DEFAULT_CASE_RECORDTYPE_ID', ExternalId__c='DEFAULT_CASE_RECORDTYPE_ID', Value__c=rt.Id));
        insert custSettings;
        
        //Run the tests
       
        Test.startTest();
            Community_Level1CaseCaptPage2Controller cont = new Community_Level1CaseCaptPage2Controller();
            PageReference testPR1 = Page.Community_Level1_Case_Capture_Page1;
            testPR1.getParameters().put('accountid',testAccount1.Id);
            testPR1.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR1);

            PageReference testPR2 = Page.Community_Level1_Case_Capture_Page2;
            testPR2.getParameters().put('accountid',testAccount1.Id);
            testPR2.getParameters().put('contactid',testContact1.Id);
            testPR2.getParameters().put('severityParam', '1 - Critical');
      //      cont.getstatusItems();
      //      cont.getTypeItems();

            testPR2.getParameters().put('typeParam', 'Documentation');
            cont.typeUpdated();

            //testPR2.getParameters().put('typeParam','Software Order');
            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','All Users');
            cont.newCase.Number_of_users_affected__c = 'All Users';
      //      cont.caseStatus = 'Implementation';
            //cont.newCase.Number_of_users_affected__c = 'Single User';
            //cont.caseType = 'Suspected Defect';
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
        //    cont.caseStatus = 'Implementation';
       //     cont.caseType = 'Consultancy';
            cont.returnSearchResults();
            cont.severityUpdated();

            
            //Attempt to add a new case with missing client and contract assets
            cont.newCase.Product_Set__c = testPS1.Id;
            cont.newCase.System__c = testSystem1.Id;
            cont.newCase.Support_Entitlement__c = testEnt1.Id;
            cont.newCase.Severity__c = 'Medium';
            cont.newCase.Internal_Severity__c = '3';
            cont.newCase.Priority = '3';
            cont.newCase.Subject = 'sub';
            cont.newCase.Description = 'desc';
            cont.newCase.Time_spent_on_issue__c = 30;
            cont.useDefaultAssignmentRules = true;
            cont.sendEmailToContact = true;
            cont.caseComment.CommentBody = 'Testing comment';
            //New lines - oe:gen - 10/08/15
            //cont.newCase.Number_of_users_affected__c = '10';
            cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
            cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
            cont.newCase.First_Occurrence__c = 'Yes';
            cont.newCase.Product_document_used_for_analysis__c = 'document';
            cont.newCase.System_Status__c = 'Live';
            
            //cont.newCase.Client_Asset__c = testCA1.Id;
             cont.returnSearchResults();
            
            PageReference retPR = cont.SaveOnly();
            cont.typeUpdated();
            cont.startPage();
            cont.NextPage();
            cont.firstOccurrenceUpdated();
            cont.PrevPage();
            cont.ContinueNextPage();
            cont.redirect();
                
        Test.stopTest();

    }


    static testmethod void testLogACase_Dropdowns5() {
        //Set up the test data
        Account testAccount1 = TestUtility.sampleAccount();
        insert testAccount1;
        
        Account testAccount2 = TestUtility.sampleAccount();
        testAccount2.Name = 'Test Account2';
        insert testAccount2;
        
        Contact testContact1 = TestUtility.sampleContact();
        testContact1.AccountId = testAccount1.Id;
        testContact1.Inactive_Contact__c = false;
        insert testContact1;
        
        System__c testSystem1 = new System__c();
        testSystem1.Account__c = testAccount1.Id;
        testSystem1.Environment2__c = 'PROD';
        testSystem1.Name = 'TS1';
        insert testSystem1;
        
        CCRT__c testCCRT1 = new CCRT__c();
        testCCRT1.Account__c = testAccount1.Id;
        testCCRT1.Client_Site_Number__c = '1234567';
        insert testCCRT1;
        
        Product_Set__c testPS1 = new Product_Set__c();
        testPS1.Account__c = testAccount1.Id;
        testPS1.Business_Group__c = 'BG1';
        testPS1.Production__c = true;
        insert testPS1;
        
        Entitlement__c testEnt1 = new Entitlement__c();
        testEnt1.Account__c = testAccount1.Id;
        testEnt1.Product_Set__c = testPS1.Id;
        testEnt1.System__c = testSystem1.Id;
        testEnt1.Status__c = 'Active';
        insert testEnt1;
        
        //No Client Assets for this test
        
        //No Contract Assets for this test  
        
        RecordType rt = [select Id from RecordType where sObjectType = 'Case' LIMIT 1];
        
        List<Constants__c> custSettings = new List<Constants__c>();
        custSettings.add(new Constants__c(Name='DEFAULT_INTERNAL_SEVERITY', ExternalId__c='DEFAULT_INTERNAL_SEVERITY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN', ExternalId__c='DEFAULT_ORIGIN', Value__c='Email'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN_PORTAL', ExternalId__c='DEFAULT_ORIGIN_PORTAL', Value__c='Web'));
        custSettings.add(new Constants__c(Name='DEFAULT_URGENCY', ExternalId__c='DEFAULT_URGENCY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_SEVERITY', ExternalId__c='DEFAULT_SEVERITY', Value__c='Medium'));
        custSettings.add(new Constants__c(Name='DEFAULT_STATUS', ExternalId__c='DEFAULT_STATUS', Value__c='New'));
        custSettings.add(new Constants__c(Name='DEFAULT_TYPE', ExternalId__c='DEFAULT_TYPE', Value__c='Technical'));
        custSettings.add(new Constants__c(Name='DUMMY PRODUCT SET ID', ExternalId__c='DUMMY PRODUCT SET ID', Value__c=testPS1.Id));
        custSettings.add(new Constants__c(Name='DEFAULT_CASE_RECORDTYPE_ID', ExternalId__c='DEFAULT_CASE_RECORDTYPE_ID', Value__c=rt.Id));
        insert custSettings;
        
        //Run the tests
       
        Test.startTest();
            Community_Level1CaseCaptPage2Controller cont = new Community_Level1CaseCaptPage2Controller();
            PageReference testPR1 = Page.Community_Level1_Case_Capture_Page1;
            testPR1.getParameters().put('accountid',testAccount1.Id);
            testPR1.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR1);

            PageReference testPR2 = Page.Community_Level1_Case_Capture_Page2;
            testPR2.getParameters().put('accountid',testAccount1.Id);
            testPR2.getParameters().put('contactid',testContact1.Id);
            testPR2.getParameters().put('severityParam', '1 - Critical');
      //      cont.getstatusItems();
      //      cont.getTypeItems();

            testPR2.getParameters().put('typeParam', 'Documentation');
            cont.typeUpdated();

            //testPR2.getParameters().put('typeParam','Software Order');
            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','All Users');
            cont.newCase.Number_of_users_affected__c = 'All Users';
            //cont.caseStatus = 'Implementation';
            //cont.newCase.Number_of_users_affected__c = 'Single User';
            //cont.caseType = 'Suspected Defect';
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
   //        cont.caseStatus = 'Test';
   //        cont.caseType = 'Consultancy';
            cont.returnSearchResults();
            cont.severityUpdated();

            
            //Attempt to add a new case with missing client and contract assets
            cont.newCase.Product_Set__c = testPS1.Id;
            cont.newCase.System__c = testSystem1.Id;
            cont.newCase.Support_Entitlement__c = testEnt1.Id;
            cont.newCase.Severity__c = 'Medium';
            cont.newCase.Internal_Severity__c = '3';
            cont.newCase.Priority = '3';
            cont.newCase.Subject = 'sub';
            cont.newCase.Description = 'desc';
            cont.newCase.Time_spent_on_issue__c = 30;
            cont.useDefaultAssignmentRules = true;
            cont.sendEmailToContact = true;
            cont.caseComment.CommentBody = 'Testing comment';
            //New lines - oe:gen - 10/08/15
            //cont.newCase.Number_of_users_affected__c = '10';
            cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
            cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
            cont.newCase.First_Occurrence__c = 'Yes';
            cont.newCase.Product_document_used_for_analysis__c = 'document';
            cont.newCase.System_Status__c = 'Live';
            
            //cont.newCase.Client_Asset__c = testCA1.Id;
             cont.returnSearchResults();
            
            PageReference retPR = cont.SaveOnly();
            cont.typeUpdated();
            cont.startPage();
            cont.NextPage();
            cont.firstOccurrenceUpdated();
            cont.PrevPage();
            cont.ContinueNextPage();
            cont.redirect();
                
        Test.stopTest();

    }

    static testmethod void testLogACase_Dropdowns6() {
        //Set up the test data
        Account testAccount1 = TestUtility.sampleAccount();
        insert testAccount1;
        
        Account testAccount2 = TestUtility.sampleAccount();
        testAccount2.Name = 'Test Account2';
        insert testAccount2;
        
        Contact testContact1 = TestUtility.sampleContact();
        testContact1.AccountId = testAccount1.Id;
        testContact1.Inactive_Contact__c = false;
        insert testContact1;
        
        System__c testSystem1 = new System__c();
        testSystem1.Account__c = testAccount1.Id;
        testSystem1.Environment2__c = 'PROD';
        testSystem1.Name = 'TS1';
        insert testSystem1;
        
        CCRT__c testCCRT1 = new CCRT__c();
        testCCRT1.Account__c = testAccount1.Id;
        testCCRT1.Client_Site_Number__c = '1234567';
        insert testCCRT1;
        
        Product_Set__c testPS1 = new Product_Set__c();
        testPS1.Account__c = testAccount1.Id;
        testPS1.Business_Group__c = 'BG1';
        testPS1.Production__c = true;
        insert testPS1;
        
        Entitlement__c testEnt1 = new Entitlement__c();
        testEnt1.Account__c = testAccount1.Id;
        testEnt1.Product_Set__c = testPS1.Id;
        testEnt1.System__c = testSystem1.Id;
        testEnt1.Status__c = 'Active';
        insert testEnt1;
        
        //No Client Assets for this test
        
        //No Contract Assets for this test  
        
        RecordType rt = [select Id from RecordType where sObjectType = 'Case' LIMIT 1];
        
        List<Constants__c> custSettings = new List<Constants__c>();
        custSettings.add(new Constants__c(Name='DEFAULT_INTERNAL_SEVERITY', ExternalId__c='DEFAULT_INTERNAL_SEVERITY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN', ExternalId__c='DEFAULT_ORIGIN', Value__c='Email'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN_PORTAL', ExternalId__c='DEFAULT_ORIGIN_PORTAL', Value__c='Web'));
        custSettings.add(new Constants__c(Name='DEFAULT_URGENCY', ExternalId__c='DEFAULT_URGENCY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_SEVERITY', ExternalId__c='DEFAULT_SEVERITY', Value__c='Medium'));
        custSettings.add(new Constants__c(Name='DEFAULT_STATUS', ExternalId__c='DEFAULT_STATUS', Value__c='New'));
        custSettings.add(new Constants__c(Name='DEFAULT_TYPE', ExternalId__c='DEFAULT_TYPE', Value__c='Technical'));
        custSettings.add(new Constants__c(Name='DUMMY PRODUCT SET ID', ExternalId__c='DUMMY PRODUCT SET ID', Value__c=testPS1.Id));
        custSettings.add(new Constants__c(Name='DEFAULT_CASE_RECORDTYPE_ID', ExternalId__c='DEFAULT_CASE_RECORDTYPE_ID', Value__c=rt.Id));
        insert custSettings;
        
        //Run the tests
       
        Test.startTest();
            Community_Level1CaseCaptPage2Controller cont = new Community_Level1CaseCaptPage2Controller();
            PageReference testPR1 = Page.Community_Level1_Case_Capture_Page1;
            testPR1.getParameters().put('accountid',testAccount1.Id);
            testPR1.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR1);

            PageReference testPR2 = Page.Community_Level1_Case_Capture_Page2;
            testPR2.getParameters().put('accountid',testAccount1.Id);
            testPR2.getParameters().put('contactid',testContact1.Id);
            testPR2.getParameters().put('severityParam', '1 - Critical');
     //       cont.getstatusItems();
     //       cont.getTypeItems();

            testPR2.getParameters().put('typeParam', 'Documentation');
            cont.typeUpdated();

            //testPR2.getParameters().put('typeParam','Software Order');
            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','None - Batch process');
            cont.newCase.Number_of_users_affected__c = 'None - Batch process';
            //cont.caseStatus = 'Implementation';
            //cont.newCase.Number_of_users_affected__c = 'Single User';
            //cont.caseType = 'Suspected Defect';
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
       //     cont.caseStatus = 'Test';
       //     cont.caseType = 'Suspected Defect';
            cont.returnSearchResults();
            cont.severityUpdated();

            
            //Attempt to add a new case with missing client and contract assets
            cont.newCase.Product_Set__c = testPS1.Id;
            cont.newCase.System__c = testSystem1.Id;
            cont.newCase.Support_Entitlement__c = testEnt1.Id;
            cont.newCase.Severity__c = 'Medium';
            cont.newCase.Internal_Severity__c = '3';
            cont.newCase.Priority = '3';
            cont.newCase.Subject = 'sub';
            cont.newCase.Description = 'desc';
            cont.newCase.Time_spent_on_issue__c = 30;
            cont.useDefaultAssignmentRules = true;
            cont.sendEmailToContact = true;
            cont.caseComment.CommentBody = 'Testing comment';
            //New lines - oe:gen - 10/08/15
            //cont.newCase.Number_of_users_affected__c = '10';
            cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
            cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
            cont.newCase.First_Occurrence__c = 'Yes';
            cont.newCase.Product_document_used_for_analysis__c = 'document';
            cont.newCase.System_Status__c = 'Live';
            
            //cont.newCase.Client_Asset__c = testCA1.Id;
             cont.returnSearchResults();
            
            PageReference retPR = cont.SaveOnly();
            cont.typeUpdated();
            cont.startPage();
            cont.NextPage();
            cont.firstOccurrenceUpdated();
            cont.PrevPage();
            cont.ContinueNextPage();
            cont.redirect();
                
        Test.stopTest();

    }

     static testmethod void testLogACase_Dropdowns7() {
        //Set up the test data
        Account testAccount1 = TestUtility.sampleAccount();
        insert testAccount1;
        
        Account testAccount2 = TestUtility.sampleAccount();
        testAccount2.Name = 'Test Account2';
        insert testAccount2;
        
        Contact testContact1 = TestUtility.sampleContact();
        testContact1.AccountId = testAccount1.Id;
        testContact1.Inactive_Contact__c = false;
        insert testContact1;
        
        System__c testSystem1 = new System__c();
        testSystem1.Account__c = testAccount1.Id;
        testSystem1.Environment2__c = 'PROD';
        testSystem1.Name = 'TS1';
        insert testSystem1;
        
        CCRT__c testCCRT1 = new CCRT__c();
        testCCRT1.Account__c = testAccount1.Id;
        testCCRT1.Client_Site_Number__c = '1234567';
        insert testCCRT1;
        
        Product_Set__c testPS1 = new Product_Set__c();
        testPS1.Account__c = testAccount1.Id;
        testPS1.Business_Group__c = 'BG1';
        testPS1.Production__c = true;
        insert testPS1;
        
        Entitlement__c testEnt1 = new Entitlement__c();
        testEnt1.Account__c = testAccount1.Id;
        testEnt1.Product_Set__c = testPS1.Id;
        testEnt1.System__c = testSystem1.Id;
        testEnt1.Status__c = 'Active';
        insert testEnt1;
        
        //No Client Assets for this test
        
        //No Contract Assets for this test  
        
        RecordType rt = [select Id from RecordType where sObjectType = 'Case' LIMIT 1];
        
        List<Constants__c> custSettings = new List<Constants__c>();
        custSettings.add(new Constants__c(Name='DEFAULT_INTERNAL_SEVERITY', ExternalId__c='DEFAULT_INTERNAL_SEVERITY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN', ExternalId__c='DEFAULT_ORIGIN', Value__c='Email'));
        custSettings.add(new Constants__c(Name='DEFAULT_ORIGIN_PORTAL', ExternalId__c='DEFAULT_ORIGIN_PORTAL', Value__c='Web'));
        custSettings.add(new Constants__c(Name='DEFAULT_URGENCY', ExternalId__c='DEFAULT_URGENCY', Value__c='3'));
        custSettings.add(new Constants__c(Name='DEFAULT_SEVERITY', ExternalId__c='DEFAULT_SEVERITY', Value__c='Medium'));
        custSettings.add(new Constants__c(Name='DEFAULT_STATUS', ExternalId__c='DEFAULT_STATUS', Value__c='New'));
        custSettings.add(new Constants__c(Name='DEFAULT_TYPE', ExternalId__c='DEFAULT_TYPE', Value__c='Technical'));
        custSettings.add(new Constants__c(Name='DUMMY PRODUCT SET ID', ExternalId__c='DUMMY PRODUCT SET ID', Value__c=testPS1.Id));
        custSettings.add(new Constants__c(Name='DEFAULT_CASE_RECORDTYPE_ID', ExternalId__c='DEFAULT_CASE_RECORDTYPE_ID', Value__c=rt.Id));
        insert custSettings;
        
        //Run the tests
       
        Test.startTest();
            Community_Level1CaseCaptPage2Controller cont = new Community_Level1CaseCaptPage2Controller();
            PageReference testPR1 = Page.Community_Level1_Case_Capture_Page1;
            testPR1.getParameters().put('accountid',testAccount1.Id);
            testPR1.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR1);

            PageReference testPR2 = Page.Community_Level1_Case_Capture_Page2;
            testPR2.getParameters().put('accountid',testAccount1.Id);
            testPR2.getParameters().put('contactid',testContact1.Id);
            testPR2.getParameters().put('severityParam', '1 - Critical');
    //        cont.getstatusItems();
    //        cont.getTypeItems();

            testPR2.getParameters().put('typeParam', 'Documentation');
            cont.typeUpdated();

            //testPR2.getParameters().put('typeParam','Software Order');
            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','Single User');
            cont.newCase.Number_of_users_affected__c = 'Single User';
            //cont.caseStatus = 'Implementation';
            //cont.newCase.Number_of_users_affected__c = 'Single User';
            //cont.caseType = 'Suspected Defect';
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
       //     cont.caseStatus = 'DR';
       //     cont.caseType = 'Suspected Defect';
            cont.returnSearchResults();
            cont.severityUpdated();

            
            //Attempt to add a new case with missing client and contract assets
            cont.newCase.Product_Set__c = testPS1.Id;
            cont.newCase.System__c = testSystem1.Id;
            cont.newCase.Support_Entitlement__c = testEnt1.Id;
            cont.newCase.Severity__c = 'Medium';
            cont.newCase.Internal_Severity__c = '3';
            cont.newCase.Priority = '3';
            cont.newCase.Subject = 'sub';
            cont.newCase.Description = 'desc';
            cont.newCase.Time_spent_on_issue__c = 30;
            cont.useDefaultAssignmentRules = true;
            cont.sendEmailToContact = true;
            cont.caseComment.CommentBody = 'Testing comment';
            //New lines - oe:gen - 10/08/15
            //cont.newCase.Number_of_users_affected__c = '10';
            cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
            cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
            cont.newCase.First_Occurrence__c = 'Yes';
            cont.newCase.Product_document_used_for_analysis__c = 'document';
            cont.newCase.System_Status__c = 'Live';
            
            //cont.newCase.Client_Asset__c = testCA1.Id;
             cont.returnSearchResults();
            
            PageReference retPR = cont.SaveOnly();
            cont.typeUpdated();
            cont.startPage();
            cont.NextPage();
            cont.firstOccurrenceUpdated();
            cont.PrevPage();
            cont.ContinueNextPage();
            cont.redirect();
                
        Test.stopTest();

    }
}