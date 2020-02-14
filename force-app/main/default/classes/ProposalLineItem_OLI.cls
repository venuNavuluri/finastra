public class ProposalLineItem_OLI extends ProposalLineItem
{
	/* IProposalItem implementation */
	override public string getProcessingType() { return getTheOLI().LineItem_Process_Type__c; }
	override public string getProposalID() { return string.valueOf((integer)getTheOLI().Pearl_ProposalNo__c); } 
	override public DateTime getTimeStamp() { return IntegrationLogUtils.interpretUpdateDateConcat(getTheOLI().PPOPPLINE_Concat__c); }
	override public Id getParentId() { return getTheOLI().OpportunityId; }
	override public Id getOBSid() { return getTheOLI().Opportunity_Billing_Schedule__c; }
	override public void setOBSid(Id theID) { getTheOLI().Opportunity_Billing_Schedule__c = theID; }
	override public Id getPBEid() { return getTheOLI().PricebookEntryId; }
	override public string getCurrencyCode() { return getTheOLI().CurrencyISOCode; }

	public ProposalLineItem_OLI(OpportunityLineItem oli)
	{
		super(oli);
	}
	
	public OpportunityLineItem getTheOLI()
	{
		return (OpportunityLineItem)theRecord;
	}

}