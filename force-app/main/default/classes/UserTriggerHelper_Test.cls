@isTest
private class UserTriggerHelper_Test {

	private static testMethod void testTwoFAMobilePhoneAppMechanish() {
	    User user1 = TestUtility.sampleUser();
	    user1.isActive= true;
	    insert user1;
	    
	    User user2 = TestUtility.sampleUser();
	    user2.isActive= true;
	    insert user2;
		List<User> testUserList= [select id,name,Authentication_Mechanism__c,Two_FA_Roll_Out_Phase__c,email,isActive,ProfileId,UserType from USER where id in (:user1.id,:user2.id) order by id asc];
	    
   	    testUserList.get(0).Authentication_Mechanism__c='Mobile Phone App';
	  
	    testUserList.get(1).Authentication_Mechanism__c='U2F Key';
	    testUserList.get(1).Apply_U2F_Key_Authentication__c=True;
	      
	    Update testUserList;
        testUserList= [select id,name,Authentication_Mechanism__c,Two_FA_Roll_Out_Phase__c,email,isActive,Apply_U2F_Key_Authentication__c from USER where id in (:user1.id,:user2.id) order by id asc];
	
        system.assertEquals('Mobile Phone App', testUserList.get(0).Authentication_Mechanism__c);
        system.assertEquals('U2F Key', testUserList.get(1).Authentication_Mechanism__c);
        system.assert(True, testUserList.get(1).Apply_U2F_Key_Authentication__c);
	}

}