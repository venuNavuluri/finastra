public abstract class OpportunityWASPTriggerHelper extends WASPRecalculateTriggerHelper
{
	protected Opportunity[] triggerOppties;
	
	public OpportunityWASPTriggerHelper(Opportunity[] pTriggerOppties)
	{
		triggerOppties = pTriggerOppties;
	}

	abstract Set<Id> collectWaspIds();
	
	public void Execute()
	{
		Set<Id> waspIds = collectWaspIds();
		// query all the Wasps that are or were attached the oppties
		Map<id, Account_Plan__c> wasps = queryAffectedWasps(waspIds);
		resetWaspAggregates(wasps.values());

		List<Opportunity> opptiesToDetach = new List<Opportunity>();

		List<Opportunity> attachedOppties = queryAttachedOpportunities(waspIds);
		Map<string, List<DatedConversionRate>> exchRateCache = FinanceUtils.GetExchRateCache();
		
		// query all the oppties that are assigned to the Wasps AFTER the update
		for (Opportunity op : attachedOppties) {
			Account_Plan__c wasp = wasps.get(op.AccountPlan__c);

			updateWaspAggregateFields(wasp, op, exchRateCache);

			// we need to remove oppties from the Wasp if the altered CloseDate falls out of the Wasp's fiscal year
			if (!trigger.isDelete && isOpportunityInDifferentFiscalYear(wasp, op)) {
				opptiesToDetach.add(op);
			}
		}
		
		update wasps.values();
		if (!trigger.isDelete) {
			detachOppties(opptiesToDetach);
		}
	}

	private boolean isOpportunityInDifferentFiscalYear(Account_Plan__c wasp, Opportunity op)
	{
		string strWaspFiscalYear = (
			al.StringUtils.isEmpty(wasp.Planning_Year__c)
			? Date.today().year().format()
			: wasp.Planning_Year__c.substring(2).trim()
		);
		return (op.CloseDate < FinanceUtils.GetFiscalYearStart(strWaspFiscalYear) ||
			FinanceUtils.GetNextFiscalYearStart(strWaspFiscalYear) <= op.CloseDate);
	}
	
	private void detachOppties(Opportunity[] oppties)
	{
		for (Opportunity op : oppties) {
			op.AccountPlan__c = null;
		}
		update oppties;
	}
	
	private Map<id, Account_Plan__c> queryAffectedWasps(Set<Id> waspIds)
	{
		return new Map<id, Account_Plan__c>([
			select id, SumClosedWon__c, SumOpen__c, Planning_Year__c, CurrencyIsoCode
			from Account_Plan__c where id in :waspIds
		]);
	}
	
}