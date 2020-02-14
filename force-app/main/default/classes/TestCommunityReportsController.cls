@isTest
public class TestCommunityReportsController{
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

        User testUser = new User();
        User testUser2 = new User();

        testUser.ProfileId = '00e20000000h4Am';
        testUser.FirstName = 'TestUserFirst';
        testUser.LastName = 'TestUserLast';
        testUser.Username = 'oegenTest' + datetime.now().millisecond() + '@d.com';
        testUser.Email = 'Test@testing.co.uk';
        testUser.Alias = 'Alias';
        testUser.TimeZoneSidKey = 'Europe/London';
        testUser.LocaleSidKey = 'en_GB';
        testUser.EmailEncodingKey = 'UTF-8';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.IsActive = False;

        insert testUser;

        testUser2 = [SELECT Id, name, IsActive FROM User WHERE profile.name = 'System Administrator' and name != '' and isactive = true LIMIT 1];


        //Fetch Test Case RecordType
        RecordType testRecType = new RecordType();

        testRecType = [SELECT Id, name FROM RecordType WHERE name = 'Almonde' and name != '' LIMIT 1];

        system.runas(testUser2){
            //Create Test Account

            Account testAccount = new Account();
            testAccount.name = 'testAccountName';
            testAccount.Site = 'testAccountSite';
            testAccount.OwnerId = testUser.Id;

            insert testAccount;

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
            system.debug('OPTION2' + options2);
            //system.assert(options2.size() == 2);
            //system.assert(string.valueof(options2[1]) == 'System.SelectOption[value="'+ testUser.Id +'", label="TestUserFirst TestUserLast", disabled="false"]');
            system.debug('Option 3 Size ' + options3.size());
            system.assertEquals(2, options3.size());
            system.assertEquals('System.SelectOption[value="Almonde", label="Almonde", disabled="false"]', string.valueof(options3[1]));

            system.assertEquals(2, options4.size());
            system.assertEquals('System.SelectOption[value="testAccountSite", label="testAccountSite", disabled="false"]', string.valueof(options4[1]));

            system.assertEquals(null, controller.systemStatus);
            system.assertEquals(null, controller.systemOwner);
            system.assertEquals(null, controller.systemRecType);
            system.assertEquals(null, controller.systemSite);
        }
    }
}

/*@isTest
public class TestCommunityReportsController {
 
    public static testMethod void TestCommunityReportsController() {
        PageReference pageRef = Page.Mysis_DashboardFilters_AHA;
        Test.setCurrentPage(pageRef);

        
       //Create Test User
        CommunityReportsController controller = new CommunityReportsController();
        
        User testUser = new User();
        User testUser2 = new User();
        
        testUser.ProfileId = '00e20000000h4Am';
        testUser.FirstName = 'TestUserFirst';
        testUser.LastName = 'TestUserLast';
        testUser.Username = 'Test@testing.co.uk';
        testUser.Email ='Test@testing.co.uk';
        testUser.Alias ='Alias';
        testUser.TimeZoneSidKey ='Europe/London';
        testUser.LocaleSidKey ='en_GB';
        testUser.EmailEncodingKey ='UTF-8';
        testUser.LanguageLocaleKey ='en_US';
        testUser.IsActive = False;
        
        insert testUser;
    
        testUser2 = [SELECT Id, name, IsActive FROM User WHERE profile.name = 'System Administrator' and name != '' LIMIT 1];
        
       
       //Fetch Test Case RecordType
        RecordType testRecType = new RecordType();
        
        testRecType = [SELECT Id, name FROM RecordType WHERE name = 'issue' and name != '' LIMIT 1];
        
        //Create Test Account
        
        Account testAccount = new Account();
        testAccount.name = 'testAccountName';
        testAccount.Site = 'testAccountSite';
        testAccount.OwnerId = testUser.Id;
        
        insert testAccount;
        
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
        
        system.assert(options2.size() == 2);
        system.assert(string.valueof(options2[1]) == 'System.SelectOption[value="'+ testUser.Id +'", label="TestUserFirst TestUserLast", disabled="false"]');
        
        system.assert(options3.size() == 2);
        system.assert(string.valueof(options3[1]) == 'System.SelectOption[value="Issue", label="Issue", disabled="false"]');
        
        system.assert(options4.size() == 2);
        system.assert(string.valueof(options4[1]) == 'System.SelectOption[value="testAccountSite", label="testAccountSite", disabled="false"]');
       
        system.assert(controller.systemStatus == null);
        system.assert(controller.systemOwner == null);
        system.assert(controller.systemRecType == null);
        system.assert(controller.systemSite == null);
    }
}*/