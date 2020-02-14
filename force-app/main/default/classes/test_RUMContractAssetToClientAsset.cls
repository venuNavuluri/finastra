@isTest
public class test_RUMContractAssetToClientAsset
{
	private static Client_Asset__c refreshClA(Id clAId)
	{
		return [select id, Total_RLF_Maintenance__c from Client_Asset__c where id = :clAId];
	}
	
	public static testmethod void doTheTest()
	{
		Account acct = TestUtility.createAccount('Test1');
		System__c sys = TestUtility.createSystem(acct);
		Product_Set__c prs = TestUtility.sampleProductSet(acct.Id);
		insert prs;
		
		Client_Asset__c clA1 = TestUtility.sampleClientAsset(prs.Id);
		insert clA1;
		Client_Asset__c clA2 = TestUtility.sampleClientAsset(prs.Id);
		insert clA2;

		Test.startTest();
			Contract_Asset__c ca1 = TestUtility.sampleContractAsset(null, sys.Id, acct.Id);
			Contract_Asset__c ca2 = TestUtility.sampleContractAsset(null, sys.Id, acct.Id);
			
			ca1.CurrencyIsoCode = 'USD';
			ca1.Contract_Annual_Maintenance__c = 100;
			ca1.Client_Asset__c = clA1.Id;
			
			ca2.CurrencyIsoCode = 'GBP';
			ca2.Contract_Annual_Maintenance__c = 100;
			ca2.Client_Asset__c = clA1.Id;
			
			Contract_Asset__c[] caList = new Contract_Asset__c[]{ca1, ca2}; 
			insert caList;
			System.debug('@@@ ca1: ' + ca1);
	/*
			Client_Asset__c clARefreshed1 = refreshClA(clA1.id);
			
			Double poundRate = FinanceUtils.GetCurrencyRateMap().get('GBP');
			System.debug('@@@ poundRate: ' + poundRate);
			if (FinanceUtils.GetCorporateCurrency() == 'USD') {
				System.debug('@@@ 1 clARefreshed1.Total_RLF_Maintenance__c: ' + clARefreshed1.Total_RLF_Maintenance__c);
				System.assertEquals(100 + 100/poundRate, clARefreshed1.Total_RLF_Maintenance__c);
				
				ca2.Contract_Annual_Maintenance__c = 150;
				update ca2;
				clARefreshed1 = refreshClA(clA1.id);
				System.debug('@@@ 2 clARefreshed1.Total_RLF_Maintenance__c: ' + clARefreshed1.Total_RLF_Maintenance__c);
				System.assertEquals(100 + 150/poundRate, clARefreshed1.Total_RLF_Maintenance__c);
				
				System.assertEquals(null, clA2.Total_RLF_Maintenance__c);
				ca2.Client_Asset__c = clA2.Id;
				update ca2;
				clARefreshed1 = refreshClA(clA1.id);
				System.debug('@@@ 3 clARefreshed1.Total_RLF_Maintenance__c: ' + clARefreshed1.Total_RLF_Maintenance__c);
				System.assertEquals(100, clARefreshed1.Total_RLF_Maintenance__c);
				Client_Asset__c clARefreshed2 = refreshClA(clA2.Id);
				System.debug('@@@ 4 clARefreshed2.Total_RLF_Maintenance__c: ' + clARefreshed2.Total_RLF_Maintenance__c);
				System.assertEquals((150/poundRate).round(), clARefreshed2.Total_RLF_Maintenance__c.round());

				System.debug('@@@ deleting ca2...');
				delete ca2;
				clARefreshed2 = refreshClA(clA2.Id);
				System.assertEquals(0, clARefreshed2.Total_RLF_Maintenance__c);
			}
			*/
		Test.stopTest();
	}

}