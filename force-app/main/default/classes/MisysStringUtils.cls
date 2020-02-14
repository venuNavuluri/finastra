public class MisysStringUtils
{
	private static final Integer ENVIRONMENT_NAME_INDEX = 2; 
	private static final Integer LICENCE_GROUP_INDEX = 3; 
	private static final Integer CUSTOM_POSTFIX_INDEX = 4; 

	public static string GetLicenceGroup(string systemName) { return GetNameFragment(systemName, LICENCE_GROUP_INDEX); }
	public static string GetEnvironmentName(string systemName) { return GetNameFragment(systemName, ENVIRONMENT_NAME_INDEX); }
	public static string GetCustomPostfix(string systemName) { return GetNameFragment(systemName, CUSTOM_POSTFIX_INDEX); }
	
	public class ContractAssetKey {
		private string[] fragments;
		public ContractAssetKey(string key) {
			fragments = key.split('#');
		}

		public string GetAccountId() { return fragments[0]; }
		public string GetProductSetName() { return fragments[1]; }
		public string GetLicenceGroupName() { return fragments[2]; }
		public string GetEnvironmentName() { return fragments[3]; }
		public string GetAssetName() { return fragments[4]; }
	}
	
	public static final Integer PEARL_ACCT_NAME_LEN = 25;
	public static final Integer PEARL_SITE_NAME_LEN = 15;
	public static final Integer PEARL_PRODUCTSET_NAME_LEN = 27;

	public static string GetClientAssetKey(string acctId, string productSetName, Id productId)
	{
		return acctId + '#' + productSetName + '#' + productId;
	}
	
	public static string GetContractAssetKey(
		string acctId, string productSetName,
		string licenceGroup, string envName,
		string oliId)
	{
		return acctId + '#' + productSetName + '#' + licenceGroup + '#' + envName + '#' + oliId;
	}
	
	public static string GetProductSetKey(string acctId, string psName)
	{
		return acctId + '#' + psName;
	}
	
	public static string GetSystemKey(string acctId, string envKey, string licenceGroup)
	{
		return (acctId + '#' + envKey + '#' + licenceGroup).toUpperCase();
	}
	
	public static string GetLOUKey(string contractAssetId, string ccrtId)
	{
		return contractAssetId + '#' + ccrtId;
	}
	
	// <account id>#<environment name>#<licence group>#<product set name>
	public static string GetEntitlementKey(string accountId, string env, string licenceGroup, string prodSetName)
	{
		return (accountId + '#' + env + '#' + licenceGroup + '#' + prodSetName).toUpperCase();
	}
	
	public static string generateSystemName(string acctName, string acctSite, PickableEnvironment env, string systemGroup)
	{
		string postfix = nvl(env.SystemPostfix).ToUpperCase();
		return truncate(acctName, PEARL_ACCT_NAME_LEN) + '-' + truncate(acctSite, PEARL_SITE_NAME_LEN)
			+ '::SYS::' + env.Name + '::' + systemGroup + '::' + postfix;
	}

	public class SystemName {
		private string[] fragments;
		public SystemName(string key) {
			fragments = key.split('::');
		}

		public string GetAccountInfo() { return fragments[0]; }
		public string GetEnvironmentName() { 
			return (fragments.size() < ENVIRONMENT_NAME_INDEX + 1 ? '' : fragments[ENVIRONMENT_NAME_INDEX]); 
		}
		public void SetEnvironment(string envDevName)
		{
			if (IsValid()) { fragments[ENVIRONMENT_NAME_INDEX] = envDevName; }
		}
		public string GetLicenceGroupName() { 
			return (fragments.size() < LICENCE_GROUP_INDEX + 1 ? '' : fragments[LICENCE_GROUP_INDEX]); 
		}
		public string GetInstanceName() {
			return (fragments.size() < CUSTOM_POSTFIX_INDEX + 1 ? '' : fragments[CUSTOM_POSTFIX_INDEX]);
		}
		public void SetInstanceName(string postfix)
		{
			if (CUSTOM_POSTFIX_INDEX + 1 == fragments.size()) { fragments[CUSTOM_POSTFIX_INDEX] = postfix; }
			else if (CUSTOM_POSTFIX_INDEX == fragments.size()) { fragments.add(postfix); }
		}
		public string GetName()
		{
			string retVal = '';
			Integer i;
			for (i = 0; i < CUSTOM_POSTFIX_INDEX; i++) {
				retVal += (fragments[i] + '::');
			}
			retVal += fragments[i];
			return retVal;
		}

		public boolean IsValid()
		{
			return (CUSTOM_POSTFIX_INDEX <= fragments.size());
		}
	}
	
	public static string ConvertPearlLicenceGroup(string pearlLG)
	{
		if (pearlLG == null || pearlLG == 'No Key:Products') { return 'Products'; }
		else if (pearlLG == 'ELS:K Products') { return 'K Products'; }
		else if (pearlLG == 'ELS:KVAR Products') { return 'KVAR Products'; }
		else if (pearlLG == 'GMS:GMS') { return 'GMS'; }
		else if (pearlLG == 'LoanIQ:LoanIQ') { return 'LoanIQ'; }
		else if (pearlLG == 'Sophis:Sophis') { return 'Sophis'; }
		else if (pearlLG == 'Summit:Summit') { return 'Summit'; }
		else if (pearlLG == 'TopOffice:Top Office') { return 'TopOffice'; }
		else if (pearlLG == 'MGR:MGR') { return 'MGR'; }
		return null;
	}
	
	public static string GetLicenceGroup(Product2 p)
	{
		if (p.Licence_Group_ELS__c) { return 'K Products'; }
		if (p.Licence_Group_LoanIQ__c) { return 'LoanIQ'; }
		if (p.Licence_Group_No_Key__c) { return 'Products'; }
		if (p.Licence_Group_GMS__c) { return 'GMS'; }
		if (p.Licence_Group_Sophis__c) { return 'Sophis'; }
		if (p.Licence_Group_ELS_KVAR__c) { return 'KVAR Products'; }
		if (p.Licence_Group_Summit__c) { return 'Summit'; }
		if (p.Licence_Group_TopOffice__c) { return 'TopOffice'; }
		if (p.Licence_Group_MGR__c) { return 'MGR'; }
		
		return null;
	}
	
	public static string GetNameFragment(string str, Integer index)
	{
		string[] fragments = str.split('::');
		if (index + 1 <= fragments.size()) {
			return fragments[index];
		}
		return '';
	}
	
	public static string GetCombinedOliKey(Product2 p)
	{
		return p.Product_Set__c + '#' + GetLicenceGroup(p);
	}
	
	public static string GenerateSupportEntitlementName(System__c sys, Product_Set__c ps, Account acct)
	{
		String accountName = truncate(acct.Name, PEARL_ACCT_NAME_LEN);
		String accountSite = truncate(acct.Site, PEARL_SITE_NAME_LEN);
		String envir = sys.Environment2__c;
		String psName = truncate(ps.Name, PEARL_PRODUCTSET_NAME_LEN);
		
		String seName = accountName + '-' + accountSite + '::SE::' + envir + '::' + psName;
		seName = truncate(seName, 80);
		return seName;
	}
	
	public static string truncate(string str, Integer len)
	{
		string s = nvl(str);
		if (s.length() > len) {
			return s.substring(0, len);
		}
		return s;
	}
	
	public static string nvl(string str)
	{
		return (str == null ? '' : str);
	}
	
	public static string nvl(string str, string defaultValue)
	{
		return (str == null ? defaultValue : str);
	}
	
	public static string GetCoverageColorCode(Double SumAssetized, Double SumContracted)
	{
		if (SumAssetized < SumContracted) {
			return 'blue';
		}
		else if (SumAssetized == SumContracted) {
			return 'green';
		}
		return 'red';
	}
	
	public static string GetPostfixedEnvironmentName(string envName, string envPostfix)
	{
		return envName + (al.StringUtils.isEmpty(envPostfix) ? '' : '@' + envPostfix);
	}
}