@isTest
public class test_CommunityProfile
{
	private static Map<String,RecordType> getRecordTypeId() {
		// Create test data (a new Account and contact)
		Map<String,RecordType> recordTypesByName = new Map<String,RecordType>();
		for (List<RecordType> recordTypes :  [SELECT Id, Name FROM RecordType]){
			for (RecordType recordType : recordTypes){
				recordTypesByName.put(recordType.Name, recordType);
			}
		}
		return recordTypesByName;
	}
	private static Account getAccount() {
		Map<String,RecordType> recordTypesByName = getRecordTypeId();
		Account acct = new Account();
		acct.Name = 'Test Account';
		acct.recordTypeId = recordTypesByName.get('Finastra Customer').Id;
		acct.Region__c = 'Europe';
		acct.site = 'test site';
		acct.type = 'Customer';
		acct.Country__c = 'United Kingdom';
		insert acct;

		return acct;
	}

	private static contact getContact(Account acct) {
		Map<String,RecordType> recordTypesByName = getRecordTypeId();
		Contact con = New Contact();
		con.Lastname = 'Testing';
		con.RecordTypeId = recordTypesByName.get('Customer Portal').Id;
		con.AccountId = acct.Id;
		con.email = 'community@test.com';
		insert con;
		return con;
	}

	private static User getUser(Contact con) {
		//Profile p = [select Id from Profile where UserType = 'Standard' LIMIT 1];
		Profile standardProf = [select id from profile where name='Customer Community Banking User'];
		User su = new User(alias = 'comm', email='community@test.com',
				emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
				localesidkey='en_US', profileid = standardProf.Id,
				timezonesidkey='Europe/London', username='community@test.com', contactId=con.Id);

		insert su;
		return su;
	}


/*
	static void testChatterFeed()
	{
 		User u = TestUtils.getStandardInternalUser('testUT_1');
    	insert u;



		FeedItem post2 = new FeedItem();
		post2.ParentId = u.Id; //eg. Opportunity id, custom object id..
		post2.Body = 'Enter post text here';
		post2.LinkUrl = 'http://www.someurl.com';
		insert post2;

		//Adding a Content post
		FeedItem post3 = new FeedItem();
		post3.ParentId = su.ID; //eg. Opportunity id, custom object id..
		post3.Body = 'Enter post text here';
		post3.ContentFileName = 'sample.pdf';
		insert post3;


		Account acct = getAccount();
	    Contact con = getContact(acct);
	    User su = getUser(con);
	    insert su;

	    Test.startTest();
		System.runAs(su) {

	        //Case cs = TestUtils.getCase(acct, con);
	        //insert cs;

		    Troubleshooting__kav a = new Troubleshooting__kav(
	            Title = 'test apex',
	            Summary = 'test from apex',
	            URLName = 'test'
	        );
	        insert a;
	        system.debug('parent Id: ' + a.knowledgeArticleId);

	        FeedItem post = new FeedItem();
			post.ParentId = a.Id;
			post.Body = 'Enter post text here';
			insert post;

			EntitySubscription follow = new EntitySubscription (
	        parentId = a.id,
	        subscriberid = su.Id);
			insert follow;



			PageReference testPR = Page.community_ChatterFeed;
			Test.setCurrentPage(testPR);
			community_ChatterFeedController controller = New community_ChatterFeedController();

		}

		Test.stopTest();
	}
	*/

	@isTest
	static void testPreferences() {

		Account acct = getAccount();
		Contact con = getContact(acct);
		User su = getUser(con);

		Test.startTest();
		system.runAs(su) {
			PageReference testPR = Page.community_CustomerPreferences;
			Test.setCurrentPage(testPR);
			System.debug('contact: ' + su.contactId);
			community_PreferenceController controller = New community_PreferenceController();
			controller.cancel();
			controller.getIsEdit();
			controller.save();
		}

		Test.stopTest();

	}

	@isTest
	static void testHomePage() {
/*
		Account acct = getAccount();
        Contact con = getContact(acct);
        User su = getUser(con);
        //con.OwnerId = su.Id;
        //update con;
        //acct.OwnerId = su.Id;
       // update acct;
		Test.startTest();
		system.runAs(su) {
			PageReference testPR = Page.community_MI_Home;
			Test.setCurrentPage(testPR);
			System.debug('contact: ' + su.contactId);
			community_MI_HomeController controller = New community_MI_HomeController();

		}

		Test.stopTest();
*/
	}


	@isTest
	static void testAdvocate() {

		Test.startTest();
		PageReference testPR = Page.community_CustomerAdvocate;
		Test.setCurrentPage(testPR);
		community_AdvocateController controller = New community_AdvocateController();
		Test.stopTest();

	}

}