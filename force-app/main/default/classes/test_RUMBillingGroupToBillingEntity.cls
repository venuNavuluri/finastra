@isTest
public class test_RUMBillingGroupToBillingEntity
{
	private static Billing_Entity__c refreshBillingEntity(Id beId)
	{
		return [select id, CY_Billing_Current_Amount__c from Billing_Entity__c where id = :beId];
	}
	
	public static testmethod void doTheTest()
	{
		Account acct = TestUtility.createAccount('Test1');
		System__c sys = TestUtility.createSystem(acct);
		Billing_Entity__c be1 = TestAssetUtils.createBillingEntity();
		Billing_Entity__c be2 = TestAssetUtils.createBillingEntity();
		Billing_Group__c bg1 = TestAssetUtils.createBillingGroup(be1);
		Billing_Group__c bg2 = TestAssetUtils.createBillingGroup(be2);
		
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
			Billing_Group__c resultBG1 = [select id, CY_Billing_Current_Amount__c from Billing_Group__c where id = :bg1.Id];
			Billing_Group__c resultBG2 = [select id, CY_Billing_Current_Amount__c from Billing_Group__c where id = :bg2.Id];
			Billing_Entity__c beRefreshed1 = refreshBillingEntity(be1.id);
			
			Double poundRate = FinanceUtils.GetCurrencyRateMap().get('GBP');
			System.debug('@@@ poundRate: ' + poundRate);
			if (FinanceUtils.GetCorporateCurrency() == 'USD') {

				System.assertEquals(Math.Round(100 + 100/poundRate), resultBG1.CY_Billing_Current_Amount__c);
				System.assertEquals(Math.Round(100 + 100/poundRate), resultBG2.CY_Billing_Current_Amount__c);

				System.debug('@@@ 1 beRefreshed1.CY_Billing_Current_Amount__c: ' + beRefreshed1.CY_Billing_Current_Amount__c);
				System.assertEquals(Math.Round(100 + 100/poundRate), beRefreshed1.CY_Billing_Current_Amount__c);
				
				ca2.CA_CY_Billing_Current_Amount__c = 150;
				update ca2;
				beRefreshed1 = refreshBillingEntity(be1.id);
				System.debug('@@@ 2 beRefreshed1.CY_Billing_Current_Amount__c: ' + beRefreshed1.CY_Billing_Current_Amount__c);
				System.assertEquals(100 + 150/poundRate, beRefreshed1.CY_Billing_Current_Amount__c);
				
				System.assertEquals(null, be2.CY_Billing_Current_Amount__c);
				ca2.CA_Billing_Group__c = bg2.Id;
				update ca2;
				beRefreshed1 = refreshBillingEntity(be1.id);
				System.debug('@@@ 3 beRefreshed1.CY_Billing_Current_Amount__c: ' + beRefreshed1.CY_Billing_Current_Amount__c);
				System.assertEquals(100, beRefreshed1.CY_Billing_Current_Amount__c);
				Billing_Entity__c beRefreshed2 = refreshBillingEntity(be2.Id);
				System.debug('@@@ 4 beRefreshed2.CY_Billing_Current_Amount__c: ' + beRefreshed2.CY_Billing_Current_Amount__c);
				System.assertEquals((150/poundRate).round(), beRefreshed2.CY_Billing_Current_Amount__c.round());

				System.debug('@@@ deleting ca2...');
				delete ca2;
				beRefreshed2 = refreshBillingEntity(be2.Id);
				System.assertEquals(0, beRefreshed2.CY_Billing_Current_Amount__c);
			}
			*/
		Test.stopTest();
	}
	
}