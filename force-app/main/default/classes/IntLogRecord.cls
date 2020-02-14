public abstract class IntLogRecord implements IProposalItem
{
	protected Integration_Log__c theRecord;
	
	public IntLogRecord(Integration_Log__c il) { theRecord = il; }
	
	/* IProposalItem */
	public Id getParentId() { return theRecord.SFDC_Id__c; }
	public DateTime getTimeStamp() { return IntegrationLogUtils.interpretUpdateDateConcat(theRecord.GenString1__c);	}
	public abstract string getProcessingType();
	public string getProposalID() { return string.valueOf(getProposalIDNum()); }
	public virtual boolean definesBillingSchedule() { return false; }
	public virtual Id getPBEid() { return null; }
	public abstract string getCurrencyCode();

	public abstract integer getProposalIDNum();

	public void setSuccess() {
		theRecord.isSuccess__c = true;
		theRecord.Status__c = 'Success';
	}
	public void setError(string error) { IntegrationLogUtils.setErrorOnILRecord(theRecord, error); }
	public void setError(Database.Error[] errors) {	IntegrationLogUtils.setErrorOnILRecord(theRecord, errors); }

	public string getType() { return theRecord.RecordTypeId; }
	
	public abstract ProposalLineItem createPLI();
	public abstract boolean hasValidPriceBookEntryId();

	public static ProposalLineItem[] CreatePLILists(IntLogRecord[] intLogList)
	{
		ProposalLineItem[] PLIsToCreate = new ProposalLineItem[]{};
		for (IntLogRecord intLog : intLogList) {
			PLIsToCreate.add(intLog.createPLI());
		}
		return PLIsToCreate;
	}
	
	public static Map<Id, ProposalLineItem[]> CreatePLILists(Map<Id, IntLogRecord[]> oppIdToIntLogListMap)
	{
		Map<Id, ProposalLineItem[]> PLIsToCreate = new Map<Id, ProposalLineItem[]>();
		for (Id oppId : oppIdToIntLogListMap.keySet()) {
			ProposalLineItem[] pliList = PLIsToCreate.get(oppId);
			if (pliList == null) {
				pliList = new ProposalLineItem[]{};
				PLIsToCreate.put(oppId, pliList);
			}

			IntLogRecord[] ILs = oppIdToIntLogListMap.get(oppId);
			for (IntLogRecord intLog : ILs) {
				pliList.add(intLog.createPLI());
			}
		}
		return PLIsToCreate;
	}
	
	
	public Opportunity_Billing_Schedule__c CreateHeader()
	{
		Opportunity_Billing_Schedule__c bs = new Opportunity_Billing_Schedule__c(
			Opportunity__c = getParentId(),
			Proposal_Number__c = getProposalIDNum(),
			Processing_Type__c = getProcessingType()
		);
		return bs;
	}
	
}