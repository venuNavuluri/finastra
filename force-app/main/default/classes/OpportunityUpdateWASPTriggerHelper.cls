public class OpportunityUpdateWASPTriggerHelper extends OpportunityWASPTriggerHelper
{
	private Map<id, Opportunity> triggerOldMap;
	
	public OpportunityUpdateWASPTriggerHelper(Opportunity[] pTriggerNew, Map<id, Opportunity> pTriggerOldMap)
	{
		super(pTriggerNew);
		triggerOldMap = pTriggerOldMap;
	}

	Set<Id> collectWaspIds()
	{
		Set<Id> waspIds = new Set<Id>();
		for (Opportunity o : triggerOppties) {
			if (!isRelevantOpportunityDataChange(o)) {
				continue;
			}
			if (o.AccountPlan__c != null) {
				waspIds.add(o.AccountPlan__c);
			}
			if (triggerOldMap.get(o.Id).AccountPlan__c != null) {
				waspIds.add(triggerOldMap.get(o.Id).AccountPlan__c);
			}
		}
		return waspIds;
	}
	
	private boolean isRelevantOpportunityDataChange(Opportunity o)
	{
		return (
			trigger.isDelete ||
			o.StageName != triggerOldMap.get(o.Id).StageName ||
			o.Amount != triggerOldMap.get(o.Id).Amount ||
			o.CurrencyIsoCode != triggerOldMap.get(o.Id).CurrencyIsoCode ||
			o.AccountPlan__c != triggerOldMap.get(o.Id).AccountPlan__c ||
			o.CloseDate != triggerOldMap.get(o.Id).CloseDate
		);
	}
	
}