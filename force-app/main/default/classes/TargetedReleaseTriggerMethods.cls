public class TargetedReleaseTriggerMethods 
{
     public static void UpdateCustomerCase(Map<ID, Targeted_Release__c> incomingTargetReleases) {
     // AC 8/28/09When a targeted release comes in with a Customer_Case__c ID, make the link between the customer case (child) and targeted release (parent)
     
       List<ID> caseIDs         = new List<ID>();
       List<Case> casesToUpdate = new List<Case>();
       
       // get list of cases on incoming target_release records
       for (Targeted_Release__c tr : incomingTargetReleases.values() ) {
         if (tr.Customer_Case__c != null) {
           caseIDs.add(tr.Customer_Case__c);
         }	 
       }
     
       Map<ID, Case> caseMap = new Map<ID, Case>([SELECT id, targeted_release_lookup__c FROM case WHERE id IN :caseIDs ]);
       	
       for (Targeted_Release__c tr : incomingTargetReleases.values() ) {
         if (tr.Customer_Case__c != null) {
       	   Case c = caseMap.get(tr.customer_case__c);
       	   if (c.targeted_release_lookup__c == null || c.targeted_release_lookup__c != tr.id)
       	   {
       	   	 c.targeted_release_lookup__c = tr.id;
       	   	 casesToUpdate.add(c);
       	   }
         }
       }       	

       update casesToUpdate;       
       	
     }

	 // function to change the Substatus of a Customer case based upon the L3 Status value in related Targeted Release record
	/* public static void L3StatusChange(Map<ID,Targeted_Release__c> updatedTargetedReleases, Map<ID,Targeted_Release__c> oldTargetedReleases)
	 {
	 	
	 	//String currentSystem = ALM_System_Parameters.getParam('CURRENT_SYSTEM');
	 	//boolean isAllscripts = currentSystem=='Allscripts';
	 	
	 	/*
	 	Map<ID, Targeted_Release__c> modifiedTargetedReleases = new Map<ID, Targeted_Release__c>();

        //Get the list of records that has the status changed
        for(Targeted_Release__c updatedTargetedRelease : updatedTargetedReleases.values())
        {
        	// check if the L3 status is modified on Targeted Release record
            if(updatedTargetedRelease.L3_Status__c != oldTargetedReleases.get(updatedTargetedRelease.Id).L3_Status__c)
            {
            	// add the targeted release record to a map
                modifiedTargetedReleases.put(updatedTargetedRelease.Id, updatedTargetedRelease);
            }
            
            modifiedTargetedReleaseIds.add(updatedTargetedRelease.Id);
        }
	 	*/
	
	/* 	
	 	// check if any records have L3 Status values modified
	 	//if(!modifiedTargetedReleases.isEmpty())
	 	//{
	 		// get all customer case records where the modified targeted release records are linked
	 		//List<Case> customerCases = [select Id, Sub_status__c, Targeted_Release_Lookup__c from Case where Targeted_Release_Lookup__c in :modifiedTargetedReleases.keySet()];
	 		List<Case> customerCases = [select Id, CaseNumber, Sub_status__c, Targeted_Release__c, Targeted_Release_Lookup__c, Targeted_Release_Lookup__r.Project_Type__c, Owner.Email, Owner.FirstName, Owner.LastName, Owner.Name, Targeted_Fix_Date__c from Case where Targeted_Release_Lookup__c in :updatedTargetedReleases.keySet()];
	 		List<Case> casesToUpdate = new List<Case>();
	 		
	 		// check if any customer case records found
	 		if(customerCases.size() > 0)
	 		{
	 			// loop through each customer record found
		 		for(Case customerCase : customerCases)
		 		{
		 			// get the details of the related targeted release record
		 			//Targeted_Release__c targetedRelease = modifiedTargetedReleases.get(customerCase.Targeted_Release_Lookup__c);
		 			Targeted_Release__c targetedRelease = updatedTargetedReleases.get(customerCase.Targeted_Release_Lookup__c);
						 			
		 			if(targetedRelease != null)
		 			{

//                      AC - 6/15/09 - removed, do not update sub-status 
//			            if(updatedTargetedReleases.get(targetedRelease.Id).L3_Status__c != oldTargetedReleases.get(targetedRelease.Id).L3_Status__c)
//			            {
//			 				// set the Customer Case's Sub Status using the Related Targeted Release
//			 				customerCase.Sub_status__c = targetedRelease.L3_Status__c;
//			 				casesToUpdate.add(customerCase);		 				
//			            }
			 
			            // IF allscripts, or if Banking and not Hotfix/None then update targeted_fix_date with the scheduled_delivery_date from the targeted release
			            
			            // SS: 11/Nov/09 : Removing the logic below of checking the project type based upon the requirement from John Leschak (ARTF53399)
			 			// -- CHANGE START //
			 			
			            // IF allscripts, or if Banking and not Hotfix/None then update targeted_fix_date with the scheduled_delivery_date from the targeted release
			            //if ((isAllscripts ||
			            //    (customerCase.Targeted_Release_Lookup__r.project_type__c != null &&
			            //     customerCase.Targeted_Release_Lookup__r.project_type__c != '' &&
			            //     customerCase.Targeted_Release_Lookup__r.project_type__c != 'None' &&
			            //     customerCase.Targeted_Release_Lookup__r.project_type__c != 'Hotfix')) &&
                        //     updatedTargetedReleases.get(targetedRelease.Id).Scheduled_Delivery_Date__c != oldTargetedReleases.get(targetedRelease.Id).Scheduled_Delivery_Date__c) {

                          if (customerCase.Targeted_Fix_Date__c == null) 
                          {
                            customerCase.Targeted_Fix_Date__c = updatedTargetedReleases.get(targetedRelease.Id).Scheduled_Delivery_Date__c; 			            
		 				    casesToUpdate.add(customerCase);		 				
                          }
			            //}
			            // -- CHANGE END //
			            
                        String ownerID = customerCase.OwnerID;
                        if (ownerID.startsWith('005'))
                        {			            
			            
			              string sEmail = customerCase.Owner.Email;
			              string sName = customerCase.Owner.Name;
			            
			              if(sName == null || sName == '')
			              {
			            	 sName = customerCase.Owner.FirstName + ' ' + customerCase.Owner.LastName;  	
			              }
			            
						  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		                  String[] toAddresses = new String[]{sEmail};
		                  mail.setToAddresses(toAddresses);
		                  mail.setReplyTo('david.grigg@misys.com');
		                  mail.setSenderDisplayName('David Grigg');
		                  mail.setSubject('Targeted Release information updated via SFDC-CSFE interface');
		                  mail.setBccSender(false);
		                  mail.setUseSignature(false);
		                  string MsgBody='';
			            
			              MsgBody += 'Dear ' + sName;
						  MsgBody += '<p>';
						  MsgBody += 'This is to notify you that the targeted release record related to the ' + customerCase.Targeted_Release__c; 
						  MsgBody += ' targeted release field on your Case ' + customerCase.CaseNumber + ' has been updated via the SFDC-CSFE interface.';
						  MsgBody += '</p>'; 
						  MsgBody += 'Please click on the <a href=\'https://emea.salesforce.com/' +  targetedRelease.Id +'\'>link</a> to see the details.';
						  MsgBody += '<p>';
						  MsgBody += 'On behalf of' + '<br/>';
						  MsgBody += 'Salesforce administration';						
						  MsgBody += '</p>';
						
						  mail.setHtmlBody(MsgBody);
                		  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		 			   }
		 			}
		 		}
		 		// update the customer cases
		 		if(casesToUpdate.size() > 0)
		 		{
		 			update casesToUpdate;
		 		}
  		     } 
	 	//}
	 }
	*/
	public static void SendNotificationMailOnFieldChange(Targeted_Release__c updatedTargetedRelease, Targeted_Release__c oldTargetedRelease)
	{
		Case customerCases = null;
		if(updatedTargetedRelease.Customer_Case__c != null)
		{
			customerCases = [select Id, CaseNumber, OwnerID,Targeted_Fix_Date__c from Case where id =:updatedTargetedRelease.Customer_Case__c];
			if(customerCases.Targeted_Fix_Date__c == null && updatedTargetedRelease.Scheduled_Delivery_Date__c != null) 
            {
                customerCases.Targeted_Fix_Date__c = updatedTargetedRelease.Scheduled_Delivery_Date__c;
            	update customerCases;
            }
				
			Boolean IsChanged = false;
	    	String NewL3Status = '',NewDeliveryReference = '',NewComponent = '',NewFixType = '',NewFixDetails = '';
	    	
	    	String OldL3Status = '',OldDeliveryReference = '',OldComponent = '',OldFixType = '',OldFixDetails = '';
	    	
			String strTable = '';
    	
	    	if(updatedTargetedRelease.L3_Status__c != null)
	    		NewL3Status = updatedTargetedRelease.L3_Status__c;
	    	if(oldTargetedRelease.L3_Status__c != null)
	    		OldL3Status = oldTargetedRelease.L3_Status__c;    	
	    	if(NewL3Status != OldL3Status)
	    	{
	    		IsChanged = true;
	    		strTable += '<tr> <td>L3 Status</td> <td>'+ NewL3Status + '</td><td>'+ OldL3Status + '</td> </tr>';
	    	} 
	    	if(updatedTargetedRelease.Delivery_Reference__c != null)
	    		NewDeliveryReference = updatedTargetedRelease.Delivery_Reference__c;
	    	if(oldTargetedRelease.Delivery_Reference__c != null)
	    		OldDeliveryReference = oldTargetedRelease.Delivery_Reference__c;    	
	    	if(NewDeliveryReference != OldDeliveryReference)
	    	{
	    		IsChanged = true;
	    		strTable += '<tr> <td>Delivery Reference</td> <td>'+ NewDeliveryReference + '</td><td>'+ OldDeliveryReference + '</td> </tr>';
	    	}
	    	
	    	if(updatedTargetedRelease.Resolution_Type__c != null)
	    		NewFixType = updatedTargetedRelease.Resolution_Type__c;
	    	if(oldTargetedRelease.Resolution_Type__c != null)
	    		OldFixType = oldTargetedRelease.Resolution_Type__c;    	
	    	if(NewFixType != OldFixType)
	    	{
	    		IsChanged = true;
	    		strTable += '<tr> <td>Fix Type</td> <td>'+ NewFixType + '</td><td>'+ OldFixType + '</td> </tr>';
	    	}
	    	
	    	if(updatedTargetedRelease.Resolution_Details__c != null)
	    		NewFixDetails = updatedTargetedRelease.Resolution_Details__c;
	    	if(oldTargetedRelease.Resolution_Details__c != null)
	    		OldFixDetails = oldTargetedRelease.Resolution_Details__c;    	
	    	if(NewFixDetails != OldFixDetails)
	    	{
	    		IsChanged = true;
	    		strTable += '<tr> <td>Fix Details</td> <td>'+ NewFixDetails + '</td><td>'+ OldFixDetails + '</td> </tr>';
	    	}
	    	
	    	if(updatedTargetedRelease.Component__c != null)
	    		NewComponent = updatedTargetedRelease.Component__c;
	    	if(oldTargetedRelease.Component__c != null)
	    		OldComponent = oldTargetedRelease.Component__c;    	
	    	if(NewComponent != OldComponent)
	    	{
	    		IsChanged = true;
	    		strTable += '<tr> <td>Component</td> <td>'+ NewComponent + '</td><td>'+ OldComponent + '</td> </tr>';
	    	}
			
			if(IsChanged == true)
			{
				if(customerCases.OwnerID != null)
				{
					//Set<ID> uniqueOwnerIds = new Set<ID>();
					String[] toAddresses = new String[]{};
					system.debug('Nitin-IssueCase.OwnerId-->'+customerCases.OwnerId);
			        if(String.valueOf(customerCases.OwnerId).startsWith('005'))
					{
			        	//uniqueOwnerIds.add(customerCases.OwnerId);
			        	Id ownerId = customerCases.OwnerId;
			        	List<User> lUser = [Select u.IsActive, u.Id, u.Email,u.Name From User u where IsActive = true and Id = :ownerId and Email != null];
			        	if(lUser != null)
			        	{	        		
			        		for(User U:lUser)
			        		{
			        			if(U.Id != Label.ALM_Integration_User_ID)
	        						toAddresses.add(U.Email);
			        			system.debug('Nitin--->'+U.Email);
			        		}
			        	}
					}
			        else
			        {
			        	//JRB 16 Jun 2011: Instead of emailing every member of a queue, only send email to the queue email address.
			        	//Map<ID,GroupMember> queueToGroupMember = new Map<ID,GroupMember>([Select g.UserOrGroupId, g.GroupId From GroupMember g where GroupId =: customerCases.OwnerId]);
				        //if(queueToGroupMember != null)
				        //{
				        //	for(GroupMember GM:queueToGroupMember.values())
				        //		uniqueOwnerIds.add(GM.UserOrGroupId);
				        //}
				        List<Group> queueGroup = new List<Group>([select Id, Email from Group where Id = :customerCases.OwnerId]);
				        if(queueGroup != null)
				        {
				       		for(Group g : queueGroup)
            				{
            					if(g.Email != null)
            					{
            						toAddresses.add(g.Email);
            					}else{
            						toAddresses.add(Label.Case_Update_Default_Email);
            					}
            				}
				        }
			        }
			        if(toAddresses.size() > 0)
			        	SendEMail(updatedTargetedRelease,customerCases,toAddresses,strTable);
				}
			}
			
		}	 		
	}
	public static void SendEMail(Targeted_Release__c TargetedRelease,Case CustomerCase,String[] toAddresses,String strTbl)
	{
		system.debug('Nitin--->'+toAddresses);
		//Messaging.MassEmailMessage
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		//String[] toAdd = new String[] {'nitin-g@hcl.com'};
		mail.setToAddresses(toAddresses);
		//mail.setToAddresses(toAdd);
		mail.setReplyTo('csfe.admin@misys.com');
		mail.setSenderDisplayName('CSFE Admin');
		mail.setSubject('Targeted Release information updated via SFDC-CSFE interface');
		
		String strHTML = '';
		strHTML += '<p> Hello </p>';
		strHTML += '<p>';
		strHTML += 'This is to notify you that the targeted release record ' + TargetedRelease.Name ; 
		strHTML += ' on your Customer Case ' + CustomerCase.CaseNumber + ' has been updated via the SFDC-CSFE interface.';
		strHTML += '</p>';
		strHTML += '<br /><br />';
		strHTML += '<table border=1 width=50%>';
		strHTML += '<tr> <td><b>Targeted Release fields</b></td>';
		strHTML += ' <td><b>NEW Value</b></td>';
		strHTML += ' <td><b>OLD Value</b></td> </tr>';
		strHTML += strTbl;
		strHTML += '</table>';
		strHTML += '<br /><br />'; 
		strHTML += 'Please click on the <a href=' + Label.Domain_URL + '/' +  TargetedRelease.Id + '>link</a> to see the details.';
		strHTML += '<p>';
		strHTML += 'On behalf of' + '<br/>';
		strHTML += 'Salesforce administration';						
		strHTML += '</p>';
		
		mail.setHtmlBody(strHTML);
		try{
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}catch(Exception e) {
		   	system.debug('Error sending email: '+e);
		}
		SFDC_CSFE_Controller.preventTriggersWhenSendingMail = true;
	}
	/* This method is replaced with the Workflow rule : "New Targeted Release notification"
	// function to change the Substatus of a Customer case based upon the L3 Status value in related Targeted Release record
	 public static void SendNotificationMail(String IssueCaseID,Targeted_Release__c TargetedRelease)
	 {
		Case IssueCase = [select Id, CaseNumber,OwnerID  from Case where id =: IssueCaseID];
		Set<ID> uniqueOwnerIds = new Set<ID>();
		system.debug('Nitin-IssueCase.OwnerId-->'+IssueCase.OwnerId);
        if(String.valueOf(IssueCase.OwnerId).startsWith('005'))
		{
        	uniqueOwnerIds.add(IssueCase.OwnerId);
		}
        else
        {
        	Map<ID,GroupMember> queueToGroupMember = new Map<ID,GroupMember>([Select g.UserOrGroupId, g.GroupId From GroupMember g where GroupId =: IssueCase.OwnerId]);
	        if(queueToGroupMember != null)
	        {
	        	for(GroupMember GM:queueToGroupMember.values())
	        		uniqueOwnerIds.add(GM.UserOrGroupId);
	        }
        }
        if(uniqueOwnerIds.size() > 0)
        {
        	String[] toAddresses = new String[]{};
        	List<User> lUser = [Select u.IsActive, u.Id, u.Email,u.Name From User u where IsActive = true and id in: uniqueOwnerIds and Email != null];
        	if(lUser != null)
        	{	        		
        		for(User U:lUser)
        		{
        			toAddresses.add(U.Email);
        			system.debug('Nitin--->'+U.Email);
        		}
        	}
        	
        	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(toAddresses);
			mail.setSubject('New Targeted Release notification');
			string MsgBody='';
			MsgBody += 'Hello ' + IssueCase.CaseNumber;
			MsgBody += '<p>';
			MsgBody += 'This is to notify you that a new targeted release ' + TargetedRelease.Name ; 
			MsgBody += ' has been added to Issue Case ' + IssueCase.CaseNumber + ' via the SFDC-CSFE interface.';
			MsgBody += '</p>'; 
			MsgBody += 'Please click on the <a href=\'https://emea.salesforce.com/' +  TargetedRelease.Id +'\'>link</a> to see the details.';
			MsgBody += '<p>';
			MsgBody += 'On behalf of' + '<br/>';
			MsgBody += 'Salesforce administration';						
			MsgBody += '</p>';
			mail.setHtmlBody(MsgBody);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}	
	 }*/
  // AC 9/4/09 - test methods moved to separate class	
}