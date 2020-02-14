public class IntegrationLog_ProposalSO_SaveUtils
{
	public static void DoSave(
		Opportunity oppty, Boolean updateOpp, Map<string, Opportunity_Billing_Schedule__c> OBSMap,
		Opportunity_Billing_Schedule__c[] deletableOBSes,  Opportunity_Billing_Schedule__c[] newOppOBSList,
		ProposalLineItem[] deletable_OLIs, ProposalLineItem[] keeperOLIs, ProposalLineItem[] PLIsToInsert, IntLogRecord[] ILList,
		ProposalLineItem[] deletable_MSs,
		Integration_Log__c[] allIntLogs,
		boolean testSetup)
	{
		System.debug(LoggingLevel.Error, '@@@ saving');
		SavePoint sp = Database.setSavePoint();
		Boolean success = SaveForOneOppty(
			oppty, updateOpp, OBSMap,
			deletableOBSes,  newOppOBSList,
			deletable_OLIs, keeperOLIs, PLIsToInsert, ILList,
			deletable_MSs,
			allIntLogs, sp
		);

		// if setting up a test case then we don't have the intLogs in the DB (we're synchronously creating the lineitems on a "floating" set of intLogs)
		if (testSetup) { return; }
		try { // prepare the responses to Pearl
			for (Integration_Log__c intLog : allIntLogs) {
				intLog.ReceivedTime__c = DateTime.now();
			}
			update allIntLogs;

			ChatterUtils.PostOpportunityMessage(oppty.Id, success, PLIsToInsert.size());
		}
		catch (Exception e)	{
			Database.rollBack(sp);
			String error = 'Failed to receive proposal line items! Opportunity number: ' + (oppty == null ? '?' : oppty.Order_Number__c);
			System.debug(LoggingLevel.ERROR, error);
			ChatterUtils.PostOpportunityMessage(oppty.Id, error);
		}
	}

	private static Boolean SaveForOneOppty(
		Opportunity oppty, Boolean updateOpp, Map<string, Opportunity_Billing_Schedule__c> OBSMap,
		Opportunity_Billing_Schedule__c[] deletableOBSes,  Opportunity_Billing_Schedule__c[] newOppOBSList,
		ProposalLineItem[] deletable_OLIs, ProposalLineItem[] keeperOLIs, ProposalLineItem[] PLIsToInsert, IntLogRecord[] ILList,
		ProposalLineItem[] deletable_MSs,
		Integration_Log__c[] allIntLogs,
		SavePoint sp)
	{
		IntLogRecord[] ILList_OLI = new IntLogRecord[]{};
		IntLogRecord[] ILList_MS = new IntLogRecord[]{};
		ProposalLineItem[] OLIsToInsert = new ProposalLineItem[]{};
		ProposalLineItem[] BSIsToInsert = new ProposalLineItem[]{};
		Boolean success = false;

		try {
			if (deletable_OLIs != null && !deletable_OLIs.isEmpty()) {
				GlobalVar.bSystemAllowOppLineItemDelete = true;
				delete ProposalLineItem.GetSObjectList(deletable_OLIs);
			}
			
			if (deletable_MSs != null && !deletable_MSs.isEmpty()) { delete ProposalLineItem.GetSObjectList(deletable_MSs); }
			
			if (deletableOBSes != null && !deletableOBSes.isEmpty()) { delete deletableOBSes; }
							
			if (updateOpp) {
				//AK - added the below line to mark it as future job as it is running via the batch job and the account trigger is called internally.
				GlobalVar.bInFuture = true; 
				update oppty; 
			}

			// divide the intlogs to OLIs and BSIs to create
			IntegrationLog_ProposalSO_SortUtils.SortIntLogsByType(/*in*/ILList, /*out*/ILList_OLI, /*out*/ILList_MS);
	
			// create the new OLIs and BSIs
			IntegrationLog_ProposalSO_SortUtils.SortPLIsByType(/*in*/PLIsToInsert, /*out*/OLIsToInsert, /*out*/BSIsToInsert);

			saveOBSes(newOppOBSList, OBSMap, OLIsToInsert, keeperOLIs, BSIsToInsert);

			if (keeperOLIs != null && !keeperOLIs.isEmpty()) { update ProposalLineItem.GetSObjectList(keeperOLIs); }

			// from now on we can do a record-by-record update
			if (OLIsToInsert != null && !OLIsToInsert.isEmpty()) {
				if (!doInsertProposalLIs(ProposalLineItem.GetSObjectList(OLIsToInsert), ILList_OLI)) {
					IntegrationLogUtils.markILsWithErr(ILList_MS, 'Failed to save some OLI records!');
					return false;
				}
			}
			
			if (BSIsToInsert != null) {
				return doInsertProposalLIs(ProposalLineItem.GetSObjectList(BSIsToInsert), ILList_MS);
			}
			return true;
		}
		catch(Exception e) {
			System.debug(LoggingLevel.ERROR, 'XXX IntegrationLog_ProposalSO_SaveUtils.SaveForOneOppty: Rollback exception: ' + e.getMessage());
			System.debug(LoggingLevel.ERROR, 'Stacktrace: ' + e.getStackTraceString());
			Database.rollBack(sp);
			IntegrationLogUtils.markILsWithErr(ILList_OLI, e);
			IntegrationLogUtils.markILsWithErr(ILList_MS, e);
			return false;
		}
	}
	
	private static void setOBSRef(ProposalLineItem[] PLIs, Map<string, Opportunity_Billing_Schedule__c> OBSMap)
	{
		if (PLIs != null) {
			/// set the OBS reference on the line items:
			for (ProposalLineItem pli : PLIs) {
				string key = pli.getProposalID() +  '#' + pli.getProcessingType();
				Opportunity_Billing_Schedule__c obs = OBSMap.get(key);
				if (obs != null) {	pli.setOBSid(obs.Id); }
			}
		}
	}
	
	private static void saveOBSes(
		Opportunity_Billing_Schedule__c[] newOppOBSList, Map<string, Opportunity_Billing_Schedule__c> OBSMap,
		ProposalLineItem[] OLIsToInsert, ProposalLineItem[] keeperOLIs, ProposalLineItem[] BSIsToInsert)
	{
		if (newOppOBSList != null && !newOppOBSList.isEmpty()) {
			insert newOppOBSList;
		}
		
		setOBSRef(BSIsToInsert, OBSMap);
		setOBSRef(OLIsToInsert, OBSMap);
		setOBSRef(keeperOLIs, OBSMap);
	}
	
	private static Boolean doInsertProposalLIs(SObject[] propLIsToInsert, IntLogRecord[] ILs)
	{
		Boolean success = true;
		// we assume that the list of records to create is in the same order as the SaveResult records that are returned
		Database.SaveResult[] saveResults = Database.Insert(propLIsToInsert, false);
			
		for(Integer i = 0; i < saveResults.size(); i++) {
			IntLogRecord intLog = ILs[i];
				
			if (saveResults[i].isSuccess()) { intLog.setSuccess(); }
			else {
				intLog.setError(saveResults[i].getErrors());
				success = false;
			}
		}
		return success;
	}
	
}