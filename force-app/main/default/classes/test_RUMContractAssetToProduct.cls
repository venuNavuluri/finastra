@isTest
public class test_RUMContractAssetToProduct
{
	private static Product2 refreshProduct(Id prId)
	{
		return [select id, CY_Billing_Current_Amount__c, CY_Billing_Previous_Amount__c from Product2 where id = :prId];
	}
	
	public static testmethod void doTheTest()
	{
		Account acct = TestUtility.createAccount('Test1');
		System__c sys = TestUtility.createSystem(acct);
		Billing_Group__c bg = TestAssetUtils.createBillingGroup();

		Product2 pr1 = TestUtility.sampleProduct();
		insert pr1;
		Product2 pr2 = TestUtility.sampleProduct();
		insert pr2;

		Test.startTest();
			Contract_Asset__c ca1 = TestUtility.sampleContractAsset(null, sys.Id, acct.Id);
			Contract_Asset__c ca2 = TestUtility.sampleContractAsset(null, sys.Id, acct.Id);
			
			ca1.CurrencyIsoCode = 'USD';
			ca1.CA_CY_Billing_Current_Amount__c = 100;
			ca1.CA_CY_Billing_Previous_Amount__c = 200;
			ca1.Product__c = pr1.Id;
			ca1.CA_Billing_Group__c = bg.Id;
			ca1.CA_Billing_Status__c = 'Active billing';
			
			ca2.CurrencyIsoCode = 'GBP';
			ca2.CA_CY_Billing_Current_Amount__c = 100;
			ca2.CA_CY_Billing_Previous_Amount__c = 200;
			ca2.Product__c = pr1.Id;
			ca2.CA_Billing_Group__c = bg.Id;
			ca2.CA_Billing_Status__c = 'Active billing';
			
			Contract_Asset__c[] caList = new Contract_Asset__c[]{ca1, ca2}; 
			insert caList;
			System.debug('@@@ ca1: ' + ca1);
	/*
			Product2 prRefreshed1 = refreshProduct(pr1.id);
			
			Double poundRate = FinanceUtils.GetCurrencyRateMap().get('GBP');
			System.debug('@@@ poundRate: ' + poundRate);
			if (FinanceUtils.GetCorporateCurrency() == 'USD') {
				System.debug('@@@ 1 prRefreshed1.CY_Billing_Current_Amount__c: ' + prRefreshed1.CY_Billing_Current_Amount__c);
				System.debug('@@@ 1 prRefreshed1.CY_Billing_Previous_Amount__c: ' + prRefreshed1.CY_Billing_Previous_Amount__c);
				System.assertEquals(100 + 100/poundRate, prRefreshed1.CY_Billing_Current_Amount__c);
				System.assertEquals(200 + 200/poundRate, prRefreshed1.CY_Billing_Previous_Amount__c);
				
				ca2.CA_CY_Billing_Current_Amount__c = 150;
				update ca2;
				prRefreshed1 = refreshProduct(pr1.id);
				System.debug('@@@ 2 prRefreshed1.CY_Billing_Current_Amount__c: ' + prRefreshed1.CY_Billing_Current_Amount__c);
				System.debug('@@@ 2 prRefreshed1.CY_Billing_Previous_Amount__c: ' + prRefreshed1.CY_Billing_Previous_Amount__c);
				System.assertEquals(100 + 150/poundRate, prRefreshed1.CY_Billing_Current_Amount__c);
				
				System.assertEquals(null, pr2.CY_Billing_Current_Amount__c);
				ca2.Product__c = pr2.Id;
				update ca2;
				prRefreshed1 = refreshProduct(pr1.id);
				System.debug('@@@ 3 prRefreshed1.CY_Billing_Current_Amount__c: ' + prRefreshed1.CY_Billing_Current_Amount__c);
				//System.assertEquals(100, prRefreshed1.CY_Billing_Current_Amount__c);
				Product2 prRefreshed2 = refreshProduct(pr2.Id);
				System.debug('@@@ 4 prRefreshed2.CY_Billing_Current_Amount__c: ' + prRefreshed2.CY_Billing_Current_Amount__c);
				//System.assertEquals(150/poundRate, prRefreshed2.CY_Billing_Current_Amount__c);

				System.debug('@@@ deleting ca2...');
				delete ca2;
				prRefreshed2 = refreshProduct(pr2.Id);
				System.assertEquals(0, prRefreshed2.CY_Billing_Current_Amount__c);
			}
			*/
		Test.stopTest();
	}

}