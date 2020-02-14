@isTest
public class test_RUMContractAssetBillingAmounts
{
	private static Account refreshAccount(Id acctId)
	{
		return [select id, CY_Billing_Current_Amount__c from Account where id = :acctId];
	}
	
	private static Billing_Group__c refreshBillingGroup(Id bgId)
	{
		return [select id, CY_Billing_Current_Amount__c from Billing_Group__c where id = :bgId];
	}
	
	public static testmethod void testContractAssetToAccount()
	{
		Account acct = TestUtility.createAccount('Test1');
		System__c sys = TestUtility.createSystem(acct);
		Billing_Group__c bg = TestAssetUtils.createBillingGroup();
		
		Account acct2 = TestUtility.createAccount('Test2');

		Test.startTest();
			Contract_Asset__c ca1 = TestUtility.sampleContractAsset(null, sys.Id, acct.Id);
			Contract_Asset__c ca2 = TestUtility.sampleContractAsset(null, sys.Id, acct.Id);
			
			ca1.CurrencyIsoCode = 'USD';
			ca1.CA_CY_Billing_Current_Amount__c = 100;
			ca1.CA_Billing_Group__c = bg.Id;	// needs to have a billing Group assigned to be added
			
			ca2.CurrencyIsoCode = 'GBP';
			ca2.CA_CY_Billing_Current_Amount__c = 100;
			ca2.CA_Billing_Group__c = bg.Id;	// needs to have a billing Group assigned to be added
			
			Contract_Asset__c[] caList = new Contract_Asset__c[]{ca1, ca2}; 
			insert caList;
			System.debug('@@@ ca1: ' + ca1);
	/*
			Account acctRefreshed = refreshAccount(acct.id);

			Double poundRate = FinanceUtils.GetCurrencyRateMap().get('GBP');
			System.debug('@@@ poundRate: ' + poundRate);
			if (FinanceUtils.GetCorporateCurrency() == 'USD') {
				System.debug('@@@ 1 acctRefreshed.CY_Billing_Current_Amount__c: ' + acctRefreshed.CY_Billing_Current_Amount__c);
				System.assertEquals(100 + 100/poundRate, acctRefreshed.CY_Billing_Current_Amount__c);
				
				ca2.CA_CY_Billing_Current_Amount__c = 150;
				update ca2;
				acctRefreshed = refreshAccount(acct.id);
				System.debug('@@@ 2 acctRefreshed.CY_Billing_Current_Amount__c: ' + acctRefreshed.CY_Billing_Current_Amount__c);
				System.assertEquals(100 + 150/poundRate, acctRefreshed.CY_Billing_Current_Amount__c);
				
				System.assertEquals(null, acct2.CY_Billing_Current_Amount__c);
				ca2.Account__c = acct2.Id;
				update ca2;
				acctRefreshed = refreshAccount(acct.id);
				System.debug('@@@ 3 acctRefreshed.CY_Billing_Current_Amount__c: ' + acctRefreshed.CY_Billing_Current_Amount__c);
				System.assertEquals(100, acctRefreshed.CY_Billing_Current_Amount__c);
				Account acctRefreshed2 = refreshAccount(acct2.Id);
				System.debug('@@@ 4 acctRefreshed2.CY_Billing_Current_Amount__c: ' + acctRefreshed2.CY_Billing_Current_Amount__c);
				System.assertEquals((150/poundRate).round(), acctRefreshed2.CY_Billing_Current_Amount__c.round());

				System.debug('@@@ deleting ca2...');
				delete ca2;
				acctRefreshed2 = refreshAccount(acct2.Id);
				System.assertEquals(0, acctRefreshed2.CY_Billing_Current_Amount__c);
			}
			*/
		Test.stopTest();
	}

	public static testmethod void testContractAssetToBillingGroup()
	{
		Account acct = TestUtility.createAccount('Test1');
		System__c sys = TestUtility.createSystem(acct);
		Billing_Entity__c be = TestAssetUtils.createBillingEntity();
		Billing_Group__c bg1 = TestAssetUtils.createBillingGroup(be);
		Billing_Group__c bg2 = TestAssetUtils.createBillingGroup(be);
		
		Test.startTest();
			Contract_Asset__c ca1 = TestUtility.sampleContractAsset(null, sys.Id, acct.Id);
			Contract_Asset__c ca2 = TestUtility.sampleContractAsset(null, sys.Id, acct.Id);
			
			ca1.CurrencyIsoCode = 'USD';
			ca1.CA_CY_Billing_Current_Amount__c = 100;
			ca1.CA_Billing_Group__c = bg1.Id;	// needs to have a billing Group assigned to be added
			
			ca2.CurrencyIsoCode = 'GBP';
			ca2.CA_CY_Billing_Current_Amount__c = 100;
			ca2.CA_Billing_Group__c = bg1.Id;	// needs to have a billing Group assigned to be added
			
			Contract_Asset__c[] caList = new Contract_Asset__c[]{ca1, ca2}; 
			insert caList;
			System.debug('@@@ ca1: ' + ca1);
	/*
			Billing_Group__c bgRefreshed1 = refreshBillingGroup(bg1.id);
			
			Double poundRate = FinanceUtils.GetCurrencyRateMap().get('GBP');
			System.debug('@@@ poundRate: ' + poundRate);
			if (FinanceUtils.GetCorporateCurrency() == 'USD') {
				System.debug('@@@ 1 bgRefreshed1.CY_Billing_Current_Amount__c: ' + bgRefreshed1.CY_Billing_Current_Amount__c);
				System.assertEquals(100 + 100/poundRate, bgRefreshed1.CY_Billing_Current_Amount__c);
				
				ca2.CA_CY_Billing_Current_Amount__c = 150;
				update ca2;
				bgRefreshed1 = refreshBillingGroup(bg1.id);
				System.debug('@@@ 2 bgRefreshed1.CY_Billing_Current_Amount__c: ' + bgRefreshed1.CY_Billing_Current_Amount__c);
				System.assertEquals(100 + 150/poundRate, bgRefreshed1.CY_Billing_Current_Amount__c);
				
				System.assertEquals(null, bg2.CY_Billing_Current_Amount__c);
				ca2.CA_Billing_Group__c = bg2.Id;
				update ca2;
				bgRefreshed1 = refreshBillingGroup(bg1.id);
				System.debug('@@@ 3 bgRefreshed1.CY_Billing_Current_Amount__c: ' + bgRefreshed1.CY_Billing_Current_Amount__c);
				System.assertEquals(100, bgRefreshed1.CY_Billing_Current_Amount__c);
				Billing_Group__c bgRefreshed2 = refreshBillingGroup(bg2.Id);
				System.debug('@@@ 4 bgRefreshed2.CY_Billing_Current_Amount__c: ' + bgRefreshed2.CY_Billing_Current_Amount__c);
				System.assertEquals((150/poundRate).round(), bgRefreshed2.CY_Billing_Current_Amount__c.round());

				System.debug('@@@ deleting ca2...');
				delete ca2;
				bgRefreshed2 = refreshBillingGroup(bg2.Id);
				System.assertEquals(0, bgRefreshed2.CY_Billing_Current_Amount__c);
			}
			*/
		Test.stopTest();
	}
	
}