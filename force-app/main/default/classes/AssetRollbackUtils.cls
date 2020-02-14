public class AssetRollbackUtils
{
	private static Contract_Asset__c[] QueryContractAssets(Id contractId)
	{
		Contract_Asset__c[] conAs = [
			select Id, Client_Asset__c, System__c from Contract_Asset__c
			where Contract__c = :contractId
		];
		return conAs;
	}
	
	private static Contract_Asset__c[] QueryChildrenOfClientAssets(Set<Id> cliAssetIds)
	{
		Contract_Asset__c[] conAs = [
			select Id, Client_Asset__c from Contract_Asset__c
			where Client_Asset__c in :cliAssetIds
		];
		return conAs;
	}
	
	private static Contract_Asset__c[] QueryChildrenOfSystems(Set<Id> systemIds)
	{
		Contract_Asset__c[] conAs = [
			select Id, System__c from Contract_Asset__c
			where System__c in :systemIds
		];
		return conAs;
	}
	
	private static Client_Asset__c[] QueryChildrenOfProductSets(Set<Id> prodSetIds)
	{
		Client_Asset__c[] cliAs = [
			select Id, Product_Set__c from Client_Asset__c
			where Product_Set__c in :prodSetIds
		];
		return cliAs;
	}
	
	private static OpportunityLineItem[] QueryContractOLIs(Contract_Asset__c[] conAs)
	{
		Set<Id> oliIds = new Set<Id>();
		for (Contract_Asset__c conA : conAs) { oliIds.add(conA.OpportunityLineItem__c); }
		OpportunityLineItem[] olis = [
			select Id from OpportunityLineItem
			where OpportunityId in :oliIds
		];
		return olis;
	}
	
	private static Location_of_Use__c[] QueryContractLOUs(Contract_Asset__c[] conAs)
	{
		Location_of_Use__c[] LOUs = [
			select Id from Location_of_Use__c
			where Contract_Asset__c in :conAs
		];
		return LOUs;
	}
	
	private static Map<Id, Client_Asset__c> QueryContractClientAssets(Contract_Asset__c[] conAs)
	{
		Set<Id> cliAIds = new Set<Id>();
		for (Contract_Asset__c conA : conAs) { cliAIds.add(conA.Client_Asset__c); }
		Client_Asset__c[] cliAs = [
			select Id, Product_Set__c from Client_Asset__c
			where Id in :cliAIds
		];
		return new Map<Id, Client_Asset__c>(cliAs);
	}
	
	private static Map<Id, Product_Set__c> QueryContractProductSets(Client_Asset__c[] cliAs)
	{
		Set<Id> prodSetIds = new Set<Id>();
		for (Client_Asset__c cliA : cliAs) { prodSetIds.add(cliA.Product_Set__c); }
		Product_Set__c[] prodSets = [
			select Id from Product_Set__c
			where Id in :prodSetIds
		];
		return new Map<Id, Product_Set__c>(prodSets);
	}
	
	private static Map<Id, System__c> QueryContractSystems(Contract_Asset__c[] conAs)
	{
		Set<Id> sysIds = new Set<Id>();
		for (Contract_Asset__c conA : conAs) { sysIds.add(conA.System__c); }
		System__c[] systems = [
			select Id from System__c
			where id in :sysIds
		];
		return new Map<Id, System__c>(systems);
	}
	
	private static Entitlement__c[] QueryContractEntitlements(Set<Id> systemIds)
	{
		Entitlement__c[] ents = [
			select Id from Entitlement__c
			where System__c in :systemIds
		];
		return ents;
	}
	
	public static void PurgeContractArtifacts(Id contractId)
	{
		System.debug('@@@ PurgeContractArtifacts - ' + contractId);
		Contract_Asset__c[] conAs = QueryContractAssets(contractId);
		Location_of_Use__c[] lous = QueryContractLOUs(conAs);
		Map<Id, System__c> systemMap = QueryContractSystems(conAs);
		
		System.debug('@@@ lous: ' + lous);
		delete lous;
		
		Map<Id, Client_Asset__c> cliAssetMap = QueryContractClientAssets(conAs);
		System.debug('@@@ conAs: ' + conAs);
		delete conAs;
		Contract_Asset__c[] otherConAs = QueryChildrenOfClientAssets(cliAssetMap.keySet());
		for (Contract_Asset__c conA : otherConAs) {	cliAssetMap.remove(conA.Client_Asset__c); }
		
		Map<Id, Product_Set__c> prodSetMap = QueryContractProductSets(cliAssetMap.values());
		System.debug('@@@ cliAssetMap.values(): ' + cliAssetMap.values());
		delete cliAssetMap.values();
		Client_Asset__c[] otherClientAssets = QueryChildrenOfProductSets(prodSetMap.keySet());
		for (Client_Asset__c cliA : otherClientAssets) { prodSetMap.remove(cliA.Product_Set__c); }
		
		System.debug('@@@ prodSetMap.values(): ' + prodSetMap.values());
		
		otherConAs = QueryChildrenOfSystems(systemMap.keySet());
		for (Contract_Asset__c conA : otherConAs) { systemMap.remove(conA.System__c); }

		Entitlement__c[] entitlements = QueryContractEntitlements(systemMap.keySet());
		delete entitlements;
		delete systemMap.values();
		delete prodSetMap.values();
	}
}