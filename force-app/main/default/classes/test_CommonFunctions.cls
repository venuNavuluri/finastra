@isTest
private class test_CommonFunctions {

	static testMethod void test_addProcessLog()
	{
		//set up test data
		//CommonFunctions.ProcessLog testLog = new CommonFunctions.ProcessLog();
		//testLog.ObjectName = 'Case';
		//testLog.Process = 'Test';
		//testLog.TypeCode = 'Apex Trigger';
		//testLog.UserId = UserInfo.getUserId();
		
		//Run the test
		//CommonFunctions.addProcessLog(new CommonFunctions.ProcessLog[]{testLog});
		CommonFunctions.addProcessLog('Case','Test','Apex Trigger');
		
		//Verify the results
		List<Process_Log__c> logs = [select Id, Name, Object__c from Process_Log__c where Object__c = 'Case' and Process__c = 'Test'];
		system.AssertEquals(logs.size(),1);
	}
	
	static testMethod void test_sendEmailErrorNotice()
	{
		//set up test data
		List<String> toAddr = new String[]{'test.user@foo.bar'};
		String testSubject = 'This is a test';
		String testMethodName = 'test_CommonFunctions.test_sendEmailErrorNotice';
		
		
		//Run the test
		//Test.startTest();
			//generate an exception
			try{
				Integer i = 1/0;
			}catch(Exception e){
				System.debug('An error has occurred: '+e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
    			CommonFunctions.sendEmailErrorNotice(toAddr,testSubject,testMethodName,e);
			}

	}
	
	static testMethod void test_getUsersFromGroup()
	{
		//set up test data
	
		//Set up Main Group to contain:
		//	2 users	
		//	1 sub group with 2 users
		//	1 role with 1 user	

		//	Main Group
		Group mainGroup = new Group();
		mainGroup.Name = 'Main Test Group';
		insert mainGroup;
		
		//	Sub Group to be part of main group and contain 3 users
		Group subGroup = new Group();
		subGroup.Name = 'Test Sub-group';
		insert subGroup;
		
		//	Users which will be part of the groups
		List<User> testUsers = new List<User>();
		for(Integer x = 0; x < 5; x++){
			User u = TestUtility.sampleUser();
			testUsers.add(u);
		}
		insert testUsers;
		
		List<GroupMember> testGMs = new List<GroupMember>();
		
		UserRole testRole = [select Id from UserRole where PortalType = 'None' LIMIT 1];
		Group gRole = [select Id, RelatedId from Group where RelatedId = :testRole.Id LIMIT 1];

		GroupMember gmRole = new GroupMember();
		gmRole.GroupId = mainGroup.Id;
		gmRole.UserOrGroupId = gRole.Id;
		testGMs.add(gmRole);
		
		GroupMember gmUser0 = new GroupMember();
		gmUser0.UserOrGroupId = testUsers[0].Id;
		gmUser0.GroupId = mainGroup.Id;
		testGMs.add(gmUser0);
		
		GroupMember gmUser1 = new GroupMember();
		gmUser1.UserOrGroupId = testUsers[1].Id;
		gmUser1.GroupId = mainGroup.Id;
		testGMs.add(gmUser1);
		
		GroupMember gmUser2 = new GroupMember();
		gmUser2.UserOrGroupId = testUsers[2].Id;
		gmUser2.GroupId = subGroup.Id;
		testGMs.add(gmUser2);
		
		GroupMember gmUser3 = new GroupMember();
		gmUser3.UserOrGroupId = testUsers[3].Id;
		gmUser3.GroupId = subGroup.Id;
		testGMs.add(gmUser3);
		
		GroupMember gmSubGroup = new GroupMember();
		gmSubGroup.UserOrGroupId = subGroup.Id;
		gmSubGroup.GroupId = mainGroup.Id;
		testGMs.add(gmSubGroup);
		
		
		Set<Id> groupMembers = new Set<Id>();
		
		//Run the test
		Test.startTest();
		User usr = [Select id from User where Id = :UserInfo.getUserId()];
		System.RunAs(usr) {
			insert testGMs;
			testUsers[4].UserRoleId = testRole.Id;
			update testUsers[4];	
		}
		groupMembers = CommonFunctions.getUsersFromGroup(mainGroup.Id);
		Test.stopTest();
		
		//Verify the results
		System.assert(groupMembers.size() >= 5);
	}
	
}