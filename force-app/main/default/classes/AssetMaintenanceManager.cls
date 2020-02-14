public class AssetMaintenanceManager
{
	private PickableOLI[] OLIs;
	private Set<PickableEnvironment> Environments;
	private Contract contract;
	private Set<Id> AssetLocations, UseLocations; 
	private Map<string, List<OpportunityLineItem>> productSetToOliListMap, licenceGroupToOliListMap;
	private Map<string, List<OpportunityLineItem>>  productSetAndLicenceGroupToOliListMap;
	private Map<string, WACAccountWithSystem> loadingMap;
	private AssetMaintenance_AssetUtils.AssetizingBase baseIndicator;
	
	public void CreateAssets()
	{
		Set<string> environmentNames = new Set<string>();
		for (PickableEnvironment env : Environments) { environmentNames.add(env.Name); }
		// <account id>#<product set name> -> product set
		Map<string, Product_Set__c> productSetMap =
			AssetMaintenance_EntitlementUtils.createProductSets(productSetToOliListMap.keySet(), AssetLocations, environmentNames);
		Set<Id> productSetIds = new Set<Id>();
		for (Product_Set__c ps : productSetMap.values()) {
			productSetIds.add(ps.Id);
		}
		System.debug('@@@ productSetMap: ' + productSetMap);
		
		Map<Id, Account> assetLocationAccounts = new Map<Id, Account>(
			[select Id, Name, Site from Account where Id in :AssetLocations]
		);
		
		// <account id>#<environment name>#<licence group> -> system
		Map<string, System__c> systemMap =
			AssetMaintenance_EntitlementUtils.createSystems(assetLocationAccounts, Environments, licenceGroupToOliListMap.keySet());
		Set<Id> systemIds = new Set<Id>();
		for (System__c sys : systemMap.values()) {
			systemIds.add(sys.Id);
		}
		System.debug('@@@ systemMap: ' + systemMap);
		
		// <account id>#<environment name>#<licence group>#<product set name>
		Map<string, Entitlement__c> entitlementMap = AssetMaintenance_EntitlementUtils.createEntitlements(
			contract, systemMap, productSetMap, assetLocationAccounts, Environments,
			productSetAndLicenceGroupToOliListMap
		);
		System.debug('@@@ entitlementMap: ' + entitlementMap);
			
		// create Client_Asset__c, and Contract_Asset__c records
		Map<string, Client_Asset__c> clientAssetMap = AssetMaintenance_AssetUtils.createClientAssets(
			productSetToOliListMap.keySet(), OLIs, productSetMap, AssetLocations, productSetMap.values()
		);
		System.debug('@@@ clientAssetMap: ' + clientAssetMap);
		
		Map<string, Contract_Asset__c> contractAssetMap = AssetMaintenance_AssetUtils.createContractAssets(
			contract, AssetLocations, Environments, clientAssetMap, systemMap, OLIs, loadingMap, baseIndicator
		);
		System.debug('@@@ contractAssetMap: ' + contractAssetMap);
			
		// <contract asset ID>#<CCRT Id>   --->   LOU
		Map<string, Location_of_Use__c> existingLOUsMap = queryExistingLOUs(contractAssetMap.values(), UseLocations);
		Map<string, Location_of_Use__c> louMap = createLocationsOfUse(
			UseLocations, contractAssetMap,
			entitlementMap, existingLOUsMap
		);
		System.debug('@@@ louMap: ' + louMap);
	}

	private static void addOliToMap(Map<string, List<OpportunityLineItem>> oneMap, string key, OpportunityLineItem oli)
	{
		List<OpportunityLineItem> oliList = oneMap.get(key);
		if (oliList == null) {
			oliList = new List<OpportunityLineItem>{};
			oneMap.put(key, oliList);
		}
		oliList.add(oli);
	}
		
	private void populateOliMaps()
	{
		productSetToOliListMap = new Map<string, List<OpportunityLineItem>>();
		licenceGroupToOliListMap = new Map<string, List<OpportunityLineItem>>();
		productSetAndLicenceGroupToOliListMap = new Map<string, List<OpportunityLineItem>>();
		for (PickableOLI oli : OLIs) {
			addOliToMap(productSetToOliListMap, oli.TheOLI.PriceBookEntry.Product2.Product_Set__c, oli.TheOLI);
			addOliToMap(licenceGroupToOliListMap, MisysStringUtils.GetLicenceGroup(oli.TheOLI.PriceBookEntry.Product2), oli.TheOLI);
			addOliToMap(
				productSetAndLicenceGroupToOliListMap,
				MisysStringUtils.GetCombinedOliKey(oli.TheOLI.PriceBookEntry.Product2),
				oli.TheOLI
			);
		}
	}
	
	public AssetMaintenanceManager(
		PickableOLI[] pOLIs, Set<PickableEnvironment> pEnvironments,
		Contract pContract, Set<Id> pAssetLocations, Set<Id> pUseLocations,
		Map<string, WACAccountWithSystem> pLoadingMap, AssetMaintenance_AssetUtils.AssetizingBase pBaseIndicator)
	{
		OLIs = pOLIs;
		populateOliMaps();
		Environments = pEnvironments;
		contract = pContract;
		AssetLocations = pAssetLocations;
		UseLocations = pUseLocations;
		loadingMap = pLoadingMap;
		baseIndicator = pBaseIndicator;
	}

	private static Map<string, Location_of_Use__c> queryExistingLOUs(
		List<Contract_Asset__c> contractAssets, Set<Id> useLocationCCRTIds)
	{
		Map<string, Location_of_Use__c> exLOUMap = new Map<string, Location_of_Use__c>();
		Location_of_Use__c[] existingLOUs = [
			select Id, Contract_Asset__c, CCRT__c
			from Location_of_Use__c
			where Contract_Asset__c in :contractAssets
			and CCRT__c in :useLocationCCRTIds
		];
		for (Location_of_Use__c exLOU : existingLOUs) {
			exLOUMap.put(MisysStringUtils.GetLOUKey(exLOU.Contract_Asset__c, exLOU.CCRT__c),	exLOU);
		}
		return exLOUMap;
	}
	
	private static Map<string, Location_of_Use__c> createLocationsOfUse(
		Set<Id> useLocations,
		Map<string, Contract_Asset__c> contractAssetMap,
		Map<string, Entitlement__c> entitlementMap,
		Map<string, Location_of_Use__c> existingLOUsMap)
	{
		List<Location_of_Use__c> louInsertList = new List<Location_of_Use__c>();
		Location_of_Use__c newLOU;
		string LOUKey, entKey;
		MisysStringUtils.ContractAssetKey conAKeyObject;
		Entitlement__c ent;
		Contract_Asset__c conA;
		
		for (Id ccrtId : useLocations) {
			for (string conAKey : contractAssetMap.keySet()) {
				conA = contractAssetMap.get(conAKey);
				conAKeyObject = new MisysStringUtils.ContractAssetKey(conAKey);
				LOUKey = MisysStringUtils.GetLOUKey(conA.Id, ccrtId);
				entKey = MisysStringUtils.GetEntitlementKey(
					conAKeyObject.GetAccountId(),
					conAKeyObject.GetEnvironmentName(),
					conAKeyObject.GetLicenceGroupName(),
					conAKeyObject.GetProductSetName()
				);
				ent = entitlementMap.get(entKey);
				System.debug('@@@ entKey: ' + entKey);
				System.debug('@@@ ent: ' + ent);
				System.debug('@@@ conA: ' + conA);
				System.debug('@@@ ccrtId: ' + ccrtId);
				
				if (!existingLOUsMap.containsKey(LOUKey)) {
					 newLOU = new Location_of_Use__c(
						Contract_Asset__c = conA.Id,
						CCRT__c = ccrtId
					);
					existingLOUsMap.put(LOUKey, newLOU);
					louInsertList.add(newLOU);
				}
			}
		}
		insert louInsertList;
		return existingLOUsMap;
	}
}