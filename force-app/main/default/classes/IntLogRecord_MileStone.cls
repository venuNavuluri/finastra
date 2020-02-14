public class IntLogRecord_MileStone extends IntLogRecord
{
	/* IProposalItem implementation */
	override public string getProcessingType() { return theRecord.GenString4__c; }
	override public Integer getProposalIDNum() { return (Integer)theRecord.NumField1__c; }

	/* IntLogRecord implementation*/
//	override public SObject createSObject()	{ return createBSI(theRecord); }
	override public ProposalLineItem createPLI()	{ return new ProposalLineItem_BS(createBSI(theRecord)); }
	override public boolean hasValidPriceBookEntryId() { return true; }
	override public boolean definesBillingSchedule() { return true; }
	override public string getCurrencyCode() { return theRecord.GenString3__c; }
		

	public IntLogRecord_MileStone(Integration_Log__c il)
	{
		super(il);
	}
	
	private Opportunity_Billing_Schedule_Item__c createBSI(Integration_Log__c intLog)
	{
		Opportunity_Billing_Schedule_Item__c bsi = new Opportunity_Billing_Schedule_Item__c();
		string opportunityId = intLog.SFDC_Id__c;  // TODO: what do i do with this???
		
		bsi.PPOPPMILE_Concat__c = intLog.GenString1__c;
		bsi.CurrencyISOCode = intLog.GenString3__c;
		bsi.LineItem_Process_Type__c = intLog.GenString4__c;
		bsi.Description__c = intLog.GenString5__c;
		bsi.Name = intLog.GenString5__c;
		bsi.Narrative__c = intLog.GenString5__c;
		bsi.Opportunity_Billing_Schedule_PID__c = string.valueOf((Integer)intLog.NumField1__c);
		bsi.Line__c = intLog.NumField2__c;
		bsi.Line_Amount_for_Milestone__c = intLog.NumField3__c;
		bsi.Line_Milestone_Sequence__c = intLog.NumField4__c;
		DateTime estDate = intLog.DateField1__c;
		if (estDate != null) {
			bsi.Line_Estimated_Completion_Date__c = Date.newInstance(estDate.year(), estDate.month(), estDate.day());
		}
		DateTime dropDate = intLog.DateField2__c;
		if (dropDate != null) {
			bsi.Line_Drop_Dead_Date__c = Date.newInstance(dropDate.year(), dropDate.month(), dropDate.day());
		}
		return bsi;
	}

}