public virtual class WASPRecalculateTriggerHelper
{
	
	protected void updateWaspAggregateFields(Account_Plan__c wasp, Opportunity op,
		Map<string, List<DatedConversionRate>> exchRateCache)
	{
		// exchange the oppty amount and add to the appropriate Wasp aggregate-field
		if (!op.IsClosed) {
			System.debug('WASPRecalculateTriggerHelper.updateWaspAggregateFields - wasp iD: ' + wasp.Id);
			System.debug('WASPRecalculateTriggerHelper.updateWaspAggregateFields - wasp curr: ' + wasp.CurrencyIsoCode);
			wasp.SumOpen__c += FinanceUtils.ExchangeCurrency(
				op.CurrencyIsoCode, wasp.CurrencyIsoCode, (Double)op.Amount, op.CloseDate, exchRateCache
			);
		}
		else if (op.isWon) {
			wasp.SumClosedWon__c += FinanceUtils.ExchangeCurrency(
				op.CurrencyIsoCode, wasp.CurrencyIsoCode, (Double)op.Amount, op.CloseDate, exchRateCache
			);
		}
	}
		
	protected void resetWaspAggregates(Account_Plan__c[] wasps)
	{
		// reset sums in the wasps
		for (Account_Plan__c w : wasps) {
			w.SumClosedWon__c = 0;
			w.SumOpen__c = 0;
		}
	}
	
	protected Opportunity[] queryAttachedOpportunities(Set<Id> waspIds)
	{
		return [
			select Id, Name, AccountPlan__c, Amount, CurrencyIsoCode,
				StageName, CloseDate, Type, isClosed, isWon
			from Opportunity
			where AccountPlan__c in :waspIds
		];
	}
	
}