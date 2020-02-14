@isTest
private with sharing class IssueCaseSearchAndAttachExtension_Test{

    @testSetup
    private static void prepareSystemParameters(){
        // Delete and recreate system parameters to ensure that this test method always behaves as expected, regardless of underlying environment settings

        List<System_Parameter__c> almParams = [SELECT id FROM System_Parameter__c];
        delete almParams;

        List<System_Parameter__c> newALMParams = new List<System_Parameter__c>();
        System_Parameter__c alm1 = new System_Parameter__c(name = 'CURRENT_SYSTEM', value__c = 'Banking', applicable_Server__c = 'All');
        //insert alm1;
        newALMParams.add(alm1);

        System_Parameter__c alm2 = new System_Parameter__c(name = 'Case_Map_Fields', value__c = 'Subject,Replication_steps__c,Case_Category__c', applicable_Server__c = 'Banking');
        //insert alm2;
        newALMParams.add(alm2);

        System_Parameter__c alm3 = new System_Parameter__c(name = 'Mandatory_Fields', value__c = 'Replication_steps__c,Case_Category__c,Severity__c', applicable_Server__c = 'Banking');
        //insert alm3;
        newALMParams.add(alm3);

        System_Parameter__c alm5 = new System_Parameter__c(name = 'Issue_Case_Defaults', value__c = 'Subject=The Subject', applicable_Server__c = 'Banking');
        //insert alm5;
        newALMParams.add(alm5);

        System_Parameter__c alm6 = new System_Parameter__c(name = 'Valid_Values_Case_Category__c', value__c = 'Defect', applicable_Server__c = 'Banking');
        //insert alm6;
        newALMParams.add(alm6);

        System_Parameter__c alm7 = new System_Parameter__c(name = 'Valid_Values_Status', value__c = 'In Progress', applicable_Server__c = 'Banking');
        //insert alm7;
        newALMParams.add(alm7);

        System_Parameter__c alm8 = new System_Parameter__c(name = 'Valid_Values_Sub-Status', value__c = 'Development', applicable_Server__c = 'Banking');
        //insert alm8;
        newALMParams.add(alm8);

        System_Parameter__c alm9 = new System_Parameter__c(name = 'Valid_Values_Self_Service_Product__c',
                value__c = 'ALM Banking Test A,ALM Banking Test B,ALM Banking Test C,BM+,Misys Trade Portal,MCR (Midas Credit Risk),' +
                        'Misys Trader,Loan Manager,ToF,Equation,EBA,Global Cash Pooling,Midas,Midas Plus,MHUBi,IFM (Integrated Financial Management),' +
                        'Trade Innovation,TI PLUS,Meridian,Meridian Replication,Misys Payment Manager,Misys Message Manager,BM - LAN,BM - LAN BPW,' +
                        'BM - LAN - FONTIS,BM - LAN - TPP - CityDealer,BM - LAN - TPP - Datastore,BM - LAN - TPP - IBSnet,BM - LAN - TPP - MyEureka,' +
                        'BM - LAN - TPP - NRS,BM - LAN - TPP - SigCap,BM - LAN - TPP - Testkey,Summit,Loan IQ,DataNet,Trader Desktop,Eagleye,Risk IQ,' +
                        'Opics Risk,Risk Vision,CMS,Misys Loan Coordinator,Almonde,Misys Incentives and Rebates,Misys Environment Registry System,' +
                        'Misys Environmental Trading Platform,Misys Connect Portal,MBI,Bankfusion UB Application,Misys Cash Portal,Opics,Tropics',
                applicable_Server__c = 'Banking');
        //insert alm9;
        newALMParams.add(alm9);

        insert newALMParams;
    }

    private static testMethod void IssueCaseSearchAndAttachExtension_Test(){

        // Create a customer case and setup the controller/page

        Case cc = new Case();
        insert cc;

        // Create an Issue Case - to be found in the search
        Case ic = new Case(recordTypeID = Label.issue_case_Id, self_service_product__c = 'TEST PRODUCT XYDABC123', status = 'Open', Case_Category__c = 'Defect');
        insert ic;

        Test.setCurrentPage(Page.IssueCaseSearchAndAttach);

        IssueCaseSearchAndAttachExtension controller = new IssueCaseSearchAndAttachExtension(new ApexPages.StandardController(cc));


        // Get the picklists and check that values have been found
        List<SelectOption> soCaseCategories = controller.getIssueCaseCategories();
        System.assertNotEquals(0, soCaseCategories.size());

        // Get the picklists and check that values have been found
        List<SelectOption> soProducts = controller.getIssueCaseProducts();
        System.assertNotEquals(0, soProducts.size());

        // Get the picklists and check that values have been found
        List<SelectOption> soStatus = controller.getIssueCaseStatus();
        System.assertNotEquals(0, soStatus.size());

        // Set the search criteria for the page - these will ensure we will find the above issue case
        controller.issueCaseCriteria.Self_Service_Product__c = 'TEST PRODUCT XYDABC123';
        controller.issueCaseCriteria.Status = 'Open';
        controller.issueCaseCriteria.Case_Category__c = 'Defect';

        // Do the search
        PageReference p = controller.doSearch();

        // Get the found cases - ensure size of returned list is 1
        List<CaseWrapper> foundCases = controller.allIssueCases;
        System.assertEquals(1, foundCases.size());

        // Attach this one record to the customer case (only one will be found so this will be automatically selected)
        p = controller.doAttach();

        // Ensure that when we read back the customer case, the issue case is set to the one selected in the search
        cc = [SELECT issue_case__c FROM case WHERE id = :cc.id];
        System.assertEquals(cc.issue_case__c, ic.id);

        // Test that doOverride resets alreadyAttached
        controller.alreadyAttached = true;
        p = controller.doOverride();
        System.assert(!controller.alreadyAttached);
        System.assertEquals(null, p);

        // Test that when we do a cancel, we are returned to the customer case
        p = controller.doCancel();
        System.assert(p.getURL().indexOf(cc.id) > -1);

        // NEGATIVE TEST - Set the search criteria for the page - these will ensure we will find the above issue case
        controller.issueCaseKeyword = 'XYZABC123123';
        controller.issueCaseNumber = '00000000';
        controller.issueCaseCriteria.Self_Service_Product__c = 'WONT FIND THIS PRODUCT XYDABC123';
        controller.issueCaseCriteria.Status = 'Open';
        controller.issueCaseCriteria.Case_Category__c = 'Defect';

        // Do the search
        p = controller.doSearch();

        // Get the found cases - ensure size of returned list is 0
        foundCases = controller.allIssueCases;
        System.assertEquals(0, foundCases.size());

        // Test no case passed in
        Case cc2 = new Case();
        IssueCaseSearchAndAttachExtension controller2 = new IssueCaseSearchAndAttachExtension(new ApexPages.StandardController(cc2));
        System.assertEquals(controller2.customerCase.id, null);
    }


}