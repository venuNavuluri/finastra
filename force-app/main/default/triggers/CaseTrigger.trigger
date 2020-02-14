trigger CaseTrigger on Case (before insert, before update, after delete, after insert, after update, after undelete) 
{
    if(Label.Disable_Case_Triggers == 'Disable')
    {
    	system.debug('Case Trigger Disabled.  Update Custom Label Disable_CaseTriggers to re-enable');
    }
    else
    {
	    //Initially, set the Case Priority based on the Severity unless Priority .  Many things are based on the standard Priority field in Salesforce
	    if(trigger.isBefore){
	    	if(trigger.isInsert){
	    		//Set the Case Priority based on the Severity, unless this is an issue case
	            for(Case c : trigger.new){
	            	//if(c.Severity__c != '' && c.Severity__c != null && c.recordtypeid != Label.issue_case_id){
	            	if(c.Severity__c != '' && c.Severity__c != null){
	            		c.Priority = CaseServices.getPriorityFromSeverity(c.Severity__c);
	            	}
	            	system.debug('CaseTrigger - 10 - Insert - Case Priority = '+c.Priority);
	            }
	    	}else if(trigger.isUpdate){
	    		//Set the Case Priority based on the Severity, if the Severity has changed and this is not an issue case
	            for(Case c : trigger.new){
	            	if(c.Severity__c != '' && c.Severity__c != null && c.Severity__c != trigger.oldMap.get(c.Id).Severity__c){
	            		c.Priority = CaseServices.getPriorityFromSeverity(c.Severity__c);
	            	}
	            	system.debug('CaseTrigger - 11 - Update - Case Priority = '+c.Priority);
	            }
	    	}
	    	
	    	//Set the MetricsStatus field for case metrics calculations
	    	for(Case c : trigger.new){
	    		if(c.Sub_Status__c != '' && c.Sub_Status__c != null){
	    			c.MetricsStatus__c = c.Status + '-' + c.Sub_Status__c;
	    		}else{
	    			c.MetricsStatus__c = c.Status;
	    		}
	    		system.debug('CaseTrigger - set MetricsStatus : '+c.MetricsStatus__c);
	        }
	        
	        //Update the Case Owner to the user lookup field.  This is used for other formulas
	        CaseServices.updateUserLookupFromOwnerOnCase(trigger.new);
	    }
	    
	    
	    PSPHelper pspHelper;
	    
	    if(trigger.isBefore && !SFDC_CSFE_Controller.preventTriggersWhenUpdatingCCfromIC)
	    {
	        if(trigger.isInsert)
	        {   
	            // Assign the SLA and BHIU to the case.  If a specific SLA and BHIU are defined for the case Product and/or Priority,
	            //   set those on the case.  Otherwise, set the Account's main SLA and BHIU to the case. 
	            CaseTriggerMethods.SetCaseSLA(trigger.new);
	            
	            // ALM - July 09 
	            if (userInfo.getUserID().substring(0,15) == Label.ALM_Integration_User_ID.substring(0,15)) {
	              CaseTriggerMethods.getOffsets(Trigger.new); 
	            }
	            
	            //Keeps Priority and CSFE_Priority_Severity in sync
	            CaseTriggerMethods.updatePrioritySeverity(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate); 
	            // - handled by workflow on MBS -- CaseTriggerMethods.updateTargetedReleaseDate(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate); 
	            //Keeps Product_Version and CSFE_Product_Version in sync
	            CaseTriggerMethods.updateProductVersion(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate); 
	            //Keeps Self Service Product and CSFE_Product in sync
	            CaseTriggerMethods.updateProduct(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate); 
	            //Updates the CSFE_TRANSACTION__c field to either insert or update
	            CaseTriggerMethods.updateCSFETransaction(Trigger.new, Trigger.oldMap, true);
	            
	            //Update the CS Case Manager
	        	CaseServices.checkCSCaseManager(Trigger.new);
	        }
	        
	        else if(trigger.isUpdate)
	        {
	        	
	            // ALM - July 09 - caseBeforeUpdateALM contents
	            //Keeps Priority and CSFE_Priority_Severity in sync
	            CaseTriggerMethods.updatePrioritySeverity(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate); 
	            // - handled by workflow on MBS -- CaseTriggerMethods.updateTargetedReleaseDate(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate); 
	            //Keeps Product_Version and CSFE_Product_Version in sync
	            CaseTriggerMethods.updateProductVersion(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate); 
	            //Keeps Self Service Product and CSFE_Product in sync
	            CaseTriggerMethods.updateProduct(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate); 
	            //Updates the CSFE_TRANSACTION__c field to either insert or update
	            CaseTriggerMethods.updateCSFETransaction(Trigger.new, Trigger.oldMap, false);
	            //Adds a case comment for the sfdc_csfe_commentary for each case passed in -- this is instead of using field history tracking
	            CaseTriggerMethods.createCaseCommentForCommentary(Trigger.new, Trigger.oldMap, false);
	            //Populates the Client Specific Data field on Issue Case when a Customer Case either creates a new Issue Case OR an existing Issue Case is attached to a Customer Case.
	            CaseTriggerMethods.updateClientSpecificData(trigger.newMap, trigger.oldMap);
	            // END ALM
	            
	            //Timestamps Date_Time_Responded__c if it is null
	            CaseTriggerMethods.SetCaseDateTimeResponded(trigger.new);         
	            
	            /*
	                Below code has been written by HCL team.
	                Below code Insert Current DateTime in the Workaround Time Stamp field if Workaround Provided
	                field is changed to 'Yes'.
	            */
	            //REFACTOR - possibly use Workflow for this instead?  Or move logic to a class instead of directly in the trigger
	            Set<ID> sTimeID = new Set<ID>();
	            for(Case objCase : trigger.new)
	            {
	                //Set the case Priority based on a lookup.  
		            //If the field or values change for Priority/Severity, it can be adjusted here
		           	String casePriority = CaseServices.getPriorityFromSeverity(objCase.Severity__c);
		           	String caseOriginalPriority = CaseServices.getPriorityFromSeverity(objCase.Original_Priority__c);
		           	system.debug('CaseTrigger - 90 - CasePriority = ' + casePriority);
		           	system.debug('CaseTrigger - 91 - CaseOriginalPriority = ' + caseOriginalPriority);
	                
	                if(objCase.Workaround_Provided__c != null && objCase.Workaround_Provided__c == 'Yes'
	                    && trigger.oldMap.get(objCase.Id).Workaround_Provided__c != 'Yes'
	                    &&objCase.Workaround_Time_Stamp__c == null)
	                {
	                    objCase.Workaround_Time_Stamp__c = Datetime.now();                     
	                    if(objCase.Time_Object__c != null)
	                        sTimeID.add(objCase.Time_Object__c);
	                }
	                else if(objCase.Workaround_Provided__c == null || objCase.Workaround_Provided__c == 'No'
	                    && trigger.oldMap.get(objCase.Id).Workaround_Provided__c == 'Yes'
	                    && objCase.Workaround_Time_Stamp__c != null)
	                    {
	                         objCase.Workaround_Time_Stamp__c = null;
	                    }                
	                //if(objCase.Priority != objCase.Original_Priority__c && objCase.Original_Priority__c == trigger.oldMap.get(objCase.Id).Priority)
	                if(casePriority != caseOriginalPriority && caseOriginalPriority == CaseServices.getPriorityFromSeverity(trigger.oldMap.get(objCase.Id).Severity__c))
	                {
	                    if(objCase.Time_Object__c != null)
	                        sTimeID.add(objCase.Time_Object__c);
	                }
	            }
	            if(sTimeID.size() > 0)
	                //Updates Original_Workaround_Timestamp__c on Time Objects
	                CaseTriggerMethods.SetCaseWorkaroundTime(sTimeID);
	            
	            //REFACTOR - move logic to a class
	            List<Case> lstUpdatedCase = new List<Case>();
	            for(Case objCase : trigger.new)
	            {
	                /* 
	                    Criteria added by HCL team.
	                    SLA and BHIU should always checked if Account or Product or Priority gets changed.                
	                */
	                //if(objCase.AccountId != trigger.oldMap.get(objCase.Id).AccountId
	                //    || objCase.Self_Service_Product__c != trigger.oldMap.get(objCase.Id).Self_Service_Product__c
	                //    || objCase.Priority != trigger.oldMap.get(objCase.Id).Priority  )
	                system.debug('CaseTrigger - 120 - current Severity - getPriorityFromSeverity(' + objCase.Severity__c + ') = '+CaseServices.getPriorityFromSeverity(objCase.Severity__c));
	                system.debug('CaseTrigger - 121 - previous Severity - getPriorityFromSeverity(' + trigger.oldMap.get(objCase.Id).Severity__c + ') = '+CaseServices.getPriorityFromSeverity(trigger.oldMap.get(objCase.Id).Severity__c));
	                if(objCase.AccountId != trigger.oldMap.get(objCase.Id).AccountId
	                    || objCase.Self_Service_Product__c != trigger.oldMap.get(objCase.Id).Self_Service_Product__c
	                    || CaseServices.getPriorityFromSeverity(objCase.Severity__c) != CaseServices.getPriorityFromSeverity(trigger.oldMap.get(objCase.Id).Severity__c))
	                {
	                    lstUpdatedCase.add(objCase);
	                }                
	            }
	            if(lstUpdatedCase.size() > 0)
	            {
	                //If the Account, Product, or Priority have changed on the case, update the SLA and BHIU as needed
	                CaseTriggerMethods.SetCaseSLA(lstUpdatedCase);
	            }
	            /* 
	                Below code section is written by HCL team
	                If Account is changed on Case record then change all the Original field values 
	                rether then Original Priority on the basis of new Account.
	            */
	            for(Case objCase : trigger.new)
	            {
	                if(objCase.AccountId != trigger.oldMap.get(objCase.Id).AccountId)
	                {
	                    if(objCase.SLA__c != null)
	                        objCase.Original_SLA__c = objCase.SLA__c;
	                    if(objCase.Business_Hours_in_Use__c != null)
	                        objCase.Original_Business_Hours_in_Use__c = objCase.Business_Hours_in_Use__c;
	                }
	            }
	            //////////////////////////////////////////////////////////////////////////
	            //
	            // HANDLING CASE RE-OPENING VIA TRIGGER BY RESETTING TIME OBJECT FLAG
	            // Added on: 22 May 2009 :16:53
	            // Added by: Salman Sheikh
	            // Requested by: Martin Cassidy
	            // 
	            //////////////////////////////////////////////////////////////////////////
	            Set<ID> timeObjectIds = new Set<ID>();
	            for(Case objCase : trigger.new)
	            {
	                // check if history exists
	                if(!trigger.oldMap.isEmpty())
	                {
	                    if(trigger.oldMap.get(objCase.Id) != null)
	                    {
	                        // case being re-opened
	                        if(trigger.oldMap.get(objCase.Id).IsClosed == true && objCase.IsClosed == false)
	                        {
	                            if(objCase.Time_Object__c != null)
	                            {
	                                if(objCase.Time_Object_Process_Closed_Flag__c == 'True')
	                                {
	                                    timeObjectIds.add(objCase.Time_Object__c);
	                                }
	                            }
	                        }
	                    }
	                }
	            }
	            
	            if(timeObjectIds.size() > 0)
	            {
	                List<Time_Object__c> lstTO = [select Id, Process_Closed_Case__c from Time_Object__c where Id in :timeObjectIds];
	                
	                if(lstTO.size() > 0)
	                {
	                    for(Time_Object__c t : lstTO)
	                    {
	                        t.Process_Closed_Case__c = false;
	                    }
	                    
	                    update lstTO;
	                }
	                
	            }
	            /* 
	                Below section has been written by HCL team.
	                This section will execute only if the Response is made for a Case.
	                This section Capture all the Original Priority field values.
	            */
	            List<Case> lCase = new List<Case>();
	            Map<String,Business_Hours_in_Use__c> mBusinessHour;
	            Set<ID> sBisunessID = new Set<ID>();   
	            for(Case objCase : trigger.new)
	            {                           
	                if(objCase.Priority != null && objCase.Original_Priority__c == null)
	                //if(CaseServices.getPriorityFromSeverity(objCase.Severity__c) != null && CaseServices.getPriorityFromSeverity(objCase.Original_Priority__c) == null)
	                {
	                    if(objCase.Business_Hours_in_Use__c != null)
	                        sBisunessID.add(objCase.Business_Hours_in_Use__c);
	                }
	            }
	            if(sBisunessID.size() > 0   )
	                mBusinessHour = new Map<String,Business_Hours_in_Use__c>([Select Normal_Working_Day_Length__c,Id from Business_Hours_in_Use__c where id in:sBisunessID]);
	            for(Case objCase : trigger.new)
	            {
	                if(objCase.Priority != null && objCase.Original_Priority__c == null)
	                {
	                    objCase.Original_Priority__c = objCase.Priority;
	                    if(objCase.SLA__c != null && objCase.Original_SLA__c == null)
	                        objCase.Original_SLA__c = objCase.SLA__c;
	                    if(objCase.Business_Hours_in_Use__c != null && objCase.Original_Business_Hours_in_Use__c == null)
	                        objCase.Original_Business_Hours_in_Use__c = objCase.Business_Hours_in_Use__c;
	                    if(objCase.Original_Normal_Working_Day_Hours__c == null && objCase.Original_Business_Hours_in_Use__c != null 
	                        && mBusinessHour.get(objCase.Original_Business_Hours_in_Use__c) != null)
	                        objCase.Original_Normal_Working_Day_Hours__c = mBusinessHour.get(objCase.Original_Business_Hours_in_Use__c).Normal_Working_Day_Length__c;
	                }
	            }            
	            //////////////////////////////////////////////////////////////////////////
	            // ENDING CASE RE-OPENING 
	            ////////////////////////////////////////////////////////////////////////// 
	            
	            //Code from Vista/Turaz - July 2012
	            CaseTriggerMethods.addCaseTrackerAndHistoryEntries(Trigger.newMap, Trigger.oldMap);
	            
	            //Update the CS Case Manager
	        	CaseServices.checkCSCaseManager(Trigger.newMap, Trigger.oldMap);       
	        }
	        
	        
	    }
	    else if(trigger.isAfter)
	    {
	        // Contents of correctcasecounts trigger
	        Set<Id> issueCaseIds = new Set<Id>();
	        
	        //Variables for TTP process
	        List<Case> lCaseInsertTTP = new List<Case>();
	        Map<Id,Case> mCaseChangeTTP = new Map<Id,Case>();
	        Set<Id> setCaseDeleteTTP = new Set<Id>();        
	        
	        // Iterate through the customer cases
	        for (Integer i = 0; i < (Trigger.isDelete ? Trigger.old.size() : Trigger.new.size()); i++) {
	            
	            // We are only interested in updates if the issue case lookup has changed
	            // or the client has changed from one issue case to another
	            if (Trigger.isUpdate && ((Trigger.old[i].Issue_Case__c != Trigger.new[i].Issue_Case__c) || (Trigger.old[i].AccountId != Trigger.new[i].AccountId))) {
	                if (Trigger.old[i].Issue_Case__c != null) issueCaseIds.add(Trigger.old[i].Issue_Case__c);
	                if (Trigger.new[i].Issue_Case__c != null) issueCaseIds.add(Trigger.new[i].Issue_Case__c);
	            } // end update change check if
	            
	            // Use the old triggered picture if we are deleting
	            if (Trigger.isDelete) {
	                if (Trigger.old[i].Issue_Case__c != null) issueCaseIds.add(Trigger.old[i].Issue_Case__c);
	            } // end check delete or update if
	            
	            // Use the new triggered picture if we are inserting or undeleting
	            if (Trigger.isInsert || Trigger.isUndelete) {
	                if (Trigger.new[i].Issue_Case__c != null) issueCaseIds.add(Trigger.new[i].Issue_Case__c);
	            } // end check for insert, update, undelete if
	        } // end iterate through the customer cases
	        
	        // Call future method to update the counts
	
	        if (!issueCaseIds.isEmpty()) CaseTriggerMethods.caseCounts(issueCaseIds);
	        
	        if(trigger.isInsert && !SFDC_CSFE_Controller.preventTriggersWhenUpdatingCCfromIC)
	        {
	            // ALM            
	            CaseTriggerMethods.createCaseCommentForCommentaryInsert(Trigger.new );       
	            if (userInfo.getUserID().substring(0,15) == Label.ALM_Integration_User_ID.substring(0,15)) {
	              CaseTriggerMethods.attachAssociatedCases(Trigger.new); 
	            }
	            
	            CaseTriggerMethods.updateClientSpecificData(trigger.newMap, null);
	            // END ALM
	            
	            if(!String.valueOf(UserInfo.getUserId()).startsWith('035'))
	            {
	                CaseTriggerMethods.CreateTimeObjectForNewCase(trigger.new);
	            }
	            if(pspHelper == null)
	                pspHelper = TimeCalculator.getPSPHelper(trigger.new);
	            CaseTriggerMethods.SetCaseOutOfHoursFlag(trigger.newMap, pspHelper);
	            CaseTriggerMethods.SetCaseSolutionBreachTime(trigger.new, pspHelper);
	        }   
	    
	        if(trigger.isUpdate && !SFDC_CSFE_Controller.preventTriggersWhenUpdatingCCfromIC)
	        {
	            if(pspHelper == null)
	                pspHelper = TimeCalculator.getPSPHelper(trigger.new);
	            
	            Map<ID,Case> mCaseUp = new Map<ID,Case>();
	            for(Case objCase : trigger.new)
	            {
	                //if(objCase.Priority != objCase.Original_Priority__c && objCase.Original_Priority__c == trigger.oldMap.get(objCase.Id).Priority)
	                if(CaseServices.getPriorityFromSeverity(objCase.Severity__c) != CaseServices.getPriorityFromSeverity(objCase.Original_Priority__c) 
	                	&& CaseServices.getPriorityFromSeverity(objCase.Original_Priority__c) == CaseServices.getPriorityFromSeverity(trigger.oldMap.get(objCase.Id).Priority))
	                {
	                    mCaseUp.put(objCase.Id,objCase);
	                }
	            }
	            
	            if(mCaseUp.size() > 0)
	            {
	                CaseTriggerMethods.SetCaseOriginalOnPriorityChange(mCaseUp, pspHelper);
	            }
	            
	            //Code is written by HCL team to calculate the time object record every when a Case is updated 
	            // Below check is because the below code should not run from test method    
	            if(DontCallFutureMethodFromTestMethod.getIsTestMethod() == false)
	            {
	                DontCallFutureMethodFromTestMethod.setIsTestMethod();
	                List<ID> lCaseId = new List<ID>();
	                for(Case c:Trigger.new)
	                    lCaseId.add(c.Id);
	                if(lCaseId.size() > 0)
	                {
	                    //JRB 2011-03-11 Move to a Future call
	                    CaseFuture.callFuture_CallWebServiceMethod(lCaseId);
	                }
	            }
	        }
            
            //Code from Turaz org - updates child cases attached to an Engineering/JIRA case.
            if(trigger.isUpdate){
            	CaseServices.closeAndUpdateChildCases(Trigger.newMap, Trigger.oldMap);
            }
	        
	        //Case Survey - Mark Survey Sent fields on Contact for tracking
	        if(trigger.isUpdate){
	        	List<Case> caseSurveysSent = new List<Case>();
	        	for(Case surveyCase : trigger.new)
	        	{
	        		//If the CaseSurveySent field is marked TRUE and was previously FALSE, then include the case for the contact update
	        		if(surveyCase.CaseSurveySent__c == true && trigger.oldMAp.get(surveyCase.Id).CaseSurveySent__c == false)
	        		{
	        			caseSurveysSent.add(surveyCase);
	        		}
	        	}
	        	if(caseSurveysSent.size() > 0){
	        		CaseServices.updateCaseSurveyContact(caseSurveysSent);
	        	}
	        }
	        
            // RBI Customer Delivery Date
            if (Trigger.isInsert)
                CaseTriggerMethods.copyCustomerDeliveryDate(null, Trigger.new);
            else if (Trigger.isUpdate)
                CaseTriggerMethods.copyCustomerDeliveryDate(Trigger.oldMap, Trigger.new);
	    }
	    
	      /////////////////////////////////////////////////////////////////////////////
	    // Store Case Owner in custom field: For CS performance metrics
	    // Added on: 31 May 2009
	    // Added by: Kim Jansen
	    // Changed on: 30 July 2009 to skip update if the case is closed
	    // Changed on: 7 Nov 2009 to only set the value of the Analyst Id once
	    // Changed on: 6 Dec to exclude the user role from the criteria
	    /////////////////////////////////////////////////////////////////////////////
	   if(trigger.isUpdate && trigger.isBefore && !SFDC_CSFE_Controller.preventTriggersWhenUpdatingCCfromIC)
	   {
	        // check if the logged in user is Standard User and does not belongs to GCC Profile
	        if(Userinfo.getUserType() == 'Standard' && Userinfo.getUserRoleId() != null && Userinfo.getUserRoleId().substring(0,15)!= '00E20000000hHJV')    
	        {
	            // if previous state of the data exists
	            if(trigger.oldMap != null && !trigger.oldMap.isEmpty())
	            {
	                // loop through the case records
	                for (Case loopCase : Trigger.new) 
	                {
	                    System.debug('loopCase.Analyst_ID__c : ' + loopCase.Analyst_ID__c);
	                    
	                    // check if the Analyst Id is not already populated AND Status is not Closed and not L3 - In Development
	                    //if(Userinfo.getUserRoleId().substring(0,15) != '00E20000000hHJV' && loopCase.Analyst_ID__c == null && loopCase.Status != 'Closed' && loopCase.Status != 'L3 - In Development' && loopCase.Status != 'L3 - In Engineering')
	                    if(Userinfo.getUserRoleId().substring(0,15) != '00E20000000hHJV' && loopCase.Analyst_ID__c == null && loopCase.Status != 'Closed' && loopCase.Status != 'In Progress' && loopCase.Sub_Status__c != 'Development')
	                    {
	                        // extract the previous value of the case before update
	                        if(trigger.oldMap.containsKey(loopCase.Id))
	                        {
	                            // get the old case record
	                            Case oldCase = trigger.oldMap.get(loopCase.Id);
	                            
	                            string oldOwner = oldCase.OwnerId;
	                            string newOwner = loopCase.OwnerId; 
	                            string myAID = oldCase.Analyst_ID__c;
	                                                        
	                            System.debug('oldOwner : ' + oldOwner);
	                            System.debug('newOwner : ' + newOwner);
	                            
	                            // check that the previous owner was a queue and a new owner is a user (assignment rule kicking)
	                            if(Userinfo.getUserRoleId().substring(0,15)!= '00E20000000hHJV' && myAID == null && oldOwner.startsWith('00G') && newOwner.startsWith('005'))
	                            {
	                                System.debug('Going to assign Analyst ID : ' + loopCase.OwnerId);
	                                loopCase.Analyst_ID__c  = loopCase.OwnerId;
	                            }
	                        }       
	                    }
	                    // If Analyst Id is populated, clear the field if certain conditions are met
	                    //else if(loopCase.Analyst_ID__c != null && loopCase.Status != 'Closed' && loopCase.Status != 'L3 - In Development')
	                    else if(loopCase.Analyst_ID__c != null && loopCase.Status != 'Closed' && loopCase.MetricsStatus__c != 'In Progress-Development')
	                    {
	                        // extract the previous value of the case before update
	                        if(trigger.oldMap.containsKey(loopCase.Id))
	                        {
	                            // get the old case record
	                            Case oldCase = trigger.oldMap.get(loopCase.Id);
	                                
	                            string oldOwner = oldCase.OwnerId;
	                            string newOwner = loopCase.OwnerId; 
	                            string myAID = oldCase.Analyst_ID__c;
	                            
	                            System.debug('oldOwner : ' + oldOwner);
	                            System.debug('newOwner : ' + newOwner);
	                            
	                            //Check if the new owner is a queue for which the Analyst Id should be cleared
	                            if(Label.TriageQueue_ClearAnalystId.contains(newOwner) && oldOwner != newOwner)
	                            {
	                                system.debug('Clearing AnalystId value due to new queue owner: '+loopCase.OwnerId);
	                                loopCase.Analyst_ID__c = null;
	                            }
	                        }
	                    }
	                }
	            }
	        }
	   }
	    if (!SFDC_CSFE_Controller.emailCheckRunning)
	    {
	        // Indicate running already in this cycle
	        SFDC_CSFE_Controller.emailCheckRunning = true;        
	        if(trigger.isUpdate && trigger.isBefore)
	        {
	            // Code is written by Nitin to send email notification in case of the change in the field values of issue case:
	            Case CaseNew = Trigger.new[0];
	            Case CaseOld = Trigger.oldMap.get(CaseNew.Id);
	            if(CaseNew.RecordTypeId == Label.issue_case_id && !SFDC_CSFE_Controller.preventTriggersWhenSendingMail)
	            {
	                CaseTriggerMethods.ChangedIssueCase(CaseNew,CaseOld);
	            }        
	        }
	    }
    } //end CaseTrigger disable
    
    /******************************
    /* CaseTrigger code from Turaz org
    /* If the code appears below, it has not been integrated with the rest of the code in Misys.
    /*
        if(Trigger.isInsert)
    {
        CaseServices.updateUserLookupFromOwnerOnCase(Trigger.new);
    }
    else if(Trigger.isUpdate)
    {
        if(Trigger.isBefore)
        {
            CaseServices.updateUserLookupFromOwnerOnCase(Trigger.new);
        }
        else if(Trigger.isAfter)
            CaseServices.closeAndUpdateChildCases(Trigger.newMap, Trigger.oldMap);
    }
    /*
    /*
    /************************************/
    
     
}