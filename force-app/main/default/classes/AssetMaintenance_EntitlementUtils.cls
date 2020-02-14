public class AssetMaintenance_EntitlementUtils
{
	private static final string CORPORATE_CURRENCY = FinanceUtils.GetCorporateCurrency();

	private static Map<string, Product_Set__c> queryExistingProductSets(Set<string> createProSetNames, Set<Id> assetLocations)
	{
		Map<string, Product_Set__c> exPSMap = new Map<string, Product_Set__c>();
		Product_Set__c[] existingProductSets = [
			select Id, Name, Account__c//, Production__c, Disaster_Recovery__c, Hot_Standby__c, Cold_Standby__c, Test__c
			from Product_Set__c
			where Name in :createProSetNames and Account__c in :assetLocations
		];
		for (Product_Set__c exPS : existingProductSets) {
			exPSMap.put(MisysStringUtils.GetProductSetKey(exPS.Account__c, exPS.Name), exPS);
		}
		return exPSMap;
	}
	
	/* The return value is keyed by accountId */
	public static Map<string, Product_Set__c> createProductSets(
		Set<string> productSetNames, Set<Id> assetLocations, Set<string> environments)
	{
		Map<string, Product_Set__c> exPSMap = queryExistingProductSets(productSetNames, assetLocations);
		Product_Set__c proSet;
		
		List<Product_Set__c> PSUpsertList = new List<Product_Set__c>();
		for(String sPSNam : productSetNames) {
			for (Id assetLocationAcctId : assetLocations) {
				Product_Set__c prodSet = exPSMap.get(MisysStringUtils.GetProductSetKey(assetLocationAcctId, sPSNam));				
				if (prodSet == null) {
					prodSet = new Product_Set__c(
						/*
						Production__c = false,
						Disaster_Recovery__c = false,
						Hot_Standby__c = false,
						Cold_Standby__c = false,
						Test__c = false,
						*/
						Name = sPSNam,
						Account__c = assetLocationAcctId,
						CurrencyISOCode = CORPORATE_CURRENCY
					);
					exPSMap.put(MisysStringUtils.GetProductSetKey(assetLocationAcctId, sPSNam), prodSet);
				}
				/*
				prodSet.Production__c |= environments.contains(EnvironmentUtils.ProductionEnvName);
				prodSet.Disaster_Recovery__c |= environments.contains(EnvironmentUtils.DREnvName);
				prodSet.Hot_Standby__c |= environments.contains(EnvironmentUtils.HotStandbyEnvName);
				prodSet.Cold_Standby__c |= environments.contains(EnvironmentUtils.ColdStandbyEnvName);
				prodSet.Test__c |= environments.contains(EnvironmentUtils.TestEnvName);
				*/
				PSUpsertList.add(prodSet);
			}
		}
		upsert PSUpsertList;
		return exPSMap;
	}
	
	private static Map<string, System__c> queryExistingSystems(Map<string, string> createUpperCaseSystemNames, Set<Id> assetLocations)
	{
		Map<string, System__c> exSystemMap = new Map<string, System__c>();
		System__c[] existingSystems = [
			select Id, Name, Account__c, Environment2__c
			from System__c
			where Account__c in :assetLocations
		];
		String licenceGroup, envName, envPostfix, devName;
		for (System__c exSystem : existingSystems) {
			devName = createUpperCaseSystemNames.get(exSystem.Name.toUpperCase());
			if (devName != null && devName == exSystem.Environment2__c) {
				licenceGroup = MisysStringUtils.GetLicenceGroup(exSystem.Name);
				envName = MisysStringUtils.GetEnvironmentName(exSystem.Name);
				envPostfix = MisysStringUtils.GetCustomPostfix(exSystem.Name);
				exSystemMap.put(
					MisysStringUtils.GetSystemKey(
						exSystem.Account__c,
						MisysStringUtils.GetPostfixedEnvironmentName(envName, envPostfix),
						licenceGroup
					),
					exSystem
				);
			}
		}
		return exSystemMap;
	}
	
	public static Map<string, System__c> createSystems(
		Map<Id, Account> assetLocationAccts, Set<PickableEnvironment> environments, Set<string> licenceGroups)
	{
		Map<string, string> createUpperCaseSystemNames = new Map<string, string>();
		for (Account acct : assetLocationAccts.values()) {
			for (PickableEnvironment env : environments) {
				for (String licenceGroup : licenceGroups) {
					createUpperCaseSystemNames.put(
						MisysStringUtils.generateSystemName(acct.Name, acct.Site, env, licenceGroup).toUpperCase(),
						env.Name
					);
				}
			}
		}
		
		Map<string, System__c> exSystemMap = queryExistingSystems(createUpperCaseSystemNames, assetLocationAccts.keySet());
		System__c sys;
		string sysName, sysKey, envKey;

		List<System__c> systemInsertList = new List<System__c>();
		for (Account assetLocationAcct : assetLocationAccts.values()) {
			for (PickableEnvironment env : environments) {
				for (string licenceGroup : licenceGroups) {
					sysName = MisysStringUtils.generateSystemName(assetLocationAcct.Name, assetLocationAcct.Site, env, licenceGroup);
					envKey = MisysStringUtils.GetPostfixedEnvironmentName(env.Name, env.SystemPostfix);
					sysKey = MisysStringUtils.GetSystemKey(assetLocationAcct.Id, envKey, licenceGroup);
					if (!exSystemMap.containsKey(sysKey)) {
						sys = new System__c(
							Name = sysName,
							Account__c = assetLocationAcct.Id,
							Environment2__c = env.Name,
							CurrencyISOCode = CORPORATE_CURRENCY
						);
						exSystemMap.put(sysKey, sys);
						systemInsertList.add(sys);
					}
				}
			}
		}
		insert systemInsertList;
		return exSystemMap;
	}

	// <account id>#<environment name>#<licence group>#<product set name>
	private static Map<string, Entitlement__c> queryExistingEntitlements(Set<Id> systemIds, Set<Id> prodSetIds)
	{
		Map<string, Entitlement__c> exEntitlementMap = new Map<string, Entitlement__c>();
		Entitlement__c[] existingEntitlements = [
			select Id, Name, Status__c, Start_Date__c, End_Date__c,
				System__c, System__r.Name, System__r.Account__c,
				Product_Set__c, Product_Set__r.Name
			from Entitlement__c
			where System__c in :systemIds and Product_Set__c in :prodSetIds
		];
		string systemName, systemPostfix;
		for (Entitlement__c exEntitlement : existingEntitlements) {
			systemName = MisysStringUtils.GetEnvironmentName(exEntitlement.System__r.Name);
			systemPostfix = MisysStringUtils.GetCustomPostfix(exEntitlement.System__r.Name);
			exEntitlementMap.put(
				MisysStringUtils.GetEntitlementKey(
					exEntitlement.System__r.Account__c,
					MisysStringutils.GetPostfixedEnvironmentName(systemName, systemPostfix),
					MisysStringUtils.GetLicenceGroup(exEntitlement.System__r.Name),
					exEntitlement.Product_Set__r.Name
				),
				exEntitlement
			);
		}
		return exEntitlementMap;
	}
	
	public static Map<string, Entitlement__c> createEntitlements(
		Contract contract,
		Map<string, System__c> systemMap,
		Map<string, Product_Set__c> productSetMap,
		Map<Id, Account> assetLocationAccounts,
		Set<PickableEnvironment> environments,
		Map<string, List<OpportunityLineItem>> productSetAndLicenceGroupToOliListMap)
	{
		Set<Id> systemIds = new Set<Id>();
		for (System__c sys : systemMap.values()) {
			systemIds.add(sys.Id);
		}
		Set<Id> productSetIds = new Set<Id>();
		for (Product_Set__c ps : productSetMap.values()) {
			productSetIds.add(ps.Id);
		}
		
		// <account id>#<environment name>#<licence group>#<product set name>
		Map<string, Entitlement__c> exEntitlementMap =
			AssetMaintenance_EntitlementUtils.queryExistingEntitlements(systemIds, productSetIds);

		string[] keyFragments;
		Entitlement__c entitlement;
		Product_Set__c prodSet;
		System__c sys;
		string productSetName, licenceGroup, entitlementKey, entitlementName, environmentName;
		List<Entitlement__c> entitlementInsertList = new List<Entitlement__c>();
		for (Account acct : assetLocationAccounts.values()) {
			for (PickableEnvironment environment : environments) {
				for (string productSetAndLicenceGroup : productSetAndLicenceGroupToOliListMap.keySet()) {
					keyFragments = productSetAndLicenceGroup.split('#');
					productSetName = keyFragments[0];
					licenceGroup = keyFragments[1];
					environmentName = MisysStringutils.GetPostfixedEnvironmentName(environment.Name, environment.SystemPostfix);
					entitlementKey = MisysStringUtils.GetEntitlementKey(acct.Id, environmentName, licenceGroup,	productSetName);
					if (!exEntitlementMap.containsKey(entitlementKey)) {
						prodSet = productSetMap.get(MisysStringUtils.GetProductSetKey(acct.Id, productSetName));
						sys = systemMap.get(MisysStringUtils.GetSystemKey(acct.Id, environmentName, licenceGroup));
						entitlementName = MisysStringUtils.GenerateSupportEntitlementName(sys, prodSet, acct);
						entitlement = new Entitlement__c(
							Name = entitlementName,
							Status__c = 'Active',
							Account__c = acct.Id,
							Product_Set__c = prodSet.Id,
							System__c = sys.Id,
							Start_Date__c = contract.StartDate,
							End_Date__c = contract.Contract_Expiry_Date__c,
							CurrencyISOCode = CORPORATE_CURRENCY
						);
						exEntitlementMap.put(entitlementKey, entitlement);
						entitlementInsertList.add(entitlement);
					}
				}
			}
		}
		insert entitlementInsertList;
		return exEntitlementMap;
	}
	
}