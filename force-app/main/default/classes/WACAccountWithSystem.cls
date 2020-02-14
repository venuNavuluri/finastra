public class WACAccountWithSystem
{
	WizAssetCreationAccountsController.LocationInstance TheAccount { get; set; }
	PickableEnvironment TheSystem { get; set; }
	public Double LoadingPercentage { get; set; }
	
	public WACAccountWithSystem(
		WizAssetCreationAccountsController.LocationInstance pAccount,
		PickableEnvironment pEnv,
		Double pPercentage
	) {
		TheAccount = pAccount;
		TheSystem = pEnv;
		LoadingPercentage = pPercentage;
	}
			
	private string getAccountName() { return TheAccount.TheAccount.Name; }
	private string getEnvironmentName() { return TheSystem.DisplayName + ' ' + TheSystem.SystemPostfix; }
	
	public string GetMyId ()
	{
		return getDOMSafeId();
	}

	public string GetMyReadableId()
	{
		return getAccountName() + ' - ' + TheAccount.TheAccount.Site + ' - ' + TheAccount.TheAccount.Country__c 
			+ ' :: ' + getEnvironmentName();
	}
	
	private string getDOMSafeId()
	{
		string unsafeString = GetMyReadableId();
		string safeString = '';
		string oneChar;
		for (Integer i = 0; i < unsafeString.length(); i++) {
			oneChar = al.StringUtils.charAt(unsafeString, i);
			if (al.Character.isLetterOrDigit(oneChar) || al.Character.isWhitespace(oneChar) || oneChar == '-' || oneChar == ':') {
				safeString = safeString + oneChar;
			}
			else {
				safeString = safeString + 'blah';
			}
		}
		return safeString;
		
	}
}