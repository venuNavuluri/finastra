public class IntegrationLog_ProposalSO_SortUtils
{
	public static void ReconcilePLIsAndILs(
		/*in*/ProposalLineItem[] proposalLIList,
		/*in-out*/IntLogRecord[] intLogList,
		/*out*/ProposalLineItem[] plisToKeep,
		/*out*/ProposalLineItem[] plisToDelete)
	{
		// delete those, where the existing ones are not from a previous batch of the same lot
		Boolean intLogItemsAreOutdated = sortProposalLIs(
			proposalLIList,
			intLogList[0].getTimeStamp(), // the timesatamp is the same on all the IL records by now
			plisToKeep,
			plisToDelete
		);
		if (intLogItemsAreOutdated) {
			while (!intLogList.isEmpty()) {
				IntLogRecord il = intLogList.remove(0);
				il.setError('Not used - outdated.');
			}
		}
	}
		
	private static boolean sortProposalLIs(
		/*in*/ ProposalLineItem[] PLIs,
		/*in*/ DateTime newTimeStamp,
		/*out*/ ProposalLineItem[] plisToKeep,
		/*out*/ ProposalLineItem[] plisToDelete)
	{
		Boolean intLogsOutdated = false;
		DateTime pliTimeStamp;

		if (PLIs == null) { return false; }
		for (ProposalLineItem pli : PLIs) {
			pliTimeStamp = pli.getTimeStamp();
			if (pliTimeStamp == null || pliTimeStamp < newTimeStamp) { // if timeStamp is blank, then it must be a manually inserted item, so trash it
				plisToDelete.add(pli);
			}
			else if (newTimeStamp == pliTimeStamp) { // keep the pli (we inserted it in a previous batch of the same lot)
				plisToKeep.add(pli);
			}
			else if (newTimeStamp < pliTimeStamp) { // keep the pli, but now we also need to discard all the incoming intLogs...
				intLogsOutdated = true;
				newTimeStamp = pliTimeStamp; // from now on this is the reference timestamp
				plisToKeep.add(pli);
			}
		}
		return intLogsOutdated;
	}
	

	public static Set<string> CollectKeeperOBSKeys(ProposalLineItem[] oppProposalLIs, IntLogRecord[] intLogList)
	{
		Set<string> keeperOBSKeys = new Set<string>();
		for (ProposalLineItem li : oppProposalLIs) {
			if (li.definesBillingSchedule()) {
				keeperOBSKeys.add(li.getProposalID() + '#' + li.getProcessingType());
			}
		}

		for (IntLogRecord il : intLogList) {
			if (il.definesBillingSchedule()) {
				keeperOBSKeys.add(il.getProposalID() + '#' + il.getProcessingType());
			}
		}

		return keeperOBSKeys;
	}

	public static Opportunity_Billing_Schedule__c[] SortOBSes(Set<string> keeperOBSKeys, Map<string, Opportunity_Billing_Schedule__c> OBSMap)
	{
		Opportunity_Billing_Schedule__c[] deletableOBSes = new Opportunity_Billing_Schedule__c[]{};
		for (string obsKey : OBSMap.keySet()) {
			if (!keeperOBSKeys.contains(obsKey)) {
				deletableOBSes.add(OBSMap.remove(obsKey));
			}
		}
		return deletableOBSes;
	}
	
	public static void SortPLIsByType(
		ProposalLineItem[] PLIs,
		ProposalLineItem[] olis,
		ProposalLineItem[] bsis)
	{
		for (ProposalLineItem pli : PLIs) {
			if (pli instanceof ProposalLineItem_OLI) {
				olis.add(pli);
			}
			else if (pli instanceof ProposalLineItem_BS) {
				bsis.add(pli);
			}
		}
	}
	
	public static void SortIntLogsByType(IntLogRecord[] IntLogList, IntLogRecord[] ILList_OLI, IntLogRecord[] ILList_MS)
	{
		for (IntLogRecord next : IntLogList) {
			if (next instanceof IntLogRecord_OLI) {
				ILList_OLI.add(next);
			}
			else if (next instanceof IntLogRecord_Milestone) { // MILESTONE
				ILList_MS.add(next);
			}
		}
	}

	
}