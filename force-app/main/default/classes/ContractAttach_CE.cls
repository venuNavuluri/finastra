public class ContractAttach_CE
{
	//public final string OPPTY_ID = 'OpptyId';
	//public string OpportunityId { get; set; }
	private final Opportunity oppty;
	public Opportunity TheOpportunity
	{
		get { return this.oppty; }
		set;
	}
	
	public ContractAttach_CE(ApexPages.StandardController stdCtrl)
	{
//		oppty = (Opportunity)stdCtrl.getRecord();
		string OpportunityId = Apexpages.currentPage().getParameters().get('id');
		oppty = [
			select Id, StageName, Name, AccountId, Client_Signed_Contract_Attached__c
			from Opportunity
			where Id = :OpportunityId
		];
	}
	
	public boolean ConfirmCreateNew { get; set; }
	public boolean ConfirmContractDocument { get; set; }

	private PickableContract[] contracts;
	public PickableContract[] OpportunityContracts {
		get {
			if (this.contracts == null) {
				this.contracts = createPickableContractList(oppty.Id);
			}
			return this.contracts;
		}
		private set;
	}
	
	private PickableContract[] createPickableContractList(string opptyId)
	{
		PickableContract[] result = new PickableContract[]{};
		Contract[] sobjContracts = [
			select Id, Name, Account.Name, ContractNumber, CreatedDate
			from Contract where Misys_Opportunity__c = :opptyId
		];
		if (al.ArrayUtils.isNotEmpty(sobjContracts)) {
			for (Contract c : sobjContracts) {
				result.add(new PickableContract(c));
				system.debug('@@@ id: ' + c.Id);
			}
		}
		if (result.size() == 1) { result[0].Selected = true; }
		system.debug('@@@ retrieveing ' + result.size());
		return result;
	}
	
	private Contract getSelectedContract()
	{
		for (PickableContract pc : OpportunityContracts) {
			if (pc.Selected) return pc.TheContract;
		}
		return null;
	}
	
	private PageReference createNoteAttachToContractPageReference(Contract c)
	{
		PageReference p = new PageReference(
			'/p/attach/NoteAttach?pid=' + c.Id + '&parentname=' + c.ContractNumber + '&retURL=%2F' + c.Id + ''
		);
		return p;
	}
	
	public boolean getOpportunityHasContract()
	{
		return OpportunityContracts.size() > 0;
	}
	
	public PageReference CreateContractAndUploadDoc()
	{
		Savepoint sp = Database.setSavepoint();
		try {
			ContractServices.ContractResult cr = ContractServices.getNewOppContractRecord(TheOpportunity);
			if (cr.result) {
				TheOpportunity.Client_Signed_contract_attached__c = true;
				update TheOpportunity;
				return createNoteAttachToContractPageReference(cr.ContractRec);
			}
			Database.rollback(sp);
		}
		catch (Exception e) {
			Database.rollback(sp);
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Failed to update the opportunity. Reason: ' + e.getMessage()));
		}
		return null;
	}
	
	public PageReference UploadDocToExistingContract()
	{
		Savepoint sp = Database.setSavepoint();
		try {
			TheOpportunity.Client_Signed_contract_attached__c = true;
			update TheOpportunity;
			PageReference pr = createNoteAttachToContractPageReference(getSelectedContract());
			return pr;
		}
		catch (Exception e) {
			Database.rollback(sp);
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Failed to update the opportunity. Reason: ' + e.getMessage()));
		}
		return null;
	}
	
	public PageReference Cancel()
	{
		return new PageReference('/' + TheOpportunity.Id);
	}
	
	
}