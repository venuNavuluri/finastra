public class WizAssetCreationAmtsAllocationController
{
	IWACMainController theMainController;
	Map<string, WACAccountWithSystem> thePairs;
	public Map<string, WACAccountWithSystem> GetLoadingMap() { return thePairs; }
	public WACAccountWithSystem[] GetAccountAndSystemPairs() {
		WACAccountWithSystem[] sortedList = new WACAccountWithSystem[]{};
		List<String> keys = new List<String>();
		keys.addAll(thePairs.keySet());
		keys.sort();
		for (string oneKey : keys) {
			sortedList.add(thePairs.get(oneKey));
		}
		return sortedList;
	}
	public string AssetizationBase { get; set; }

	public WizAssetCreationAmtsAllocationController(
		IWACMainController parent,
		WizAssetCreationAccountsController.LocationInstance[] pAccounts,
		PickableEnvironment[] pEnvironments
	) {
		if (thePairs == null) { initPairs(pAccounts, pEnvironments); }
		theMainController = parent;
		AssetizationBase = 'remaining';
	}
	
	private void initPairs(
		WizAssetCreationAccountsController.LocationInstance[] pAccounts,
		PickableEnvironment[] pEnvironments
	) {
		Integer prodCount = 0;
		for (WizAssetCreationAccountsController.LocationInstance acct : pAccounts) {
			for (PickableEnvironment env : pEnvironments) {
				if (env.Selected && env.Name == 'PROD' && acct.AssetLocation) {
					prodCount++;
				}
			}
		}
		thePairs = new Map<string, WACAccountWithSystem>();
		WACAccountWithSystem onePair;
		for (WizAssetCreationAccountsController.LocationInstance acct : pAccounts) {
			for (PickableEnvironment env : pEnvironments) {
				if (acct.AssetLocation && env.Selected) {
					onePair = new WACAccountWithSystem(acct, env, (env.Name == 'PROD' ? Math.floor((10000/prodCount))/100 : 0));
					thePairs.put(acct.TheAccount.Id + '#' + env.Name, onePair);
				}
			}
		}
	}
	
	public Double GetSumLoadingPercentage()
	{
		Double allocated = 0;
		for (WACAccountWithSystem bucket : GetAccountAndSystemPairs()) {
			allocated += MathUtils.NVL(bucket.LoadingPercentage);
		}
		return allocated;
	}
}