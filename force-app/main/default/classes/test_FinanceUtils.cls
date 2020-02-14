@isTest
public with sharing class test_FinanceUtils
{
	public static testMethod void testNonExistentCurrency()
	{
		Map<string, List<DatedConversionRate>> cache = FinanceUtils.GetExchRateCache();
		System.debug('test_FinanceUtils - the cache: ' + cache);
		try {
			FinanceUtils.ExchangeCurrency('USD', 'JOC', 1000, Date.today(), cache);
		}
		catch (FinanceUtils.NoExchangeRateException ex) {
			System.debug('FinanceUtils.NoExchangeRateException thrown: ' + ex);
		}
	}
}