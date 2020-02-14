public class CaseFuture {

	//This class contains 'callFuture' methods and 'Future' methods.  
	//	--'callFuture' methods are used to determine if the system is currently running in @Future context.  If so, the target method is called 
	//		directly.  If not, the necessary data preparation is done and then the target method is called.
	//  --'Future' methods call the asynchronous process
	//	This was set up to more easily run methods in a @Future context without running into problems with calling @Future methods from a 
	//  @Future method.
	//  JRB

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	public static void callFuture_CallWebServiceMethod(List<Id> lCaseId){
		if(GlobalVar.bInFuture == true){
			//Call the method directly
			CaseTriggerMethods.CallWebServiceMethod(lCaseId);
		}else{
			//Call the method in the @Future context
			CaseFuture.Future_CallWebServiceMethod(lCaseId);
		}
	}

	@future public static void Future_CallWebServiceMethod(List<Id> lCaseId){
		//Set the flag that this is running asynchronously        
        GlobalVar.bInFuture = true;
        system.debug('XXXXX In Future_CreateTimeObjectForNewCase - bInFuture='+GlobalVar.bInFuture);

		CaseTriggerMethods.CallWebServiceMethod(lCaseId);
	}

	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	public static void callFuture_CallSetTimeObjectOnCase(Set<Id> setTimeObjectIds){
		if(GlobalVar.bInFuture == true){
			//Call the method directly
			CaseTriggerMethods.SetTimeObjectOnCase(setTimeObjectIds);
		}else{
			//Call the method in the @Future context
			CaseFuture.Future_CallSetTimeObjectOnCase(setTimeObjectIds);
		}
	}

	@future public static void Future_CallSetTimeObjectOnCase(Set<Id> setTimeObjectIds){
		//Set the flag that this is running asynchronously        
        GlobalVar.bInFuture = true;
        system.debug('XXXXX In Future_CallSetTimeObjectOnCase - bInFuture='+GlobalVar.bInFuture);

		CaseTriggerMethods.SetTimeObjectOnCase(setTimeObjectIds);
	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	@future public static void Future_SetCaseWorkAroundTime(Set<Id> sTimeObjectIds, datetime dtTimeStamp)
	{
		GlobalVar.bInFuture = true;
        List<Time_Object__c> uniqueTimeObjects = new List<Time_Object__c>([Select t.Original_Workaround_Time_Stamp__c from Time_Object__c t where t.Original_Workaround_Time_Stamp__c = null and t.Id in :sTimeObjectIds]);
        for(Time_Object__c t:uniqueTimeObjects)
            t.Original_Workaround_Time_Stamp__c = dtTimeStamp;
	}

	@future public static void caseNotify(List<Id> changedCases, List<String> fieldNames) {
        
        SFDC_CSFE_Controller.CSFEtransactionUpdateRunning = true; // never allow CSFE Transaction Type update on this future call - it will already run for the update that triggered this call. AC 7/28        // Query all the fields we need for the changed cases
        
        List<Case> triggeredCases = [Select Id, RecordTypeId, OwnerId, CaseNumber From Case Where Id in :changedCases];
        
        // AC 11/3 - don't need to check if its an issue case id - only issue cases will come in the list.
        // We need the issue case record type
        // Id issueCaseRecodTypeId = Label.issue_case_id;
        
        // We need to record the ids of the issue cases for subsequent associated customer case query
        List<Id> issueCaseIds = new List<Id>();
        
        // We need a map of case id to owners
        Map<Id,Set<Id>> caseIdToOwners = new Map<Id,Set<Id>>();
        
        // We need a map of owner to user (for the email addresses)
        Map<Id,User> ownerToUser = new Map<Id,User>();
        
        // We need a map of case id to the email text
        Map<Id,String> caseIdToEmailText = new Map<Id,String>();
        
        // This can be fired on either an issue or a customer case.  For an issue case we need the email addresses
        // of the owners of all associated customer cases.  For a customer case it will be just the one email
        for (Integer i=0; i<triggeredCases.size(); i++) {
                
            // Create the email body text and put in case id to text map
            String emailBody = Label.following_change_text + ' ' + triggeredCases[i].CaseNumber + '.\n' + fieldNames.get(i);
            caseIdToEmailText.put(triggeredCases[i].Id,emailBody);
            System.debug('This case is of interest ' + triggeredCases[i].CaseNumber);
        
            // AC 11/3 - don't need to check if its an issue id - only issue IDs will be passed to this method.
            // If this is an issue case then put in the issue cases list
            // if (triggeredCases[i].RecordTypeId == issueCaseRecodTypeId) {
                issueCaseIds.add(triggeredCases[i].Id);
                System.debug('This is an issue case');
            // } // end issue case check if
            
            // Put the trigger to owner id in the map
            Set<Id> owners = new Set<Id>();
            owners.add(triggeredCases[i].OwnerId);
            caseIdToOwners.put(triggeredCases[i].Id,owners);    
        } // end loop through cases
        
        if (issueCaseIds.size() >0) {
            // Query back all cases associated with any issue cases we found.  We need the owner ids for emailing
            List<Case> attachedCases = [Select OwnerId, Issue_Case__c From Case Where Issue_Case__c in :issueCaseIds];
            System.debug('Attached cases are:');
            System.debug(attachedCases);
            
            // Loop through all attached cases, added the owner ids to the lists against the issue case
            // so that we can subsequently email them
            for (Case attachedCase : attachedCases) {
                
                // The issue case must already have been recorded so add the attached owner id to the list
                Set<Id> owners = caseIdToOwners.get(attachedCase.Issue_Case__c);
                System.debug('Looked up owners list of:');
                System.debug(owners);
                owners.add(attachedCase.OwnerId);
                System.debug('Added owner id.  List is now:');
                System.debug(owners);
                
                // AC 11/3 - add back into map.
                caseIdToOwners.put(attachedCase.Issue_Case__c,owners);  
            } // end loop through attached cases for
        } // end check we have issue cases before querying if 
        
        // Now we get a set of owner ids so that we can query back the email addresses
        Set<Id> uniqueOwnerIds = new Set<Id>();
        for (Set<Id> ownerList : caseIdToOwners.values()) {
            for (Id ownerId : ownerList) {
                uniqueOwnerIds.add(ownerId);
            }
        }
        System.debug('Set of owner ids:');
        System.debug(uniqueOwnerIds);
        
        // Query back email addresses
        if (uniqueOwnerIds.size() > 0) {
            ownerToUser = new Map<Id,User>([Select Id, Email From User Where Id in :uniqueOwnerIds]);
            System.debug('Owner to user map brought back:');
            System.debug(ownerToUser);
        } // end check for any owner ids if
        
        // Loop through the case ids
        Integer emailsSent = 0;
  
        for (Id caseId : caseIdToOwners.keyset()) {
            
            // Loop through the owners forming the to address
            Integer toAddressCount = 0;
            List<String> toAddresses = new List<String>();
            for (Id owner : caseIdToOwners.get(caseId)) {
                User emailUser = ownerToUser.get(owner);
                
                // Note that this can be null if the owner is a queue.  If this is the case move to the next
                // iteration of the loop
                if (emailUser == null) continue;
                
                toAddresses.add(emailUser.Email);
                toAddressCount++;
             

                
                // If we are at the limit of addresses per email (10) then 
                // send out an email and create another one (i.e. send out batches of 10 addresses each)
                if (toAddressCount >= 10) {
                    
                    //Send here
                    System.debug('Sending email to:');
                    System.debug(toAddresses);
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(toAddresses);
                    mail.setReplyTo('no-reply@misys.com');
                    mail.setSenderDisplayName('Case Updated Notifier');
                    mail.setSubject('Case Update');
                    mail.setPlainTextBody(caseIdToEmailText.get(caseId));
                    System.debug('Mail object 1');
                    System.debug(mail);
                    if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    
                    // Prepare for next iteration
                    toAddresses = new List<String>();
                    toAddressCount = 0;
                    emailsSent++;
                    
                    // Exit loop if we hit the maximum allowed to be sent
                    if (emailsSent >= 10) {
                        System.debug('Hit the maximum number of emails sent so exiting 1');
                        break;
                    } // end check for maximum emails if
                } // end check address count
            } // end loop through the owners
                
                              
                
            // Exit this loop if we hit the maximum number of emails allowed
            if (emailsSent >= 10) {
                System.debug('Hit the maximum number of emails sent so exiting 2');
                break;
            } // end check for maximum emails if    
            
                        
            // If there are still addresses to send to then send another email
            if (toAddresses.size() > 0) {
                
                // Exit this loop if we hit the maximum number of emails allowed
                if (emailsSent >= 10) {
                    System.debug('Hit the maximum number of emails sent so exiting 3');
                    break;
                } // end check for maximum emails if    
                            
                System.debug('Sending email to:');
                System.debug(toAddresses);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddresses);
                mail.setReplyTo('no-reply@misys.com');
                mail.setSenderDisplayName('Case Updated Notifier');
                mail.setSubject('Case Update');
                mail.setPlainTextBody(caseIdToEmailText.get(caseId));
                System.debug('Mail object 1');
                System.debug(mail);
                if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                System.debug('Sending email to last addresses for case');
                System.debug(toAddresses);
                emailsSent++;
            } // end check for email addresses if
        } // end loop through case ids for
    } // end caseNotify
    
} // end class