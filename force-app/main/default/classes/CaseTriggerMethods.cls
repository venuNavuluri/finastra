public class CaseTriggerMethods
{
    // 30th August By Nitin
   public static void ChangedIssueCase(Case CaseNew,Case CaseoLD)
    {
        Boolean IsChanged = false;
        String NewParentStatus = '',NewCaseCategory = '',NewCSFECommentary = '',NewReplicationStepsForL3 = '',NewProductModule = '',NewPriority = '';
        String NewProductVersion = '',NewDescription = '',NewSubject = '',NewFixType = '',NewFixDetails = '',NewProductName = '';
        

        String OldParentStatus = '',OldCaseCategory = '',OldCSFECommentary = '',OldReplicationStepsForL3 = '',OldProductModule = '',OldPriority = '';
        String OldProductVersion = '',OldDescription = '',OldSubject = '',OldFixType = '',OldFixDetails = '',OldProductName = '';
        
        String strTable = '';
        
        if(CaseNew.CSFE_Parent_Status__c != null)
            NewParentStatus = CaseNew.CSFE_Parent_Status__c;
        if(CaseOld.CSFE_Parent_Status__c != null)
            OldParentStatus = CaseOld.CSFE_Parent_Status__c;        
        if(NewParentStatus != OldParentStatus)
        {
            IsChanged = true;
            strTable += '<tr> <td>CSFE Parent Status</td> <td>'+ NewParentStatus + '</td><td>'+ OldParentStatus + '</td> </tr>';
        } 
            
        if(CaseNew.Case_Category__c != null)
            NewCaseCategory = CaseNew.Case_Category__c;
        if(CaseOld.Case_Category__c != null)
            OldCaseCategory = CaseOld.Case_Category__c;     
        if(NewCaseCategory != OldCaseCategory)
        {
            IsChanged = true;
            strTable += '<tr> <td>Case Category</td> <td>'+ NewCaseCategory + '</td><td>'+ OldCaseCategory + '</td> </tr>';
        }
        
        if(CaseNew.SFDC_CSFE_Commentary__c != null)
            NewCSFECommentary = CaseNew.SFDC_CSFE_Commentary__c;
        if(CaseOld.SFDC_CSFE_Commentary__c != null)
            OldCSFECommentary = CaseOld.SFDC_CSFE_Commentary__c;        
        if(NewCSFECommentary != OldCSFECommentary)
        {
            IsChanged = true;
            strTable += '<tr> <td>SFDC-CSFE Commentary</td> <td>'+ NewCSFECommentary + '</td><td>'+ OldCSFECommentary + '</td> </tr>';
        }
            
        if(CaseNew.Replication_Steps__c != null)
            NewReplicationStepsForL3 = CaseNew.Replication_Steps__c;
        if(CaseOld.Replication_Steps__c != null)
            OldReplicationStepsForL3 = CaseOld.Replication_Steps__c;        
        if(NewReplicationStepsForL3 != OldReplicationStepsForL3)
        {
            IsChanged = true;
            strTable += '<tr> <td>Replication steps for L3</td> <td>'+ NewReplicationStepsForL3 + '</td><td>'+ OldReplicationStepsForL3 + '</td> </tr>';
        }
        
        if(CaseNew.Self_Service_Product__c != null)
            NewProductName = CaseNew.Self_Service_Product__c;
        if(CaseOld.Self_Service_Product__c != null)
            OldProductName = CaseOld.Self_Service_Product__c;       
        if(NewProductName != OldProductName)
        {
            IsChanged = true;
            strTable += '<tr> <td>Product</td> <td>'+ NewProductName + '</td><td>'+ OldProductName + '</td> </tr>';
        }
        
        if(CaseNew.Product_Module__c != null)
            NewProductModule = CaseNew.Product_Module__c;
        if(CaseOld.Product_Module__c != null)
            OldProductModule = CaseOld.Product_Module__c;       
        if(NewProductModule != OldProductModule)
        {
            IsChanged = true;
            strTable += '<tr> <td>Product Module</td> <td>'+ NewProductModule + '</td><td>'+ OldProductModule + '</td> </tr>';
        }
        
        if(CaseNew.Priority != null)
            NewPriority = CaseNew.Priority;
        if(CaseOld.Priority != null)
            OldPriority = CaseOld.Priority;     
        if(NewPriority != OldPriority)
        {
            IsChanged = true;
            strTable += '<tr> <td>Priority</td> <td>'+ NewPriority + '</td><td>'+ OldPriority + '</td> </tr>';
        }
        
        if(CaseNew.Product_Version__c != null)
            NewProductVersion = CaseNew.Product_Version__c;
        if(CaseOld.Product_Version__c != null)
            OldProductVersion = CaseOld.Product_Version__c;     
        if(NewProductVersion != OldProductVersion)
        {
            IsChanged = true;
            strTable += '<tr> <td>Product Version</td> <td>'+ NewProductVersion + '</td><td>'+ OldProductVersion + '</td> </tr>';
        }
        
        if(CaseNew.Description != null)
            NewDescription = CaseNew.Description;
        if(CaseOld.Description != null)
            OldDescription = CaseOld.Description;       
        if(NewDescription != OldDescription)
        {
            IsChanged = true;
            strTable += '<tr> <td>Description</td> <td>'+ NewDescription + '</td><td>'+ OldDescription + '</td> </tr>';
        }
        
        if(CaseNew.Subject != null)
            NewSubject = CaseNew.Subject;
        if(CaseOld.Subject != null)
            OldSubject = CaseOld.Subject;       
        if(NewSubject != OldSubject)
        {
            IsChanged = true;
            strTable += '<tr> <td>Subject</td> <td>'+ NewSubject + '</td><td>'+ OldSubject + '</td> </tr>';
        }
        
        if(CaseNew.Resolution_Type__c != null)
            NewFixType = CaseNew.Resolution_Type__c;
        if(CaseOld.Resolution_Type__c != null)
            OldFixType = CaseOld.Resolution_Type__c;        
        if(NewFixType != OldFixType)
        {
            IsChanged = true;
            strTable += '<tr> <td>Fix Type</td> <td>'+ NewFixType + '</td><td>'+ OldFixType + '</td> </tr>';
        }
        
        if(CaseNew.Resolution_Details__c != null)
            NewFixDetails = CaseNew.Resolution_Details__c;
        if(CaseOld.Resolution_Details__c != null)
            OldFixDetails = CaseOld.Resolution_Details__c;      
        if(NewFixDetails != OldFixDetails)
        {
            IsChanged = true;
            strTable += '<tr> <td>Fix Details</td> <td>'+ NewFixDetails + '</td><td>'+ OldFixDetails + '</td> </tr>';
        }
        IF(IsChanged == true)
        {
            List<Case> lParentCase = [Select c.OwnerId,c.Issue_Case__r.Id, c.Issue_Case__c, c.Id From Case c where Issue_Case__c =: CaseNew.Id];
            Set<ID> uniqueOwnerIds = new Set<ID>();
            Set<ID> uniqueQueueIds = new Set<ID>();
            if(String.valueOf(CaseNew.OwnerId).startsWith('005'))
                uniqueOwnerIds.add(CaseNew.OwnerId);
            else
                uniqueQueueIds.add(CaseNew.OwnerId);
            if(lParentCase != null && lParentCase.size() > 0)
            {
                if(lParentCase[0].OwnerId != null)
                {
                    if(String.valueOf(lParentCase[0].OwnerId).startsWith('005'))
                        uniqueOwnerIds.add(lParentCase[0].OwnerId);
                    else
                        uniqueQueueIds.add(lParentCase[0].OwnerId);
                }
            }
            
            //Get the Issue Case Owner name
            String CaseOwnerName;
            List<User> lCaseOwnerUser;
            List<Group> lCaseOwnerGroup;
            if(String.ValueOf(CaseNew.OwnerId).startsWith('005'))
            {
            	lCaseOwnerUser = [select Name from User where Id =: CaseNew.OwnerId LIMIT 1];
            	CaseOwnerName = lCaseOwnerUser[0].Name;
            }
            else
            {
            	lCaseOwnerGroup = [select Name from Group where Id =: CaseNew.OwnerId LIMIT 1];
            	CaseOwnerName = lCaseOwnerGroup[0].Name;
            }
            system.debug('CaseOwnerName = '+CaseOwnerName);
            //JRB 16 Jun 2011: Instead of emailing every member of a queue, only send email to the queue email address.
            //Map<ID,GroupMember> queueToGroupMember = null;
            //if(uniqueQueueIds.size() > 0)
            //    queueToGroupMember = new Map<ID,GroupMember>([Select g.UserOrGroupId, g.GroupId From GroupMember g where GroupId in: uniqueQueueIds]);
            //if(queueToGroupMember != null)
            //{
            //    for(GroupMember GM:queueToGroupMember.values())
            //        uniqueOwnerIds.add(GM.UserOrGroupId);
            //}
            Map<Id,Group> queueToGroup = null;
            String[] toAddresses = new String[]{};
            if(uniqueQueueIds.size() > 0) 
            	queueToGroup = new Map<Id,Group>([Select Id, Email from Group where Id in :uniqueQueueIds]);
            if(queueToGroup != null)
            {
            	for(Group g : queueToGroup.values())
            	{
            		if(g.Email != null)
            		{
            			toAddresses.add(g.Email);
            		}else{
            			toAddresses.add(Label.Case_Update_Default_Email);
            		}
            	}
            }
            if(uniqueOwnerIds.size() > 0)
            {
                List<User> lUser = [Select u.IsActive, u.Id, u.Email,u.Name From User u where IsActive = true and id in: uniqueOwnerIds and Email != null];
                if(lUser != null)
                {                   
                    for(User U:lUser)
                    {
                        if(U.Id != Label.ALM_Integration_User_ID)
                            toAddresses.add(U.Email);
                    }
                }
                if(toAddresses.size() > 0)
                    SendEMail(CaseNew,CaseOwnerName, toAddresses,strTable);
            }
        }
    } 
 
    public static void SendEMail(Case CaseNew,String caseOwner, String[] toAddresses,String strTbl)
    {
        System.debug('Nitin--->'+toAddresses);
        //Messaging.MassEmailMessage
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //String[] toAdd = new String[] {'nitin-g@hcl.com'};
        mail.setToAddresses(toAddresses);
        //mail.setToAddresses(toAdd);
        mail.setSubject(caseOwner + ' - Issue Case ' + CaseNew.CaseNumber + ' has been updated');
        mail.setSenderDisplayName('SFDC Banking');
        String strHTML = '';
        strHTML = 'This is to alert you that there has been a change to Issue Case <b>'
                + CaseNew.CaseNumber + '</b> with subject <b>' + CaseNew.Subject + '</b>.';
        strHTML += '<br /><br />The following field values have changed.';
        strHTML += '<br /><br />';
        strHTML += '<table border=1 width=50%>';
        strHTML += '<tr> <td><b>Bidirectional fields</b></td>';
        strHTML += ' <td><b>NEW Value</b></td>';
        strHTML += ' <td><b>OLD Value</b></td> </tr>';
        strHTML += strTbl;
        strHTML += '</table>';
        strHTML += '<br /><br /><br />More details can be accessed at <a href=' + Label.Domain_URL + '/' + CaseNew.Id + '>' + Label.Domain_URL + '/' + CaseNew.Id + '</a> (link to the Issue Case ID)';
        strHTML += '<br /><br /><br />This is an automatically generated email. Please do not reply to it.';
        mail.setHtmlBody(strHTML);
        try{
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }catch(Exception e){
        	system.debug('Error sending email: '+e);
        }
        SFDC_CSFE_Controller.preventTriggersWhenSendingMail = true;
    }
 
    
    // SS: 05-March-2010 - Added this static field to query the business hours in use once
    public static Map<ID,Business_Hours_in_Use__c> mapBusinessHoursInUse_Static;
    
    ///////////////////////////////////////////////////////////
    // ALM Methods - Saaspoint 6/18/09
    ///////////////////////////////////////////////////////////

   //AC 9/3/09 - For a given issue case being created by CSFE, find the customer and client offset values
   //            This method will not run for any other cases than those created by CSFE integration user
    
   public static void getOffsets(List<Case> newRecs) {
     
     Set<String> externalSourceIDs = new Set<String>();

     // Put the key (external ID source + external ID) into a Set so that we can read all ALM records in one go      
     for (Case loopCase : newRecs) {
        if (loopCase.external_id__c != null && loopCase.external_id_source__c != null) {
            externalSourceIDs.add(loopCase.external_id_source__c + loopCase.external_id__c);
        }
     }

     // Read the ALM offset records and put them into a map.
     Map<String, ALM_External_Count_Offset__c> offsetMap = new Map<String, ALM_External_Count_Offset__c>();
     for (ALM_External_Count_Offset__c offsetLoop : [SELECT external_source_id_concatenated__c, call_count_offset__c, client_count_offset__c FROM ALM_External_Count_Offset__c WHERE external_source_id_concatenated__c IN :externalSourceIDs]) {
       offsetMap.put(offsetLoop.external_source_id_concatenated__c, offsetLoop);    
     }

     // For each case, lookup the offsets from the map created above
     for (Case loopCase : newRecs) {
        if (loopCase.external_id__c != null && loopCase.external_id_source__c != null) {
            ALM_External_Count_Offset__c alm = offsetMap.get(loopCase.external_id_source__c + loopCase.external_id__c);
            if (alm != null) {
                loopCase.customer_count_offset__c = alm.client_count_offset__c;
                loopCase.case_count_offset__c   = alm.call_count_offset__c;
            }
        }
     }
   }
    /*
        Code has been written by HCL team to invoke the web service method.
        Web service calculates the time object values.  
    */
    //JRB 2011-03-11 Removed @future notation and moved @Future call to CaseFuture class 
    //@ future
    public static void CallWebServiceMethod(List<ID> lCaseId)
    {
        TimeCalculator.CalculateTimesNew(lCaseId);
    }

   //AC 9/3/09 - For a given issue case being created by CSFE, find the customer and client offset values
   //            This method will not run for any other cases than those created by CSFE integration user
   //            This method runs after insert, so that we have the Issue Case ID
   //            All related customer cases will be updated with the Issue Case ID which will rerun the triggers to recalculate the counts on the issue case itself
   //            Note - some trigger firing will be disabled on this later update by use of the preventTriggersWhenUpdatingCCfromIC flag 

   public static void attachAssociatedCases(List<Case> newRecs) {

     Set<String> externalSourceIDs = new Set<String>();
     Map<String, String> issueCaseIDs = new Map<String, String>();
     
     // Loop through all incoming cases to find their external ID and external ID source.
     // Put them into a set to allow us to read all the lookup values in one go
     // Put the issue case id into a map indexed by external ID and external Source for use later
     for (Case loopCase : newRecs) {
        if (loopCase.external_id__c != null && loopCase.external_id_source__c != null) {
            externalSourceIDs.add(loopCase.external_id_source__c + loopCase.external_id__c);
            issueCaseIDs.put(loopCase.external_id_source__c + loopCase.external_id__c, loopCase.id);
        }
     }

     List<Case> customerCasesToUpdate = new List<Case>();
     
     // Loop through all ALM records that are referenced by the externalSourceIDs captured above
     for (ALM_External_Customer_Case__c loopALM : [SELECT id, External_Source_ID_Concatenated__c, customer_case__r.issue_case__c FROM ALM_External_Customer_Case__c WHERE External_Source_ID_Concatenated__c IN :externalSourceIDs]) {
       
       // get the Issue Case ID from the map we built earlier
       String issueCaseID = issueCaseIDs.get(loopALM.External_Source_ID_Concatenated__c);
       
       // if we found an issue case ID, then stamp it onto the customer case and place into List for update
       if (issueCaseID != null) {
          Case customerCase = loopALM.customer_case__r;
          // AC 11/13/09 - only attempt to set issue_case__c if the customerCase != null
          if (customerCase != null) {
            customerCase.issue_case__c = issueCaseID;
            customerCasesToUpdate.add(customerCase);          
          }
       }
     }      
    
     // Update the list of customer cases, but make sure that the triggers don't fire 
     // by setting the preventTriggersWhenUpdatingCCfromIC flag.
     // The only triggers that should fire will be for recalculating the customer counts.
     // This will update the issue cases and unfortunately, will fire the triggers again - but because they are not customer
     // cases, no action will be taken.
     SFDC_CSFE_Controller.preventTriggersWhenUpdatingCCfromIC = true;
     update customerCasesToUpdate;
     SFDC_CSFE_Controller.preventTriggersWhenUpdatingCCfromIC = false;
    
   }


    // AC 7/31/09 - Add a case comment for the sfdc_csfe_commentary for each case passed in -- this is instead of using field history tracking
    public static void createCaseCommentForCommentary(List<Case> newRecs, Map<ID, Case> caseMapOld, boolean isInsert) {
     try {      
      // Get the integration user ID
      ID integrationUserID = Label.ALM_Integration_User_ID;
      List<CaseComment> caseCommentsToInsert = new List<CaseComment>();
      
      if (!SFDC_CSFE_Controller.CSFECommentaryRunning) {
                
        SFDC_CSFE_Controller.CSFECommentaryRunning = true;

        for (Case c : newRecs) {
          
          if (userInfo.getUserId() == integrationUserID) {
          
            Case origCase = new Case(sfdc_csfe_Commentary__c=null);
            if (!isInsert) {
              origCase = caseMapOld.get(c.id);
            }
        
            // If incoming commentary is blank but there is a prior value, then write a history record for the PRIOR value
            if (c.sfdc_csfe_commentary__c == null && origCase.sfdc_csfe_commentary__c != null) {
              caseCommentsToInsert.add(new CaseComment(commentbody=origCase.sfdc_csfe_commentary__c, parentID=c.id));
            }
          
            // If incoming commentary is not blank and there is no prior value, then write a history record for the CURRENT VALUE
            if (c.sfdc_csfe_commentary__c != null && origCase.sfdc_csfe_commentary__c == null) {
              caseCommentsToInsert.add(new CaseComment(commentbody=c.sfdc_csfe_commentary__c, parentID=c.id));
              c.SFDC_CSFE_Commentary__c = null;
            }

            // If incoming commentary is not blank but there is a prior value that is different, then write a history record for both the PRIOR VALUE and the CURRENT VALUE
            if (c.sfdc_csfe_commentary__c != null && origCase.sfdc_csfe_commentary__c != null && c.sfdc_csfe_commentary__c != origCase.SFDC_CSFE_Commentary__c) {
              caseCommentsToInsert.add(new CaseComment(commentbody=origCase.sfdc_csfe_commentary__c, parentID=c.id));
              caseCommentsToInsert.add(new CaseComment(commentbody=c.sfdc_csfe_commentary__c, parentID=c.id));
              c.SFDC_CSFE_Commentary__c = null;
            }
        
          } else {
            
            String commentPrefix = Label.comment_for_L3 + ' ' + userInfo.getFirstName() + ' ' + userInfo.getLastName();
            if (c.SFDC_CSFE_Commentary__c != null && c.SFDC_CSFE_Commentary__c.indexOf(commentPrefix) != 0)  {
                c.SFDC_CSFE_Commentary__c = commentPrefix + '\r\n' + c.SFDC_CSFE_Commentary__c;
            }
            
          }
        }
        insert caseCommentsToInsert;
//        SFDC_CSFE_Controller.CSFECommentaryRunning = false;     
      }
      
     } catch (Exception e) {
//        SFDC_CSFE_Controller.CSFECommentaryRunning = false;     
        throw e;
     } 
    }

    // AC 7/31/09 - Add a case comment for the sfdc_csfe_commentary for each case passed in -- this is instead of using field history tracking
    public static void createCaseCommentForCommentaryInsert(List<Case> newRecs) {

      if (!SFDC_CSFE_Controller.CSFECommentaryRunning) {
                
        SFDC_CSFE_Controller.CSFECommentaryRunning       = true;

        ID integrationUserID = Label.ALM_Integration_User_ID;

        if (userInfo.getUserID() == integrationUserID) {
        
          Set<String> caseIDs = new Set<String>();
          for (Case c : newRecs) {
            caseIDs.add(c.id);
          }
          createCaseCommentForCommentaryFuture(caseIDs);

        }
      }
    }
    
    @future
    public static void createCaseCommentForCommentaryFuture(Set<String> newRecs) {
      
      //Set the flag that this is running asynchronously 
      GlobalVar.bInFuture = true;
      
      if (!SFDC_CSFE_Controller.CSFECommentaryRunning) {
                
        SFDC_CSFE_Controller.CSFECommentaryRunningFuture = true;
        SFDC_CSFE_Controller.CSFECommentaryRunning = true;

        // Get the integration user ID
        List<Case> cases = [SELECT id, sfdc_csfe_commentary__c FROM case WHERE id IN :newRecs];
        List<CaseComment> caseCommentsToInsert = new List<CaseComment>();
      

        for (Case c : cases) { 
          
            // If incoming commentary is not blank and there is no prior value, then write a history record for the CURRENT VALUE
            if (c.sfdc_csfe_commentary__c != null ) {
              caseCommentsToInsert.add(new CaseComment(commentbody=c.sfdc_csfe_commentary__c, parentID=c.id));
              c.SFDC_CSFE_Commentary__c = null;
            }
        
        }
        if(cases.size() > 0) 
            update cases;
        if(caseCommentsToInsert.size() > 0)
            insert caseCommentsToInsert;
      
      }
    }


// AC - @future removed - needs to be synchronous for the migration utility 
public static void caseCounts(Set<Id> issueCaseIds) {
    
    SFDC_CSFE_Controller.CSFEtransactionUpdateRunning = true; // never allow CSFE Transaction Type update on this future call - it will already run for the update that triggered this call. AC 7/28

    // List of cases to update
    List<Case> updateCases = new List<Case>();
        
    // Pull back the account id for all customer cases associated with these issue cases
    List<Case> attachedCases = new List<Case>([Select AccountId, Issue_Case__c From Case Where Issue_Case__c in :issueCaseIds]);
    
    // Iterate through the issue case ids, calculating the counts for each one
    for (Id issueCaseId : issueCaseIds) {
        Set<Id> accountsForIssueCase = new Set<Id>();
        Integer callCount = 0;
        
        // Iterate through the customer calls counting the matches
        for (Case customerCase : attachedCases) {
            
            // Check if it hangs off our issue case
            if (customerCase.Issue_Case__c == issueCaseId) {
                
                // Add the account id to the set
                accountsForIssueCase.add(customerCase.AccountId);
                
                // Increment the call count for this issue case
                callCount++;
            } // end check for matching case if
        } // end iterate through customer cases for
        
        // Create the record for updating
        updateCases.add(new Case(Id = issueCaseId, Client_Count_Calculated__c = accountsForIssueCase.size(), Call_Count_Calculated__c = callCount));
    } // end iterate through the issue case ids for
    
    // Update issue cases with the new counts
    if (!updateCases.isEmpty()) update updateCases;
} // end caseCounts
 
    // AC 7/29/09 - Added updateCSFETransaction to update the CSFE_TRANSACTION__C field to either insert or update
    public static void updateCSFETransaction(List<Case> newRecs, Map<ID, Case> caseMapOld, boolean isInsert) {
      
      if (!SFDC_CSFE_Controller.CSFEtransactionUpdateRunning) { // prevent from running this update if already 
        
        SFDC_CSFE_Controller.CSFEtransactionUpdateRunning = true;
        
        for (Case incomingCase : newRecs) {
          
          Case origCase;
          if (caseMapOld != null) {
            origCase = caseMapOld.get(incomingCase.id);
          }

          if ((incomingCase.CSFE_Sync_Result__c != null && origCase != null && origCase.CSFE_Sync_Result__c == null) ||
              (isInsert && incomingCase.CSFE_Sync_Result__c != null)) {
             incomingCase.CSFE_Transaction_Type__c = 'Insert';  
          } else if (incomingCase.CSFE_Transaction_Type__c == 'Insert'){
             incomingCase.CSFE_Transaction_Type__c = 'Update';
          }
        }
      }
    }

    // AC 7/31/09 - added for CSFE integration
    public static void updatePrioritySeverity(List<Case> newRecs, Map<ID,Case> caseMapOld, boolean isInsert, boolean isUpdate) {
      
      // CSFE uses CSFE_Priority_Severity to record severity. 
      // This field exists on both Banking and Allscripts.
      
      // In Banking - this previously mapped to Priority, but is now Severity__c. This method keeps the two in synch
      
      // In Allscripts - this needs to map to Severity__c.
      
      boolean currentUserIsIntegrationUser = userInfo.getUserID().substring(0,15) == Label.ALM_Integration_User_ID.substring(0,15);
                    
      for (Case currentCase : newRecs) {

        Case oldCase;
        if (isUpdate) {
          oldCase = caseMapOld.get(currentCase.id);
        }
		
        // If priority hasn't changed and CSFE_Priority_Severity has, then this is an update
        // from CSFE, so update the priority. 
        //if (isUpdate && currentCase.Priority == oldCase.Priority &&
        if (isUpdate && currentCase.Severity__c == oldCase.Severity__c &&
            currentCase.CSFE_Priority_Severity__c != oldCase.CSFE_Priority_Severity__c) 
        {
          currentCase.Priority = currentCase.CSFE_Priority_Severity__c;     
          currentCase.Severity__c = CaseServices.getSeverityForPriority(currentCase.CSFE_Priority_Severity__c);
        }      

        // If Priority has changed and CSFE_Priority_Severity hasn't, then this is an update
        // in Salesforce, so update the CSFE_Priority_Severity (OR its an insert but user IS NOT INTEGRATION USER)
        //if ((!currentUserIsIntegrationUser && isInsert) || 
        //     (isUpdate && currentCase.Priority != oldCase.Priority && currentCase.CSFE_Priority_Severity__c == oldCase.CSFE_Priority_Severity__c)) 
		if ((!currentUserIsIntegrationUser && isInsert) || 
             (isUpdate && currentCase.Severity__c != oldCase.Severity__c && currentCase.CSFE_Priority_Severity__c == oldCase.CSFE_Priority_Severity__c))             
        {
          currentCase.CSFE_Priority_Severity__c = CaseServices.getPriorityFromSeverity(currentCase.Severity__c);
        }      

        // If the record is being inserted by the integration user, then use the CSFE_Priority_Severity field to set the Severity field.
        if (currentUserIsIntegrationUser && isInsert) {
           currentCase.Severity__c = CaseServices.getSeverityForPriority(currentCase.CSFE_Priority_Severity__c);
           currentCase.Priority = currentCase.CSFE_Priority_Severity__c;
        }


      }
    }  


    // AC 7/31/09 - added for CSFE integration
    public static void updateProduct(List<Case> newRecs, Map<ID,Case> caseMapOld, boolean isInsert, boolean isUpdate) {
      
      // CSFE uses CSFE_Product to record the product name. 
      // This field exists on both Banking and Allscripts.
      
      // In Banking - this maps to Self Service Product. This method keeps the two in synch
      
      // In Allscripts - this needs to map to Select_A_Product__c.
      
      boolean currentUserIsIntegrationUser = userInfo.getUserID().substring(0,15) == Label.ALM_Integration_User_ID.substring(0,15);
                    
      for (Case currentCase : newRecs) {

        Case oldCase;
        if (isUpdate) {
          oldCase = caseMapOld.get(currentCase.id);
        }

        // If Select A Product hasn't changed and CSFE_Product has, then this is an update
        // from CSFE, so update the Select A Product. 
        if (isUpdate && currentCase.Self_Service_Product__c == oldCase.Self_Service_Product__c &&
            currentCase.CSFE_Product__c != oldCase.CSFE_Product__c) 
        {
          currentCase.Self_Service_Product__c = currentCase.CSFE_Product__c;     
        }      

        // If Select A Product has changed and CSFE_Product hasn't, then this is an update
        // in Salesforce, so update the CSFE_Product
        // OR if the record is being inserted but not by the Integration User i.e. in Salesforce
        if ((!currentUserIsIntegrationUser && isInsert) || 
             (isUpdate && currentCase.Self_Service_Product__c != oldCase.Self_Service_Product__c && currentCase.CSFE_Product__c == oldCase.CSFE_Product__c)) 
        {
          currentCase.CSFE_Product__c = currentCase.Self_Service_Product__c;
        }      

        // If the record is being inserted by the integration user, then use the CSFE_Product field to set the Select A Product field.
        if (currentUserIsIntegrationUser && isInsert) {
           currentCase.Self_Service_Product__c = currentCase.CSFE_Product__c;
        }

      }
    }  

    // AC 7/31/09 - added for CSFE integration
    public static void updateProductVersion(List<Case> newRecs, Map<ID,Case> caseMapOld, boolean isInsert, boolean isUpdate) {
      
      // CSFE uses CSFE_Product_Version to record the product version 
      // This field exists on both Banking and Allscripts.
      
      // In Banking - this maps to Product_Version. This method keeps the two in synch
      
      // In Allscripts - this needs to map to Current_Revision__c.
      
      boolean currentUserIsIntegrationUser = userInfo.getUserID().substring(0,15) == Label.ALM_Integration_User_ID.substring(0,15);

      for (Case currentCase : newRecs)
      {
        System.debug('Nitin---1>'+currentCase.Product_Version__c);
        Case oldCase;
        if (isUpdate) {
          oldCase = caseMapOld.get(currentCase.id);
        }

        // If Current Revision hasn't changed and CSFE_Product Version has, then this is an update
        // from CSFE, so update the priority. 
        //if (isUpdate && currentCase.Description == oldCase.Product_Version__c &&
        if (isUpdate && currentCase.Product_Version__c == oldCase.Product_Version__c &&
            currentCase.CSFE_Product_Version__c != oldCase.CSFE_Product_Version__c) 
        {
          currentCase.Product_Version__c = currentCase.CSFE_Product_Version__c;     
        }      

        // If Current Revision has changed and CSFE_Product Version hasn't, then this is an update
        // in Salesforce, so update the CSFE_Product_Version. OR if its an insert BUT NOT THE INTEGRATION USER
        if ((!currentUserIsIntegrationUser && isInsert) || 
             (isUpdate && currentCase.Product_Version__c != oldCase.Product_Version__c && currentCase.CSFE_Product_Version__c == oldCase.CSFE_Product_Version__c)) 
        {
          currentCase.CSFE_Product_Version__c = currentCase.Product_Version__c;
        }      

        // If the record is being inserted by the integration user, then use the CSFE_Product_Version field to set the Current_Revision field.
        if (currentUserIsIntegrationUser && isInsert) {
           currentCase.Product_Version__c = currentCase.CSFE_Product_Version__c;
        }
        System.debug('Nitin---1>'+currentCase.Product_Version__c);
      }
    }  



    // AC 7/31/09 - added for CSFE integration - handled by formula field on MBS
    // public static void setCreatedName(List<Case> newRecs) {
    //   for (Case currentCase : newRecs) {
    //      currentCase.created_by_name__c        = userInfo.getFirstName() + ' ' + userInfo.getLastName();     
    //   }
    // }

    // AC 7/31/09 - added for CSFE integration - keeps Targeted Release date up-to-date on customer cases
    
   public static void updateTargetedReleaseDate(List<Case> newRecs, Map<ID,Case> caseMapOld, boolean isInsert, boolean isUpdate) {
      List<ID> targetIDs = new List<ID>();
      for (Case currentCase : newRecs) {
        if (currentCase.targeted_release_lookup__c != null) {
          targetIDs.add(currentCase.targeted_release_lookup__c);
        }
      }
      
      Map<ID, targeted_release__c> targetMap = new Map<ID, targeted_release__c>([SELECT id, scheduled_delivery_date__c, project_type__c FROM targeted_release__c WHERE id IN :targetIDs]);

      for (Case currentCase : newRecs) {
        Case oldCase;
        if (isUpdate) {
          oldCase = caseMapOld.get(currentCase.id);
        }
        if (currentCase.Targeted_Release_Lookup__c != null && (isInsert || oldCase.Targeted_Release_Lookup__c == null || currentCase.Targeted_Release_Lookup__c != oldCase.Targeted_Release_Lookup__c)) {
          Targeted_Release__c tr = targetMap.get(currentCase.targeted_release_lookup__c);

        // SS: 05-Nov-2009 : Remove the additional logic of checking Project type before updating Targeted Fix Date and replacing with a check (if the date is not already populated) 
        
        //if (tr.project_type__c != null && 
        //    tr.project_type__c != ''   &&
        //    tr.project_type__c != 'None' &&
        //    tr.project_type__c != 'Hotfix') 
                
          if(currentCase.Targeted_Fix_Date__c == null)
          {     
            currentCase.Targeted_Fix_Date__c = tr.scheduled_delivery_date__c;
          }
        }
      } 
    }
    
    
    // SS: 25-Nov-2009 :    This method populates the Client Specific Data field on Issue Case when a Customer Case either creates a new 
    //                      Issue Case OR an existing Issue Case is attached to a Customer Case.
    //                      In either scenario, the field on Issue case is populated in the following format
    //                      <Customer Case Number>\<<Customer Case ID>\<Account Name>\<Account Site>\<Product Version>
    public static void updateClientSpecificData(Map<ID,Case> caseMapNew, Map<ID,Case> caseMapOld) 
    {
        List<Case> lstCasesToProcess = new List<Case>();
        Set<ID> issueCaseIds = new Set<ID>();
        Set<ID> customerCaseIds = new Set<ID>();
            
        // Get all case records where the Issue Case field has been modified on the Customer Case.
        // This will happen where the Issue case is created or attached to the customer case
        // Also ensure that the Customer Case's Client Specific Delivery field value is 'Yes'
        for(Case c : caseMapNew.values())
        {
            if(caseMapOld != null && !caseMapOld.isEmpty())
            {
                if(caseMapOld.containsKey(c.Id) && c.Issue_Case__c != null && c.Issue_Case__c != caseMapOld.get(c.Id).Issue_Case__c && c.Client_Specific_Delivery__c == 'Yes')
                {
                    lstCasesToProcess.add(c);
                    
                    if(!issueCaseIds.contains(c.Issue_Case__c))
                        issueCaseIds.add(c.Issue_Case__c);
                    
                    if(!customerCaseIds.contains(c.Id))
                        customerCaseIds.add(c.Id);
                }
            }
            else if(caseMapOld == null)
            {
                if(c.Issue_Case__c != null && c.Client_Specific_Delivery__c == 'Yes')
                {
                    lstCasesToProcess.add(c);
                    
                    if(!issueCaseIds.contains(c.Issue_Case__c))
                        issueCaseIds.add(c.Issue_Case__c);
                    
                    if(!customerCaseIds.contains(c.Id))
                        customerCaseIds.add(c.Id);
                }
            }
        }
        
        if(lstCasesToProcess != null && lstCasesToProcess.size() > 0)
        {
            Map<ID,Case> mapIssueCases = new Map<ID,Case>([Select Id, Client_Specific_Data__c From Case where Id in :issueCaseIds]);
            Map<ID,Case> mapCustomerCases = new Map<ID,Case>([Select Id, CaseNumber, AccountId, Account.Name, Account.Site, Product_Version__c, Issue_Case__c From Case where Id in :customerCaseIds]);

            if(mapIssueCases != null && !mapIssueCases.isEmpty())
            {
                for(Case c : mapCustomerCases.values())
                {
                    if(c.Issue_Case__c != null)
                    {
                        if(mapIssueCases.containsKey(c.Issue_Case__c))
                        {
                            String clientSpecificData = mapIssueCases.get(c.Issue_Case__c).Client_Specific_Data__c;
                            
                            if(clientSpecificData == null)
                            {
                                clientSpecificData = '';
                            }
                            else
                            {
                                clientSpecificData += '\r\n';
                            }
                            
                            String accountSite = '';
                            if(c.account.site != null)
                                accountSite = c.account.site;

                            clientSpecificData += c.CaseNumber + '|' + c.Id + '|' + c.account.Name + '|' + accountSite + '|' + c.Product_Version__c;
                            mapIssueCases.get(c.Issue_Case__c).Client_Specific_Data__c = clientSpecificData;
                        }
                    }
                }
                
                update mapIssueCases.values();
            }
        }
    }   
    
    
    ///////////////////////////////////////////////////////////
    // END ALM Methods 
    ///////////////////////////////////////////////////////////

    
    /*
    public static void issueCaseChangeEmail(Map<ID,Case> updatedCases, Map<ID,Case> oldCases)
    {
        Map<ID, Case> modifiedCases = new Map<ID, Case>();

        RecordType issueRecordType = [select Id, Name from RecordType where Name = 'Issue'];
        
        //Get the list of issue cases where the following fields have been modified
        // SFDC-CSFE Commentary
        // Subject
        // Description
        // Replication Steps
        for(Case updatedCase : updatedCases.values())
        {
            boolean bModified = false;
            
            if(updatedCase.RecordTypeId == issueRecordType.Id)
            {
                if(updatedCase.Subject != oldCases.get(updatedCase.Id).Subject)
                {
                    bModified = true;
                }
                if(updatedCase.Description != oldCases.get(updatedCase.Id).Description)
                {
                    bModified = true;
                }
                if(updatedCase.SFDC_CSFE_Commentary__c != oldCases.get(updatedCase.Id).SFDC_CSFE_Commentary__c)
                {
                    bModified = true;
                }
                if(updatedCase.Replication_Steps__c != oldCases.get(updatedCase.Id).Replication_Steps__c)
                {
                    bModified = true;
                }
                
                if(bModified == true)
                {
                    modifiedCases.put(updatedCase.Id, updatedCase);     
                }
            }
        }
        
        if(!modifiedCases.isEmpty())
        {
            List<Case> lstCustomerCases = [select Id, Issue_Case__c, Owner.Email from Case where Issue_Case__c in :modifiedCases.keySet()];
            
            if(lstCustomerCases.size() > 0)
            {
                for(Case customerCase : lstCustomerCases)
                {
                    String sEmail = customerCase.Owner.Email;
                    
                    Case issueCase = modifiedCases.get(customerCase.Issue_Case__c);
                    
                    String sSubject = issueCase.Subject;
                    String sDescription = issueCase.Description;
                    String sCommentary = issueCase.SFDC_CSFE_Commentary__c;
                    String sReplicationSteps = issueCase.Replication_Steps__c;
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[]{sEmail};
                    mail.setToAddresses(toAddresses);
                    mail.setSubject('Notification: Issue Case Details Changed');
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    string MsgBody='';

                    MsgBody=MsgBody+'<br><br>This is an automatic email notification from Salesforce. <br><br>Following change(s) have been observed:<br>';
                    
                    Case oldIssueCase = oldCases.get(issueCase.Id);
                    
                    if(issueCase.Subject != oldIssueCase.Subject)
                    { 
                        MsgBody=MsgBody+ '<br>Subject <b>' + issueCase.Subject +'</b>';
                    }
                    
                    if(issueCase.Description != oldIssueCase.Description)
                    { 
                        MsgBody=MsgBody+ '<br>Description <b>' + issueCase.Description +'</b>';
                    }
                    
                    if(issueCase.SFDC_CSFE_Commentary__c != oldIssueCase.SFDC_CSFE_Commentary__c)
                    { 
                        MsgBody=MsgBody+ '<br>SFDC CSFE Commentary <b>' + issueCase.SFDC_CSFE_Commentary__c +'</b>';
                    }
                    
                    if(issueCase.Replication_Steps__c != oldIssueCase.Replication_Steps__c)
                    { 
                        MsgBody=MsgBody+ '<br>Replication Steps <b>' + issueCase.Replication_Steps__c +'</b>';
                    }
                    
                    mail.setHtmlBody(MsgBody);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }  
            }           
        }
    }
    */
    
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                                                                           //
    //                                  PSP METHODS                                              //
    //                                                                                           //
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    // Code added by Salman on 09-Mar-2009
    // Code updated by Jason on 12-Jul-2011
    //		Changed RT exclusion list to come from a label instead of running a SOQL query
    //		Changed the addition of the Time Object to be done by creating a separate instance of the new case and running an Update.  The 
    //			original newCase record (part of trigger.new) is read-only since it has already been saved.
    // Code update by Jason on 21-Jul-2011
    //		FIXED PROBLEM from previous update.  If the case is updated before the initial insert operation is complete, it resets the flag set to 
    //			send email notification to the case contact.  DO NOT UPDATE Case again within the After trigger
    //		Changed the code to run the update of the Time Object on the new case to a Future update
    //
    public static void CreateTimeObjectForNewCase(List<Case> newCases)
    {
        List<Time_Object__c> newTimeObjects = new List<Time_Object__c>();        
        
        //Get the list of case Record types that should not have an associated Time Object
        Set<String> setRTexclusions = new Set<String>(); 
        setRTexclusions.addAll(Label.Case_TimeObject_RecType_Exclusions.split(','));
        
        //Loop through the new cases and create the new Time Object as needed
        for(Case newCase : newCases)
        {
            System.debug('newCase.Id : ' + newCase.Id); 
            
            if(!setRTexclusions.contains(newCase.RecordTypeId))
            {       
            	newTimeObjects.add(new Time_Object__c(Case__c=newCase.Id));
            }
        }
        insert newTimeObjects;

		//Build a set of the new Time Object Ids
		Set<Id> newTimeObjectIds = new Set<Id>();
		for(Time_Object__c t : newTimeObjects)
		{
			newTimeObjectIds.add(t.Id);
		}
		
		//Call the method to update the Time Object field on the new case(s)
		CaseFuture.callFuture_CallSetTimeObjectOnCase(newTimeObjectIds);

		/*
		// Loop back through the new Time Objects to get the new Id's associated to the cases
		Map<Id,Id> mapCasetoTimeObject = new Map<Id,Id>();
		for(Time_Object__c t : newTimeObjects)
		{
			mapCaseToTimeObject.put(t.Case__c,t.Id);
		}

        //Now, loop through the cases, create a copy of the case, and run the update on the case
		List<Case> casesToUpdate = new List<Case>();
		Case c;
        for(Case newCase : newCases)
        {
            if(mapCasetoTimeObject.containsKey(newCase.Id))
            {
            	if(!setRTexclusions.contains(newCase.RecordTypeId))
            	{       
					c = newCase.clone(true);
                    c.Time_Object__c = mapCaseToTimeObject.get(newCase.Id);
                    casesToUpdate.add(c);
               	}
            }
        }
        update casesToUpdate;              
        System.debug('casesToUpdate : ' + casesToUpdate);
        */
    }
    
    public static void SetTimeObjectOnCase(Set<Id> TimeObjectIds)
    {
    	//Code created by Jason on 21-Jul-2011
    	//		The update to the Time_Object__c field on Case must be run as a @Future update.  The new Id for the created Time Object is 
    	//			not available until the After trigger, during with no updates can be made to Case fields.  
    	
    	//run SOQL to get Time Object records
    	List<Time_Object__c> newTimeObjects = [select Id, Case__c from Time_Object__c where Id in :TimeObjectIds];
    	
    	//get a list of CaseIds from the Time Objects
    	Map<Id,Id> mapCaseIdToTimeObjectId = new Map<Id,Id>();
    	for(Time_Object__c t : newTimeObjects)
    	{
    		mapCaseIdToTimeObjectId.put(t.Case__c,t.Id);
    	}
    	
    	//run SOQL to get Case records
    	List<Case> casesToUpdate = [select Id, Time_Object__c from Case where Id in :mapCaseIdToTimeObjectId.keySet()];
    	
    	//for each Case, update the Time Obejct field
    	for(Case c : casesToUpdate)
    	{
    		c.Time_Object__c = mapCaseIdToTimeObjectId.get(c.Id);
    	}
    	
    	//Update the Case objects in the database
    	try
    	{
    		update casesToUpdate;
    	}
    	catch(Exception e)
    	{
    		system.debug('Error in SetTimeObjectOnCase: '+e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
    		ScheduledCommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),'Apex Error in Case Future job','CaseTriggerMethods.SetTimeObjectOnCase',e);
    	}
    }
    
    /*
    public static void SetCaseElapsedTime(List<Case> updatedCases, PSPHelper pspHelper)
    {
        System.debug('in SetCaseElapsedTime');
        //Create a unique list of caseIDs
        Set<ID> uniqueTimeObjectIDs = new Set<ID>();

        for(Case updatedCase: updatedCases)
        {
            if(updatedCase != null)
            {
                System.debug('updatedCase : ' + updatedCase);
                System.debug('updatedCase.IsClosed : ' + updatedCase.IsClosed);
                System.debug('updatedCase.Time_Object__c : ' + updatedCase.Time_Object__c);

                uniqueTimeObjectIDs.add(updatedCase.Time_Object__c);
            }
        }
        
        if(uniqueTimeObjectIDs.size() > 0)
        {
            Map<ID,Time_Object__c> uniqueTimeObjects = new Map<ID,Time_Object__c>([Select t.Elapsed_Time__c from Time_Object__c t where t.Id in :uniqueTimeObjectIDs]);

            System.debug('uniqueTimeObjects : ' + uniqueTimeObjects);
            
            TimeCalculator.PerformCalculation(updatedCases, 'Elapsed', uniqueTimeObjects, pspHelper.getMapSLA(), pspHelper.getMapAccountSLA_BH(), pspHelper.getMapBusinessHours(), pspHelper.getGlobalBH(), pspHelper.getMapCSM(), pspHelper.getMapCaseIdCaseHistory());

            update uniqueTimeObjects.values();
            System.debug('uniqueTimeObjects : ' + uniqueTimeObjects);
        }
    }
    */
    
    public static Boolean AlreadySetCaseRespondedTime = false;

    public static void SetCaseRespondedTime(Map<ID,Case> updatedCases, PSPHelper pspHelper)
    {
        /*
        Set<ID> uniqueCaseIDs = new Set<ID>();
        for(Case c:uniqueCases.values())
            uniqueCaseIDs.add(c.Id);            
        Map<ID,Case> updatedCases = new Map<ID,Case>([Select c.Original_Priority__c,c.Process_Me__c, c.AccountId, c.CreatedDate, c.ClosedDate, c.Time_Object__c, c.SLA__c, c.IsClosed, c.Priority, c.Case_Category__c, c.Status, c.Category__c, c.Sub_status__c, c.Business_Hours_in_Use__c, c.Business_Hours_in_Use__r.Business_Hours__c, c.Business_Hours_in_Use__r.Normal_Working_Day_Length__c from Case c where c.Time_Object__c != null and c.Id in :uniqueCaseIDs]);
        */
        if(!AlreadySetCaseRespondedTime)
        {
            Set<ID> caseIds = new Set<ID>();
            Set<ID> uniqueTimeObjectIDs = new Set<ID>();

            for(Case updatedCase : updatedCases.values())
            {
                uniqueTimeObjectIDs.add(updatedCase.Time_Object__c);
            }
            if(uniqueTimeObjectIDs.size() > 0)
            {
                Map<ID,Time_Object__c> uniqueTimeObjects = new Map<ID,Time_Object__c>([Select t.SLA2_Response_Timestamp__c, t.Response_Time__c, t.Date_Time_Responded__c, t.PSP2_Date_Time_Responded__c,t.Original_Response_Time__c from Time_Object__c t where t.Id in :uniqueTimeObjectIDs and PSP2_Date_Time_Responded__c != null and Response_Time__c = null for update]);
                List<Case> casesToUpdate = new List<Case>();
                
                if(!uniqueTimeObjects.isEmpty())
                {
                    for(Case updatedCase : updatedCases.values())
                    {
                        Time_Object__c timeObject = uniqueTimeObjects.get(updatedCase.Time_Object__c);
                        
                        if(timeObject != null)
                        {
                            if(timeObject.PSP2_Date_Time_Responded__c != null && timeObject.Response_Time__c == null)
                            {
                                casesToUpdate.add(updatedCase);
                            }
                        }
                    }                    
                    TimeCalculator.PerformCalculation(casesToUpdate, 'Responded', uniqueTimeObjects, pspHelper.getMapSLA(), pspHelper.getMapAccountSLA_BH(), pspHelper.getMapBusinessHours(), pspHelper.getGlobalBH(), pspHelper.getMapCSM(), pspHelper.getMapCaseIdCaseHistory());
                    update uniqueTimeObjects.values();
                }
            }
        }
    }
    public static void SetCaseOriginalOnPriorityChange(Map<ID,Case> uniqueCases, PSPHelper pspHelper)
    {
        Set<ID> uniqueCaseIDs = new Set<ID>();
        for(Case c:uniqueCases.values())
            uniqueCaseIDs.add(c.Id);            
        Map<ID,Case> updatedCases = new Map<ID,Case>([Select c.Original_SLA__c,c.Original_Priority__c,
                                    c.Time_Object__c, c.SLA__c, c.Priority, c.Business_Hours_in_Use__c,c.CreatedDate,                                   
                                    c.Original_Business_Hours_in_Use__r.Business_Hours__c,c.Original_Business_Hours_in_Use__c,
                                    c.Original_Business_Hours_in_Use__r.Normal_Working_Day_Length__c, Severity__c from Case c 
                                    where c.Time_Object__c != null and c.Id in :uniqueCaseIDs]);
        Set<ID> caseIds = new Set<ID>();
        Set<ID> uniqueTimeObjectIDs = new Set<ID>();       

        for(Case updatedCase : updatedCases.values())
        {
            uniqueTimeObjectIDs.add(updatedCase.Time_Object__c);
        }
        if(uniqueTimeObjectIDs.size() > 0)
        {
            Map<ID,Time_Object__c> uniqueTimeObjects = new Map<ID,Time_Object__c>([Select t.Original_Response_Time__c from Time_Object__c t where t.Id in :uniqueTimeObjectIDs and Original_Response_Time__c = null]);
            List<Case> casesToUpdate = new List<Case>();
            
            if(!uniqueTimeObjects.isEmpty())
            {
                for(Case updatedCase : updatedCases.values())
                {
                    Time_Object__c timeObject = uniqueTimeObjects.get(updatedCase.Time_Object__c);
                    
                    if(timeObject != null)
                    {
                        casesToUpdate.add(updatedCase);
                    }
                }
                TimeCalculator.CalculateOriginalFields(casesToUpdate, uniqueTimeObjects, pspHelper.getMapSLA(), pspHelper.getMapAccountSLA_BH(), pspHelper.getMapBusinessHours(), pspHelper.getGlobalBH(), pspHelper.getMapCSM(), pspHelper.getMapCaseIdCaseHistory());
                update uniqueTimeObjects.values();
            }
        }
    }
    public static void SetCaseWorkaroundTime(Set<ID> TimeID)
    {
        List<Time_Object__c> uniqueTimeObjects = new List<Time_Object__c>([Select t.Original_Workaround_Time_Stamp__c from Time_Object__c t where t.Original_Workaround_Time_Stamp__c = null and t.Id in :TimeID]);
        for(Time_Object__c t:uniqueTimeObjects)
            t.Original_Workaround_Time_Stamp__c = Datetime.now();
        try{
        	update uniqueTimeObjects;
        }catch(Exception e){
			System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
			CaseFuture.Future_SetCaseWorkAroundTime(TimeID, Datetime.now());
		}
    }
    
    public static void SetCaseSolutionTime(Map<ID,Case> updatedCases, PSPHelper pspHelper)
    {
        /*
        Set<ID> uniqueCaseIDs = new Set<ID>();
        for(Case c:uniqueCases.values())
            uniqueCaseIDs.add(c.Id);            
        Map<ID,Case> updatedCases = new Map<ID,Case>([Select c.Original_Priority__c,c.Workaround_Time_Stamp__c,c.Process_Me__c, c.AccountId, c.CreatedDate, c.ClosedDate, c.Time_Object__c, c.SLA__c, c.IsClosed, c.Priority, c.Case_Category__c, c.Status, c.Category__c, c.Sub_status__c, c.Business_Hours_in_Use__c, c.Business_Hours_in_Use__r.Business_Hours__c, c.Business_Hours_in_Use__r.Normal_Working_Day_Length__c from Case c where c.Time_Object__c != null and c.Id in :uniqueCaseIDs]);
        */
        Set<ID> uniqueTimeObjectIDs = new Set<ID>();

        //Create a unique list of caseIDs
        Set<ID> caseIds = new Set<ID>();
        
        for(Case updatedCase: updatedCases.Values())
        {
            System.debug('updatedCase : ' + updatedCase);
            System.debug('updatedCase.IsClosed : ' + updatedCase.IsClosed);
            System.debug('updatedCase.Time_Object__c : ' + updatedCase.Time_Object__c);
            caseIds.add(updatedCase.Id);
            uniqueTimeObjectIDs.add(updatedCase.Time_Object__c);
        }
        
        if(uniqueTimeObjectIDs.size() > 0 && caseIds.size() > 0)
        {
            Map<ID,Time_Object__c> uniqueTimeObjects = new Map<ID,Time_Object__c>([Select t.Customer_Case_Time__c ,t.Original_Workaround_Time_Stamp__c,t.Case_at_Closed_Status_Time__c, t.Process_Closed_Case__c, t.Elapsed_Time__c, t.X10_Working_Days__c, t.Time_in_L3__c, t.Time_in_L2__c, t.Time_in_L1__c, t.Response_Time__c, t.Misys_Solution_Time__c, t.Misys_Resolution_Time__c,t.Time_to_Workaround__c,t.Original_Priority_Resolution_Time__c from Time_Object__c t where t.Id in :uniqueTimeObjectIDs for update]);

            TimeCalculator.PerformCalculation(updatedCases.Values(), 'SolutionTime', uniqueTimeObjects, pspHelper.getMapSLA(), pspHelper.getMapAccountSLA_BH(), pspHelper.getMapBusinessHours(), pspHelper.getGlobalBH(), pspHelper.getMapCSM(), pspHelper.getMapCaseIdCaseHistory());
            update uniqueTimeObjects.values();
        }
    }
    
    public static void SetCaseSLA(List<Case> uniqueCases)
    {
        Set<ID> accountIds = new Set<ID>();
        Set<ID> contactIds = new Set<ID>();
        Map<ID,Contact> mapContact;
        Map<ID,RecordType> mRecordType = new Map<ID,RecordType>([Select r.Name, r.Id,r.SobjectType From RecordType r where SobjectType = 'Case']);
        // Declared by HCL team for captching the Case's Priority and Product values
        Set<String> sCaseProd = new Set<String>{'All'};
        Set<String> sCasePriority = new Set<String>{'All'};
        String strCaseProd='';
        String strCasePriority='';

        for(Case uniqueCase : uniqueCases)
        {
            // captching the Case's Priority and RecordType values
            if(uniqueCase.Priority != null)
                sCasePriority.add(uniqueCase.Priority);
            RecordType r = mRecordType.get(uniqueCase.RecordTypeId);            
            sCaseProd.add(r.Name);
            if(uniqueCase.AccountId != null)
            {
                if(!accountIds.contains(uniqueCase.AccountId))
                {
                    accountIds.add(uniqueCase.AccountId);
                }
            }
            else
            {
                if(uniqueCase.ContactId != null)
                {
                    if(!contactIds.contains(uniqueCase.ContactId))
                    {
                        contactIds.add(uniqueCase.ContactId);
                    }
                }
            }
        }
        
        
        if(contactIds.size() > 0)
        {
            mapContact = new Map<ID,Contact>([select Id, AccountId from Contact where Id in :contactIds]);
            
            if(!mapContact.isEmpty())
            {
                for(Contact con : mapContact.values())
                {
                    if(!accountIds.contains(con.AccountId))
                    {
                        accountIds.add(con.AccountId);
                    }
                }
            }
        }
         
        for(String s:sCaseProd)
            strCaseProd += '\'' + s + '\',';
        for(String s:sCasePriority)
            strCasePriority += '\'' + s + '\',';
        strCaseProd = strCaseProd.substring(0, strCaseProd.length()-1);
        strCasePriority = strCasePriority.substring(0, strCasePriority.length()-1);
        if(accountIds.size() > 0)
        {
            // SS: 05-March-2010 : Query the Business Hours in Use
            
            if(mapBusinessHoursInUse_Static == null)
            {
                mapBusinessHoursInUse_Static = new Map<ID,Business_Hours_in_Use__c>([select Id, SLA__c, SLA__r.Priority__c, SLA__r.SLA_Product__c, Business_Hours__c, Account__c, Account__r.Id, SLA__r.Id, Normal_Working_Day_Length__c from Business_Hours_in_Use__c where Account__c in : accountIds and (SLA__r.SLA_Product__c INCLUDES (:strCaseProd) or SLA__r.Priority__c INCLUDES (:strCasePriority))]);
                System.debug('mapBusinessHoursInUse_Static : ' + mapBusinessHoursInUse_Static);
            }
            // Query all the Business Hours in use according to the Product and Priority
            String sBHIUQuery = 'select Id, SLA__c, SLA__r.SLA_Product__c, Business_Hours__c, SLA__r.Priority__c,' 
                                + 'Account__c, Account__r.Id, SLA__r.Id, Normal_Working_Day_Length__c'
                                + ' from Business_Hours_in_Use__c where Account__c in : accountIds';                                                    
            sBHIUQuery += ' and (SLA__r.SLA_Product__c INCLUDES (' + strCaseProd + ')';
            sBHIUQuery += ' and SLA__r.Priority__c INCLUDES (' + strCasePriority + '))';            
            List<Business_Hours_in_Use__c> lstBHIU = database.query(sBHIUQuery);            
            for(Case uniqueCase : uniqueCases)
            {
                Id caseAccountId = uniqueCase.AccountId;
                
                if(caseAccountId == null)
                {
                    if(mapContact != null && !mapContact.isEmpty())
                    {
                        caseAccountId = mapContact.get(uniqueCase.ContactId).AccountId;
                    }
                }
                
                if(caseAccountId != null)
                {
                    Id slaProdALLId,slaProdExactId;
                    Business_Hours_in_Use__c BHIUProdAll,BHIUProdExact;
                    Id slaPrirtyALLId,slaPrirtyExactId;
                    Business_Hours_in_Use__c BHIUPrirtyAll,BHIUPrirtyExact;
                    
                    for(Business_Hours_in_Use__c bhiu : lstBHIU)
                    {
                        if(bhiu.Account__c == caseAccountId)                            
                        {
                            String CaseProd = '';
                            String CasePriority = '';                                   
                            RecordType r = mRecordType.get(uniqueCase.RecordTypeId);            
                            CaseProd = String.valueOf(r.Name).toLowerCase();
                            if(uniqueCase.Priority != null)
                                CasePriority = String.valueOf(uniqueCase.Priority).toLowerCase();
                            if((String.valueOf(bhiu.SLA__r.SLA_Product__c).toLowerCase()).contains(CaseProd))
                            {
                                if((String.valueOf(bhiu.SLA__r.Priority__c).toLowerCase()).contains(CasePriority))
                                {
                                    slaProdExactId = bhiu.SLA__c;
                                    BHIUProdExact = bhiu;
                                }
                                else if((String.valueOf(bhiu.SLA__r.Priority__c).toLowerCase()).contains('all'))
                                {
                                    slaProdALLId = bhiu.SLA__c;
                                    BHIUProdAll = bhiu;
                                }
                            }
                            else if((String.valueOf(bhiu.SLA__r.SLA_Product__c).toLowerCase()).contains('all'))
                            {
                                if((String.valueOf(bhiu.SLA__r.Priority__c).toLowerCase()).contains(CasePriority))
                                {
                                    slaPrirtyExactId = bhiu.SLA__c;
                                    BHIUPrirtyExact = bhiu;
                                    
                                }
                                else if((String.valueOf(bhiu.SLA__r.Priority__c).toLowerCase()).contains('all'))
                                {
                                    slaPrirtyALLId = bhiu.SLA__c;
                                    BHIUPrirtyAll = bhiu;
                                }
                            }
                        }
                    }
                    if(slaProdExactId != null)
                    {
                        uniqueCase.SLA__c = slaProdExactId;
                        uniqueCase.Business_Hours_in_Use__c = BHIUProdExact.Id;
                        uniqueCase.BusinessHours__c = BHIUProdExact.Business_Hours__c;
                    }
                    else if(slaProdALLId != null)
                    {
                        uniqueCase.SLA__c = slaProdALLId;
                        uniqueCase.Business_Hours_in_Use__c = BHIUProdAll.Id;
                        uniqueCase.BusinessHours__c = BHIUProdAll.Business_Hours__c;
                    }
                    else if(slaPrirtyExactId != null)
                    {
                        uniqueCase.SLA__c = slaPrirtyExactId;
                        uniqueCase.Business_Hours_in_Use__c = BHIUPrirtyExact.Id;
                        uniqueCase.BusinessHours__c = BHIUPrirtyExact.Business_Hours__c;
                    }
                    else if(slaPrirtyALLId != null)
                    {
                        uniqueCase.SLA__c = slaPrirtyALLId;
                        uniqueCase.Business_Hours_in_Use__c = BHIUPrirtyAll.Id;
                        uniqueCase.BusinessHours__c = BHIUPrirtyAll.Business_Hours__c;
                    }
                    else
                    {
                        uniqueCase.SLA__c = null;
                        uniqueCase.Business_Hours_in_Use__c = null;
                        uniqueCase.BusinessHours__c = null;
                    }
                }
            }            
            //uniqueCases[0].addError('Sorry'+uniqueCases[0].SLA__c);           
        }
    }
    

    public static void SetCaseSolutionBreachTime(List<Case> updatedCases, PSPHelper pspHelper)
    {
    //Update 21-Jul-2011 Jason
    //		Change code below to select the Time Objects based on the Case Ids since the Time_Object__c field on Case is not populated yet for a new case.
    
        System.debug('in SetCaseSolutionBreachTime');
        
        //Set<ID> uniqueTimeObjectIDs = new Set<ID>();

        //for(Case updatedCase: updatedCases)
        //{
        //    if(updatedCase != null && updatedCase.Time_Object__c != null)
        //    {
        //        uniqueTimeObjectIDs.add(updatedCase.Time_Object__c);
        //    }
        //}
        
        Set<Id> updatedCaseIds = new Set<Id>();
        for(Case c : updatedCases)
        {
        	updatedCaseIds.add(c.Id);
        }
        
        //if(uniqueTimeObjectIDs.size() > 0)
        if(updatedCaseIds.size() > 0)
        {
            //Map<ID,Time_Object__c> uniqueTimeObjects = new Map<ID,Time_Object__c>([Select t.Solution_Target_Time__c,t.Resolution_Target_Time__c,t.Original_Priority_Resolution_Target_Time__c,t.Case_at_Closed_Status_Time__c, t.Elapsed_Time__c, t.Customer_Case_Time__c, t.Misys_Solution_Time__c, t.Misys_Resolution_Time__c, t.Out_of_Hours__c, t.Solution_Will_Breach_At__c, t.SLA_Resolution_Target_will_Breach_at__c from Time_Object__c t where t.Id in :uniqueTimeObjectIDs for update]);
            Map<ID,Time_Object__c> uniqueTimeObjects = new Map<ID,Time_Object__c>();
            for(Time_Object__c t : [Select t.Solution_Target_Time__c,t.Resolution_Target_Time__c,t.Original_Priority_Resolution_Target_Time__c,t.Case_at_Closed_Status_Time__c, t.Elapsed_Time__c, t.Customer_Case_Time__c, t.Misys_Solution_Time__c, t.Misys_Resolution_Time__c, t.Out_of_Hours__c, t.Solution_Will_Breach_At__c, t.SLA_Resolution_Target_will_Breach_at__c, t.Case__c from Time_Object__c t where t.Case__c in :updatedCaseIds for update])
            {
            	uniqueTimeObjects.put(t.Case__c,t);
            }

            System.debug('uniqueTimeObjects : ' + uniqueTimeObjects);
        
            // first check if the checkbox is set or not
            for(Case updatedCase : updatedCases)
            {
                //Set the case Priority based on a lookup.  
	            //If the field or values change for Priority/Severity, it can be adjusted here
	           	String casePriority = CaseServices.getPriorityFromSeverity(updatedCase.Severity__c);
	           	String caseOriginalPriority = CaseServices.getPriorityFromSeverity(updatedCase.Original_Priority__c);
                
                if(uniqueTimeObjects.keySet().contains(updatedCase.Id))
                {
	                //Time_Object__c timeObject = uniqueTimeObjects.get(updatedCase.Time_Object__c);
	                Time_Object__c timeObject = uniqueTimeObjects.get(updatedCase.Id);
	            
	                System.debug('timeObject : ' + timeObject);
	                System.debug('timeObject.Out_of_Hours__c : ' + timeObject.Out_of_Hours__c);
	                
	                if(pspHelper.getMapSLA() != null)
	                {
	                    // get the SLA related to the Case
	                    SLA__c caseSLA = pspHelper.getMapSLA().get(updatedCase.SLA__c);
	                        
	                    if(caseSLA != null)
	                    {
	                        BusinessHours caseBH = pspHelper.getMapBusinessHours().get(updatedCase.Business_Hours_in_Use__r.Business_Hours__c);// = mapBusinessHours.get(mapSLA.get(uniqueCase.SLA__c).Business_Hours__c);
	    
	                        //System.debug('caseBH : ' + caseBH);
	                        
	                        // SS:  05-March-2010 : As the above caseBH will always be null due to the Business_Hours_in_Use__r.Business_Hours__c not found via the relationship.
	                        //      Hence, using the static list retrieved earlier to pull out the Business Hours record                                
	                        if(mapBusinessHoursInUse_Static != null && !mapBusinessHoursInUse_Static.isEmpty())
	                        {
	                            System.debug('found the mapBusinessHoursInUse_Static already populated');
	                            System.debug('mapBusinessHoursInUse_Static : ' + mapBusinessHoursInUse_Static);
	                            System.debug('caseBH : ' + pspHelper.getMapBusinessHours().get(mapBusinessHoursInUse_Static.get(updatedCase.Business_Hours_in_Use__c).Business_Hours__c));
	                            caseBH = pspHelper.getMapBusinessHours().get(mapBusinessHoursInUse_Static.get(updatedCase.Business_Hours_in_Use__c).Business_Hours__c);                         
	                        }
	                            
	                        if(caseBH != null)
	                        {
	                            Double normalWorkingDayLength = updatedCase.Business_Hours_in_Use__r.Normal_Working_Day_Length__c;
	                                    
	                            Double dSolutionTargetTime = 0;
	                            String sSolutionTargetTime = '';
	                            Datetime dtSolutionWillBreachAt;
	                            
	                            Double dResolutionTargetTime = 0;
	                            String sResolutionTargetTime = '';
	                            Datetime dtResolutionWillBreachAt;
	                            
	                            System.debug('casePriority: ' + casePriority);
	                                    
	                            // now get the SLA solution target value based upon the case priority
	                            // JRB 2012-09 if(updatedCase.Priority == 'Critical')  
	                            if(casePriority == 'Critical')
	                            {
	                                dSolutionTargetTime = caseSLA.Solution_Target_Time_Critical__c;
	                                sSolutionTargetTime = caseSLA.Solution_Target_Critical_Value__c;
	                                sResolutionTargetTime = caseSLA.Resolution_Target_Critical_Value__c;
	                            }
	                            //JRB 2012-09 else if(updatedCase.Priority == 'High')
	                            else if(casePriority == 'High')
	                            {
	                                dSolutionTargetTime = caseSLA.Solution_Target_Time_High__c;
	                                sSolutionTargetTime = caseSLA.Solution_Target_High_Value__c;
	                                sResolutionTargetTime = caseSLA.Resolution_Target_High_Value__c;
	                            }
	                            //JRB 2012-09 else if(updatedCase.Priority == 'Medium')
	                            else if(casePriority == 'Medium')
	                            {
	                                dSolutionTargetTime = caseSLA.Solution_Target_Time_Medium__c;
	                                sSolutionTargetTime = caseSLA.Solution_Target_Medium_Value__c;
	                                sResolutionTargetTime = caseSLA.Resolution_Target_Medium_Value__c;
	                            }
	                            //JRB 2012-09 else if(updatedCase.Priority == 'Low')
	                            else if(casePriority == 'Low')
	                            {
	                                dSolutionTargetTime = caseSLA.Solution_Target_Time_Low__c;
	                                sSolutionTargetTime = caseSLA.Solution_Target_Low_Value__c;
	                                sResolutionTargetTime = caseSLA.Resolution_Target_Low_Value__c;
	                            }
	                            Double dSolutionToAdd = 0;
	                            Double dResolutionToAdd = 0;
	                            
	                            if(sSolutionTargetTime.startsWith('D'))
	                            {
	                                //system.debug('XXX - sSolutionTargetTime: '+sSolutionTargetTime);
	                                //system.debug('XXX - normalWorkingDayLength: '+normalWorkingDayLength);
	                                dSolutionToAdd = Double.valueOf(sSolutionTargetTime.replace('D', '')) * normalWorkingDayLength * 60 * 60;
	                            }
	                            else if(sSolutionTargetTime.startsWith('M'))
	                            {
	                                dSolutionToAdd = Double.valueOf(sSolutionTargetTime.replace('M', '')) * 60;
	                            }
	    
	                            if(sResolutionTargetTime.startsWith('D'))
	                            {
	                                dResolutionToAdd = Double.valueOf(sResolutionTargetTime.replace('D', '')) * normalWorkingDayLength * 60 * 60;
	                            }
	                            else if(sResolutionTargetTime.startsWith('M'))
	                            {
	                                dResolutionToAdd = Double.valueOf(sResolutionTargetTime.replace('M', '')) * 60;
	                            }
	                            if(dResolutionToAdd > 0)
	                                timeObject.Resolution_Target_Time__c = dResolutionToAdd;
	                                
	                            if(dSolutionToAdd > 0)
	                                timeObject.Solution_Target_Time__c = dSolutionToAdd;
	                            
	                            //check if the solution targets are populated, 
	                            // if not then we need to skip the Solution_Will_Breach_at__c field 
	                            Boolean bIsSolutionTargetEmpty = false;
	                            if(dSolutionToAdd == 0)
	                            {
	                                bIsSolutionTargetEmpty = true;
	                            }       
	                            
	                            System.debug('dSolutionToAdd : ' + dSolutionToAdd);
	                            System.debug('dResolutionToAdd : ' + dResolutionToAdd);
	                                    
	                            dSolutionToAdd += (timeObject.Customer_Case_Time__c);
	                            dResolutionToAdd += (timeObject.Customer_Case_Time__c);                            
	    
	                            System.debug('After adding customer time');
	                            
	                            System.debug('dSolutionToAdd : ' + dSolutionToAdd);
	                            System.debug('dResolutionToAdd : ' + dResolutionToAdd);
	    
	                            System.debug('Before adding closed timebucket');
	                                    
	                            if(timeObject.Case_at_Closed_Status_Time__c > 0)
	                            {
	                                dSolutionToAdd += (timeObject.Case_at_Closed_Status_Time__c);
	                                dResolutionToAdd += (timeObject.Case_at_Closed_Status_Time__c);
	                            }
	                                    
	                            // for Resolution Breach Time, remove the difference between Solution Time and Resolution Time
	                            // as we want to remove all buckets where Resolution Time is not being calculated
	                            dResolutionToAdd += (timeObject.Misys_Solution_Time__c - timeObject.Misys_Resolution_Time__c);
	                            
	                            System.debug('After adding closed timebucket');
	    
	                            System.debug('dSolutionToAdd : ' + dSolutionToAdd);
	                            System.debug('dResolutionToAdd : ' + dResolutionToAdd);
	                            
	                            dSolutionToAdd *= 1000;
	                            dResolutionToAdd *= 1000;
	                            
	                            if(dSolutionToAdd > 0 && bIsSolutionTargetEmpty == false)
	                            {
	                                dtSolutionWillBreachAt = BusinessHours.add(caseBH.id, updatedCase.CreatedDate, dSolutionToAdd.longValue());
	                                System.debug('dtSolutionWillBreachAt : ' + dtSolutionWillBreachAt);
	                                timeObject.Solution_Will_Breach_At__c = dtSolutionWillBreachAt;
	                                System.debug('timeObject.Solution_Will_Breach_At__c : ' + timeObject.Solution_Will_Breach_At__c);
	                            }
	    
	                            if(dResolutionToAdd > 0)
	                            {                               
	                                dtResolutionWillBreachAt = BusinessHours.add(caseBH.id, updatedCase.CreatedDate, dResolutionToAdd.longValue());
	                                System.debug('dtResolutionWillBreachAt : ' + dtResolutionWillBreachAt);
	                                timeObject.SLA_Resolution_Target_will_Breach_at__c = dtResolutionWillBreachAt;
	                                System.debug('timeObject.SLA_Resolution_Target_will_Breach_at__c : ' + timeObject.SLA_Resolution_Target_will_Breach_at__c);
	                            }                            
	                        }
	                    }
	                    /* 
	                        get the Original SLA related to the Case
	                        Code written by HCL team to calculate the Original Resolution Target Breach at field's value 
	                    */
	                    SLA__c caseOriginalSLA = pspHelper.getMapSLA().get(updatedCase.Original_SLA__c);
	                    system.debug('Nitin->'+caseOriginalSLA);
	                    if(caseOriginalSLA != null)
	                    {
	                        BusinessHours caseBH = pspHelper.getMapBusinessHours().get(updatedCase.Original_Business_Hours_in_Use__r.Business_Hours__c);// = mapBusinessHours.get(mapSLA.get(uniqueCase.SLA__c).Business_Hours__c);
	    
	                        System.debug('caseBH1 : ' + caseBH);
	                        
	                        // SS:  05-March-2010 : As the above caseBH will always be null due to the Business_Hours_in_Use__r.Business_Hours__c not found via the relationship.
	                        //      Hence, using the static list retrieved earlier to pull out the Business Hours record                                
	                        if(mapBusinessHoursInUse_Static != null && !mapBusinessHoursInUse_Static.isEmpty())
	                        {
	                            System.debug('found the mapBusinessHoursInUse_Static already populated');
	                            System.debug('mapBusinessHoursInUse_Static : ' + mapBusinessHoursInUse_Static);
	                            System.debug('caseBH : ' + pspHelper.getMapBusinessHours().get(mapBusinessHoursInUse_Static.get(updatedCase.Business_Hours_in_Use__c).Business_Hours__c));
	                            caseBH = pspHelper.getMapBusinessHours().get(mapBusinessHoursInUse_Static.get(updatedCase.Original_Business_Hours_in_Use__c).Business_Hours__c);                         
	                        }
	                            
	                        if(caseBH != null)
	                        {
	                            Double normalWorkingDayLength = updatedCase.Original_Business_Hours_in_Use__r.Normal_Working_Day_Length__c;
	                                    
	                            // Code writter by HCL team for calculating the Resolution target fields on Time object 
	                            Double dOriginalResolutionTargetTime = 0;
	                            String sOriginalResolutionTargetTime = '';
	                            Datetime dtOriginalResolutionWillBreachAt;
	                            System.debug('dResolutionToAdd Nitin 11 ---->: ' + caseOriginalSLA);
	                            //JRB 2012-09 if(updatedCase.Original_Priority__c == 'Critical')
	                            if(caseOriginalPriority == 'Critical')
	                            {
	                                sOriginalResolutionTargetTime = caseOriginalSLA.Resolution_Target_Critical_Value__c;
	                            }
	                            //JRB 2012-09 else if(updatedCase.Original_Priority__c == 'High')
	                            else if(caseOriginalPriority == 'High')
	                            {
	                                sOriginalResolutionTargetTime = caseOriginalSLA.Resolution_Target_High_Value__c;
	                            }
	                            //JRB 2012-09 else if(updatedCase.Original_Priority__c == 'Medium')
	                            else if(caseOriginalPriority == 'Medium')
	                            {
	                                sOriginalResolutionTargetTime = caseOriginalSLA.Resolution_Target_Medium_Value__c;
	                            }
	                            //JRB 2012-09 else if(updatedCase.Original_Priority__c == 'Low')
	                            else if(caseOriginalPriority == 'Low')
	                            {
	                                sOriginalResolutionTargetTime = caseOriginalSLA.Resolution_Target_Low_Value__c;
	                            }
	                            System.debug('dResolutionToAdd Nitin 111 ---->: ' + sOriginalResolutionTargetTime);
	                            Double dOriginalResolutionToAdd = 0;
	                            if(sOriginalResolutionTargetTime.startsWith('D'))
	                            {
	                                dOriginalResolutionToAdd = Double.valueOf(sOriginalResolutionTargetTime.replace('D', '')) * normalWorkingDayLength * 60 * 60;
	                            }
	                            else if(sOriginalResolutionTargetTime.startsWith('M'))
	                            {
	                                dOriginalResolutionToAdd = Double.valueOf(sOriginalResolutionTargetTime.replace('M', '')) * 60;
	                            }
	                            timeObject.Original_Priority_Resolution_Target_Time__c = dOriginalResolutionToAdd;
	                            dOriginalResolutionToAdd += (timeObject.Customer_Case_Time__c);
	                            if(timeObject.Case_at_Closed_Status_Time__c > 0)
	                            {
	                                dOriginalResolutionToAdd += (timeObject.Case_at_Closed_Status_Time__c);
	                            }
	                            dOriginalResolutionToAdd += (timeObject.Misys_Solution_Time__c - timeObject.Misys_Resolution_Time__c);
	                            dOriginalResolutionToAdd *= 1000;
	                            if(dOriginalResolutionToAdd > 0)
	                            {
	                                dtOriginalResolutionWillBreachAt = BusinessHours.add(caseBH.id, updatedCase.CreatedDate, dOriginalResolutionToAdd.longValue());
	                                timeObject.SLA_Original_Resolution_Target_Breach_at__c = dtOriginalResolutionWillBreachAt;
	                            }
	                        }
	                    }
	                }
            	}
            }            
            if(!uniqueTimeObjects.isEmpty())
            {
                update uniqueTimeObjects.values();
                System.debug('uniqueTimeObjects : ' + uniqueTimeObjects);
            }
            
        }
    }
    
    
    public static void SetCaseOutOfHoursFlag(Map<ID,Case> mapUpdateCases, PSPHelper pspHelper)
    {
        System.debug('in SetCaseOutOfHoursFlag');
        //Map<ID,Case> mapUpdatedCases = new Map<ID,Case>([Select c.CreatedDate,c.SLA__c, c.Business_Hours_in_Use__c, c.Business_Hours_in_Use__r.Business_Hours__c, c.Business_Hours_in_Use__r.Normal_Working_Day_Length__c from Case c where c.Time_Object__c != null and c.Id in :mapUpdateCases.keySet()]);
        Map<ID,Case> mapUpdatedCases = mapUpdateCases;
        Set<ID> uniqueTimeObjectIDs = new Set<ID>();
        system.debug('nitinYes---->>>>>'+mapUpdatedCases.isEmpty());
        if(!mapUpdatedCases.isEmpty())
        {
            //Get related Business_Hours_In_Use records
            Set<Id> setBHIUids = new Set<Id>();
            for(Case c : mapUpdatedCases.values())
            {
            	if(c.Business_Hours_In_Use__c != null)
            		setBHIUids.add(c.Business_Hours_In_Use__c);
            }
            Map<Id,Business_Hours_In_Use__c> mapBHIU = new Map<Id,Business_Hours_In_Use__c>([select Id, SLA__c, SLA__r.Priority__c, SLA__r.SLA_Product__c, Business_Hours__c, Account__c, Account__r.Id, SLA__r.Id, Normal_Working_Day_Length__c from Business_Hours_in_Use__c where Id in :setBHIUids]);
            
            //Get related Time Objects
            Map<ID,Time_Object__c> uniqueTimeObjects = new Map<ID,Time_Object__c>([Select t.Elapsed_Time__c, t.Out_of_Hours__c, t.Case__c from Time_Object__c t where t.Case__c in :mapUpdatedCases.keySet()]);
            
            List<Time_Object__c> lstTimeObjectsToUpdate = new List<Time_Object__c>();
            
            System.debug('uniqueTimeObjects : ' + uniqueTimeObjects);

            for(Time_Object__c timeObject : uniqueTimeObjects.values())
            {
                Case updatedCase = mapUpdatedCases.get(timeObject.Case__c);
                
                // get the SLA related to the Case
                if(pspHelper.getMapSLA() != null)
                {
                    SLA__c caseSLA = pspHelper.getMapSLA().get(updatedCase.SLA__c);
                    
                    System.debug('caseSLA : ' + caseSLA);
                    
                    if(caseSLA != null)
                    {
            			//if((mapBusinessHoursInUse_Static == null || mapBusinessHoursInUse_Static.isEmpty()) && updatedCase.Business_Hours_in_Use__c != null)
            			//{
                		//mapBusinessHoursInUse_Static = new Map<ID,Business_Hours_in_Use__c>([select Id, SLA__c, SLA__r.Priority__c, SLA__r.SLA_Product__c, Business_Hours__c, Account__c, Account__r.Id, SLA__r.Id, Normal_Working_Day_Length__c from Business_Hours_in_Use__c where Account__c in : accountIds and (SLA__r.SLA_Product__c INCLUDES (:strCaseProd) or SLA__r.Priority__c INCLUDES (:strCasePriority))]);
                		//System.debug('mapBusinessHoursInUse_Static : ' + mapBusinessHoursInUse_Static);
            			//}
                        
                        System.debug('pspHelper.getMapBusinessHours() : ' + pspHelper.getMapBusinessHours());
                        System.debug('updatedCase.Business_Hours_in_Use__c : ' + updatedCase.Business_Hours_in_Use__c);
                        System.debug('updatedCase.Business_Hours_in_Use__r.Business_Hours__c : ' + updatedCase.Business_Hours_in_Use__r.Business_Hours__c);
                        System.debug('mapBHIU.get(updatedCase.Business_Hours_In_Use__c) : ' + mapBHIU.get(updatedCase.Business_Hours_In_Use__c));
                        System.debug('mapBHIU.get(updatedCase.Business_Hours_In_Use__c).Business_Hours__c : ' + mapBHIU.get(updatedCase.Business_Hours_In_Use__c).Business_Hours__c);
                        //System.debug('mapBusinessHours.get(mapSLA.get(updatedCase.SLA__c).Business_Hours__c) : ' + pspHelper.getMapBusinessHours().get(mapSLA.get(updatedCase.SLA__c).Business_Hours__c));
                        
                        BusinessHours caseBH;
                        caseBH = pspHelper.getMapBusinessHours().get(updatedCase.Business_Hours_in_Use__r.Business_Hours__c);// = mapBusinessHours.get(mapSLA.get(uniqueCase.SLA__c).Business_Hours__c);
                        System.debug('caseBH : ' + caseBH);
                        if(caseBH == null)
                        	caseBH = pspHelper.getMapBusinessHours().get(mapBHIU.get(updatedCase.Business_Hours_In_Use__c).Business_Hours__c);
                        System.debug('caseBH : ' + caseBH);
                        
                        // SS:  05-March-2010 : As the above caseBH will always be null due to the Business_Hours_in_Use__r.Business_Hours__c not found via the relationship.
                        //      Hence, using the static list retrieved earlier to pull out the Business Hours record                                
                        // JRB: 21-Jul-2011 : mapBusinessHoursInUse_Static is also null for new cases.  Instead, a map of BHIU was populated using a SOQL
                        //if(mapBusinessHoursInUse_Static != null && !mapBusinessHoursInUse_Static.isEmpty() && updatedCase.Business_Hours_in_Use__c != null)
                        //{
                        //    System.debug('found the mapBusinessHoursInUse_Static already populated');
                        //    System.debug('mapBusinessHoursInUse_Static : ' + mapBusinessHoursInUse_Static);
                        //    System.debug('caseBH : ' + pspHelper.getMapBusinessHours().get(mapBusinessHoursInUse_Static.get(updatedCase.Business_Hours_in_Use__c).Business_Hours__c));
                        //    if(pspHelper != null && pspHelper.getMapBusinessHours() != null && !pspHelper.getMapBusinessHours().isEmpty())
                        //    {
                        //        if(mapBusinessHoursInUse_Static.containsKey(updatedCase.Business_Hours_in_Use__c) && pspHelper.getMapBusinessHours().containsKey(mapBusinessHoursInUse_Static.get(updatedCase.Business_Hours_in_Use__c).Business_Hours__c))
                        //        {
                        //            caseBH = pspHelper.getMapBusinessHours().get(mapBusinessHoursInUse_Static.get(updatedCase.Business_Hours_in_Use__c).Business_Hours__c);
                        //        }
                        //    }                           
                        //}
                        
                        if(caseBH != null)
                        {
                            Datetime createdDate = Datetime.now();
                            
                            if(updatedCase.CreatedDate != null)
                            {
                                createdDate = updatedCase.CreatedDate;
                            }
                    
                            Datetime dtNextWorkingSecond = BusinessHours.add(caseBH.id, createdDate, 1 * 1000L);
                        
                            System.debug('updatedCase.CreatedDate : ' + createdDate);
                            System.debug('dtNextWorkingSecond : ' + dtNextWorkingSecond);
    
                            if(dtNextWorkingSecond > createdDate.addSeconds(1))
                            {
                                System.debug('Setting out of hours flag to true');
                                
                                timeObject.Out_of_Hours__c = true;
                                lstTimeObjectsToUpdate.add(timeObject); 
                            }
                        }
                    }
                }
            }
            
            if(lstTimeObjectsToUpdate.size() > 0)
            {
                update lstTimeObjectsToUpdate;
            }
        }
    }   
    
   //JRB: 14-Jul-2011 no longer used
   /*
   public static void setCaseBHIU(List<Case> updatedCases, PSPHelper pspHelper)
    {
        for(Case updatedCase : updatedCases)
        {
            if(updatedCase.Business_Hours_in_Use__c == null)
            {
                if(pspHelper.getMapSLA() != null)
                {
                    SLA__c caseSLA = pspHelper.getMapSLA().get(updatedCase.SLA__c);
                        
                    if(caseSLA != null)
                    {
                        BusinessHours caseBH;// = mapBusinessHours.get(mapSLA.get(uniqueCase.SLA__c).Business_Hours__c);
                        List<Business_Hours_in_Use__c> lstBHIU = pspHelper.getMapAccountSLA_BH().get(String.valueOf(updatedCase.AccountId) + String.valueOf(updatedCase.SLA__c));
            
                        System.debug('lstBHIU : ' + lstBHIU);
                            
                        if(lstBHIU != null)
                        {
                            for(Business_Hours_in_Use__c bhiu : lstBHIU)
                            {
                                if(bhiu.Account__c == updatedCase.AccountId)
                                {
                                    updatedCase.Business_Hours_in_Use__c = bhiu.Id;
                                }   
                            }
                        }
                    }
                }
            }
        }
    }
    */
    
    public static void SetCaseDateTimeResponded(List<Case> updatedCases)
    {
        System.debug('in SetCaseDateTimeResponded..........');
        
        for(Case updatedCase : updatedCases)
        {
            System.debug('updatedCase.Date_Time_Responded__c : ' + updatedCase.Date_Time_Responded__c);
            
            if(updatedCase.Date_Time_Responded__c == null)
            {
                System.debug('updatedCase.Status : ' + updatedCase.Status);
                System.debug('updatedCase.Sub_status__c : ' + updatedCase.Sub_status__c);
                
                //if(!((updatedCase.Status == 'L1 - Awaiting Analysis') || ((updatedCase.Status == 'L2 - Under Analysis') && (updatedCase.Sub_status__c == 'L2 To Review'))))
                //AK - 994224 - The response time should be calculated for status New only.
                //if(!((updatedCase.Status == 'New') || (updatedCase.Status == 'Assigned')))
                if(!(updatedCase.Status == 'New'))
                {
                    updatedCase.Date_Time_Responded__c = Datetime.now();
                    System.debug('updatedCase.Date_Time_Responded__c :55555555555 ' + updatedCase.Date_Time_Responded__c);
                }               
            }
        }
    }

	//Begin - Code originally from Turaz production org
    public static Boolean createdCaseTrackersAndHistories
    {
        get
        {
            if(createdCaseTrackersAndHistories == null)
                createdCaseTrackersAndHistories = false;
            
            return createdCaseTrackersAndHistories;
        }
    }
    
    public static void addCaseTrackerAndHistoryEntries(Map<Id, Case> newMap, Map<Id, Case> oldMap)
    {
        if(!createdCaseTrackersAndHistories)
        {
        	List<Case_Tracker__c> allCaseTrackersToInsert = getCaseTrackers(newMap.values());
            insert allCaseTrackersToInsert;
        	
        	//List<Case_History__c> allCaseHistoriesToInsert = getCaseHistories(newMap, oldMap);
            //insert allCaseHistoriesToInsert;
        	
        	createdCaseTrackersAndHistories = true;
        }
        
    }
        
    public static List<Case_Tracker__c> getCaseTrackers(List<Case> cases)
    {
        List<Case_Tracker__c> allCaseTrackersToInsert = new List<Case_Tracker__c>();
        for(Case c: cases)
        {
            //if(  c.Time_Spent_Hours__c == null && c.Time_Spent_Minutes__c == null )
            if( c.Time_Spent_on_issue__c == null )
                continue;
            else
            {
                integer hrs = 0;
                integer minutes = 0;
                //if(c.Time_Spent_Hours__c != null) hrs = Integer.valueOf(c.Time_Spent_Hours__c);
                //if(c.Time_Spent_Minutes__c != null) minutes = Integer.valueOf(c.Time_Spent_Minutes__c);
                if(c.Time_Spent_on_issue__c != null) minutes = Integer.valueOf(c.Time_Spent_on_issue__c);
                
                integer timeInMinutes = (hrs*60)+minutes;
                //if(timeInMinutes > 0)
                if(timeInMinutes != 0)
                {
                    Case_Tracker__c ct = new Case_Tracker__c();
                    ct.Case__c = c.id;
                    //Limit to prevent too large of a time, which causes database errors due to field size.
                    if(timeInMinutes > 60000){
                    	timeInMinutes = 60000;
                    }
                    ct.Time_Spent_Minutes__c = timeInMinutes;
                    allCaseTrackersToInsert.add(ct);
                }
                
                //c.Time_Spent_Hours__c = '0';
                //c.Time_Spent_Minutes__c = '0';
                c.Time_Spent_on_issue__c = 0;
                //if(c.Total_Time_Spent__c == null) c.Total_Time_Spent__c = 0;
                if(c.Total_Time_Spent_on_Case__c == null) c.Total_Time_Spent_on_Case__c = 0;
                c.Total_Time_Spent_on_Case__c += timeInMinutes;
            }
        }
        
        return allCaseTrackersToInsert;
    }
    
    public static void copyCustomerDeliveryDate(Map<Id, Case> oldMap, List<Case> cases) {
        Set<Id> changedIds = new Set<Id>();
        for (Case c : cases) {
            if (oldMap == null || c.Targeted_Fix_Date__c != oldMap.get(c.Id).Targeted_Fix_Date__c || c.Engineering_Target_Release_Qtr__c != oldMap.get(c.Id).Engineering_Target_Release_Qtr__c)
                changedIds.add(c.Id);
        }
        if (changedIds.size() == 0) return;
        
        List<Case> toUpdate = [select Id, Customer_Delivery_Date__c from Case where ParentId in :changedIds];
        for (Case c : toUpdate)
            c.RBI_CDD__c = c.Customer_Delivery_Date__c;
        update toUpdate;
    }
    
    /**************************************************************************************************
    /*  Not using CaseHistories for now (too many records generated and little need for the data)
    /*  JRB Sept 2012
    /*
    public static List<Case_History__c> getCaseHistories(Map<Id, Case> newMap, Map<Id, Case> oldMap)
    {
        List<Case_History__c> allCaseHistoriesToInsert = new List<Case_History__c>();
        Map<String, Case_History_Fields__c> allCaseHistoryFields = Case_History_Fields__c.getAll();
        Set<ID> caseIDsWithHistories = getCaseIdsWithHistories(newMap);
        
        if(allCaseHistoryFields != null && allCaseHistoryFields.size() > 0)
        {
            integer x = 0;
            for(Case c: newMap.values())
            {
            	if(caseIdsWithHistories != null && caseIdsWithHistories.contains(c.id))
                {
                
                    for(String fld: allCaseHistoryFields.keySet())
                    {
                        if(c.get(fld) != oldMap.get(c.id).get(fld))
                        {
                            Case_History__c ch = new Case_History__c();
                            ch.Case__c = c.id;
                            ch.User__c = UserInfo.getUserId();
                            ch.Date__c = DateTime.now();
                            ch.Field__c = fld;
                            ch.Field_Label__c = allCaseHistoryFields.get(fld).Field_Label__c;
                            ch.To__c = String.valueOf(c.get(fld));
                            ch.From__c = String.valueOf(oldMap.get(c.id).get(fld));
                            allCaseHistoriesToInsert.add(ch);
                        }
                    }
                }
                else
                {
                    for(String fld: allCaseHistoryFields.keySet())
                    {
                        Case_History__c ch = new Case_History__c();
                        ch.Case__c = c.id;
                        ch.User__c = UserInfo.getUserId();
                        ch.Date__c = DateTime.now();
                        ch.Field__c = fld;
                        ch.Field_Label__c = allCaseHistoryFields.get(fld).Field_Label__c;
                        ch.To__c = String.valueOf(c.get(fld));
                        //if(ch.To__c == null) ch.To__c = Constants.STATUS_NEW;
                        if(ch.To__c == null) ch.To__c = Constants__c.getValues('STATUS_NEW').Value__c;
                        ch.From__c = 'Empty';
                        ch.Created__c = true;
                        allCaseHistoriesToInsert.add(ch);
                    }
                }
            }
        }
        
        return allCaseHistoriesToInsert;
        
    }
    
    private static Set<ID> getCaseIdsWithHistories(Map<Id, Case> newMap)
    {
        Set<Id> caseIdsWithHistories = new Set<Id>();
        for(Case_History__c ch: [Select ID , Case__c from Case_History__c where Case__c in: newMap.keySet()])
        {
            for(Case c: newMap.values())
            {
                if(ch.Case__c == c.id)
                {
                    caseIdsWithHistories.add(c.id);
                }
            }
        }
        return caseIdsWithHistories;
    }
    **************************************************************************************************/

	//End - Code originally from Turaz production org    
  	
  	
	
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //                                                                                           //
    //                                  TEST METHODS                                             //
    //                                                                                           //
    ///////////////////////////////////////////////////////////////////////////////////////////////
    //Moved to CaseTriggerMethods_Test by JRB on 12-Jul-2011    
    

}