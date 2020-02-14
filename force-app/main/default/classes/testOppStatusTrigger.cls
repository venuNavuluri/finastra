@isTest
private class testOppStatusTrigger {

	static testMethod void testTrigger()
	{  
		System.debug('test opp');	
		
		Opportunity[] opp =new Opportunity[]
		{
			new Opportunity(  Name='Apex Test Opportunity', AccountId='00120000000loSo', StageName='Suspect', CloseDate=System.today() )
		};
		
		try
		{
			insert opp;		// add a known opp
			System.debug('Inserted Opp is: ' + opp[0].Id);
			
			Deal_Approval__c[] da =new Deal_Approval__c[]
			{
				new Deal_Approval__c(  Name='Apex Test Deal Approval', Opportunity__c = opp[0].Id, Approval_Status__c = 'Pending', Approval_Ref__c='123')
			};
			insert da;
			System.debug('Inserted Deal Approval is: ' + da[0].id);
			
			da[0].Approval_Status__c = 'Approved';
			update da;
		}
		catch(Exception ex)
		{
			System.debug('error');	
		}
		
		
	}
}