@isTest
private class test_CommunityMiProfileController{

	private static Map<String, RecordType> getRecordTypeId(){
		// Create test data (a new Account and contact)
		Map<String, RecordType> recordTypesByName = new Map<String, RecordType>();
		for(List<RecordType> recordTypes : [SELECT Id, Name FROM RecordType]){
			for(RecordType recordType : recordTypes){
				recordTypesByName.put(recordType.Name, recordType);
			}
		}
		return recordTypesByName;
	}
	private static Account getAccount(){
		Map<String, RecordType> recordTypesByName = getRecordTypeId();
		Account acct = new Account();
		acct.Name = 'Test Account 1';
		acct.recordTypeId = recordTypesByName.get('Finastra Customer').Id;
		acct.Region__c = 'Europe';
		acct.site = 'test site';
		acct.type = 'Customer';
		acct.Country__c = 'United Kingdom';
		insert acct;

		return acct;
	}


	private static contact getContact(Account acct){
		Map<String, RecordType> recordTypesByName = getRecordTypeId();
		Contact con = New Contact();
		con.Lastname = 'Testing';
		con.RecordTypeId = recordTypesByName.get('Customer Portal').Id;
		con.AccountId = acct.Id;
		con.email = 'community@test.com';
		insert con;
		return con;
	}

	private static contact getContact(string acct){
		Map<String, RecordType> recordTypesByName = getRecordTypeId();
		Contact con = New Contact();
		con.Lastname = 'Testing';
		con.RecordTypeId = recordTypesByName.get('Customer Portal').Id;
		con.AccountId = acct;
		con.email = 'community@test.com';
		insert con;
		return con;
	}

	private static User getUser(Contact con, Profile standardProf, string roleId){
		//Profile p = [select Id from Profile where UserType = 'Standard' LIMIT 1];

		User su = new User(alias = 'comm', email = 'community2b@test.com',
				emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
				localesidkey = 'en_US', profileid = standardProf.Id,
				timezonesidkey = 'Europe/London', username = 'community@test.com', contactId = con.Id);

		insert su;
		return su;
	}

	private static Product_Set__c setUpProductSet(Id acctId, Id pvmId, Id uId){
		Product_Set__c ps1 = new Product_Set__c(); //TestUtility.sampleProductSet(acctId);
		ps1.Name = 'Almonde';
		ps1.Account__c = acctId;
		ps1.Product_Version_Master__c = pvmId;
		ps1.Customer_Advocate__c = uId;
		insert ps1;
		system.debug('test_ProductSetToAccountRollUpManager ps1=' + ps1);
		system.debug('#####support date:' + ps1.Standard_Support__c);
		return ps1;
	}

	private static Product_version_Master__c setUpProductVersionMaster(string StandardSupportDate, integer year){
		Product_version_Master__c pvm = New Product_version_Master__c();
		pvm.name = 'test';
		pvm.Product_Name__c = 'test product';
		pvm.Product_Family__c = 'Fusion Banking';
		pvm.Standard_Support__c = StandardSupportDate;
		date supportDate = date.newinstance(year, 5, 17);
		pvm.Standard_Support_Date__c = supportDate.addMonths(6);
		pvm.Sustaining_Support_Date__c = supportDate.addMonths(16);
		pvm.Technical_Support_Date__c = supportDate.addMonths(26);
		insert pvm;
		return pvm;
	}

	private static System__c setUpSystem(Id acctId){
		System__c sys1 = TestUtility.sampleSystem(acctId);
		sys1.Environment2__c = 'PROD';
		insert sys1;
		system.debug('test_ProductSetToAccountRollUpManager sys1=' + sys1);
		return sys1;
	}

	private static Entitlement__c setUpEntitlement(Id acctId, Id sysId, Id psId){
		Entitlement__c ent1 = TestUtility.sampleEntitlement(acctId, sysId);
		ent1.Product_Set__c = psId;
		insert ent1;
		system.debug('test_ProductSetToAccountRollUpManager ent1=' + ent1);
		return ent1;
	}

	public static User systemUser(){
		//Get a standard user profile
		Profile p = [select Id from Profile where UserType = 'Standard' LIMIT 1];
		//Create the User and set defaults
		User u = new User();
		u.LastName = 'Dummy';
		u.Alias = 'ddum1234';
		u.Email = 'dummy@d.com';
		u.Username = 'dummy' + datetime.now().millisecond() + '@d.com';
		u.ProfileId = p.Id;
		u.TimeZoneSidKey = 'America/Panama';
		u.LocaleSidKey = 'en_US';
		u.EmailEncodingKey = 'ISO-8859-1';
		u.LanguageLocaleKey = 'en_US';
		insert u;
		return u;
	}

	@isTest static void shouldInitializeCtrl(){
		User u = systemUser();
		Profile standardProf = [select id from profile where name = 'Customer Community Banking User'];
		String roleId = [select id from userrole where name = 'Erste Group Bank AG2 Customer Executive' LIMIT 1].Id;

		Account acct = getAccount();
		Contact con = getContact(acct);
		User su = getUser(con, standardProf, roleId);

		Product_version_Master__c pvm1 = setUpProductVersionMaster('Jan-17', 2017);
		Product_Set__c ps1 = setUpProductSet(acct.Id, pvm1.Id, u.Id);


		//update ps1;
		system.debug('###########unit test acc:' + con.Accountid);

		Test.startTest();
        Constants__c setting = new Constants__c();
        setting.Name = 'CommunityURL';
        setting.Value__c = 'https://misyslive.force.com/SupportCommunity/';
        setting.ExternalId__c = 'CommunityURL';
        insert setting;

		community_MI_ProfileController cont;
		System.runAs(su){
			cont = new community_MI_ProfileController();
			PageReference testPR = Page.community_MI_Profile;
			Test.setCurrentPage(testPR);
			//	cont.accountOwnerEmail = '';s
		}
		Test.stopTest();


		system.assertEquals(1, cont.expiredProducts);
		system.assertEquals(1, cont.numberOfProducts);
		system.assertEquals(0, cont.expiringProducts);
		system.assertEquals(1, cont.lstProductSetVersion.size());
		system.assertEquals('update', cont.lstProductSetVersion.get(0).updateClass);
		system.assertEquals('content-pad content expired group', cont.lstProductSetVersion.get(0).contentDivClass);
		system.assertEquals(true, cont.lstProductSetVersion.get(0).showUpdate);
		system.assertEquals(u.Id, cont.lstProductSetVersion.get(0).customerAdvocate.Id);
		system.assertEquals(pvm1.Id, cont.lstProductSetVersion.get(0).productVersionMaster.Id);
		system.assertEquals(ps1.Id, cont.lstProductSetVersion.get(0).ProductSetDetail.Id);
		system.assertEquals(null, cont.accountOwnerEmail);

	}
}