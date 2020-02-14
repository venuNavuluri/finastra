@isTest
class TestCaseSurveyServices 
{
	static testMethod void testCaseSurveyTriggerUpdatesContact()
	{
		Account a = TestUtils.getAccount('ut acc 1');
		insert a;
		Contact cnt = TestUtils.getContact(a);
		insert cnt;
		Case c = TestUtils.getCase(a);
		c.ContactId = cnt.id;
		insert c;
		
		//assert that the checkbox on Contact is false
		cnt = [Select ID, Sent_Survey_Contact__c from Contact where id=: cnt.id];
		System.assertEquals(false, cnt.Sent_Survey_Contact__c);
		
		//now create a Case Survey record and verify that the checkbox is checked
		Case_Survey__c cs = new Case_Survey__c();
		cs.Case__c = c.id;
		insert cs;
		cnt = [Select ID, Sent_Survey_Contact__c from Contact where id=: cnt.id];
		System.assertEquals(true, cnt.Sent_Survey_Contact__c);
		
		
	}
}