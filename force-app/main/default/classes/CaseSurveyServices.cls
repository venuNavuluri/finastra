/* CaseSurveyServices class
*
* 3/1/2012 - Naushad Sunnivohra (Bluewolf)
* Services class to host static livel methods for the object Case_Survey__c. 
*   
*/
public with sharing class CaseSurveyServices 
{
	//called from after insert trigger on Case_Survey__c
	public static void markSurveyReceivedOnContactOnCase(Map<ID, Case_Survey__c> newMap)
	{
		Set<ID> caseIDs = new Set<ID>();
		for(Case_Survey__c cs: newMap.values())
			caseIDs.add(cs.Case__c);
		
		if(caseIDs.size() > 0)
		{
			List<Contact> contactsToUpdate = new List<Contact>();
			for(Case c: [Select ID, ContactID from Case where ContactID !=: null and id in: caseIDs])
			{
				Contact cnt = new Contact(id = c.ContactID);
				cnt.Sent_Survey_Contact__c = true;
				contactsToUpdate.add(cnt);
			}
			
			if(contactsToUpdate.size() > 0)
			{
				try
				{
					update contactsToUpdate;
				}
				catch(Exception exc)
				{
					System.debug('\n\nException when updating Sent_Survey_Contact__c field on Contact when Case Survey is created: '+exc.getMessage()+'\n\n');
				}
			}
		}
	}
}