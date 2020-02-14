public class Deal_Approval_Structure {
	public Deal_Approval__c iobj_DA{get; set;}
	public ProcessInstanceStep iProcessInstanceStep_FirstAppr {get; set;}
	public ProcessInstanceStep iProcessInstanceStep_SecondAppr {get; set;}
	public ProcessInstanceStep iProcessInstanceStep_ThirdAppr {get; set;}
	public ProcessInstanceStep iProcessInstanceStep_FourthAppr {get; set;}

	public class DAException extends Exception {}

	public class WinformApproval{
		public Integer intLogId;
		public String RoleId;
		public Integer Level;
		public String LevelName;
		public String Title;
		public String Division;
		public String RecType;
		public String Region;
		public String Branch;
		public String Reason;
		public Boolean HoldBack;
		public String ApproverUserId;
		public String UpdateStatus = null;
	}
	
	public class WinformBucket{
		public String RecTypeId;
		public String RecTypeName;
		public String UpdateStatus = null;
		public List<WinformApproval> Approvals;
	}
	
	public class Winform{
		public String Id;
		public String OpportunityId;
		public String OppNumber;
		public String OppEmail;
		public String FileName;
		public String AttachmentId;
		public String SubmittedBy;
		public DateTime DateSubmitted;
		public String CurrencyIsoCode;
		public Decimal ILF_Discount;
		public Decimal RLF_Discount;
		public Decimal PS_Discount;
		public Decimal FD_Discount;
		public Decimal Deal_Value;
		public Decimal ILF_total;
		public Decimal RLF_Total;
		public Decimal PS_Total;
		public Decimal FD_Total;
		public Boolean IsProcessed;
		public String UpdateStatus = null;
		public Map<String,WinformBucket> mapBuckets;
	}
	
	public static Map<String,Deal_Approval_Structure.Winform> getMapWinformData(List<Integration_Log__c> lIntLogsWinform)
	{
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		//Loop through incoming records and build a data structure with all the info
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		String wfId;
		String wfRecordTypeId;
		Boolean bContinueProcessing;
		Boolean bBlankApproval;
		Integer	listCounter = 0;	//position of the IntLog in the List, used for referring to the record later since the Id is not yet created (this is a BEFORE trigger!)
		Map<String,Deal_Approval_Structure.Winform> mapWinformData = new Map<String,Deal_Approval_Structure.Winform>();
		
		for(Integration_Log__c intLog : lIntLogsWinform)
		{
			bContinueProcessing = true;
			bBlankApproval = false;
			
			//Check if there is actually a deal approval to enter.
			if(intLog.GenString5__c == null)	//RecordTypeId in input data
				bBlankApproval = true;
			
			//Check if we have already added a Winform for this opportunity.  In case of duplicate submission, use the latest
			if(bContinueProcessing == true)
			{
				for(Deal_Approval_Structure.Winform wfCheck : mapWinformData.values())
				{
					//If the Opporunity Id's match and the Winform Id's do not match...
					system.debug('intLog.SFDC_Id__c = '+intLog.SFDC_ID__c);
					system.debug('wfCheck.OpportunityId = '+wfCheck.OpportunityId);
					system.debug('intLog.External_Id__c = '+intLog.External_Id__c);
					system.debug('wfCheck.Id = '+wfCheck.Id);
					
					string[] intLogExternalIdSplit = intLog.External_Id__c.split('-');
					string firstValueIntLogSplit;
					system.debug('intLogExternalIdSplit = ' + intLogExternalIdSplit);
					
					string[] wfCheckIdSplit = wfCheck.Id.split('-');
					string firstValueWfCheckSplit;
					system.debug('wfCheckIdSplit = ' + wfCheckIdSplit);
					
					if(intLogExternalIdSplit != null && intLogExternalIdSplit.size() > 0){
						firstValueIntLogSplit = intLogExternalIdSplit[0];
						system.debug('intLogExternalIdSplit = ' + firstValueIntLogSplit);
					}
					if(wfCheckIdSplit != null && wfCheckIdSplit.size() > 0){
						firstValueWfCheckSplit = wfCheckIdSplit[0];
						system.debug('firstValueWfCheckSplit = ' + firstValueWfCheckSplit);
					}
					//added the criteria to check if the External Id of the winforms are for the same type of Deal. This is done by checking the first portion of the external id.
					if(intLog.SFDC_Id__c == wfCheck.OpportunityId && intLog.External_Id__c != wfCheck.Id && wfCheck.IsProcessed != true && firstValueIntLogSplit == firstValueWfCheckSplit)
					{
						//if current Winform is older than Winform already in list
						system.debug('Found multiple Winforms for the same opportunity.  Newest submission will be used.');
						system.debug('intLog.DateField1__c = '+intLog.DateField1__c);
						system.debug('wfCheck.DateSubmitted = '+wfCheck.DateSubmitted);
						if(intLog.DateField1__c < wfCheck.DateSubmitted)
						{
							//Set the IsProcessed flag = true and add to the map.  Move to the next IntLog record
							Deal_Approval_Structure.Winform wfOld = new Deal_Approval_Structure.Winform();
							wfOld.IsProcessed = true;
							wfOld.OpportunityId = intLog.SFDC_Id__c;
							wfOld.OppNumber = intLog.GenString1__c;
							mapWinformData.put(intLog.External_Id__c,wfOld);
							//Exit the loop since we now need to move to the next IntLog record in the main loop
							bContinueProcessing = false;
							break;
						}
						else
						{
							wfCheck.IsProcessed = true;
							bContinueProcessing = true;
							break;
						}
					}
				}
			}
			
			if(bContinueProcessing == true)
			{
				wfId = intLog.External_Id__c;
				wfRecordTypeId = intLog.GenString5__c;
				Deal_Approval_Structure.WinformApproval wfAppr;
				Deal_Approval_Structure.WinformBucket wfBucket;
				Deal_Approval_Structure.Winform iWF;
				
				if(bBlankApproval == false)
				{
					//Copy the individual approval details
					wfAppr = new Deal_Approval_Structure.WinformApproval();
					wfAppr.intLogId = listCounter;
					wfAppr.RoleId = intLog.GenString6__c;
					wfAppr.Division = intLog.GenString12__c;
					wfAppr.RecType = intLog.GenString10__c;
					wfAppr.Region = intLog.GenString7__c;
					wfAppr.Branch = intLog.GenString8__c;
					wfAppr.Reason = intLog.LongString1__c;
					wfAppr.Title = intLog.GenString9__c;
					wfAppr.LevelName = intLog.GenString13__c;
					wfAppr.HoldBack = intLog.Boolean1__c;
					wfAppr.Level = intLog.NumField10__c.intValue();
					wfAppr.ApproverUserId = intLog.GenString14__c;
				}
					
				//Check if we have already added this Winform Id to the list
				if(!mapWinformData.keySet().contains(wfId))
				{
					if(bBlankApproval == false)
					{
						//Copy the Winform Bucket details
						wfBucket = new Deal_Approval_Structure.WinformBucket();
						wfBucket.Approvals = new List<Deal_Approval_Structure.WinformApproval>();
						wfBucket.RecTypeId = wfRecordTypeId;
						wfBucket.RecTypeName = intLog.GenString11__c;
						
						//Add the Approval record
						wfBucket.Approvals.add(wfAppr);
					}
					
					//Copy the Winform details
					iWF = new Deal_Approval_Structure.Winform();
					iWF.mapBuckets = new Map<String,Deal_Approval_Structure.WinformBucket>();
					iWF.Id = wfId;
					iWF.OpportunityId = intLog.SFDC_Id__c;
					iWF.OppNumber = intLog.GenString1__c;
					iWF.OppEmail = intLog.GenString2__c;
					iWF.FileName = intLog.FilePath1__c;
					iWF.SubmittedBy = intLog.GenString3__c;
					iWF.DateSubmitted = intLog.DateField1__c;
					iWF.CurrencyIsoCode = intLog.GenString4__c;
					iWF.ILF_Discount = intLog.NumField1__c;
					iWF.RLF_Discount = intLog.NumField2__c;
					iWF.PS_Discount = intLog.NumField3__c;
					iWF.FD_Discount = intLog.NumField4__c;
					iWF.Deal_Value = intLog.NumField5__c;
					iWF.ILF_Total = intLog.NumField6__c;
					iWF.RLF_Total = intLog.NumField7__c;
					iWF.PS_Total = intLog.NumField8__c;
					iWF.FD_Total = intLog.NumField9__c;
					iWF.IsProcessed = false;
					//Add the bucket record
					//if(bBlankApproval == false)
						iWF.mapBuckets.put(wfRecordTypeId,wfBucket);
					
					//Add to the maps
					mapWinformData.put(intLog.External_Id__c,iWF);
					
				}
				else  //maps already contain records for the Winform
				{
					//Check if the Bucket does not exist on the Winform
					if(!mapWinformData.get(wfId).mapBuckets.keySet().contains(wfRecordTypeId))
					{
						//Copy the Winform Bucket details
						wfBucket = new Deal_Approval_Structure.WinformBucket();
						wfBucket.Approvals = new List<Deal_Approval_Structure.WinformApproval>();
						wfBucket.RecTypeId = wfRecordTypeId;
						wfBucket.RecTypeName = intLog.GenString11__c;
						
						//Add the Approval record to the Bucket
						wfBucket.Approvals.add(wfAppr);
						
						//Add the Bucket to the Winform
						mapWinformData.get(wfId).mapBuckets.put(wfRecordTypeId,wfBucket);
					}
					else  //Winform already contains the Bucket, so we just add the Approval to the Bucket list
					{
						mapWinformData.get(wfId).mapBuckets.get(wfRecordTypeId).Approvals.add(wfAppr);
					}
				}
			}
			listCounter++;
		}
		return mapWinformData;
	}
	
	public static Map<Id,List<Deal_Approval__c>> getMapOppToExistingApprovals(Set<Id> sOppIds, Set<Id> daRecordTypeIds)
	{	
		//Using the Opportunity Ids, get all pending deal approval records related to the opportunities into a map
		//Retrieving the record type id to match with the Integration Logs to only delete the matching records. 
		Map<Id,List<Deal_Approval__c>> mapOppToExistingApprovals = new Map<Id,List<Deal_Approval__c>>();
		for(Deal_Approval__c currentDA : [select Id, Opportunity__c, Name, RecordTypeId from Deal_Approval__c where Opportunity__c in :sOppIds and RecordTypeId in :daRecordTypeIds and Approval_Status__c = 'Not Started' and Services_Group_Approval_Status__c = 'Not Started'])
		{
			if(!mapOppToExistingApprovals.keySet().contains(currentDA.Opportunity__c))
			{
				mapOppToExistingApprovals.put(currentDA.Opportunity__c,new Deal_Approval__c[]{currentDA});
			}
			else
			{
				mapOppToExistingApprovals.get(currentDA.Opportunity__c).add(currentDA);
			}
		}
		return mapOppToExistingApprovals;
	}	
	
	public static List<Deal_Approval__c> createDealApprovalRecords(Winform wfRecord)
	{
		//Create the Deal Approval records required for the Winform Buckets
		List<Deal_Approval__c> lBuckets = new List<Deal_Approval__c>();
		String strApprovalReasons;
		String strFieldName;
		
		//Get a map of all fields on the Deal Approval object.  This will be used to verify a field exists.
		Map<String, Schema.SObjectField> mapDAfields = Schema.SObjectType.Deal_Approval__c.fields.getMap();
		
		for(WinformBucket b : wfRecord.mapBuckets.values())
		{
			if(b != null)
			{
				Deal_Approval__c da = new Deal_Approval__c();
				da.Name = wfRecord.OppNumber + ' - ' + b.RecTypeName;
				da.RecordTypeId = b.RecTypeId;
				da.Approval_Ref__c = wfRecord.Id;
				da.Opportunity__c = wfRecord.OpportunityId;
				da.Submitted_By__c = wfRecord.SubmittedBy;
				da.CurrencyIsoCode = wfRecord.CurrencyIsoCode;
				da.Date_Submitted__c = wfRecord.DateSubmitted.Date();
				da.Winform_Attachment_Id__c = wfRecord.AttachmentId;
				da.Deal_Value__c = wfRecord.Deal_Value;
				da.ILF_Discount__c = wfRecord.ILF_Discount;
				da.RLF_Discount__c = wfRecord.RLF_Discount;
				da.PS_Discount__c = wfRecord.PS_Discount;
				da.FD_Discount__c = wfRecord.FD_Discount;
				da.ILF_Total__c = wfRecord.ILF_Total;
				da.RLF_Total__c = wfRecord.RLF_Total;
				da.PS_Total__c = wfRecord.PS_Total;
				da.FD_Total__c = wfRecord.FD_Total;
				
				strApprovalReasons = '';
				for(WinformApproval wfa : b.Approvals)
				{
					//Create the field string for the Approval checkbox flag (this field determines which approval process runs)
					strFieldName = wfa.Division + '_' + wfa.RecType + '_' + wfa.RoleId + '_' + 'Approval__c';
					
					//Correct the field name for an exception
					if(strFieldName == 'TCM_EVP_EV_Approval__c')
						strFieldName = 'TCM_EVP_Approval__c'; 
					
					//Build list of Approval Reasons
					if(wfa.Title != null)
						strApprovalReasons = strApprovalReasons + wfa.Title + ':\n';
					if(wfa.Reason != null)
					{
						strApprovalReasons = strApprovalReasons + wfa.Reason + '\n\n';
					}
					
					//Update the specific Approval checkbox flag
					system.debug('strFieldName:'+strFieldName);
					try{
						//if(!mapDAfields.keySet().contains(strFieldName))
						//	throw new DAException('Error: Constructed field name '+strFieldName+' does not exist.');
						da.put(strFieldName,true);
					}
					catch(Exception e)
					{
						System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
						wfRecord.UpdateStatus = 'Deal Approval Record Creation Failed';
						String errSubject = 'Error Setting flag for Winform Approval process';
						String errLocation = 'IntegrationLog.processWFApprovals - field name '+strFieldName ;
						CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),errSubject,errLocation,e);
						continue;
					}
				}
			system.debug('strApprovalReasons:'+strApprovalReasons);
			da.Approval_Reasons__c = strApprovalReasons;
			system.debug('new Deal Approval da: '+da);
			lBuckets.add(da);
			}
		}
		return lBuckets;
	}
	
	public static Approval.ProcessSubmitRequest[] createApprovalRequests(Id ParentId, List<WinformApproval> wfApprovals, String strSubmittedBy)
	{
		//Create the Approval Process records on the Deal Approval record
		Approval.ProcessSubmitRequest[] apprReqs = new Approval.ProcessSubmitRequest[]{};
		List<Id> idApprovers = new List<Id>();
		
		//Loop through list of approvals for this bucket
		//for(WinformApproval appr : wfApprovals)
		//{
		//Get the first required approval and set the approver name
		WinformApproval appr = wfApprovals[0];
			if(appr.Title != '' && appr.HoldBack == false)
			{
				//Set the next approver.  The view used to insert the data has already sorted the approvers in the correct order.
				if(appr.ApproverUserId != null && appr.ApproverUserId != '')
				{
					if(IntegrationLog.isTestMode)
						idApprovers.add(IntegrationLog.testApproverId);
					else
						idApprovers.add(appr.ApproverUserId);
				//else
					//NOTIFY:  No Approver assigned!!
				}
			}	
		//}
		
		//Create the approval request
		Approval.ProcessSubmitRequest apprReq = new Approval.ProcessSubmitRequest();
		if(idApprovers.size() == 1)
		{
			apprReq.setObjectId(ParentId);
			apprReq.setNextApproverIds(idApprovers);  //Set only the first approver in the list
			apprReq.setComments('Submitted by: ' + strSubmittedBy);
			apprReqs.add(apprReq);
			system.debug('prepared Approval Request approver list: '+apprReq.getNextApproverIds());
		}
		else if(idApprovers.size() >1)
		{	
			appr.UpdateStatus = 'Deal Approval Record Creation Failed';
			CommonFunctions.CustomException ce = new CommonFunctions.CustomException('More than one Approver selected for Deal Approval with id '+ParentId);
			CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),'Error Submitting Approval request ','IntegrationLog.processWFApprovals',ce);
		}
		
		return apprReqs;
	}
}