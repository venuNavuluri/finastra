@isTest
private with sharing class ContactWrapper_Test {

	static testmethod void testContactWrapper(){
		//, Server_Type__c = 'AIX'
		Account testAccount = new Account(Name='Acc test',Site='Parent',AccountNumber='123');
		insert testAccount;
		Contact testContact = new Contact(LastName='last name',AccountId=testAccount.Id);
		insert testContact;

		ContactWrapper cw = new ContactWrapper(testContact,testAccount);

        // AC 14/Jul/09 - System Asserts added at recommendation of Salesforce
        System.assertEquals(cw.contact.id, testContact.id);
        System.assertEquals(cw.account.id, testAccount.id);
        		
		ContactWrapper cw2 = new ContactWrapper(testContact.Id,testAccount.Id);
        System.assertEquals(cw.contact.id, testContact.id);
        System.assertEquals(cw.account.id, testAccount.id);

		ContactWrapper cw3 = new ContactWrapper(true,testContact.Id,testAccount.Id);
        System.assertEquals(cw.contact.id, testContact.id);
        System.assertEquals(cw.account.id, testAccount.id);

		ContactWrapper cw4 = new ContactWrapper(testAccount);
        System.assertNotEquals(null, testContact.id);
        System.assertEquals(cw.account.id, testAccount.id);

		ContactWrapper cw5 = new ContactWrapper(testAccount.Id);
        System.assertNotEquals(null, testContact.id);
        System.assertEquals(cw.account.id, testAccount.id);

        cw2.ShowAIX = true;
		cw2.getFullDetails();
		System.assert(cw2.ShowAIX);
		
//		System.assert(!cw2.CheckForSupportHolds());
		
		
		List<ContactWrapper> cws = new List<ContactWrapper>();
		cws.add(cw);
		cws.add(cw2);
		cws.add(cw3);
		ContactWrapper.SortItems(cws);
		
		System.assertEquals(3, cws.size());
		
	}

}