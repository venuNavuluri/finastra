public class IntegrationLog_Pricebook
{
	private static Id standardPBId;
	private static Id getStdPbId() {
		if (standardPBId == null) {
			standardPBId = [select Id from Pricebook2 where isStandard = true LIMIT 1].Id;
		}
		return standardPBId;
	}

	private static void loadILtoPBE(PricebookEntry pbe, Integration_Log__c il)
	{
		pbe.Pricebook2Id = il.GenString3__c;
		pbe.Product2Id = il.GenString4__c;
		pbe.CurrencyIsoCode = il.GenString5__c;
		pbe.UnitPrice = il.NumField5__c;
		pbe.UseStandardPrice = (il.NumField6__c != null && il.NumField6__c.intValue().format() == '1');
		pbe.IsActive = (il.NumField1__c != null && il.NumField1__c.intValue().format() == '1');
	}

	public static void processPMPBENTRY(List<Integration_Log__c> IntLogsPMPBENTRY, Set<Id> idsPMPBENTRY)
	{
		List<Integration_Log__c> ilsToCreate = new List<Integration_Log__c>();
		List<Integration_Log__c> ilsToUpdate = new List<Integration_Log__c>();
		Set<Id> pbeIdsToUpdate = new Set<Id>();
		Set<Id> productIds = new Set<Id>();
		
		for(Integration_Log__c il : IntLogsPMPBENTRY){
			if(il.SFDC_Id__c == null){
				ilsToCreate.add(il);
			}else{
				ilsToUpdate.add(il);
				pbeIdsToUpdate.add(il.SFDC_Id__c);
			}
			productIds.add(il.GenString4__c);
		}
		
		if(!ilsToCreate.isEmpty()){
			doInserts(ilsToCreate, productIds);
		}
		
		if(!ilsToUpdate.isEmpty()){
			doUpdates(ilsToUpdate, pbeIdsToUpdate);
		}
		
	}
	
	private static void doUpdates(List<Integration_Log__c> ilsToUpdate, Set<Id> pbeIdsToUpdate)
	{
		//Remove Duplicates based on External Id for sorting and SFDC Id
		ilsToUpdate = IntegrationLogUtils.removeDuplicates(ilsToUpdate);
		
		Map<Id, PricebookEntry> pbeIdToPBEMap = new Map<Id, PricebookEntry>([
			select Id, UnitPrice, UseStandardPrice, IsActive
			from PricebookEntry
			where Id in :pbeIdsToUpdate
		]);
		
		List<PricebookEntry> pbesToUpdate = new List<PricebookEntry>();
		
		for(Integration_Log__c ilToUpdate : ilsToUpdate){
			if(pbeIdToPBEMap.containsKey(ilToUpdate.SFDC_Id__c)){
				PricebookEntry pbeToUpdate = pbeIdToPBEMap.get(ilToUpdate.SFDC_Id__c);
				pbeToUpdate.UnitPrice = ilToUpdate.NumField5__c;
				pbeToUpdate.UseStandardPrice = (ilToUpdate.NumField6__c != null && ilToUpdate.NumField6__c.intValue().format() == '1');
				pbeToUpdate.IsActive = (ilToUpdate.NumField1__c != null && ilToUpdate.NumField1__c.intValue().format() == '1');
				
				pbesToUpdate.add(pbeToUpdate);
			}
		}
		
		if(!pbesToUpdate.isEmpty()){
			Savepoint sp = Database.setSavepoint();
			if (!saveCustomPBE(pbesToUpdate, ilsToUpdate)) {
				Database.rollback(sp);
			}
		}
	}

	private static Map<string, PricebookEntry> queryExistingStdPBEs(Set<Id> productIds)
	{
		Map<string, PricebookEntry> theMap = new Map<string, PricebookEntry>();
		for (PricebookEntry existingPBE : [
			select Id, Product2Id, Pricebook2Id, CurrencyISOCode, IsActive
			from PricebookEntry
			where Pricebook2Id = :getStdPbId()
			and Product2Id in :productIds
		]) {
			theMap.put(existingPBE.Product2Id + '#' + existingPBE.CurrencyISOCode, existingPBE);
		}
		return theMap;
	}
	
	private static void doInserts(List<Integration_Log__c> ilsToCreate, Set<Id> productIds)
	{
		Map<string, PricebookEntry> existingStdPBEs = queryExistingStdPBEs(productIds);

		List<PricebookEntry> pbesToCreate = new List<PricebookEntry>();
		List<PricebookEntry> standardPBESToSave = new List<PricebookEntry>();

		for(Integration_Log__c ilToCreate : ilsToCreate) {
			PricebookEntry standardPBE = existingStdPBEs.get(ilToCreate.GenString4__c + '#' + ilToCreate.GenString5__c);
			if (standardPBE == null) {
				standardPBE = new PricebookEntry();
				loadILtoPBE(standardPBE, ilToCreate);
				standardPBE.Pricebook2Id = getStdPbId();
				standardPBE.IsActive = true;
				standardPBESToSave.add(standardPBE);
			}
			else if (!standardPBE.IsActive) {
				standardPBE.IsActive = true;
				standardPBESToSave.add(standardPBE);
			}
			
			PricebookEntry pbeToCreate = new PricebookEntry();
			loadILtoPBE(pbeToCreate, ilToCreate);
			pbesToCreate.add(pbeToCreate);
		}
		
		Savepoint sp = Database.setSavepoint();
		if (!saveStandardPBE(standardPBESToSave)) {
			Database.rollback(sp);
			return;
		}
		if (!saveCustomPBE(pbesToCreate, ilsToCreate)) {
			Database.rollback(sp);
		}
	}
	
	private static boolean saveCustomPBE(List<PricebookEntry> pbesToCreate, List<Integration_Log__c> ilsToSave)
	{
		try {
			Database.UpsertResult[] saveResults = Database.Upsert(pbesToCreate, false);
				
			for(Integer i = 0; i < saveResults.size(); i++){
				Integration_Log__c intLog = ilsToSave[i];
					
				if(saveResults[i].isSuccess()){
					intLog.isSuccess__c = true;
					intLog.Status__c = 'Success';
				}else{
					intLog.isSuccess__c = false;
					intLog.Status__c = 'Failed';
					for(Database.Error dbError : saveResults[i].getErrors()){
						intLog.Message__c += dbError.getMessage() + ', ';
					}
				}	
			}
		}
		catch (Exception e) {
			for(Integer i = 0; i < ilsToSave.size(); i++){
				Integration_Log__c intLog = ilsToSave[i];
				intLog.isSuccess__c = false;
				intLog.Status__c = 'Failed';
				intLog.Message__c = e.getMessage();
			}
			return false;
		}
		return true;
	}	
	
	private static boolean saveStandardPBE(List<PricebookEntry> standardPBESToSave)
	{
		try {
			Database.UpsertResult[] saveResults = Database.Upsert(standardPBESToSave, false);
		}
		catch (Exception e) {
			System.debug(LoggingLevel.ERROR, 'Error in processPMPBENTRY (saving standard PBEs): ' + e.getMessage());
			return false;
		}
		return true;
	}
	
}