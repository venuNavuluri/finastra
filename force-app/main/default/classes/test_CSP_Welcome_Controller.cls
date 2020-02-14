@isTest
private class test_CSP_Welcome_Controller
{

    private static testmethod void welcome_controller_testmethod(){     
        
        //Set up test data
        UserRole portalRole = [Select Id From UserRole Where Name = 'CEO' Limit 1];

        //User runUser = [select Id from User where Profile.Name = 'System Administrator' and UserRoleId =: portalRole.Id and  isActive = true LIMIT 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        
        User runUser = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'testWelcomeController.finastra@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert runUser;
        Contact testContact;
        System.runAs(runUser){
            Account testAcc = TestUtility.sampleAccount();
            testAcc.Site = 'Test Site';
            insert testAcc;         
            testContact = TestUtility.sampleContact();
            testContact.AccountId = testAcc.Id;
            testContact.Email = 'test@abc123.com';
            insert testContact;
        }
        User testCSPuser = TestUtility.sampleCustPortalUser(testContact);
        //testCSPuser.ProfileId = profile1.Id;
        insert testCSPuser;
        List<String> lString =  new List<String>();
        
        //Run the test
        Test.startTest();
        System.runAs(testCSPuser){         
            CSP_Welcome_Controller WC = new CSP_Welcome_Controller();
            lString = WC.getRecords();
            WC.profile();
            WC.logout();
            //WC.Security();
        }
        Test.stopTest();
        
        //Verify test results
        System.assert(lString != null);
    }
    
    private static testmethod void Security_Statement_test(){
        
        UserRole portalRole = [Select Id From UserRole Where Name = 'CEO' Limit 1];

        //User runUser = [select Id from User where Profile.Name = 'System Administrator' and UserRoleId =: portalRole.Id and  isActive = true LIMIT 1];
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        
        User runUser = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = 'testSecurityStatement.finastra@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        insert runUser;
        Contact testContact;
        System.runAs(runUser){
            Account testAcc = TestUtility.sampleAccount();
            insert testAcc;         
            testContact = TestUtility.sampleContact();
            testContact.AccountId = testAcc.Id;
            testContact.Email = 'test@abc123.com';
            insert testContact;
        }
        User testCSPuser = TestUtility.sampleCustPortalUser(testContact);
        //testCSPuser.ProfileId = profile1.Id;
        insert testCSPuser; 
        PageReference p = Page.CSP_Security;
        
        //Run the test
        Test.startTest();
        System.runAs(testCSPuser){         
            CSP_Welcome_Controller WC = new CSP_Welcome_Controller();
            p = WC.Security();
        }
        Test.stopTest();        
        
        //Verify the results
        system.assert(p.getURL().contains('/servlet/servlet.FileDownload'));
    }
}