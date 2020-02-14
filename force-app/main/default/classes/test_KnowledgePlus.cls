@isTest
private class test_KnowledgePlus {
    
	static testMethod void testKnowledgePusController() {
		// Create test data (a new Account and contact)
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Finastra Customer').getRecordTypeId();
        acct.Region__c = 'Europe';
        acct.site = 'test site';
        acct.type = 'Customer';
        acct.Country__c = 'United Kingdom';
        insert acct;
        
        Contact con = new Contact();
        con.Lastname = 'Testing';
        con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Customer Portal').getRecordTypeId();
        con.AccountId = acct.Id;
        con.email = 'community@test.com';
        insert con;
        
        Profile standardProf = [select Id from Profile where Name = 'Customer Community BANKING User']; 
        User su = new User(alias = 'comm', email='community@test.com', 
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
                           localesidkey='en_US', profileid = standardProf.Id, 
                           timezonesidkey='Europe/London', username='community@test.com', contactId=con.Id);
        insert su;

        //insert some homepage content
        Community_Homepage_CMS__c CMSContent = New Community_Homepage_CMS__c();
        CMSContent.Is_Lead_Feature__c = true;
        CMSContent.Active__c = true;
        CMSContent.Title__c = 'Test Lead Content article';
        CMSContent.Body_Copy__c = 'Test Lead Body copy';
        insert CMSContent;

        Community_Feature_Hyperlink__c CMSHyperLinks = New Community_Feature_Hyperlink__c();
        CMSHyperLinks.Knowledge_Homepage_Feature__c = CMSContent.Id;
        CMSHyperLinks.Hyperlink_Text__c = 'this is the link text';
        CMSHyperLinks.URL__c = 'http://www.google.com';
        insert CMSHyperLinks;
        
        Test.startTest();
      
        // Switch current user to Partner Community User
        System.runAs(su) {    
            pageReference pageRef = Page.Community_Knowledge_Plus;  
            documentPortalController testController = New documentPortalController(); 
        }

        delete CMSContent;

        Test.stopTest();
	}
}