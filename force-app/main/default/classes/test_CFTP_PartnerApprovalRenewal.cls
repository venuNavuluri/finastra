@isTest
private class test_CFTP_PartnerApprovalRenewal {
    
    private static testmethod void testForm_ChecklistNew() 
    {
        //Set up the test data
        Account testAccount = TestUtility.sampleAccount();
        insert testAccount;
        Partner_Approvals_Renewals__c testPARnew = TestUtility.samplePartnerApprovalsRenewals(testAccount.Id);
        testPARnew.RecordTypeId = Label.RecType_CFTP_SalesAgentAppt;
        insert testPARnew;
        Boolean isComplete_step1 = false;
        Boolean isComplete_step2 = false;
        PageReference p1a = null;
        PageReference p1b = null;
        PageReference p2 = null;
        
        //Run the Test
        Test.startTest();
            
            //Set the form field values
            testPARnew.Names_of_Partners_Directors_Provided__c = null;
            testPARnew.Company_Registration_Docs_Provided__c = 'Yes';
            testPARnew.References_Provided_and_Checked__c = 'Yes';
            testPARnew.Check_with_Lawyer_on_Addtl_Requirements__c = 'Yes';
            testPARnew.Questionnaire_for_CFTP_Completed__c = 'Yes';
            testPARnew.Form_Attached_to_Partner_Letter_Complete__c = 'Yes';
            
            //Set the field values that are required for Approval Submission
            testPARnew.Regional_Sales_Director_Approval_Status__c = 'Approved';
            testPARnew.External_Agency_Letter_Uploaded_Date__c = date.today();
            testPARnew.Due_dilligence_completed_date__c = date.today();
            testPARnew.Internal_Sales_Agency_Completed_Date__c = date.today();
            
            //Create the Controller reference
            CFTP_Checklist_CE controller = new CFTP_Checklist_CE(new ApexPages.Standardcontroller(testPARnew));
            p1a = controller.saveComplete();
            p1b = controller.saveChanges();
            isComplete_step1 = testPARnew.CommOps_checklist_completed__c;
            
            //Set additional fields to complete the form
            testPARnew.Names_of_Partners_Directors_Provided__c = 'Yes';
            testPARnew.Lexis_Check__c = 'Completed';
            //testPARnew.Will_CFTP_Provide_Other_Services__c = 'No';
        
            //Run the update and get the returned page
            p2 = controller.saveComplete();
            isComplete_step2 = testPARnew.CommOps_checklist_completed__c;
            
        Test.stopTest();
        
        //Verify the results
        system.assert(p1a == null);
        system.assert(p2.getURL().contains(testPARnew.Id));
        system.assertEquals(false,isComplete_step1);
        system.assertEquals(true,IsComplete_step2);
        
    }
    
    private static testmethod void testForm_ChecklistLocked() 
    {
        //Set up the test data
        Account testAccount = TestUtility.sampleAccount();
        insert testAccount;
        Partner_Approvals_Renewals__c testPARlocked = TestUtility.samplePartnerApprovalsRenewals(testAccount.Id);
        testPARlocked.CommOps_checklist_completed__c = true;
        testPARlocked.Names_of_Partners_Directors_Provided__c = 'Yes';
        testPARlocked.Company_Registration_Docs_Provided__c = 'No';
        testPARlocked.References_Provided_and_Checked__c = 'Yes';
        testPARlocked.Check_with_Lawyer_on_Addtl_Requirements__c = 'Yes';
        //testPARlocked.Will_CFTP_Assist_with_Visas_and_Permits__c = 'Yes';
        //testPARlocked.Will_CFTP_Facilitate_Requested_Meetings__c = 'No';
        //testPARlocked.Will_CFTP_Provide_Bid_Bonds_Guarantees__c = 'Yes';
        //testPARlocked.Will_CFTP_Identify_Prospective_Clients__c = 'No';
        //testPARlocked.Will_CFTP_Provide_Resources_to_Assist__c = 'Yes';
        //testPARlocked.Will_CFTP_Advise_on_Local_Customs__c = 'No';
        //testPARlocked.Will_CFTP_Facilitate_Local_Support_Svcs__c = 'Yes';
        //testPARlocked.Will_CFTP_Provide_Other_Services__c = 'No';
        insert testPARlocked;
        
        boolean formIsLocked = false;
        PageReference p1 = null;
        //string checkbox1 = null;
        //string checkbox2 = null;
        //string checkbox3 = null;
        //string checkbox4 = null;
        //string checkbox5 = null; 
        
        //Run the Test
        Test.startTest();
            Test.setCurrentPage(Page.CFTP_Checklist);
            CFTP_Checklist_CE controller = new CFTP_Checklist_CE(new ApexPages.Standardcontroller(testPARlocked));
            formIsLocked = controller.isLocked;
            p1 = ApexPages.currentPage();
            system.debug('p1='+p1);
            //checkbox1 = controller.getCheckboxImage1();
            //checkbox2 = controller.getCheckboxImage2();
            //checkbox3 = controller.getCheckboxImage3();
            //checkbox4 = controller.getCheckboxImage4();
        Test.stopTest();
        
        //Verify the results
        system.assert(formIsLocked == true);
        //system.assertEquals('/img/checkbox_checked.gif',checkbox1);
        //system.assertEquals('/img/checkbox_unchecked.gif',checkbox2);
        //system.assertEquals('/img/checkbox_checked.gif',checkbox3);
    }
    
