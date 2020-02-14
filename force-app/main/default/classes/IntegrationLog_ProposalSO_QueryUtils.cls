public class IntegrationLog_ProposalSO_QueryUtils
{
	public static Map<Id, PricebookEntry> QueryPricebookAndBuildMap(Set<Id> pbeIds)
	{
		Map<Id, PricebookEntry> pbeIdToPBE = new Map<Id, PricebookEntry>([
			Select p.Id, p.Pricebook2Id from PricebookEntry p where p.Id in :pbeIds
		]);
		return pbeIdToPBE;
	}
	
	public static ProposalLineItem[] QueryExistingProposalLineItems(Id oppId)
	{
		ProposalLineItem[] proposalLIList = new ProposalLineItem[]{};
		for (OpportunityLineItem[] originalOlis : [
			select Id, PPOPPLINE_Concat__c, OpportunityId, Pearl_ProposalNo__c, LineItem_Process_Type__c
			from OpportunityLineItem 
			where OpportunityId = :oppId and GP_Product__c  = false
		]) {
			for (OpportunityLineItem oli : originalOlis) {
				proposalLIList.add(new ProposalLineItem_OLI(oli));
			}
		}

		for (Opportunity_Billing_Schedule_Item__c[] originalBSIs : [
			select Id, PPOPPMILE_Concat__c, 
				Opportunity_Billing_Schedule__c, 
				Opportunity_Billing_Schedule__r.Opportunity__c,
				Opportunity_Billing_Schedule_PID__c, 
				LineItem_Process_Type__c
			from Opportunity_Billing_Schedule_Item__c
			where Opportunity_Billing_Schedule__r.Opportunity__c = :oppId
		]) {
			for (Opportunity_Billing_Schedule_Item__c bsi : originalBSIs) {
				proposalLIList.add(new ProposalLineItem_BS(bsi));
			}
		}
		return proposalLIList;
	}
	
	public static Opportunity QueryOpportunity(Id oppId)
	{
		// query the opps with pricebookid, and currency
		Opportunity[] opp = [
			select Id, Order_Number__c, Pricebook2Id, CurrencyISOCode, Is_PearlMastered__c
			from Opportunity
			where Id = :oppId
		];
		return (opp.size() == 0) ? null : opp[0];
	}
	
	public static Map<Id, Opportunity> QueryOppsAndBuildMap(Set<Id> oppIds)
	{
		// query the opps with pricebookid, and currency
		Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
			select Id, Order_Number__c, Pricebook2Id, CurrencyISOCode, Is_PearlMastered__c
			from Opportunity
			where Id in :oppIds
		]);
		return oppMap;
	}
	
	public static Map<string, Opportunity_Billing_Schedule__c> QueryOBSes(Id oppId)
	{
		Map<string, Opportunity_Billing_Schedule__c> OBSMap = new Map<string, Opportunity_Billing_Schedule__c>();
		for (Opportunity_Billing_Schedule__c obs : [
			select Id, Name, Opportunity__c, Proposal_Number__c, Processing_Type__c 
			from Opportunity_Billing_Schedule__c
			where Opportunity__c = :oppId
		]) {
			OBSMap.put(obs.Proposal_Number__c + '#' + obs.Processing_Type__c, obs);
		}
		return OBSMap;
	}
	
}