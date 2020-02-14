public class IntegrationLog_Proposal_TestUtils
{
	public class BaseData
	{
		public Opportunity testOpp { get; set; }
		public Integration_Log__c[] intLogs { get; set; }
		public PricebookEntry[] PBEntries { get; set; }
		
		public BaseData(Opportunity pTestOpp, Integration_Log__c[] pIntLogs, PricebookEntry[] pPBEntries) {
			testOpp = pTestOpp;
			intLogs = pIntLogs;
			PBEntries = pPBEntries;
		}
		
		public SObject[] GetIntLogSObjectList()
		{
			SObject[] result = new SObject[]{};
			for(Integration_Log__c il : intLogs) {
				result.add(il);
			}
			return result;
		}
	}
	
	public class ResultData
	{
		// key: oppId
		public Map<Id, Opportunity_Billing_Schedule__c[]> obsHeaders { get; set; }
		// key: <oppId>#<obsId>
		public Map<string, Opportunity_Billing_Schedule_Item__c[]> obsItems { get; set; }
		// key: <oppId>#<obsId>
		public Map<string, OpportunityLineItem[]> olis { get; set; }
		
		public Integration_Log__c[] intLogs { get; set; }
	}
	
	public static Map<Id, BaseData> SetupLoadTestScenario(Integer oppCnt, Integer oliPerOppCnt, Integer msPerOppCnt)
	{
		Map<Id, BaseData> result = new Map<Id, BaseData>{};
		Set<id> oppIds = new Set<Id>{};
		for (integer i = 0; i < oppCnt; i++) {
			Opportunity testOpp = createOpportunity();
			oppIds.add(testOpp.Id);
		}
		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
			select Id, Name, Is_PearlMastered__c, CurrencyISOCode, Pricebook2Id, Order_Number__c
			from Opportunity where Id in :oppIds
		]);
		
		Product2[] products = createProducts(oliPerOppCnt);
		PricebookEntry[] PBEntries = createPBEntries(products);

		integer proposalId = 0;
		Integration_Log__c[] intLogs;
		Map<Id, Integration_Log__c[]> oppIdToILsMap = new Map<Id, Integration_Log__c[]>{};
		for (Id oppId : oppMap.keySet()) {
			proposalId++;
			intLogs = new Integration_Log__c[]{};
			oppIdToILsMap.put(oppId, intLogs);
	
			for (integer i = 0; i < oliPerOppCnt; i++) {
				intLogs.add(createIntLog_OLI(proposalId, oppId, PBEntries[i].Id, 'ILF'));
			}
			for (integer i = 0; i < msPerOppCnt; i++) {
				intLogs.add(createIntLog_MS(proposalId, oppId, 'ILF'));
			}
		}
		
		for (Id oppId : oppMap.keySet()) {
			result.put(oppId, new BaseData(oppMap.get(oppId), oppIdToILsMap.get(oppId), PBEntries));
		}
		return result;
	}
	
	public static BaseData SetupBasicScenario(Integer proposalId, boolean createOLIs, boolean createMSs)
	{
		Integer oliCnt = 4;
		
		Opportunity testOpp = createOpportunity();
		testOpp = [select Id, Name, Is_PearlMastered__c, CurrencyISOCode, Pricebook2Id, Order_Number__c from Opportunity where Id = :testOpp.Id];
		
		Product2[] products = createProducts(oliCnt);
		PricebookEntry[] PBEntries = createPBEntries(products);

		Integration_Log__c[] intLogs = new Integration_Log__c[]{};
		if (createOLIs) {
			intLogs.add(createIntLog_OLI(proposalId, testOpp.Id, PBEntries[0].Id, 'ILF'));
			intLogs.add(createIntLog_OLI(proposalId, testOpp.Id, PBEntries[1].Id, 'ILF'));
			intLogs.add(createIntLog_OLI(proposalId, testOpp.Id, PBEntries[2].Id, 'SVFP'));
			intLogs.add(createIntLog_OLI(proposalId, testOpp.Id, PBEntries[3].Id, 'SVFP'));
		}
		
		if (createMSs) {
			intLogs.add(createIntLog_MS(proposalId, testOpp.Id, 'ILF'));
			intLogs.add(createIntLog_MS(proposalId, testOpp.Id, 'SVFP'));
		}
		
		return new BaseData(testOpp, intLogs, PBEntries);
	}
	
	public static BaseData SetupBasicScenario(Integer proposalId)
	{
		return SetupBasicScenario(proposalId, true, true);
	}
	
	public static ResultData queryCreatedArtifacts(Set<Id> oppIds)
	{
		ResultData retVal = new ResultData();
		retVal.obsHeaders = new Map<Id, Opportunity_Billing_Schedule__c[]>();
		Opportunity_Billing_Schedule__c[] headers;
		for (Opportunity_Billing_Schedule__c obs : [
			select Id, Name, Opportunity__c, Key__c, Processing_Type__c, Proposal_Number__c
			from Opportunity_Billing_Schedule__c
			where Opportunity__c in :oppIds
		]) {
			headers = getOrCreateMapMemberList(obs.Opportunity__c, retVal.obsHeaders);
			headers.add(obs);
		}
		
		retVal.obsItems = new Map<string, Opportunity_Billing_Schedule_Item__c[]>();
		Opportunity_Billing_Schedule_Item__c[] items;
		for (Opportunity_Billing_Schedule_Item__c item : [
			select Id, Name, LineItem_Process_Type__c, Opportunity_Billing_Schedule__c, Opportunity_Billing_Schedule__r.Opportunity__c
			from Opportunity_Billing_Schedule_Item__c
			where Opportunity_Billing_Schedule__r.Opportunity__c in :oppIds
		]) {
			items = getOrCreateMapMemberList(
				item.Opportunity_Billing_Schedule__r.Opportunity__c + '#' + item.Opportunity_Billing_Schedule__c,
				retVal.obsItems
			);
			items.add(item);
		}
		
		retVal.olis = new Map<string, OpportunityLineItem[]>();
		OpportunityLineItem[] newOlis;
		for (OpportunityLineItem oli : [
			select Id, OpportunityId, PricebookEntry.Product2.Name,
				Opportunity_Billing_Schedule__c,
				Opportunity_Billing_Schedule__r.Name,
				LineItem_Process_Type__c
			from OpportunityLineItem
			where OpportunityId in :oppIds
		]) {
			newOlis = getOrCreateMapMemberList(
				oli.OpportunityId + '#' + oli.Opportunity_Billing_Schedule__c, retVal.olis
			);
			newOlis.add(oli);
		}
		
		retVal.intLogs = [select Id, isSuccess__c, Status__c, SFDC_ID__c, Message__c, CreatedDate from Integration_Log__c where SFDC_ID__c in :oppIds order by CreatedDate];
		
		dump(retVal);
		return retVal;
	}
	
	private static void dump(ResultData myData)
	{
		System.debug(LoggingLevel.Error, '@@@ obsHeaders: ' + myData.obsHeaders);
		System.debug(LoggingLevel.Error, '@@@ obsItems: ' + myData.obsItems);
		System.debug(LoggingLevel.Error, '@@@ olis: ');
		for (string key : myData.olis.keySet()) {
			System.debug(LoggingLevel.Error, '@@@ key: ' + key);
			for (OpportunityLineItem oli : myData.olis.get(key)) {
				System.debug(LoggingLevel.Error, '@@@ ID: ' + oli.Id);
				System.debug(LoggingLevel.Error, '@@@ Product: ' + oli.PricebookEntry.Product2.Name);
				System.debug(LoggingLevel.Error, '@@@ OBS: ' + oli.Opportunity_Billing_Schedule__r.Name);
				System.debug(LoggingLevel.Error, '@@@ ');
			}
		}
		System.debug(LoggingLevel.Error, '@@@ intLogs... ');
		for (Integration_Log__c il : myData.intLogs) {
			System.debug(LoggingLevel.Error, '@@@ intLog: ' + il);
		}
	}
	
	private static Product2[] createProducts(Integer cnt)
	{
		Product2[] products = new Product2[]{};
		for (Integer i = 0; i < cnt; i++) {
			Product2 prod = new Product2();
			prod.Name = 'Product ' + i;
			products.add(prod);
		}
		insert products;
		return products;
	}

	private static PricebookEntry[] createPBEntries(Product2[] products)
	{
		PricebookEntry[] pbEntries = new PricebookEntry[]{};
		PricebookEntry[] stdPBEntries = new PricebookEntry[]{};
		for (Integer i = 0; i < products.size(); i++) {
			PricebookEntry pbe = new PricebookEntry();
			pbe.Product2Id = products[i].Id;
			pbe.Pricebook2Id = TestIntegrationLogUtils.GetStandardPricebookId();
			pbe.UnitPrice = 10;
			pbe.CurrencyISOCode = 'GBP';
			pbe.IsActive = true;
			stdPBEntries.add(pbe);

			pbe = new PricebookEntry();
			pbe.Product2Id = products[i].Id;
			pbe.Pricebook2Id = TestIntegrationLogUtils.GetMisysPricebookId();
			pbe.UnitPrice = 10;
			pbe.CurrencyISOCode = 'GBP';
			pbe.IsActive = true;
			pbEntries.add(pbe);
		}
		insert stdPBEntries;
		insert pbEntries;
		return pbEntries;
	}

	public static Integration_Log__c createIntLog_OLI(Integer proposalId, Id oppId, Id pbeId, string procType)
	{
		List<Integration_Log__c> ils = new List<Integration_Log__c>();
		
		Integration_Log__c il = new Integration_Log__c();
		il.SFDC_Id__c = oppId;
		il.GenString2__c = pbeId;
		il.GenString3__c = 'GBP';
		il.RecordTypeId = TestIntegrationLogUtils.GetIntLogOLIRecTypeId();
		il.GenString1__c = 'ellisr/703.03-20/07/2012 20:09:46';
		il.GenString11__c = procType; // processing type 
		il.NumField1__c = 100;
		il.NumField30__c = proposalId;
		return il;
	}
	
	public static Integration_Log__c createIntLog_MS(Integer proposalId, Id oppId, string procType)
	{
		List<Integration_Log__c> ils = new List<Integration_Log__c>();
		
		Integration_Log__c il = new Integration_Log__c();
		il.SFDC_Id__c = oppId;
		il.GenString3__c = 'GBP';
		il.RecordTypeId = TestIntegrationLogUtils.GetIntLogMSRecTypeId();
		il.GenString1__c = 'ellisr/703.03-20/07/2012 20:09:46';
		il.GenString4__c = procType; // processing type
		il.NumField1__c = proposalId;
		return il;
	}
	
	private static Opportunity createOpportunity()
	{
		Account testAcc = TestUtility.sampleAccount();
		insert testAcc;
		
		//An opportunity that will have existing line items		
		Opportunity testOpp = TestUtility.sampleOpportunity();
		testOpp.AccountId = testAcc.Id;
		testOpp.CurrencyIsoCode = 'USD';
		insert testOpp;
		return testOpp;
	}
	
	private static OpportunityLineItem[] getOrCreateMapMemberList(string theKey, Map<string, OpportunityLineItem[]> theMap)
	{
		OpportunityLineItem[] theList = theMap.get(theKey);
		if (theList == null) {
			theList = new OpportunityLineItem[]{};
			theMap.put(theKey, theList);
		}
		return theList;
	}
	
	private static Opportunity_Billing_Schedule_Item__c[] getOrCreateMapMemberList(string theKey, Map<string, Opportunity_Billing_Schedule_Item__c[]> theMap)
	{
		Opportunity_Billing_Schedule_Item__c[] theList = theMap.get(theKey);
		if (theList == null) {
			theList = new Opportunity_Billing_Schedule_Item__c[]{};
			theMap.put(theKey, theList);
		}
		return theList;
	}
	
	private static Opportunity_Billing_Schedule__c[] getOrCreateMapMemberList(Id theId, Map<Id, Opportunity_Billing_Schedule__c[]> theMap)
	{
		Opportunity_Billing_Schedule__c[] theList = theMap.get(theId);
		if (theList == null) {
			theList = new Opportunity_Billing_Schedule__c[]{};
			theMap.put(theId, theList);
		}
		return theList;
	}
	
}