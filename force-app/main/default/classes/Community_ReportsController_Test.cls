@isTest
public class Community_ReportsController_Test{
    /*public static testMethod void Community_ReportsController_TestMethod(){
        PageReference testPR = Page.Community_Reports_Page;
        CommunityReportsController cst = new CommunityReportsController();
        Test.setCurrentPage(testPR);
    }*/
    public static testMethod void TestCommunityReportsController(){
        PageReference pageRef = Page.Community_Reports_Page;
        Test.setCurrentPage(pageRef);


        //Create Test User
        CommunityReportsController controller = new CommunityReportsController();
        Account testAccount;
        Contact testContact;
        RecordType testRecType;

/*
        testUser.ProfileId = '00e20000000h4Am';
        testUser.FirstName = 'TestUserFirst11';
        testUser.LastName = 'TestUserLast11';
        testUser.Username = 'Test111@testing.co.uk';
        testUser.Email = 'Test1111@testing.co.uk';
        testUser.Alias = 'Alias';
        testUser.TimeZoneSidKey = 'Europe/London';
        testUser.LocaleSidKey = 'en_GB';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.IsActive = False;
*/


        User testUser2 = [SELECT Id, name, IsActive FROM User WHERE profile.name = 'System Administrator' and name != '' and isactive = true LIMIT 1];

        system.runAs(testUser2){
            //Fetch Test Case RecordType
            testRecType = [SELECT Id, name FROM RecordType WHERE name = 'Almonde' and name != '' LIMIT 1];

            //Create Test Account

            testAccount = new Account();
            testAccount.name = 'testAccountName';
            testAccount.Site = 'testAccountSite';
            testAccount.OwnerId = testUser2.Id;

            insert testAccount;

            testContact = new Contact(accountId = testAccount.Id, firstname = 'test', lastname = 'contact');
            insert testContact;

        }
        User testUser = TestUtility.sampleCustPortalUser(testContact);
        insert testUser;

        system.runAs(testUser2){
            //Create Test Case

            Case testcase = new Case();
            Case testcase2 = new Case();
            testcase.System_status__c = 'Live';
            testcase.OwnerId = testUser.Id;
            testcase.RecordTypeId = testRecType.Id;
            testcase.AccountId = testAccount.Id;
            testcase.Case_Owner_User_lookup__c = testUser.Id;

            insert testcase;

            testcase2 = [SELECT Id, OwnerId, Owner.name, RecordTypeId, RecordType.name, accountID, System_status__c, Case_Owner_User_lookup__c FROM Case WHERE AccountId = :testcase.AccountId];

            //Initiate Controller and prime lists
            Test.startTest();
            controller = new CommunityReportsController();
            List<SelectOption> options1 = controller.getStatus();
            List<SelectOption> options2 = controller.getCOwner();
            List<SelectOption> options3 = controller.getCRecType();
            List<SelectOption> options4 = controller.getSite();

            //Call Class Methods

            controller.changedPickList();
            controller.SetsystemStatus();
            controller.SetsystemOwner();
            controller.SetsystemRecType();
            controller.SetsystemSite();

            Test.stopTest();
            //Assert Data is as expected

            system.assert(options1.size() > 1);

            system.assertEquals(2, options2.size());
            system.assertEquals('System.SelectOption[value="test contact", label="test contact", disabled="false"]',string.valueof(options2[1]));
            system.debug('Option 3 Size ' + options3.size());
            system.assertEquals(2, options3.size());
            system.assertEquals('System.SelectOption[value="Almonde", label="Almonde", disabled="false"]',string.valueof(options3[1]));

            system.assertEquals(2, options4.size());
            system.assertEquals('System.SelectOption[value="testAccountSite", label="testAccountSite", disabled="false"]',string.valueof(options4[1]));

            system.assertEquals(null, controller.systemStatus);
            system.assertEquals(null, controller.systemOwner);
            system.assertEquals(null, controller.systemRecType);
            system.assertEquals(null, controller.systemSite);
        }
    }
}