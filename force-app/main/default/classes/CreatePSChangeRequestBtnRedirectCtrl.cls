public class CreatePSChangeRequestBtnRedirectCtrl
{	
	Opportunity oppty;
	
	public CreatePSChangeRequestBtnRedirectCtrl()
	{
		string opptyId = ApexPages.currentPage().getParameters().get('id');
		Opportunity[] results = [
			select
				Id,
				Name,
				AccountId,
				Sales_Region_FY07__c,
				CurrencyIsoCode,
				Type,
				MainProduct__c,
				Pricing_Country__c ,
				IsWon
			from Opportunity
			where Id = :opptyId
		];
		if (results != null && results.size() == 1) {
			oppty = results[0];
		} 
	}
	
	public PageReference RedirectUser()
	{
		if (oppty != null) {
			return oppty.IsWon ? getCreatePSCRPage() : getSorryPage();
		}
		return null;
	}
	
	private PageReference getCreatePSCRPage()
	{
		PageReference pr = new PageReference('/006/e');
		pr.getParameters().put('retURL', '/' + oppty.Id);
		pr.getParameters().put('accid', oppty.AccountId);
		pr.getParameters().put(
			'RecordType',
			GenericServices.getRecordTypesNameMapBySObject('Opportunity').get(Constants.OPPORTUNITY_RECORD_TYPE_CHANGE_ORDER).id
		);
		pr.getParameters().put('ent', 'Opportunity');
		pr.getParameters().put('opp3', oppty.Name + '-' + 'change request name');
		pr.getParameters().put('00N20000000ohBZ', oppty.Sales_Region_FY07__c);
		pr.getParameters().put('currcode', oppty.CurrencyIsoCode);
		pr.getParameters().put('opp5', oppty.Type);
		pr.getParameters().put('00N20000003e4pH', '"FALSE"');
		pr.getParameters().put('00N20000000h1Ck', oppty.MainProduct__c);
		pr.getParameters().put('00N20000003e4ok', '"Services Only"');
		pr.getParameters().put('CF00N20000003e4ol', oppty.Name);
		pr.getParameters().put('00N20000003eTbS', oppty.Pricing_Country__c);
		return pr;
	}
	
	private PageReference getSorryPage()
	{
		return Page.CROportunitySorryneedsclosedwon;
	}
}