    private static testmethod void testForm_RiskAssessment_New() 
    {
        //Set up the test data
        Account testAccount = TestUtility.sampleAccount();
        insert testAccount;
        Partner_Approvals_Renewals__c testPARnew = TestUtility.samplePartnerApprovalsRenewals(testAccount.Id);
        testPARnew.Contract_Term__c = 'one year';
        testPARnew.Proposed_Commission__c = 'cookie';
        testPARnew.Solution_Coverage__c = 'yes';
        testPARnew.Exclusive_or_not__c = 'Yes';
        insert testPARnew;
        
        PageReference p1 = null;
        PageReference p2 = null;
        string riskLevel1 = null;
        string riskLevel2 = null;
        
        //Run the Test
        Test.startTest();
            
            //Set some of the form field values
            testPARnew.CPI_Territory_Score__c = 25;
            //testPARnew.CPI_Territory_25__c = true;
            testPARnew.CPI_Country_Score__c = 25;
            //testPARnew.CPI_Country_25__c = true;
            
            //Create the Controller reference
            CFTP_RiskAssessment_CE controller = new CFTP_RiskAssessment_CE(new ApexPages.Standardcontroller(testPARnew));
        
            //Run the update and get the returned page
            p1 = controller.saveThisForm();
            riskLevel1 = controller.getRiskLevel();
            
            //Set the rest of the field values
            testPARnew.CPI_Territory_Score__c = 100;
            //testPARnew.CPI_Territory_100__c = true;
            //testPARnew.CPI_Territory_50__c = true;
            testPARnew.CPI_Country_Score__c = 100;
            //testPARnew.CPI_Country_100__c = true;
            //testPARnew.CPI_Country_50__c = true;
            testPARnew.Appt_is_as_Sales_Agent__c = true;
            testPARnew.Sales_Agent_Comm_High__c = true;
            testPARnew.Partner_Selection_Form_completed__c = true;
            testPARnew.Completed_Uploaded_Date__c = date.today();
            testPARnew.Risk_Assessment_Completed_Date__c = date.today();        
            
            //Run the save update again
            p2 = controller.completeForm();
            riskLevel2 = controller.getRiskLevel();
            
        Test.stopTest();
        
        //Verify the results
        Partner_Approvals_Renewals__c afterPAR = [select Id, Level_of_Risk__c, Risk_Assessment_Completed_Date__c from Partner_Approvals_Renewals__c where Id = :testPARnew.Id];
        system.assertEquals('Elevated',afterPAR.Level_of_Risk__c);
        system.assertEquals(Date.Today(),afterPAR.Risk_Assessment_Completed_Date__c);
        system.assert(p2.getURL().contains('/'+testPARnew.Id));
        system.assertEquals('Low',riskLevel1);
        system.assertEquals('Elevated',riskLevel2);
    }
    
    /*private static testmethod void testForm_RiskAssessment_Locked()
    {
        //Set up the test data
        Account testAccount = TestUtility.sampleAccount();
        insert testAccount;
        Partner_Approvals_Renewals__c testPARlocked = TestUtility.samplePartnerApprovalsRenewals(testAccount.Id);
        testPARlocked.CPI_Territory_Score__c = 100;
        //testPARlocked.CPI_Territory_100__c = true;
        //testPARlocked.CPI_Territory_50__c = false;
        testPARlocked.CPI_Territory_Score__c = 100;
        //testPARlocked.CPI_Country_100__c = true;
        //testPARlocked.CPI_Country_50__c = false;
        testPARlocked.Appt_is_as_Sales_Agent__c = true;
        testPARlocked.Sales_Agent_Comm_High__c = true;
        testPARlocked.Regional_Sales_Director_Approval_Status__c = 'APPROVED';
        testPARlocked.Risk_Assessment_Completed_Date__c = date.today();
        insert testPARlocked;
        
        PageReference p1 = null;
        boolean formIsLocked = null;
        string checkboxT1 = null;
        string checkboxT2 = null;
        string checkboxT3 = null;
        string checkboxC1 = null;
        string checkboxC2 = null;
        string checkboxC3 = null;
        string checkboxSA = null;
        string checkboxSC = null;
        
        //Run the Test
        Test.startTest();
            
            //Create the Controller reference
            Test.setCurrentPage(Page.CFTP_RiskAssessmentForm);
            CFTP_RiskAssessment_CE controller = new CFTP_RiskAssessment_CE(new ApexPages.Standardcontroller(testPARlocked));
            formIsLocked = controller.getIsLocked();
            p1 = ApexPages.currentPage();
            system.debug('p1='+p1);
            checkboxT1 = controller.getCheckboxTerritory100();
            checkboxT2 = controller.getCheckboxTerritory50();
            checkboxT3 = controller.getCheckboxTerritory25();
            checkboxC1 = controller.getCheckboxCountry100();
            checkboxC2 = controller.getCheckboxCountry50();
            checkboxC3 = controller.getCheckboxCountry25();
            checkboxSA = controller.getCheckboxApptAsAgent();
            checkboxSC = controller.getCheckboxSalesAgentComm();
            
        Test.stopTest();
        
        //Verify the results
        system.assert(formIsLocked == true);
        system.assertEquals('/img/checkbox_checked.gif',checkboxT1);
        system.assertEquals('/img/checkbox_checked.gif',checkboxSA);
        system.assertEquals('/img/checkbox_unchecked.gif',checkboxT3);
        system.assertEquals('/img/checkbox_unchecked.gif',checkboxC3);
    }*/
    
