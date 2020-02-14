public class OpportunityDeleteWASPTriggerHelper extends OpportunityWASPTriggerHelper
{
	public OpportunityDeleteWASPTriggerHelper(Opportunity[] pTriggerOld)
	{
		super(pTriggerOld);
	}

	Set<Id> collectWaspIds()
	{
		Set<Id> waspIds = new Set<Id>();
		for (Opportunity o : triggerOppties) {
			if (o.AccountPlan__c != null) {
				waspIds.add(o.AccountPlan__c);
			}
		}
		return waspIds;
	}
	
}