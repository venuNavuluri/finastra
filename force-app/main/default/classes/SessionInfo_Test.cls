@isTest
private with sharing class SessionInfo_Test {
	static testmethod void testSessionInfo(){
		// AC 14/Jul/09 - System Asserts added at recommendation of Salesforce
		Account newAcc =  TestUtils.getAccount('tests acc');
        newAcc.Site = 'Parent';
        insert newAcc;
        
        Contact portalContact1 = TestUtils.getContact(newAcc, 'PortalContac1t');
        insert portalContact1;
            
        User u1 = TestUtils.getCustomerPortalUser('test.portal1@gmail.com', portalContact1);
        u1.Alias = 'por1user';
        u1.email='test@gmail.com';            
       
		System.runAs(u1) {
		  SessionInfo si = new SessionInfo();
		  si.setUser();
		  System.assertEquals(si.LoggedInContactID, u1.contactID);
		}

	}

}