public abstract class ProposalLineItem implements IProposalItem
{
	protected SObject theRecord;
	
	public ProposalLineItem(SObject obj)
	{
		theRecord = obj;
	}

	public abstract Id getParentId();
	public abstract string getProcessingType();
	public abstract string getProposalID(); 
	public abstract DateTime getTimeStamp();
	public virtual Id getPBEid() { return null; }
	public virtual boolean definesBillingSchedule() { return false; }
	public abstract string getCurrencyCode();
	
	public abstract Id getOBSid();
	public abstract void setOBSid(Id theID);
	
	public static SObject[] GetSObjectList(ProposalLineItem[] theList) {
		Sobject[] result = new Sobject[]{};
		for (ProposalLineItem pli : theList) {
			result.add(pli.theRecord);
		}
		return result;
	}
	
}