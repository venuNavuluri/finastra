public class WizAssetCreationAccountsController
{
	public class LocationInstance
	{
		public Account TheAccount{ get; set; }
		public CCRT__c TheCcrt{ get; set; }

		public LocationInstance(Account acct) {
			TheAccount = acct;
			TheCcrt = null;
		}

		public LocationInstance(CCRT__c ccrt) {
			TheCcrt = ccrt;
			TheAccount = null;
		}

		public boolean AssetLocation {
			get { return TheAccount != null; }
			private set;
		}
		
		public boolean UseLocation {
			get { return TheAccount != null || TheCcrt != null; }
			private set;
		}
		
		public Id getId()
		{
			if (TheAccount != null) { return TheAccount.Id; }
			if (TheCcrt != null) { return TheCcrt.Id; }
			return null;
		}
	}

	IWACMainController theMainController;
	LocationInstance[] locations;
	Client_Asset__c accountSearchDummyObject;
	Location_of_Use__c ccrtSearchDummyObject;
	public boolean IncludeAccountChildren { get; set; }
	public string LocationIdToDelete { get; set; }

	public WizAssetCreationAccountsController(IWACMainController parent)
	{
		theMainController = parent;
	}

	public void MakeBasicAccountSelection()
	{
		LocationInstance contractAcct = getAccounts()[0];
	}
	
	public void DeleteLocationInstance()
	{
		List<LocationInstance> newList = new List<LocationInstance>{};
		for (LocationInstance loc : locations) {
			if (loc.getId() != LocationIdToDelete) { newList.add(loc);	}
		}
		locations = newList;
	}
	
	public void AddCcrt()
	{
		theMainController.SetPageMessage(null);
		if (GetCcrtSearchDummyObject().CCRT__c == null) {
			ccrtSearchDummyObject = null;
			return;
		}
		addCcrt([
			select id, Name, Client_Site_Number__c, Country_ISO_Code__c, Account__c
			from CCRT__c
			where Id = :GetCcrtSearchDummyObject().CCRT__c
		]);
	}
	
	public void AddAccount()
	{
		theMainController.SetPageMessage(null);
		if (GetAccountSearchDummyObject().Account__c == null) {
			clearSearchAccount();
			return;
		}
		addAccount([
			select id, Name, Site, Country__c, Type, CCRT_Entry__c, CSN__c
			from Account
			where Id = :GetAccountSearchDummyObject().Account__c
		]);
		if (IncludeAccountChildren) {
			for (Account childAccount : [
				select id, Name, Site, Country__c, Type, CCRT_Entry__c, CSN__c
				from Account where ParentId = :GetAccountSearchDummyObject().Account__c
			]) {
				addAccount(childAccount);
			}
		}
	}
	
	private void addAccount(Account newListItem)
	{
		for (LocationInstance acc : locations) {
			if (acc.getId() == newListItem.Id || acc.getId() == newListItem.CCRT_Entry__c) { return; }
		}
		locations.add(new LocationInstance(newListItem));
	}
	
	private void addCcrt(CCRT__c newListItem)
	{
		for (LocationInstance loc : locations) {
			if (loc.getId() == newListItem.Id || loc.getId() == newListItem.Account__c) { return; }
		}
		locations.add(new LocationInstance(newListItem));
	}
	
	public void clearSearchAccount()
	{
		accountSearchDummyObject = null;
		IncludeAccountChildren = false;
	}
	
	public Client_Asset__c GetAccountSearchDummyObject()
	{
		if (accountSearchDummyObject == null) {
			accountSearchDummyObject = new Client_Asset__c();
		}
		return accountSearchDummyObject;
	}
	
	public Location_of_Use__c GetCcrtSearchDummyObject()
	{
		if (ccrtSearchDummyObject == null) {
			ccrtSearchDummyObject = new Location_of_Use__c();
		}
		return ccrtSearchDummyObject;
	}
	
	private LocationInstance[] getLocations()
	{
		if (locations == null) {
			LocationInstance contractingAccount = new LocationInstance([
				select Id, Name, Site, Country__c, Type, CCRT_Entry__c, CSN__c
				from Account
				where id = :theMainController.GetContractAccountId()
			]);
			locations = new LocationInstance[] { contractingAccount };
		}
		return locations;
	}
	
	public LocationInstance[] getAccounts()
	{
		LocationInstance[] accounts = new LocationInstance[]{};
		for (LocationInstance loc : getLocations()) {
			if (loc.TheAccount != null) { accounts.add(loc); }
		}
		return accounts;
	}
	
	public LocationInstance[] getCcrts()
	{
		LocationInstance[] ccrts = new LocationInstance[]{};
		for (LocationInstance loc : getLocations()) {
			if (loc.TheCcrt != null) { ccrts.add(loc); }
		}
		return ccrts;
	}
	
	public string validateAccounts()
	{
		Set<Id> assetLocations = new Set<Id>{};
		
		for (LocationInstance acct : getAccounts()) {
			if (acct.AssetLocation) { assetLocations.add(acct.TheAccount.Id); }
		}

		if (assetLocations.size() == 0) {
			return 'Please mark at least one account as asset-location account!';
		}

		return null;
	}
}