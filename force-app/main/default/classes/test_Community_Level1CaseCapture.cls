@isTest
private class test_Community_Level1CaseCapture {
  private static Account testAccount1 = TestUtility.sampleAccount();
    private static Account testAccount2 = TestUtility.sampleAccount();
    private static Contact testContact1  = TestUtility.sampleContact(); 
    private static System__c testSystem1 = new System__c();
    private static CCRT__c testCCRT1   = new CCRT__c();        
    private static Product_Set__c testPS1 = new Product_Set__c(); 
    private static Entitlement__c testEnt1 = new Entitlement__c(); 
    
    //No Contract Assets for this test      
    private static RecordType rt  = [select Id from RecordType where sObjectType = 'Case' LIMIT 1]; 
    private static List<Constants__c> custSettings = new List<Constants__c>();
    
    

    @isTest static void createTestData(){

      insert testAccount1;
      testAccount2.Name = 'Test Account2';
      insert testAccount2;
      
      //Contact testContact1 = TestUtility.sampleContact();
      testContact1.AccountId = testAccount1.Id;
      testContact1.Inactive_Contact__c = false;
      insert testContact1;
      
      //System__c testSystem1 = new System__c();
      testSystem1.Account__c = testAccount1.Id;
      testSystem1.Environment2__c = 'PROD';
      testSystem1.Name = 'TS1';
      insert testSystem1;
      
      //CCRT__c testCCRT1 = new CCRT__c();
      testCCRT1.Account__c = testAccount1.Id;
      testCCRT1.Client_Site_Number__c = '1234567';
      insert testCCRT1;
      
      //Product_Set__c testPS1 = new Product_Set__c();
      testPS1.Account__c = testAccount1.Id;
      testPS1.Business_Group__c = 'BG1';
      testPS1.Production__c = true;
      insert testPS1;
      
      //Entitlement__c testEnt1 = new Entitlement__c();
      testEnt1.Account__c = testAccount1.Id;
      testEnt1.Product_Set__c = testPS1.Id;
      testEnt1.System__c = testSystem1.Id;
      testEnt1.Status__c = 'Active';
      insert testEnt1;

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
    }
  
  @isTest static void test_method_one() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','Single User');
            cont.newCase.Number_of_users_affected__c = 'Single User';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
            //cont.caseStatus = 'DR';
            //cont.caseType = 'Configuration / Set-up Issue';
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
  
  @isTest static void test_method_two() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','Single User');
            cont.newCase.Number_of_users_affected__c = 'Single User';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
            //cont.caseStatus = 'Live';
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

  @isTest static void test_method_three() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'Whole Function';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
            //cont.caseStatus = 'Live';
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
  
  @isTest static void test_method_four() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'Whole Function';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
            //cont.caseStatus = 'Live';
            //cont.caseType = 'Configuration / Set-up Issue';
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
  
  @isTest static void test_method_five() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'Whole Function';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
            //cont.caseStatus = 'Live';
            //cont.caseType = 'Consultancy';
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

  @isTest static void test_method_six() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'Whole Function';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
            //cont.caseStatus = 'Implementation';
            //cont.caseType = 'Consultancy';
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

  @isTest static void test_method_seven() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'Whole Function';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
            //cont.caseStatus = 'DR';
            //cont.caseType = 'Suspected Defect';
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
       //cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            cont.productSetChosen = 'test';
            //cont.populateSystems();
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

  @isTest static void test_method_eight() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','Single User');
            cont.newCase.Number_of_users_affected__c = 'Single User';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
           // cont.caseStatus = 'Implementation';
           // cont.caseType = 'Configuration / Set-up Issue';
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
    //   cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            cont.productSetChosen = 'test';
            //cont.populateSystems();
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

  @isTest static void test_method_nine() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'Whole Function';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
            //cont.caseStatus = 'Implementation';
            //cont.caseType = 'Software Order';
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
  //     cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            cont.productSetChosen = 'test';
            //cont.populateSystems();
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

