public class ProposalLineItem_BS extends ProposalLineItem
{
	/* IProposalItem implementation */
	override public string getProcessingType() { return getTheBSIRecord().LineItem_Process_Type__c; }
	override public string getProposalID() { return string.valueOf(getTheBSIRecord().Opportunity_Billing_Schedule_PID__c); }
	override public DateTime getTimeStamp() { return IntegrationLogUtils.interpretUpdateDateConcat(getTheBSIRecord().PPOPPMILE_Concat__c); }
	override public Id getParentId() { return getTheBSIRecord().Opportunity_Billing_Schedule__r.Opportunity__c; }
	override public boolean definesBillingSchedule() { return true; }
	override public Id getOBSid() { return getTheBSIRecord().Opportunity_Billing_Schedule__c; }
	override public void setOBSid(Id theID) { getTheBSIRecord().Opportunity_Billing_Schedule__c = theID; }
	override public string getCurrencyCode() { return getTheBSIRecord().CurrencyISOCode; }
	
	public ProposalLineItem_BS(Opportunity_Billing_Schedule_Item__c ms)
	{
		super(ms);
	}
	
	public Opportunity_Billing_Schedule_Item__c getTheBSIRecord() { return (Opportunity_Billing_Schedule_Item__c)theRecord; }
	
}