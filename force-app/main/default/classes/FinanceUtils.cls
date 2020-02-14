public class FinanceUtils
{
	private static Integer fiscalYearStartMonth;
	private static final List<currencytype > CUR_TYPES = [SELECT isocode,conversionrate FROM currencytype where isActive=true];
	public class NoExchangeRateException extends Exception
	{
		private string fromCurrencyCode;
		private string toCurrencyCode;
		private Date exchangeDate;
		
		public NoExchangeRateException(string fromC, string toC, Date xchgDate)
		{
			this.fromCurrencyCode = fromC;
			this.toCurrencyCode = toC;
			this.exchangeDate = xchgDate;
		}
	}

	private static Map<String, Double> currencyRateMap;
	private static Map<string, List<DatedConversionRate>> exchangeRateCache;
	private static string corporateCurrency;
    public static List<currencytype > GetCurrencyRateMap2() {
        return CUR_TYPES;
    }
	public static Integer GetFiscalYearStartMonth()
	{
		if (fiscalYearStartMonth == null) {
			fiscalYearStartMonth = [
				select FiscalYearStartMonth
				from Organization
				where id=:Userinfo.getOrganizationId()
			].FiscalYearStartMonth;
		}
		return fiscalYearStartMonth;
	}
	
	public static Integer GetFiscalYear()
	{
		Date nextFYStartDate = GetNextFiscalYearStart();
		Date currentFYLastDate = nextFYStartDate.addDays(-1);
		return currentFYLastDate.year();
	}
	
	public static Date GetCurrentFiscalYearStart()
	{
		Date now = Date.today();
		if (GetFiscalYearStartMonth() <= now.month() && now.month() <= 12) {
			return Date.newinstance(now.year(), GetFiscalYearStartMonth(), 1);
		}
		else {
			return Date.newinstance(now.year() - 1, GetFiscalYearStartMonth(), 1);
		}
	}
	
	public static Date GetNextFiscalYearStart()
	{
		Date now = Date.today();
		if (1 <= now.month() && now.month() < GetFiscalYearStartMonth()) {
			return Date.newinstance(now.year(), GetFiscalYearStartMonth(), 1);
		}
		else {
			return Date.newinstance(now.year() + 1, GetFiscalYearStartMonth(), 1);
		}
	}
	
	public static Date GetFiscalYearStart(string strYear)
	{
		return Date.newInstance(Integer.valueOf(strYear) - 1, GetFiscalYearStartMonth(), 1);
	}
	
	public static Date GetNextFiscalYearStart(string strYear)
	{
		return Date.newInstance(Integer.valueOf(strYear), GetFiscalYearStartMonth(), 1);
	}
	
	public static Double GetAmountInCorporateCurrency(
		string fromCurrency, Double amount,
		Date exchangeDate, Map<string, List<DatedConversionRate>> exchRateCache)
	{
		for (DatedConversionRate datedRate : exchRateCache.get(fromCurrency)) {
			if (datedRate.StartDate <= exchangeDate && exchangeDate < datedRate.NextStartDate) {
				//AK - 1000289 - Included the if condition to check if the amount has any value in it or not.
				//Without this check if the amount was null then the null pointer exception was being thrown.
				Double retAmt = 0.00;
				if(amount != null && amount != 0){
					retAmt = (amount / datedRate.ConversionRate);
				}
				return retAmt;
				//return (amount / datedRate.ConversionRate);
			}
		}
		throw new NoExchangeRateException(fromCurrency, GetCorporateCurrency(), exchangeDate);
	}

	public static Double GetCorporateCurrencyAmountInOtherCurrency(
		string toCurrency, Double amount,
		Date exchangeDate, Map<string, List<DatedConversionRate>> exchRateCache)
	{
		system.debug('FinanceUtils.GetCorporateCurrencyAmountInOtherCurrency toCurrency: ' + toCurrency);
		if (toCurrency == GetCorporateCurrency()) { return amount; }
		DatedConversionRate[] rates = exchRateCache.get(toCurrency);
		if (rates != null) {
			for (DatedConversionRate datedRate : rates) {
				if (datedRate.StartDate <= exchangeDate && exchangeDate < datedRate.NextStartDate) {
					return (amount * datedRate.ConversionRate);
				}
			}
		}
		throw new NoExchangeRateException(GetCorporateCurrency(), toCurrency, exchangeDate);
	}

	public static Double ExchangeCurrency(
		string fromCurrencyCode, string toCurrencyCode,
		Double amount, Date exchangeDate,
		Map<string, List<DatedConversionRate>> exchRateCache)
	{
		Double amountInCorporateCurrency = GetAmountInCorporateCurrency(fromCurrencyCode, amount, exchangeDate, exchRateCache);
		return GetCorporateCurrencyAmountInOtherCurrency(toCurrencyCode, amountInCorporateCurrency, exchangeDate, exchRateCache);
	}
	
	/*
	public static Double GetOpportunityValueInCorporateCurrency(Opportunity op, Map<string, List<DatedConversionRate>> exchRateCache)
	{
		return GetAmountInCorporateCurrency(op.CurrencyIsoCode, (Double)op.Amount, op.CloseDate, exchRateCache);
	}

	public static Double GetOpportunityValueInCurrency(Opportunity op, string toCurrencyCode, Map<string, List<DatedConversionRate>> exchRateCache)
	{
		return ExchangeCurrency(op.CurrencyIsoCode, toCurrencyCode, (Double)op.Amount, op.CloseDate, exchRateCache);
	}
	*/
	
	public static Map<string, List<DatedConversionRate>> GetExchRateCache()
	{
		if (exchangeRateCache != null) { return exchangeRateCache; }
		
		exchangeRateCache = new Map<string, List<DatedConversionRate>>();

		for (DatedConversionRate rate :	[SELECT ISOCode, ConversionRate, StartDate, NextStartDate FROM DatedConversionRate])
		{
			List<DatedConversionRate> rateList = exchangeRateCache.get(rate.IsoCode);
			if (rateList == null) {
				rateList = new List<DatedConversionRate>();
				exchangeRateCache.put(rate.IsoCode, rateList);
			}
			rateList.add(rate);
		}
		return exchangeRateCache;
	}

	public static string GetCorporateCurrency()
	{
		if (corporateCurrency == null) {
			List<CurrencyType> c = [SELECT ISOCode FROM CurrencyType WHERE IsActive = true and IsCorporate = true];
			corporateCurrency = c[0].ISOCode;
		}
		return corporateCurrency;
	}
	
	public static map<String, Double> GetCurrencyRateMap()
	{
		if (currencyRateMap == null) {
			currencyRateMap = new map<String, Double>();
			
			List<CurrencyType> allCurrList = [select ConversionRate, IsoCode from CurrencyType where IsActive = :true];
			
			for (CurrencyType ct : allCurrList) {
				currencyRateMap.put(ct.IsoCode, ct.ConversionRate);
			}
		}
		return currencyRateMap;
	}

	public static boolean IsDateInCurrentFiscalYear(Date myDate)
	{
		return GetCurrentFiscalYearStart() <= myDate && myDate < GetNextFiscalYearStart(); 
	}
	
	public static boolean IsDateInFirstQuarter(Date myDate)
	{
		Date firstQStart = GetCurrentFiscalYearStart();
		Date secondQStart = GetCurrentFiscalYearStart().addMonths(3);
		return firstQStart <= myDate && myDate < secondQStart;
	}

	public static boolean IsDateInSecondQuarter(Date myDate)
	{
		Date secondQStart = GetCurrentFiscalYearStart().addMonths(3);
		Date thirdQStart = GetCurrentFiscalYearStart().addMonths(6);
		return secondQStart <= myDate && myDate < thirdQStart;
	}

	public static boolean IsDateInThirdQuarter(Date myDate)
	{
		Date thirdQStart = GetCurrentFiscalYearStart().addMonths(6);
		Date fourthQStart = GetCurrentFiscalYearStart().addMonths(9);
		return thirdQStart <= myDate && myDate < fourthQStart;
	}

	public static boolean IsDateInFourthQuarter(Date myDate)
	{
		Date fourthQStart = GetCurrentFiscalYearStart().addMonths(9);
		return fourthQStart <= myDate && myDate < GetNextFiscalYearStart();
	}

}