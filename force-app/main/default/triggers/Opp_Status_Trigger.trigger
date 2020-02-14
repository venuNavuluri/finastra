trigger Opp_Status_Trigger on Deal_Approval__c (after update) 
{
	System.debug('Old approval status is: ' + Trigger.new[0].Approval_Status__c.toLowerCase());
	Opportunity opp;
	
	if(Trigger.new[0].Approval_Ref__c.startsWithIgnoreCase('DEALSHEET')){
		if (Trigger.new[0].Approval_Status__c.toLowerCase() != 'not started') 
		{
			// check if approval record is latest.
			// This can be done by matching Approval Ref with latest record's Approval Ref
			String ref = [select Id, Approval_Ref__c from Deal_Approval__c where Opportunity__c = :Trigger.old[0].Opportunity__c and Approval_Ref__c like 'DEALSHEET%' order by CreatedDate desc limit 1].Approval_Ref__c;
			
			System.debug('Ref: ' + ref);
			
			if(ref != '' && ref == Trigger.old[0].Approval_Ref__c)
			{
				System.assert(ref == Trigger.old[0].Approval_Ref__c, 'IGNORE! triggering from earlier submission.');
				// this is the correct record to process
				String sOppId = Trigger.old[0].Opportunity__c;
				
				System.debug(sOppId);
				
				// Retrieve the Parent Opportunity's Deal Status
				//Opportunity opp = [select Id, Approval_Status__c from Opportunity where Id = :sOppId];
				opp = [select Id, Approval_Status__c from Opportunity where Id = :sOppId];
				//String sOppStatus = [select Id, Approval_Status__c from Opportunity where Id = :sOppId].Approval_Status__c;
				String sOppStatus = opp.Approval_Status__c;
				
				if(sOppStatus == null || sOppStatus == '')
				{
					sOppStatus = 'not submitted';
				}
				
				System.debug('Opportunity Status : ' + sOppStatus);
							
				// Now check the new status
				String sNewStatus = Trigger.new[0].Approval_Status__c;
				
				System.debug('New Deal Status : ' + sNewStatus);
	
				if(sNewStatus.toLowerCase() == 'pending')
				{
					if((sOppStatus.toLowerCase() == 'not required') || (sOppStatus.toLowerCase() == 'not submitted'))
					{
						opp.Approval_Status__c = 'Pending Approval';
						//update opp;
					}
				}
				else if(sNewStatus.toLowerCase() == 'rejected')
				{
					if(sOppStatus.toLowerCase() != 'rejected')
					{
						opp.Approval_Status__c = 'Rejected';
						//update opp;
					}				
				}
				else if(sNewStatus.toLowerCase() == 'approved')
				{
					// first find out if all other sibling deal approval records are approved.
					// i.e. this is the last record to approve
					
					Boolean isLastRecordToApprove = true;
					
					for (Deal_Approval__c[] dealApprovals : [SELECT id, Approval_Status__c FROM Deal_Approval__c where Approval_Ref__c = :Trigger.new[0].Approval_Ref__c]) 
					{
						for (Deal_Approval__c dealApproval : dealApprovals) 
						{
							if(dealApproval.Id != Trigger.new[0].Id)
							{
								if(dealApproval.Approval_Status__c.toLowerCase() != 'approved')
								{
									isLastRecordToApprove = false;
								}
							}
						}
					}
					
					// check if the flag is still active
					if(isLastRecordToApprove == true)
					{
						// this was the last approval record set the opp status to be approved
						opp.Approval_Status__c = 'Approved';
						//update opp;
					}
				}
			}
			else
			{
				System.debug('ignore this record as new submission exists');	
			}
		}
	} else {
		if((trigger.new[0].CB_PS_Quote_Approval_Status__c != null && trigger.new[0].CB_PS_Quote_Approval_Status__c.toLowerCase() == 'approved') || 
			(trigger.new[0].PS_Head_of_Academy_Approval_Status__c != null && trigger.new[0].PS_Head_of_Academy_Approval_Status__c.toLowerCase() == 'approved')){//PS_Head_of_Academy_Approval_Status__c
			
			if(opp == null && trigger.old[0].Opportunity__c != null){
				opp = [select Id, PS_Quote_Approval_Status__c from Opportunity where Id = :trigger.old[0].Opportunity__c];
				//opp.PS_Quote_Approval_Status__c = 'APPROVED';


					// first find out if all other sibling deal approval records are approved.
					// i.e. this is the last record to approve
					
					Boolean isLastRecordToApprove = true;
					
					for (Deal_Approval__c[] dealApprovals : [SELECT id, CB_PS_Quote_Approval_Status__c, PS_Head_of_Academy_Approval_Status__c FROM Deal_Approval__c where Approval_Ref__c = :Trigger.new[0].Approval_Ref__c]) 
					{
						for (Deal_Approval__c dealApproval : dealApprovals) 
						{
							if(dealApproval.Id != Trigger.new[0].Id)
							{
								if(dealApproval.CB_PS_Quote_Approval_Status__c != null && dealApproval.CB_PS_Quote_Approval_Status__c.toLowerCase() != 'approved' && dealApproval.CB_PS_Quote_Approval_Status__c.toLowerCase() != 'Not started')
								{
									isLastRecordToApprove = false;
								}
								if(dealApproval.PS_Head_of_Academy_Approval_Status__c != null && dealApproval.PS_Head_of_Academy_Approval_Status__c.toLowerCase() != 'approved' && dealApproval.PS_Head_of_Academy_Approval_Status__c.toLowerCase() != 'Not started')
								{
									isLastRecordToApprove = false;
								}
							}
						}
					}
					
					// check if the flag is still active
					if(isLastRecordToApprove == true)
					{
						// this was the last approval record set the opp status to be approved
						opp.PS_Quote_Approval_Status__c = 'APPROVED';
						//update opp;
					}
			}
		}
	}
	
	if(opp != null){
		update opp;
	}
	
}