  @isTest static void test_method_ten() {
    // Implement test code
    createTestData();
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
       //     cont.getstatusItems();
       //     cont.getTypeItems();

            testPR2.getParameters().put('typeParam', 'Documentation');
            cont.typeUpdated();

            testPR2.getParameters().put('occurrenceParam','No');
            //testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'Single User';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
     //       cont.caseStatus = 'Implementation';
     //       cont.caseType = 'Consultancy';
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
      // cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            cont.productSetChosen = 'test';
            //cont.populateSystems();
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

  @isTest static void test_method_eleven() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('occurrenceParam','No');
            //testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'None - Batch process';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
           // cont.caseStatus = 'Implementation';
           // cont.caseType = 'Consultancy';
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
    //   cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            cont.productSetChosen = 'test';
            //cont.populateSystems();
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

  @isTest static void test_method_twelve() {
    // Implement test code
    createTestData();
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
        //    cont.getstatusItems();
        //    cont.getTypeItems();

            testPR2.getParameters().put('typeParam', 'Documentation');
            cont.typeUpdated();

            testPR2.getParameters().put('occurrenceParam','No');
            //testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'Single User';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
        //    cont.caseStatus = 'DR';
        //    cont.caseType = 'Consultancy';
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
    //   cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            cont.productSetChosen = 'test';
            //cont.populateSystems();
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

  @isTest static void test_method_thirteen() {
    // Implement test code
    createTestData();
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
       //     cont.getstatusItems();
       //     cont.getTypeItems();

            testPR2.getParameters().put('typeParam', 'Documentation');
            cont.typeUpdated();

            testPR2.getParameters().put('occurrenceParam','No');
            //testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'Single User';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
      //      cont.caseStatus = 'DR';
      //      cont.caseType = 'Consultancy';
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
    //   cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            cont.productSetChosen = 'test';
            //cont.populateSystems();
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

  @isTest static void test_method_fourteen() {
    // Implement test code
    createTestData();
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
       //     cont.getstatusItems();
       //     cont.getTypeItems();

            testPR2.getParameters().put('typeParam', 'Documentation');
            cont.typeUpdated();

            testPR2.getParameters().put('occurrenceParam','No');
            //testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'All Users';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
       //     cont.caseStatus = 'DR';
       //     cont.caseType = 'Consultancy';
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
    //   cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            cont.productSetChosen = 'test';
            //cont.populateSystems();
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

  @isTest static void test_method_fifthteen() {
    // Implement test code
    createTestData();
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
       //     cont.getstatusItems();
       //     cont.getTypeItems();

            testPR2.getParameters().put('typeParam', 'Documentation');
            cont.typeUpdated();

            testPR2.getParameters().put('occurrenceParam','No');
            //testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'None - Batch process';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
     //       cont.caseStatus = 'DR';
     //       cont.caseType = 'Consultancy';
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
  //     cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            cont.productSetChosen = 'test';
            //cont.populateSystems();
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

  @isTest static void test_method_sixteen() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('occurrenceParam','No');
            //testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'Single User';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
     //       cont.caseStatus = 'Live';
     //       cont.caseType = 'Configuration / Set-up Issue';
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
  //     cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            cont.productSetChosen = 'test';
            //cont.populateSystems();
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
    
    @isTest static void test_method_seventeen() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('occurrenceParam','No');
            //testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'Single User';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
          system.assert(testPR3.getURL().contains('page3'));
            Test.setCurrentPage(testPR3);
            
            
       //     cont.caseStatus = 'Live';
       //     cont.caseType = 'Configuration / Set-up Issue';
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
    //   cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
            //Attempt to add a new case with missing client and contract assets
            cont.newCase.Product_Set__c = testPS1.Id;
            cont.newCase.System__c = testSystem1.Id;
            cont.newCase.Support_Entitlement__c = testEnt1.Id;
            cont.newCase.Severity__c = 'Medium';
            //cont.newCase.Internal_Severity__c ;
            cont.newCase.Priority = '3';
            cont.newCase.Subject = 'sub';
            cont.newCase.Description = 'desc';
            cont.newCase.Time_spent_on_issue__c = 30;
            cont.useDefaultAssignmentRules = true;
            cont.sendEmailToContact = true;
            cont.caseComment.CommentBody = 'Testing comment';
            //New lines - oe:gen - 10/08/15
            //cont.newCase.Number_of_users_affected__c = '10';
            //cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
            //cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
            //cont.newCase.First_Occurrence__c = 'Yes';
            //cont.newCase.Product_document_used_for_analysis__c = 'document';
            cont.newCase.System_Status__c = 'Live';
            cont.productSetChosen = 'test';
            //cont.populateSystems();
            //cont.newCase.Client_Asset__c = testCA1.Id;
             cont.returnSearchResults();
            cont.isCriticalCase = false;
        cont.displayAllPage3Fields = true;
          
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
    
     @isTest static void test_method_eightteen() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('occurrenceParam','No');
            //testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'Single User';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
          system.assert(testPR3.getURL().contains('page3'));
            Test.setCurrentPage(testPR3);
            
            
      //      cont.caseStatus = 'Live';
      //      cont.caseType = 'Configuration / Set-up Issue';
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
  //     cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
            //Attempt to add a new case with missing client and contract assets
            cont.newCase.Product_Set__c = testPS1.Id;
            cont.newCase.System__c = testSystem1.Id;
            cont.newCase.Support_Entitlement__c = testEnt1.Id;
            cont.newCase.Severity__c = 'Medium';
            //cont.newCase.Internal_Severity__c ;
            cont.newCase.Priority = '3';
            cont.newCase.Subject = '';
            cont.newCase.Description = 'desc';
            cont.newCase.Time_spent_on_issue__c = 30;
            cont.useDefaultAssignmentRules = true;
            cont.sendEmailToContact = true;
            cont.caseComment.CommentBody = 'Testing comment';
            cont.newCase.System_Status__c = 'Live';
            cont.productSetChosen = 'test';
            cont.returnSearchResults();
            cont.isCriticalCase = false;
        cont.displayAllPage3Fields = true;
          
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
    
    @isTest static void test_method_nineteen() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('typeParam', '');
            cont.typeUpdated();

            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','Single User');
            
            cont.newCase.Number_of_users_affected__c = 'Single User';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
     //       cont.caseStatus = 'Test';
     //       cont.caseType = 'Configuration / Set-up Issue';
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
  //     cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            cont.productSetChosen = 'test';
            //cont.populateSystems();
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
    
    @isTest static void test_method_twenty() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('typeParam', '');
            cont.typeUpdated();

            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','Whole Function');
            cont.newCase.Number_of_users_affected__c = 'Whole Function';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
   //         cont.caseStatus = 'Test';
   //         cont.caseType = 'Configuration / Set-up Issue';
          
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
  //     cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            
            cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
            cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
            cont.newCase.First_Occurrence__c = 'Yes';
            cont.newCase.Product_document_used_for_analysis__c = 'document';
            cont.newCase.System_Status__c = 'Live';
            cont.productSetChosen = 'test';
            //cont.populateSystems();
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
    
    @isTest static void test_method_twentyOne() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('typeParam', '');
            cont.typeUpdated();

            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','None - Batch process');
            cont.newCase.Number_of_users_affected__c = 'None - Batch process';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
    //        cont.caseStatus = 'Test';
    //        cont.caseType = 'Consultancy';
          
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
  //     cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            
            cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
            cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
            cont.newCase.First_Occurrence__c = 'Yes';
            cont.newCase.Product_document_used_for_analysis__c = 'document';
            cont.newCase.System_Status__c = 'Live';
            cont.productSetChosen = 'test';
            //cont.populateSystems();
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
    
    @isTest static void test_method_twentyTwo() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('typeParam', '');
            cont.typeUpdated();

            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','None - Batch process');
            cont.newCase.Number_of_users_affected__c = 'None - Batch process';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
     //       cont.caseStatus = 'Live';
     //       cont.caseType = 'Question';
          
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
    //   cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            
            cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
            cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
            cont.newCase.First_Occurrence__c = 'Yes';
            cont.newCase.Product_document_used_for_analysis__c = 'document';
            cont.newCase.System_Status__c = 'Live';
            cont.productSetChosen = 'test';
            //cont.populateSystems();
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
    
    @isTest static void test_method_twentyThree() {
    // Implement test code
    createTestData();
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

            testPR2.getParameters().put('typeParam', '');
            cont.typeUpdated();

            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','None - Batch process');
            cont.newCase.Number_of_users_affected__c = 'None - Batch process';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
     //       cont.caseStatus = 'Live';
     //       cont.caseType = 'Software Order';
          
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
  //     cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            
            cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
            cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
            cont.newCase.First_Occurrence__c = 'Yes';
            cont.newCase.Product_document_used_for_analysis__c = 'document';
            cont.newCase.System_Status__c = 'Live';
            cont.productSetChosen = 'test';
            cont.populateEntitlements();
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
    
    @isTest static void test_method_twentyFour() {
    // Implement test code
    createTestData();
     Test.startTest();
          Map<String,RecordType> caseRecordTypesByName = new Map<String,RecordType>();
       for (List<RecordType> recordTypes :  [SELECT Id, Name FROM RecordType WHERE sobjecttype = 'case' and isActive = true]){
               for (RecordType recordType : recordTypes){
                   caseRecordTypesByName.put(recordType.Name, recordType);
               }
            }

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
      cont.newCase.RecordTypeId =  caseRecordTypesByName.get('Digital Channels').Id;
            testPR2.getParameters().put('typeParam', '');
            cont.typeUpdated();

          
            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','None - Batch process');
            cont.newCase.Number_of_users_affected__c = 'None - Batch process';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
      //      cont.caseStatus = 'Live';
      //      cont.caseType = 'Suspected Defect';
          
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
    //   cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            
            cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
            cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
            cont.newCase.First_Occurrence__c = 'Yes';
            cont.newCase.Product_document_used_for_analysis__c = 'document';
            cont.newCase.System_Status__c = 'Live';
            cont.productSetChosen = 'test';
            cont.populateEntitlements();
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
    
    @isTest static void test_method_twentyFive() {
    // Implement test code
    createTestData();
     Test.startTest();
          Map<String,RecordType> caseRecordTypesByName = new Map<String,RecordType>();
       for (List<RecordType> recordTypes :  [SELECT Id, Name FROM RecordType WHERE sobjecttype = 'case' and isActive = true]){
               for (RecordType recordType : recordTypes){
                   caseRecordTypesByName.put(recordType.Name, recordType);
               }
            }

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
      cont.newCase.RecordTypeId =  caseRecordTypesByName.get('Digital Channels').Id;
            testPR2.getParameters().put('typeParam', '');
            cont.typeUpdated();

          
            testPR2.getParameters().put('occurrenceParam','No');
            testPR2.getParameters().put('Number_of_users_affected__c','None - Batch process');
            cont.newCase.Number_of_users_affected__c = 'None - Batch process';
        
            Test.setCurrentPage(testPR2);

            PageReference testPR3 = Page.Community_Level1_Case_Capture_Page3;
            testPR3.getParameters().put('accountid',testAccount1.Id);
            testPR3.getParameters().put('contactid',testContact1.Id);
            Test.setCurrentPage(testPR3);
            
            
      //      cont.caseStatus = 'Live';
      //      cont.caseType = 'Suspected Defect';
          
            cont.returnSearchResults();
            cont.severityUpdated();

           

            cont.entitlementName = 'test';
       cont.assetName  = 'test';
    //   cont.Severity = 'test';
       cont.systemname  = 'test';
       cont.projectParam  = 'test';
       cont.generalMessage  = 'test';
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
            
            
            
            cont.newCase.Details_when_error_occurred_reproduced__c = 'Details';
            cont.newCase.Actions_done_to_do_workaround_or_resolve__c = 'Actions';
            cont.newCase.First_Occurrence__c = 'Yes';
            cont.newCase.Product_document_used_for_analysis__c = 'document';
            cont.newCase.System_Status__c = 'Live';
            cont.productSetChosen = 'test';
          cont.populateProductSet();
          cont.populateSystems();
            cont.populateEntitlements();
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