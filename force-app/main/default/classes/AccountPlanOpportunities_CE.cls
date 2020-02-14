public class AccountPlanOpportunities_CE
{
	final Integer FiscalYearStartMonth = FinanceUtils.GetFiscalYearStartMonth();
	
	private final Account_Plan__c acctPlan;
	public Account_Plan__c TheAccountPlan
	{
		get { return this.acctPlan; }
		set;
	}
	
	private PickableOpportunity[] opportunities;
	public PickableOpportunity[] AcctPlanOpportunities {
		get {
			if (this.opportunities == null) {
				this.opportunities = createPickableOpportunityList(TheAccountPlan.Id);
			}
			return this.opportunities;
		}
		private set;
	}

	public AccountPlanOpportunities_CE(ApexPages.StandardController stdCtrl)
	{
		string acctPlanId = Apexpages.currentPage().getParameters().get('id');
		acctPlan = [
			select Id, Name, OwnerId
			from Account_Plan__c
			where Id = :acctPlanId
		];
	}
	
	private PickableOpportunity[] createPickableOpportunityList(string acctPlanId)
	{
		PickableOpportunity[] result = new PickableOpportunity[]{};
		Opportunity[] sobjOppties = [
			select Id, Name, AccountPlan__c, OwnerId, Order_Number__c, Amount, CurrencyIsoCode, StageName, CloseDate
			from Opportunity
			where OwnerId = :TheAccountPlan.OwnerId
			and (AccountPlan__c = null or AccountPlan__c = :TheAccountPlan.Id)
			and CloseDate >= :getCurrentFiscalYearStart()
			and CloseDate < :getNextFiscalYearStart()
		];
		if (al.ArrayUtils.isNotEmpty(sobjOppties)) {
			for (Opportunity o : sobjOppties) {
				PickableOpportunity po = new PickableOpportunity(o);
				po.Selected = (o.AccountPlan__c == TheAccountPlan.Id);
				result.add(po);
			}
		}
		return result;
	}

	private Date getCurrentFiscalYearStart()
	{
		Date now = Date.today();
		if (FiscalYearStartMonth <= now.month() && now.month() <= 12) {
			return Date.newinstance(now.year(), FiscalYearStartMonth, 1);
		}
		else {
			return Date.newinstance(now.year() - 1, FiscalYearStartMonth, 1);
		}
	}
	
	private Date getNextFiscalYearStart()
	{
		Date now = Date.today();
		if (1 <= now.month() && now.month() < FiscalYearStartMonth) {
			return Date.newinstance(now.year(), FiscalYearStartMonth, 1);
		}
		else {
			return Date.newinstance(now.year() + 1, FiscalYearStartMonth, 1);
		}
	}
	
	public PageReference Save()
	{
		List<Opportunity> oppsToSave = new List<Opportunity>();
		for (PickableOpportunity op : AcctPlanOpportunities) {
			if (op.Selected && op.TheOpportunity.AccountPlan__c == null ||
				!op.Selected && op.TheOpportunity.AccountPlan__c != null)
			{
				op.TheOpportunity.AccountPlan__c = (op.Selected ? TheAccountPlan.Id : null);
				oppsToSave.add(op.TheOpportunity);
			}
		}
		update oppsToSave;
		return createParentWASPPageReference();
	}

	public PageReference Cancel()
	{
		return createParentWASPPageReference();
	}

	private PageReference createParentWASPPageReference()
	{
		PageReference p = new PageReference('/' + TheAccountPlan.Id);
		return p;
	}
}