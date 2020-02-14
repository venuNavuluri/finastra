@isTest
private class test_searchResultsController
{

	@isTest
	static void testMethod1()
	{
		Map<String,RecordType> recordTypesByName = new Map<String,RecordType>();
        for (List<RecordType> recordTypes :  [SELECT Id, Name FROM RecordType]){
           for (RecordType recordType : recordTypes){
               recordTypesByName.put(recordType.Name, recordType);
           }
        }

		Account acct = new Account();
        acct.Name = 'Test Account';
        acct.recordTypeId = recordTypesByName.get('Finastra Customer').Id;
        acct.Region__c = 'Europe';
        acct.site = 'test site';
        acct.type = 'Customer';
        acct.Country__c = 'United Kingdom';
        insert acct;
        
        Contact con = New Contact();
        con.Lastname = 'Testing';
        con.RecordTypeId = recordTypesByName.get('Customer Portal').Id;
        con.AccountId = acct.Id;
        con.email = 'community@test.com';
        insert con;
       
        Profile standardProf = [select id from profile where name='Customer Community BANKING User']; 
        String roleId = [select id from userrole where name = 'Erste Group Bank AG2 Customer Executive' LIMIT 1].Id;
        
        User su = new User(alias = 'comm', email='community@test.com', 
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US', 
        localesidkey='en_US', profileid = standardProf.Id, 
        timezonesidkey='Europe/London', username='community@test.com', contactId=con.Id);
        insert su;
  
        Profile p = [select Id from Profile where UserType = 'Standard' LIMIT 1];
        //Create the User and set defaults
        User u = new User();
        u.LastName = 'Dummy';
        u.Alias = 'ddum1234';
        u.Email = 'dummy@d.com';
        u.Username = 'dummy'+datetime.now().millisecond()+'@d.com';
        u.ProfileId = p.Id;
        u.TimeZoneSidKey = 'America/Panama';
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US';
        insert u;

		Test.startTest();
        System.runAs(su) { 
			community_searchResultsController controller = New community_searchResultsController();
			pageReference pageRef = Page.Community_SearchResults;
			pageRef.getParameters().put('s','cases');
            pageRef.getParameters().put('sbstr', 'test');
            Test.setCurrentPage(pageRef);
            
            controller.getItems();

            controller.searchOptions = 'cases';
            controller.searchText = 'misys';
            controller.search();
            controller.getCases();

            community_searchResultsController controller2 = New community_searchResultsController();
            controller2.searchOptions = 'attachments';
            controller2.searchText = 'misys';
            controller2.search();
            controller2.getCases();

            community_searchResultsController controller3 = New community_searchResultsController();
            controller3.searchOptions = 'comments';
            controller3.searchText = 'misys';
            controller3.search();
            controller3.getCases();
		}
		Test.stopTest();
	}
}