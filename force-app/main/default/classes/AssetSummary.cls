public class AssetSummary
{
	public class DLocationOfUse extends Sortable {
		public Location_of_Use__c TheLou { get; set; }
		public DLocationOfUse(Location_of_Use__c pLou) { TheLou = pLou; }
		public override string GetSortName() { return TheLou.CCRT__r.Name; }
	}
	
	public class DProductSet extends Sortable 
	{
		public Product_Set__c TheProductSet { get; set; }
		public DProductSet(Product_Set__c  pProdSet) { TheProductSet = pProdSet;}
		
		private DEntitlement[] entitlements;
		public DEntitlement[] GetEntitlements()	{
			if (entitlements == null) {
				entitlements = new List<AssetSummary.DEntitlement>{};
			}
			entitlements.sort();
			return entitlements;
		}
		
		private DClientAsset[] clientAssets;
		public DClientAsset[] GetClientAssets()	{
			if (clientAssets == null) {
				clientAssets = new DClientAsset[]{};
			}
			clientAssets.sort();
			return clientAssets;
		}
		public override string GetSortName() { return TheProductSet.Name; }

	}
	
	public class DEntitlement extends Sortable
	{
		public Entitlement__c TheEntitlement { get; set; }
		public System__c TheSystem { get; set; }
		public override string GetSortName() { return TheEntitlement.Name; }
	}

	public class DAccount extends Sortable {
		public Account TheAccount { get; set; }
		
		public DAccount(Account pAcct, DProductSet[] pProductSets) {
			TheAccount = pAcct;
			productSets = pProductSets;
		}
		private DProductSet[] productSets;
		public DProductSet[] GetProductSets()
		{
			if (productSets == null) {
				productSets = new DProductSet[]{}; 
			}
			productSets.sort();
			return productSets;
		}
		public override string GetSortName() { return TheAccount.Name + '-' + TheAccount.Site; }
	}
	
	public class DOLI extends Sortable {
		public OpportunityLineItem TheOLI { get; set; }
		private DContractAsset[] contractAssets;
		public DContractAsset[] GetContractAssets()
		{
			if (contractAssets == null) {
				contractAssets = new DContractAsset[]{}; 
			}
			contractAssets.sort();
			return contractAssets;
		}
		
		public DOLI(OpportunityLineItem oli) { TheOLI = oli; }
		public string GetProductLicenceGroup() { return MisysStringUtils.GetLicenceGroup(TheOLI.PricebookEntry.Product2); }
		public override string GetSortName() {
//			return TheOLI.PricebookEntry.Product2.Name + '(' + GetProductLicenceGroup() + ')';
			return MisysStringUtils.nvl(TheOLI.Location__c);
		}
	}

	public class DClientAsset extends Sortable {
		public Client_Asset__c TheClientAsset { get; set; }
		public DClientAsset(Client_Asset__c pCliA) { TheClientAsset = pCliA; }
		public Product2 TheProduct { get; set; }
		
		private Map<Id, DOLI> olis;
		public Map<Id, DOLI> GetOLIMap()
		{
			if (olis == null) {
				olis = new Map<Id, DOLI>(); 
			}
			return olis;
		}
		public DOLI[] GetOLIs() {
			DOLI[] olisToSort = GetOLIMap().values();
			olisToSort.sort();
			return olisToSort;
		}
		public override string GetSortName() { return TheClientAsset.Name; }
	}
	
	public class DContractAsset extends Sortable {
		public Contract_Asset__c TheContractAsset { get; set; }
		public DContractAsset(Contract_Asset__c pConA) {
			TheContractAsset = pConA;
		}
		
		private DLocationOfUse[] locationsOfUse;
		public DLocationOfUse[] GetLocationsOfUse()	{
			if (locationsOfUse == null) {
				locationsOfUse = new DLocationOfUse[]{};
			}
			locationsOfUse.sort();
			return locationsOfUse;
		}
		
		public string GetSystemLicenceGroup() {
			MisysStringUtils.SystemName sysName = new MisysStringUtils.SystemName(TheContractAsset.System__r.Name);
			return sysName.GetLicenceGroupName();
		}
		
		public string GetSystemInstanceName() {
			MisysStringUtils.SystemName sysName = new MisysStringUtils.SystemName(TheContractAsset.System__r.Name);
			return sysName.GetInstanceName();
		}

		public override string GetSortName() {
			return
			TheContractAsset.Name + ' on ' +
			TheContractAsset.Environment2__c + GetSystemInstanceName() +
			' (' + GetSystemLicenceGroup() + ')';
		}
	}
	
}