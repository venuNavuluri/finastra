public with sharing class AssetSummaryController
{
	public Account[] AssetLocations { get; set; }
	public Contract_Asset__c[] ContractAssets { get; set; }
	public Client_Asset__c[] ClientAssets { get; set; }
	public OpportunityLineItem[] olis { get; set; }
	public Product_Set__c[] ProdSets { get; set; }
	public Location_of_Use__c[] LocationsOfUse { get; set; }
	public Entitlement__c[] Entitlements {get; set; }
	public System__c[] Systems { get; set; }
	
	private Contract theContract; 
	public AssetSummary.DAccount[] DAssetLocations { get; set; }
	/*
	public Contract_Asset__c[] ContractAssets { get; set; }
	public OpportunityLineItem[] olis { get; set; }
	public Product_Set__c[] ProdSets { get; set; }
	public Location_of_Use__c[] LocationsOfUse { get; set; }
	public Entitlement__c[] Entitlements {get; set; }
	public System__c[] Systems { get; set; }
	*/
	
	public AssetSummaryController(ApexPages.StandardController stdCtrl)
	{
		init(((Contract)stdCtrl.getRecord()).Id);
	}
	
	private void init(Id contractId)
	{
		theContract = [select Id, Misys_Opportunity__c from Contract where id = :contractId];
		olis = [
			select Id, Location__c,
				PricebookEntry.Product2.Name,
				PricebookEntry.Product2.Id,
				PricebookEntry.Product2.Licence_Group_ELS__c,
				PricebookEntry.Product2.Licence_Group_LoanIQ__c,
				PricebookEntry.Product2.Licence_Group_No_Key__c,
				PricebookEntry.Product2.Licence_Group_GMS__c,
				PricebookEntry.Product2.Licence_Group_Sophis__c,
				PricebookEntry.Product2.Licence_Group_ELS_KVAR__c,
				PricebookEntry.Product2.Licence_Group_Summit__c,
				PricebookEntry.Product2.Licence_Group_TopOffice__c,
				PricebookEntry.Product2.Licence_Group_MGR__c
			from OpportunityLineItem
			where OpportunityId = :theContract.Misys_Opportunity__c
		];
		Set<id> productIds = new Set<id>();
		Map<string, OpportunityLineItem> oliMap = new Map<string, OpportunityLineItem>(olis);
		Map<string, List<OpportunityLineItem>> clientAssetIdTocontractedOliListMap = new Map<string, List<OpportunityLineItem>>();
		Set<string> oliIds = new Set<string>();
		for (OpportunityLineItem oli : olis) {
			oliIds.add(oli.Id);
			productIds.add(oli.PricebookEntry.Product2.Id);
		}
		System.debug('@@@ oliIds: ' + oliIds);
		
		Product2[] products = [
			select Id, Name, Licence_Group_ELS__c, Licence_Group_LoanIQ__c, Licence_Group_MGR__c,
				Licence_Group_No_Key__c, Licence_Group_GMS__c, Licence_Group_Sophis__c,
				Licence_Group_ELS_KVAR__c, Licence_Group_Summit__c, Licence_Group_TopOffice__c
			from Product2
			where id in :productIds
		];

		ContractAssets = [
			select Id, Name, Contract__c, Client_Asset__c, System__c,
			OpportunityLineItem__c,
			Environment2__c,
			System__r.Name,
			Contract_Annual_Maintenance__c
			from Contract_Asset__c
			where Contract__c = :theContract.Id
			and OpportunityLineItem__c in :oliIds
		];
		Set<Id> contractAssetIds = new Set<Id>();
		Set<Id> clientAssetIds = new Set<Id>();
		Set<Id> contractAssetSystemIds = new Set<Id>();
		for (Contract_Asset__c contractAsset : ContractAssets) {
			clientAssetIds.add(contractAsset.Client_Asset__c);
			contractAssetIds.add(contractAsset.Id);
			contractAssetSystemIds.add(contractAsset.System__c);
			List<OpportunityLineItem> oliList = clientAssetIdTocontractedOliListMap.get(contractAsset.Client_Asset__c);
			if (oliList == null) {
				oliList = new List<OpportunityLineItem>();
				clientAssetIdTocontractedOliListMap.put(contractAsset.Client_Asset__c, oliList);
			}
			oliList.add(oliMap.get(contractAsset.OpportunityLineItem__c));
		}

		ClientAssets = [
			select Id, Product_Set__c, Name
			from Client_Asset__c
			where Id in :clientAssetIds
		];
		Set<Id> prodSetIds = new Set<Id>();
		for (Client_Asset__c clientAsset : ClientAssets) {
			prodSetIds.add(clientAsset.Product_Set__c);
		}
		
		ProdSets = [
			select Id, Account__c, Name
			from Product_Set__c
			where Id in	:prodSetIds
		];
		Set<Id> acctIds = new Set<Id>();
		Map<Id, AssetSummary.DProductSet> dProductSetMap = new Map<Id, AssetSummary.DProductSet>();
		Map<Id, List<AssetSummary.DProductSet>> acctIdToDisplayProductSetMap = new Map<Id, List<AssetSummary.DProductSet>>();
		for (Product_Set__c prodSet : ProdSets) {
			acctIds.add(prodSet.Account__c);
			AssetSummary.DProductSet dPS = new AssetSummary.DProductSet(prodSet);
			dProductSetMap.put(prodSet.Id, dPS);

			List<AssetSummary.DProductSet> theList = acctIdToDisplayProductSetMap.get(prodSet.Account__c);
			if (theList == null) {
				theList = new List<AssetSummary.DProductSet>{};
				acctIdToDisplayProductSetMap.put(prodSet.Account__c, theList);
			}
			theList.add(dPS);
		}
				
		DAssetLocations = new AssetSummary.DAccount[]{};
		AssetLocations = [
			select Id, Name, Site
			from Account
			where Id in :acctIds
		];
		for (Account acct : AssetLocations) {
			AssetSummary.DAccount dAcct = new AssetSummary.DAccount(acct, acctIdToDisplayProductSetMap.get(acct.Id));
			DAssetLocations.add(dAcct);
		}
		
		LocationsOfUse = [
			select Id, CCRT__r.Name, Contract_Asset__c
			from Location_of_Use__c
			where Contract_Asset__c in :contractAssetIds
		];
		
		Systems = [
			select Id, Name, Environment2__c
			from System__c
			where Id in :contractAssetSystemIds
		];
		Map<Id, System__c> systemMap = new Map<Id, System__c>(Systems);
		

		Entitlements = [
			select Id, System__c, Product_Set__c, System__r.Name, Name
			from Entitlement__c
			where Product_Set__c in :prodSetIds
			and System__c in :systemMap.keySet()
		];
		
		Map<Id, Entitlement__c> entitlementMap = new Map<Id, Entitlement__c>(Entitlements);
		for (Entitlement__c ent : Entitlements) {
			AssetSummary.DEntitlement newEnt = new AssetSummary.DEntitlement();
			newEnt.TheEntitlement = ent;
			newEnt.TheSystem = systemMap.get(ent.System__c);

			AssetSummary.DProductSet dPS = dProductSetMap.get(ent.Product_Set__c);
			dPS.getEntitlements().add(newEnt);
		}
		
		Map<Id, AssetSummary.DClientAsset> dClientAssetMap = new Map<Id, AssetSummary.DClientAsset>();
		for (Client_Asset__c cliA : ClientAssets) {
			AssetSummary.DClientAsset[] theList = dProductSetMap.get(cliA.Product_Set__c).GetClientAssets();
			AssetSummary.DClientAsset newCliA = new AssetSummary.DClientAsset(cliA);
			theList.add(newCliA);
			dClientAssetMap.put(cliA.Id, newCliA);
		}
		
		Map<Id, AssetSummary.DContractAsset> dContractAssetMap = new Map<Id, AssetSummary.DContractAsset>();
		for (Contract_Asset__c conA : ContractAssets) {
			Map<Id, AssetSummary.DOLI> cliAOliMap = dClientAssetMap.get(conA.Client_Asset__c).GetOLIMap();
			AssetSummary.DOLI doli = cliAOliMap.get(conA.OpportunityLineItem__c);
			if (doli == null) {
				doli = new AssetSummary.DOLI(oliMap.get(conA.OpportunityLineItem__c));
				cliAOliMap.put(conA.OpportunityLineItem__c, doli);
			}
			AssetSummary.DContractAsset newConA = new AssetSummary.DContractAsset(conA);
			doli.GetContractAssets().add(newConA);
			dContractAssetMap.put(conA.Id, newConA);
			System.debug('@@@ contA: ' + ContractAssets);
		}
		
		for (Location_of_Use__c lou : LocationsOfUse) {
			AssetSummary.DLocationOfUse[] theList = dContractAssetMap.get(lou.Contract_Asset__c).GetLocationsOfUse();
			AssetSummary.DLocationOfUse newLou = new AssetSummary.DLocationOfUse(lou);
			theList.add(newLou);
		}
	}
	
	public PageReference GotoContractPage()
	{
		return new PageReference('/' + theContract.Id);
	}
	
	public PageReference DeleteAll()
	{
		AssetRollbackUtils.PurgeContractArtifacts(theContract.Id);
		return GotoContractPage();
	}
}