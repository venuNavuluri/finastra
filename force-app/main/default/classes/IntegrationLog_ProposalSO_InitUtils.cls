public class IntegrationLog_ProposalSO_InitUtils
{
	
	public static IntLogRecord[] GetUpToDateIntLogWrapperList(List<Integration_Log__c> intLogs)
	{
		IntLogRecord[] ilWrapperList = new IntLogRecord[]{};
		for (Integration_Log__c il : intLogs) {
			
			IntLogRecord intLog = createIntLog(il);

			if(!intLog.hasValidPriceBookEntryId()) {
				intLog.setError('Invalid PBE Id');
				continue;
			}
			
			DateTime newILTimestamp = intLog.getTimeStamp();
			
			if (ilWrapperList.size() == 0) {
				ilWrapperList.add(intLog);
			}
			else {
				DateTime existingILTimestamp = ilWrapperList[0].getTimeStamp();
				if (existingILTimestamp == newILTimestamp) {
					ilWrapperList.add(intLog);
				}
				else if (existingILTimestamp < newILTimestamp) {
					// discard the entire lists; use the new item
					for (IntLogRecord existingLog : ilWrapperList) { existingLog.setError('Not used - newer update in batch'); }
					ilWrapperList = new IntLogRecord[]{intLog};
				}
				else { // existingILTimestamp > newILTimestamp
					// just drop the new item; there are newer ones in the list
					intLog.setError('Not used - newer update in batch');
				}
			}
		}
		return ilWrapperList;
	}
	
	private static IntLogRecord createIntLog(Integration_Log__c intLog)
	{
		IntLogRecord ilr;
		if (intLog.RecordTypeId == Label.Integration_RecTypeId_PPOPPLINE) {
			ilr = new IntLogRecord_OLI(intLog);
		}
		else if (intLog.RecordTypeId == Label.Integration_RecTypeId_PPOPPMILE) {
			ilr = new IntLogRecord_MileStone(intLog);
		}
		return ilr;
	}
	
	public static Set<Id> GetPricebookIDs(IntLogRecord[] intLogs)
	{
		Set<Id> pbeIds = new Set<Id>();
		for (IntLogRecord intLog : intLogs) {
			// collect the pricebookentry IDs for querying. The OLIs determine the pricebook on the opportunity:
			if (intLog instanceof IntLogRecord_OLI) {
				pbeIds.add(((IntLogRecord_OLI)intLog).getPBEid());
			}
		}
		return pbeIds;
	}
	
}