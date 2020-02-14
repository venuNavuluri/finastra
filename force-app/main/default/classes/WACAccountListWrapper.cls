public class WACAccountListWrapper
{
	public WizAssetCreationAccountsController.LocationInstance[] TheLocations { get; set; }
	
	public WACAccountListWrapper(WizAssetCreationAccountsController.LocationInstance[] pAccounts)
	{
		TheLocations = pAccounts;
	}
}