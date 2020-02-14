public interface IWACMainController
{
	void SetPageMessage(string msg);
	Id GetContractAccountId();
	Id GetContractOpportunityId();
	boolean AssetizeByRemainingAmount();
}