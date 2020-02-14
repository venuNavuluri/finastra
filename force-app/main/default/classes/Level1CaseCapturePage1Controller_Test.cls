@isTest
private with sharing class Level1CaseCapturePage1Controller_Test{

    static testmethod void Level1CaseCapturePage1Controller_Test(){


        //User lstuser = [select id,name, profileid from user where isactive = true AND usertype = 'Standard' limit 1]; //profileid= :pf.id limit 1];
        //   Profile pf = [Select p.UserType,p.Name from Profile p where p.id = :lstuser.profileid limit 1 ]; //p.name = 'Customer Portal User HC Employee on site' AND

        //User lstuser1 = [select id ,name, profileid from user where isactive = true AND  usertype != 'Standard' and profile.UserType='PowerCustomerSuccess' limit 1 ]; //profileid= :pf.id limit 1];

        User lstuser1;
        Account testAcc = new Account(Name = 'Test acczzzz', Site = 'Parent');
        insert testAcc;
        Account testAcc1 = new Account(Name = 'Test acczzzz');
        insert testAcc1;

        Contact testCont = new Contact(LastName = 'Smithyzzzz', AccountId = testAcc.Id);
        insert testCont;

        Case testCase = new Case(Subject = 'test case', ContactId = testCont.Id, AccountId = testAcc.Id);
        insert testCase;


        Accounts_Supported__c testAccSupp = new Accounts_Supported__c(Contact__c = testCont.id, name = 'AccountSupported', Supported_Account__c = testAcc1.id);
        insert testAccSupp;

        System.runAs(new User(Id = UserInfo.getUserId())){
            lstuser1 = TestUtility.sampleCustPortalUser(testCont);
            insert lstuser1;
            // System.runAs(lstuser){
            ///PageReference pageRef = Page.Level1_Case_Capture_Paging;
            ///Test.setCurrentPage(pageRef);
            Level1CaseCapturePage1Controller cont = new Level1CaseCapturePage1Controller();

            cont.CustomerSearch = '';
            cont.ContactSearch = '';

            cont.SearchCustomers();

            cont.CustomerSearch = 'Test acczzzz';
            cont.ContactSearch = '';

            cont.SearchCustomers();

            // AC 14/Jul/09 - System Asserts added at recommendation of Salesforce
            // System.assertEquals(1, cont.SearchContactsFullDataSet.size());

            cont.ContactSearch = 'Smithyzzzz';
            cont.SearchCustomers();

            // AC 14/Jul/09 - System Asserts added at recommendation of Salesforce
            // System.assertEquals(1, cont.SearchContactsFullDataSet.size());

            cont.CustomerSearch = '';
            cont.SearchCustomers();

            // AC 14/Jul/09 - System Asserts added at recommendation of Salesforce
            // System.assertEquals(1, cont.SearchContactsFullDataSet.size());

            cont.ContactSelected();
            if(cont.SearchContacts.size() > 0){
                cont.SearchContacts[0].Selected = true;
            }
            cont.ContactSelected();

            Case c1 = [Select id from Case limit 1];
            ID strOrderId = ApexPages.currentPage().getParameters().put('caseid', c1.id);
            cont.GetCaseDetails();

            PageReference p = cont.LogCase();

            // AC 14/Jul/09 - System Asserts added at recommendation of Salesforce
            ///System.assert(p.getURL().indexOf('level1_case_capture_p2_v2') > -1);
            ///System.assert(p.getURL().indexOf(testCont.id) > -1);

            //PB(12/17/2009)
    /*
        p = cont.CreateAndLog();
        // AC 14/Jul/09 - System Asserts added at recommendation of Salesforce
        System.assert(p.getURL().indexOf('level1_case_contact') > -1);

        p = cont.EditAndLog();
        // AC 14/Jul/09 - System Asserts added at recommendation of Salesforce
        System.assert(p.getURL().indexOf('level1_case_contact') > -1);
        System.assert(p.getURL().indexOf(testCont.id) > -1);
     */

            //cont.EditSelectedCase();
            if(cont.existingCustomerCases.size() > 0){
                cont.existingCustomerCases[0].Selected = true;
            }
            p = cont.EditSelectedCase();

            // AC 14/Jul/09 - System Asserts added at recommendation of Salesforce
            //  System.debug('URL...' + p.getURL());
            //  System.assert(p.getURL().indexOf(cont.existingCustomerCases[0].internalCase.id) > -1);

            cont.ForwardOn();
            cont.getNextPage();
            cont.getPreviousPage();
            //     }
        }

        System.runAs(lstuser1){
            // System.runAs(lstuser){
            ///PageReference pageRef = Page.Level1_Case_Capture_Paging;
            ///Test.setCurrentPage(pageRef);
            Level1CaseCapturePage1Controller cont = new Level1CaseCapturePage1Controller();

            cont.CustomerSearch = '';
            cont.ContactSearch = '';

            cont.SearchCustomers();

            cont.CustomerSearch = 'Test acczzzz';
            cont.ContactSearch = '';

            cont.SearchCustomers();

            cont.ContactSearch = 'Smithyzzzz';
            cont.SearchCustomers();

            cont.CustomerSearch = '';
            cont.SearchCustomers();

            cont.ContactSelected();
            if(cont.SearchContacts.size() > 0){
                cont.SearchContacts[0].Selected = true;
            }
            cont.ContactSelected();

            Case c1 = [Select id from Case limit 1];
            ID strOrderId = ApexPages.currentPage().getParameters().put('caseid', c1.id);
            cont.GetCaseDetails();

            PageReference p = cont.LogCase();

            //cont.EditSelectedCase();
            if(cont.existingCustomerCases.size() > 0){
                cont.existingCustomerCases[0].Selected = true;
            }
            p = cont.EditSelectedCase();
            cont.ForwardOn();
            cont.getNextPage();
            cont.getPreviousPage();
            //     }
        }
    }
}