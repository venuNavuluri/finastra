@isTest
private class TriggerTests 
{
	// Opp_Status_Trigger
	 static testMethod void testTrigger()
	 {  
		System.debug('test opp');	
		
		Opportunity[] opp =new Opportunity[]
		{
			new Opportunity(  Name='Apex - Test Opportunity', AccountId='00120000000loSo', StageName='Suspect', CloseDate=System.today() )
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
			
			System.assert(da[0].Approval_Ref__c == '123');
			da[0].Approval_Status__c = 'Approved';
			update da;
			
			da[0].Approval_Status__c = 'Rejected';
			update da;
			
		}
		catch(Exception ex)
		{
			System.debug('error');	
		}
	}
	/*
	 // Case_Status_Trigger
	 public static testmethod void testCaseStatusTrigger()
	 {
		 //Insert Case for test 
         Case testCase = new Case( Subject = 'Test Case for trigger', Status = 'Awaiting Analysis', GEMS_Number__c = '123');
         try
         {
         	insert testCase;
         }
         catch (DmlException e) 
         {
         	System.debug(e.getMessage());
         }

        // Obtain reference to new created Case
    	// This is the Case that will change as part of the test     
    	// field values should cause the trigger to fire
	    Case updatedCase = new Case(Id = testCase.Id, Status = 'Under Analysis' );
    
		// update in database
    	try
    	{
        	// this should fire the after update trigger    
            update updatedCase;
        }
        catch (DmlException e) 
        {
        	System.debug(e.getMessage());
        }    
	 }
	 */
	 
	 
}