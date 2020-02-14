public interface IProposalItem
{
	Id getParentId();
	DateTime getTimeStamp();
	string getProcessingType(); 
	string getProposalID();
	boolean definesBillingSchedule();
	Id getPBEid();
	string getCurrencyCode();
}