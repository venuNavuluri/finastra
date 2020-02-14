public class IntegrationLog_Proposal_SingleOppty
{
	private boolean isTestSetup;
	private Opportunity theOpp;
	private Set<Id> pbeIds;
	private Integration_Log__c[] allIntLogs;
	private IntLogRecord[] upToDateIntLogs;
	
	private Id getOppId() { return theOpp.Id; }
	
	private Map<Id, IntLogRecord[]> oppIdToIntLogListMap = new Map<Id, IntLogRecord[]>();

	public static void processPPOPPLINE_n_PPOPPMILE(Opportunity opp, List<Integration_Log__c> intLogs)
	{
		processPPOPPLINE_n_PPOPPMILE(opp, intLogs, false);
	}
	
	public static void processPPOPPLINE_n_PPOPPMILE(Opportunity opp, List<Integration_Log__c> intLogs, boolean testSetup)
	{
		IntegrationLog_Proposal_SingleOppty mgr = new IntegrationLog_Proposal_SingleOppty(opp, intLogs, testSetup);
		mgr.doProcess();
	}
	
	private IntegrationLog_Proposal_SingleOppty(Opportunity opp, List<Integration_Log__c> intLogs, boolean testSetup)
	{
		isTestSetup = testSetup;
		theOpp = opp;
		allIntLogs = intLogs;
		upToDateIntLogs = IntegrationLog_ProposalSO_InitUtils.GetUpToDateIntLogWrapperList(intLogs);
		pbeIds = IntegrationLog_ProposalSO_InitUtils.GetPricebookIDs(upToDateIntLogs);
	}
	
	private void doProcess()
	{
		// select the OLIs and BSIs under it
		ProposalLineItem[] oppProposalLIs = IntegrationLog_ProposalSO_QueryUtils.QueryExistingProposalLineItems(getOppId());

		// delete those, where the existing ones are not from a previous batch of the same lot
		// (note, that we're filtering the original intLogs further as well: if they are outdated, then we'll discard the whole incoming lot
		ProposalLineItem[] plisToKeep = new ProposalLineItem[]{};
		ProposalLineItem[] plisToDelete = new ProposalLineItem[]{};
		IntegrationLog_ProposalSO_SortUtils.ReconcilePLIsAndILs(/*in*/oppProposalLIs, /*in-out*/upToDateIntLogs, /*out*/plisToKeep, /*out*/plisToDelete);
		
		// now the plisToKeep collection contains everything that need to be kept (the deletable items have just been removed)
		ProposalLineItem[] keeperOLIs = new ProposalLineItem[]{};
		ProposalLineItem[] keeperBSIs = new ProposalLineItem[]{};
		IntegrationLog_ProposalSO_SortUtils.SortPLIsByType(/*in*/plisToKeep, /*out*/keeperOLIs, /*out*/keeperBSIs);

		// get a map of the billing schedules. key: <proposalID>#<processing type>
		Map<string, Opportunity_Billing_Schedule__c> OBSMap = IntegrationLog_ProposalSO_QueryUtils.QueryOBSes(getOppId());

		// collect the OBS keys in the update: <proposalId>#<procType>
		// loop through oppProposalLIs, and oppIdToIntLogListMap
		Set<string> keeperOBSKeys = IntegrationLog_ProposalSO_SortUtils.CollectKeeperOBSKeys(plisToKeep, upToDateIntLogs);

		// loop through OBSMap:
		// 1. pick the ones to delete, and put them to a collection
		// 2. remove them from the original
		Opportunity_Billing_Schedule__c[] deletableOBSes = IntegrationLog_ProposalSO_SortUtils.SortOBSes(/*in*/keeperOBSKeys, /*in-out*/OBSMap);

		// divide the list to OLIs and BSIs to delete
		ProposalLineItem[] deletable_OLIs = new ProposalLineItem[]{};
		ProposalLineItem[] deletable_MSs = new ProposalLineItem[]{};
		IntegrationLog_ProposalSO_SortUtils.SortPLIsByType(/*in*/plisToDelete, /*out*/deletable_OLIs, /*out*/deletable_MSs);

		// create the new PLIs
		ProposalLineItem[] plisToInsert = IntLogRecord.CreatePLILists(upToDateIntLogs);

		//Get details of the pricebook entries
		Map<Id, PricebookEntry> pbeIdToPBE = IntegrationLog_ProposalSO_QueryUtils.QueryPricebookAndBuildMap(pbeIds);
		
		// now we get the affected oppties
		Opportunity oppty = theOpp;
		// update the opp with the new pricebook and currency, and pearl-mastered flag. Note, that the OLI lines drive the opportunity update!
		Boolean needToUpdateOppty = updateOpptyIfNecessary(oppty, upToDateIntLogs, pbeIdToPBE);
		
		// create the new billing schedule headers
		Opportunity_Billing_Schedule__c[] newOBSList = createMissingOBSes(/*in*/upToDateIntLogs, /*in-out*/OBSMap);

		IntegrationLog_ProposalSO_SaveUtils.DoSave(
			oppty, needToUpdateOppty,
			OBSMap,
			deletableOBSes, newOBSList,
			deletable_OLIs, keeperOLIs, plisToInsert, upToDateIntLogs,
			deletable_MSs,
			allIntLogs,
			isTestSetup
		);
	}
	
	private static Opportunity_Billing_Schedule__c[] createMissingOBSes(
		IntLogRecord[] ILs,
		Map<string, Opportunity_Billing_Schedule__c> OBSMap)
	{
		Opportunity_Billing_Schedule__c[] OBSList = new Opportunity_Billing_Schedule__c[]{};
		Opportunity_Billing_Schedule__c newOBS;
		string obsKey;
		
		for (IntLogRecord il : ILs) {
			if (!il.definesBillingSchedule()) { continue; }
			obsKey = il.getProposalID() + '#' + il.getProcessingType();
			if (!OBSMap.containsKey(obsKey)) { // if the required OBS does not exist, then need to create
				newOBS = il.CreateHeader();
				OBSList.add(newOBS);
				
				// add it to the map as well, so that we can pick the OBS ID by its key, and update the reference on the new OLI/BSI records 
				OBSMap.put(obsKey, newOBS);
			}
		}
		return OBSList;
	}
	
	private static Boolean updateOpptyIfNecessary(
		Opportunity oppty,
		IntLogRecord[] upToDateIntLogs,
		Map<Id, PricebookEntry> pbeIdToPBE)
	{
		Boolean needToUpdate = false;
		if (upToDateIntLogs == null || upToDateIntLogs.size() == 0) { return false; }
		if (oppty.CurrencyIsoCode != upToDateIntLogs[0].getCurrencyCode()) {
			oppty.CurrencyIsoCode = upToDateIntLogs[0].getCurrencyCode();
			needToUpdate = true;
		}
		Id pbeId = upToDateIntLogs[0].getPBEid();
		if (pbeId != null &&
			oppty.Pricebook2Id != pbeIdToPBE.get(pbeId).Pricebook2Id) {
			oppty.Pricebook2Id = pbeIdToPBE.get(pbeId).Pricebook2Id;
			needToUpdate = true;
		}
		if (!oppty.Is_PearlMastered__c) {
			oppty.Is_PearlMastered__c = true;
			needToUpdate = true;
		}
		return needToUpdate;
	}

/*	
	private static void dump(Map<Id, IntLogRecord[]> ilMap)
	{
		for (IntLogRecord[] ils : ilMap.values()) {
			for (IntLogRecord il : ils) {
				System.debug(LoggingLevel.Error, '@@@ IL type: ' + il.getType());
			}
		}
	}
*/
	
}