    private static testmethod void testForm_Questionnaire_New() 
    {
        //Set up the test data
        Account testAccount = TestUtility.sampleAccount();
        insert testAccount;
        Partner_Approvals_Renewals__c testPARnew = TestUtility.samplePartnerApprovalsRenewals(testAccount.Id);
        insert testPARnew;
        
        PageReference p1 = null;
        PageReference p2 = null;
        boolean requireExpl = false;
        boolean formIsLocked = false;
        
        //Run the Test
        Test.startTest();
        
            //Set some of the form field values
            testPARnew.How_first_hear_about_proposed_CFTP__c = 'Blah blah blah blah';
            testPARnew.Can_you_verify_CFTP_has_no_ties__c = 'Unable to Verify';
            
            //Create the Controller reference
            CFTP_Questionnaire_CE controller = new CFTP_Questionnaire_CE(new ApexPages.Standardcontroller(testPARnew));
        
            //Run the update and get the returned page
            requireExpl = controller.getRequireExplanation();
            //p1 = controller.saveThisForm();
            
            //Set the rest of the field values
            testPARnew.Explain_why_unable_to_verify_no_ties__c = 'Blah blah blah blah';
            testPARnew.Questionnaire_Signature__c = UserInfo.getName();
            testPARnew.Verify_Questionnaire__c = 'I Agree';
            testPARnew.Internal_Sales_Agency_Completed_Date__c = date.today();
            
            //Run the update again
            p2 = controller.saveComplete();
            
            //Create a new controller reference now that the form is completed
            CFTP_Questionnaire_CE controller2 = new CFTP_Questionnaire_CE(new ApexPages.Standardcontroller(testPARnew));
            formIsLocked = controller2.isLocked;
        
        Test.stopTest();
        
        //Verify the results
        //system.assert(p1 == null);
        //system.assert(p2.getURL().contains(testPARnew.Id));
        system.assert(requireExpl == true);
        system.assert(formIsLocked == false);
    }
    
    private static testmethod void test_CFTP_PDFform_CE()
    {
        //Set up test data
        Account testAccount = TestUtility.sampleAccount();
        insert testAccount;
        Partner_Approvals_Renewals__c testPARnew = TestUtility.samplePartnerApprovalsRenewals(testAccount.Id);
        insert testPARnew;
        
        //Run the test
        Test.startTest();
            //Create a Risk Assessment form
            PageReference pRA = new PageReference('/apex/CFTP_PDFform');
            pRA.getParameters().put('id',testPARnew.Id);
            pRA.getParameters().put('form','RA');
            Test.setCurrentPage(pRA);
            CFTP_PDFform_CE controllerRA = new CFTP_PDFform_CE(new ApexPages.StandardController(testPARnew));
            PageReference pRA2 = controllerRA.createPDF();

            //Create a Checklist form
            PageReference pCOC = new PageReference('/apex/CFTP_PDFform');
            pCOC.getParameters().put('id',testPARnew.Id);
            pCOC.getParameters().put('form','COC');
            Test.setCurrentPage(pCOC);
            CFTP_PDFform_CE controllerCOC = new CFTP_PDFform_CE(new ApexPages.StandardController(testPARnew));
            PageReference pCOC2 = controllerCOC.createPDF();
            
            //Create a Questionnaire form
            PageReference pISQ = new PageReference('/apex/CFTP_PDFform');
            pISQ.getParameters().put('id',testPARnew.Id);
            pISQ.getParameters().put('form','ISQ');
            Test.setCurrentPage(pISQ);
            CFTP_PDFform_CE controllerISQ = new CFTP_PDFform_CE(new ApexPages.StandardController(testPARnew));
            PageReference pISQ2 = controllerISQ.createPDF();            
        Test.stopTest();
        
        //Verify the results
        system.debug('pRA2: '+pRA2.getUrl());
        system.debug('pCOC2: '+pCOC2.getUrl());
        system.debug('pISQ2: '+pISQ2.getUrl());
    }
    
}