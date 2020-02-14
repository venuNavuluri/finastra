public class IntegrationLog_WinformApproval
{

	public static void processWFApprovals(List<Integration_Log__c> IntLogWFApprovals, Set<Id> idsWFApprovals, Set<Id> daRecordTypeIds)
	{
		////////////////////////////////////////////////////////////////////////////////////////////////////////
		//Processes incoming Winform data for Opportunity Deal Approvals
		//
		//Prior to the data being pushed to SFDC from the Approvals database via Informatica, all unprocessed
		//	Winform files are uploaded to SFDC and attached to the related opportunity.  Any duplicate 
		//	files are not uploaded, but a check is done to be sure an incoming submission has not already 
		//	been processed.
		////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		map<String,Deal_Approval_Structure.Winform> mapWinforms = new map<String,Deal_Approval_Structure.Winform>(); 
		map<Id,List<Deal_Approval__c>> mapOppToExistingApprovals = new map<Id,List<Deal_Approval__c>>();
		map<Id,List<Attachment>> mapOppToAttachments = new map<Id,List<Attachment>>();
        //get all the ids of quote approval record types
        map<string, QuoteApprovalRecordTypes__c> qaRecTypeIds = QuoteApprovalRecordTypes__c.getAll();
		
		//Get the data from the Integration Logs into the Winform data structure for processing.
		system.debug('IntLogWFApprovals = '+IntLogWFApprovals);
		mapWinforms = Deal_Approval_Structure.getMapWinformData(IntLogWFApprovals);
		system.debug('Winform map data = '+mapWinforms);

		//Get all pending deal approval records related to the opportunities into a map
		mapOppToExistingApprovals = Deal_Approval_Structure.getMapOppToExistingApprovals(idsWFApprovals, daRecordTypeIds);
		system.debug('mapOppToExistingApprovals = '+mapOppToExistingApprovals);
		
		//Get all attachments for the opportunities into a map
		mapOppToAttachments = CommonFunctions.getAttachmentsMap(idsWFApprovals);
		system.debug('Attachment list in mapOppToAttachments = '+mapOppToAttachments);
		
		//Get the Opportunities related to the Winforms
		map<Id,Opportunity> mapOpportunities = new map<Id,Opportunity>([select Id, Name, Total_Approvals_Required__c, Approval_Status__c, Approver_Names__c from Opportunity where Id in: idsWFApprovals]);
		system.debug('Opportunity list - '+mapOpportunities);
		
		//Check for any Winforms of the same name that have already been processed.  If found, this is a duplicate submission and can be ignored.
		Set<String> processedWinforms = new Set<String>();
		for(Integration_Log__c processedLog : [select External_Id__c from Integration_Log__c where External_Id__c in :mapWinforms.keySet() and isSuccess__c = true])
		{
			processedWinforms.add(processedLog.External_Id__c);
		}
		
		//////////////////////////////////////////////////////////////////
		//Loop through and process all Winform Deal Approvals
		//////////////////////////////////////////////////////////////////
		List<Deal_Approval__c> outdatedDealApprovals = new List<Deal_Approval__c>();
		List<Deal_Approval__c> newDealApprovals = new List<Deal_Approval__c>();
		Approval.ProcessSubmitRequest[] wfApprReqs = new Approval.ProcessSubmitRequest[]{};
		List<Opportunity> updatedOpportunities = new List<Opportunity>();
		set<Id> oppIds = new set<Id>();
		map<Id,String> mapOppToWinform = new map<Id,String>();
		Integer iNumApprovals;
		String strApproverList;
		Boolean bApprovalRecordsCreated;
        Boolean quoteApprovalRecord;
        Boolean dealApprovalRecord;
		
		//Loop through each Winform and process
		for(Deal_Approval_Structure.Winform wf : mapWinforms.values())
		{
			wf.UpdateStatus = null;
            quoteApprovalRecord = false;
            dealApprovalRecord = false;
			system.debug('Current Winform map data = '+wf);
			
			if(processedWinforms.contains(wf.Id))
			{
				wf.UpdateStatus = 'Duplicate Submission - Winform Previously Processed';
				wf.IsProcessed = true;
				system.debug('Duplicate Winform Id - '+wf.Id+' - Not Processed');
			}
			
			//Do not process if this has already been processed in this operation or previously
			if(wf.IsProcessed == false && !processedWinforms.contains(wf.Id))
			{			
				iNumApprovals = 0;
				strApproverList = '';
				bApprovalRecordsCreated = false;
				Boolean bFilenameMatch = false;
				system.debug('Current Winform: '+wf.Id);
				
				//Verify the Winform file is attached to the opportunity
				if(mapOppToAttachments.keySet().contains(wf.OpportunityId))
				{
					//Extract the Winform filename from the given file path 
					String sFileName = wf.FileName;
					system.debug('Winform file name: '+sFileName);
					
					//If the filename is blank or can't be extracted, we can't verify if the file exists.  To avoid losing data, we mark it as an error and continue to the next item.
					if(sFileName == '' || sFileName == null)
					{
						system.debug('Filename blank or unable to read.  Continue to next Winform');
						wf.UpdateStatus = 'Attachment Verify Failed1';
						//continue;
					}
					else
					{
						//Loop through Opp attachments to check if there is a match
						for(Attachment oppAtt : mapOppToAttachments.get(wf.OpportunityId))
						{
							system.debug('Current Attachment: '+oppAtt.Name);
							if(oppAtt.Name == sFileName)
							{
								//If the incoming Winform filename does match an existing attachment, this verifies the file was uploaded successfully.
								system.debug('Attachment match');
								bFileNameMatch = true;
								wf.AttachmentId = oppAtt.Id;
								//break;
							}
						}
					}
					
					//If there are Approval records on the Opp but no attachments, it is odd, but we continue to process as a re-submission	
				}
				system.debug('Current Winform map data = '+wf);
				
				//If there is no match, the file is missing, and we need to send a notification email, then continue to the next item to process.
				if(bFileNameMatch == false)
				{
					system.debug('Winform filename not matched to an attachment.');
					wf.UpdateStatus = 'Attachment Verify Failed2';
					String errMessage = 'Unable to verify the Winform file ' + wf.FileName + ' was successfully attached to the opportunity with Id '+wf.OpportunityId;
					String errSubject = 'Error Updating Opportunity in Winform Deal Approval integration';
					String errLocation = 'IntegrationLog.processWFApprovals - Opportunity Id '+wf.OpportunityId;
					CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),errSubject,errLocation,new CommonFunctions.CustomException(errMessage));
					//continue;
				}
				else
				{
					//If there have been no failures with this Winform so far, continue processing
					if(wf.UpdateStatus == null)
					{
						//Check if any untouched Approval records exist on the Opportunity.  If so, this indicates it is a re-submission and we need to remove any untouched approval requests.
						if(mapOppToExistingApprovals.keySet().contains(wf.OpportunityId))
						{
							//Add the existing approval records for this Opp to the list to be deleted 
							outdatedDealApprovals.addAll(mapOppToExistingApprovals.get(wf.OpportunityId));
							system.debug('Outdated Deal Approvals found: '+outdatedDealApprovals);
							
						}//end if Deal Approval records already exist
			
						//Create the new Deal Approval records for the Buckets
						List<Deal_Approval__c> wfDealApprovals = new List<Deal_Approval__c>();
						try
						{
							system.debug('Creating Deal Approval records for Winform '+wf.Id);
							wfDealApprovals = Deal_Approval_Structure.createDealApprovalRecords(wf);	
						}
						catch(Exception e)
						{
							System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
							wf.UpdateStatus = 'Deal Approval Record Creation Failed';
							String errSubject = 'Error Creating Winform Deal Approval records';
							String errLocation = 'IntegrationLog.processWFApprovals - Opportunity Id '+wf.OpportunityId;
							CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),errSubject,errLocation,e);
							continue;
						}
						wf.UpdateStatus = 'Deal Approval Record Creation Success';
						newDealApprovals.addAll(wfDealApprovals);
						if(wfDealApprovals.size()>0)
							bApprovalRecordsCreated = true;
						
						//Loop through Buckets on this Winform to prepare the fields to update on the opportunity
						for(Deal_Approval_Structure.WinformBucket wfBucket : wf.mapBuckets.values())
						{
							if(wfBucket != null)
							{
								//Update the total count of approvals for this Winform
								iNumApprovals = iNumApprovals + wfBucket.Approvals.size();
								
								//Build approver list for Opportunity update
								for(Deal_Approval_Structure.WinformApproval a : wfBucket.Approvals)
								{
									if(strApproverList != '')
										strApproverList = strApproverList + '\n';
									strApproverList = strApproverList + wfBucket.RecTypeName + ' - ' + a.LevelName;
								}
                                
                                //check if this is Quote Approval record
                                if(wfBucket.RecTypeId != null && qaRecTypeIds != null && qaRecTypeIds.containsKey(wfBucket.RecTypeId)){
                                   quoteApprovalRecord = true; 
                                } else if(wfBucket.RecTypeId != null && qaRecTypeIds != null && !qaRecTypeIds.containsKey(wfBucket.RecTypeId)) {
                                	dealApprovalRecord = true;
                                } else {
                                	dealApprovalRecord = true;
                                }
							}
						}			
						system.debug('Pending Opp update for Number of Approvals: '+iNumApprovals);
						system.debug('Pending Opp update for List of Approvers: '+strApproverList);
						
						//Update the Winform fields on the Opportunity
						Opportunity opp = mapOpportunities.get(wf.OpportunityId);
						mapOppToWinform.put(opp.Id,wf.Id);
						opp.Total_Approvals_Required__c = iNumApprovals;
						
						if(dealApprovalRecord == false && quoteApprovalRecord == false){
							dealApprovalRecord = true;
						}
                        //if the record is not for quote approval then set the Approval Status on Opportunity
                        if(dealApprovalRecord == true){
                            if(bApprovalRecordsCreated == true)
                                opp.Approval_Status__c = 'Pending Approval';
                            else
                                opp.Approval_Status__c = 'Not Required';
                        } 
                        if(quoteApprovalRecord == true) {
                            if(bApprovalRecordsCreated == true)
                                opp.PS_Quote_Approval_Status__c = 'Pending';
                            else
                                opp.PS_Quote_Approval_Status__c = 'Not required';
                        }
						system.debug('Approval Status:'+opp.Approval_Status__c);
						opp.Approver_Names__c = strApproverList;
						opp.Winform_Reference__c = wf.Id;
						//this is to check that same opp is not added twice
						if(!oppIds.contains(opp.Id)){
							updatedOpportunities.add(opp);
							oppIds.add(opp.Id);
						}
						
						//update the isProcessed flag on the Winform
						wf.UpdateStatus = 'Success';
						wf.IsProcessed = true;
					}
				}
				system.debug('Current Winform map data = '+wf);
			}//end If IsProcessed=False
		}//end Winform processing loop
		
		//apply the Opportunity updates and verify the results
		Database.SaveResult[] resultsOppUpdate = Database.update(updatedOpportunities,false);
		system.debug('results list: '+resultsOppUpdate);
		system.debug('updated records: '+updatedOpportunities);
		for(Integer x = 0; x <= updatedOpportunities.size()-1; x++)
		{
			if(!resultsOppUpdate[x].isSuccess())
			{
				mapWinforms.get(mapOppToWinform.get(updatedOpportunities[x].Id)).UpdateStatus = 'Opportunity Update Failed';
				String errMessage = resultsOppUpdate[x].getErrors()[0].getStatusCode()+' - '+resultsOppUpdate[x].getErrors()[0].getFields()+' - '+resultsOppUpdate[x].getErrors()[0].getMessage();
				String errSubject = 'Error Updating Opportunity in Winform Deal Approval integration';
				String errLocation = 'IntegrationLog.processWFApprovals - Opportunity Id '+mapWinforms.get(mapOppToWinform.get(updatedOpportunities[x].Id)).OpportunityId;
				system.debug('Error updating Opportunity: '+errMessage);
				CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),errSubject,errLocation,new CommonFunctions.CustomException(errMessage));
			}
		}
		
		//delete the untouched approval process records that were identified above.  
		try
		{
			//If there is an error, continue processing the rest of them
			Database.DeleteResult[] resultsDeleteDAs = Database.delete(outdatedDealApprovals,false);
		}
		catch(Exception e)
		{
			System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
		}
		
		//Loop through list of new Deal Approvals and remove any where the Opportunity update failed.
		Deal_Approval__c removedDA;
		for(Integer x = 0; x <= newDealApprovals.size()-1; x++)
		{
			//if(failedOppUpdated.contains(d[x].Opportunity__c))
			system.debug('Check for Opp update failures... UpdateStatus= '+mapWinforms.get(newDealApprovals[x].Approval_Ref__c).UpdateStatus);
			if(mapWinforms.get(newDealApprovals[x].Approval_Ref__c).UpdateStatus == 'Opportunity Update Failed')
				removedDA = newDealApprovals.Remove(x);
		}
		//Insert the Deal Approval records and verify the results
		Database.SaveResult[] resultsDealApprovalInsert = Database.insert(newDealApprovals,false);
		system.debug('results list: '+resultsDealApprovalInsert);
		for(Integer x = 0; x <= newDealApprovals.size()-1; x++)
		{
			if(!resultsDealApprovalInsert[x].isSuccess())
			{
				mapWinforms.get(newDealApprovals[x].Approval_Ref__c).mapBuckets.get(newDealApprovals[x].RecordTypeId).UpdateStatus = 'Deal Approval Insert Failed';
				String errMessage = resultsDealApprovalInsert[x].getErrors()[0].getStatusCode()+' - '+resultsDealApprovalInsert[x].getErrors()[0].getFields()+' - '+resultsDealApprovalInsert[x].getErrors()[0].getMessage();
				String errSubject = 'Error Inserting Deal Approval record in Winform Deal Approval integration';
				String errLocation = 'IntegrationLog.processWFApprovals - Intergration Log Id '+newDealApprovals[x].Id;
				system.debug('Error inserting Deal Approval record: '+errMessage);
				CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),errSubject,errLocation,new CommonFunctions.CustomException(errMessage));
			}
		}
		system.debug('Winform map data = '+mapWinforms);
		
		//Loop back through the Buckets (Deal Approval records) and create the Approval Process records now that we have an Id for the Deal Approval records
		Map<Id,Deal_Approval__c> mapNewDealApprovals = new map<Id,Deal_Approval__c>();
		for(Deal_Approval__c da : newDealApprovals)
		{
			//If the Deal Approval record was added successfully
			if(mapWinforms.get(da.Approval_Ref__c).mapBuckets.get(da.RecordTypeId).UpdateStatus != 'Deal Approval Insert Failed')
			{
				//Create the Approval Request records to be inserted
				system.debug('da.Id='+da.Id);
				system.debug('mapWinforms.get(da.Approval_Ref__c).mapBuckets.get(da.RecordTypeId).Approvals='+mapWinforms.get(da.Approval_Ref__c).mapBuckets.get(da.RecordTypeId).Approvals);
				system.debug('mapWinforms.get(da.Approval_Ref__c).SubmittedBy='+mapWinforms.get(da.Approval_Ref__c).SubmittedBy);
				Approval.Processsubmitrequest[] daApprovals = Deal_Approval_Structure.createApprovalRequests(da.Id,mapWinforms.get(da.Approval_Ref__c).mapBuckets.get(da.RecordTypeId).Approvals,mapWinforms.get(da.Approval_Ref__c).SubmittedBy);
				if(daApprovals.size() > 0)
				{					
					wfApprReqs.addAll(daApprovals);
					mapNewDealApprovals.put(da.Id,da);
				}
			}
		}
		//Submit the Approval Requests to start the process and verify the results
		system.debug('Approvals to process: '+wfApprReqs);
		Approval.ProcessResult[] resultsApprReqs = Approval.process(wfApprReqs,false);
		system.debug('Approval Request results: '+resultsApprReqs);
		Set<Id> setApproverIds;
		for(Integer x = 0; x <= wfApprReqs.size()-1; x++)
		{
			if(!resultsApprReqs[x].isSuccess())
			{
				setApproverIds = new Set<Id>();
				setApproverIds.addAll(wfApprReqs[x].getNextApproverIds());
				for(Deal_Approval_Structure.WinformApproval wfa : mapWinforms.get(mapNewDealApprovals.get(wfApprReqs[x].getObjectId()).Approval_Ref__c).mapBuckets.get(mapNewDealApprovals.get(wfApprReqs[x].getObjectId()).RecordTypeId).Approvals)
				{
					if(setApproverIds.contains(wfa.ApproverUserId))
						wfa.UpdateStatus = 'Approval Request Insert Failed';
				}
				String errMessage = resultsApprReqs[x].getErrors()[0].getStatusCode()+' - '+resultsApprReqs[x].getErrors()[0].getFields()+' - '+resultsApprReqs[x].getErrors()[0].getMessage();
				String errSubject = 'Error Inserting Approval Process records in Winform Deal Approval integration';
				String errLocation = 'IntegrationLog.processWFApprovals - Deal Approval Id '+mapNewDealApprovals.get(wfApprReqs[x].getObjectId()).Id;
				system.debug('Error inserting new Approval Process records: '+errMessage);
				CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),errSubject,errLocation,new CommonFunctions.CustomException(errMessage));
			}
		}
		
		//Loop back through the Winform structure to create a map for the success/fail update
		map<Integer,String> mapUpdateResults = new map<Integer,String>();
		for(Deal_Approval_Structure.Winform wfAfter : mapWinforms.values())
		{
			system.debug('Current Winform map data BEFORE = '+wfAfter);
			//Check for any errors at the Winform level
			String strWinformStatus;
			if(wfAfter.UpdateStatus == null || wfAfter.UpdateStatus == 'Success')
			{
				strWinformStatus = 'Success';
			}
			else
			{
				strWinformStatus = wfAfter.UpdateStatus;
			}
			
			system.debug('wfAfter.mapBuckets:'+wfAfter.mapBuckets);
			for(Deal_Approval_Structure.WinformBucket wfbAfter : wfAfter.mapBuckets.values())
			{
				system.debug('wfbAfter:'+wfbAfter);
				if(wfbAfter != null)
				{
					//Check for any errors at the Winform Bucket level
					String strBucketStatus;
					if(wfbAfter.UpdateStatus == null || wfbAfter.UpdateStatus == 'Success')
					{
						strBucketStatus = 'Success';
					}
					else
					{
						strBucketStatus = wfbAfter.UpdateStatus;
					}
						
					for(Deal_Approval_Structure.WinformApproval wfaAfter : wfbAfter.Approvals)
					{
						system.debug('wfaAfter:'+wfaAfter);
						if(wfaAfter != null)
						{
							//Check for any errors at the Winform Approval level
							String strApprovalStatus;
							if(wfaAfter.UpdateStatus == null || wfaAfter.UpdateStatus == 'Success')
							{
								strApprovalStatus = 'Success';
							}
							else
							{
								strApprovalStatus = wfaAfter.UpdateStatus;
							}
								
							//Update the map with the results for the Winform, Bucket, and Approval
							system.debug('wfaAfter.IntLogId:'+wfaAfter.IntLogId);
							system.debug('strWinformStatus:'+strWinformStatus);
							system.debug('strBucketStatus:'+strBucketStatus);
							system.debug('strApprovalStatus:'+strApprovalStatus);
							mapUpdateResults.put(wfaAfter.IntLogId,'Winform:'+strWinformStatus+';Bucket:'+strBucketStatus+';Approval:'+strApprovalStatus);
						}
					}
				}
			}
			system.debug('Current Winform map data AFTER = '+wfAfter);
			//system.debug('mapUpdateResults = '+mapUpdateResults);
		} 
		
		//Loop back through the Integration Logs and update the isSuccess flag and status message appropriately
		for(Integer x = 0; x <= IntLogWFApprovals.size()-1; x++)
		{
			String result; 
			if(mapUpdateResults.containsKey(x))
			{	
				result = mapUpdateResults.get(x);
				IntLogWFApprovals[x].Message__c = result;
				if(result.contains('Failed'))
				{
					IntLogWFApprovals[x].isSuccess__c = false;
					IntLogWFApprovals[x].Status__c = 'Failed';
				}
				else
				{
					IntLogWFApprovals[x].isSuccess__c = true;
					IntLogWFApprovals[x].Status__c = 'Success';
				}
				system.debug(IntLogWFApprovals[x].External_Id__c+' isSuccess/Result = '+IntLogWFApprovals[x].isSuccess__c+'/'+result);
				system.debug('IntLog = '+IntLogWFApprovals[x]);
			}
			else
			{ 
				IntLogWFApprovals[x].Message__c = 'Successfully processed (no updates)';
				IntLogWFApprovals[x].isSuccess__c = true;
				IntLogWFApprovals[x].Status__c = 'Success';
			}
		}
		
	}
	
}