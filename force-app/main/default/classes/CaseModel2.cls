public class CaseModel2
{
	private Case record;
	public Case GetTheCase() { return record; }
	
	public CaseModel2(Id customerCaseId)
	{
		record = EscalationUtils.QueryCustomerCase(customerCaseId);
	}

	public Boolean isEscalateable
	{
		get	{
			return (!HasParent() && !IsClosed() && StepsToReproduceProvided() && ProductSetVersionProvided() && ProductSetModuleVersionProvided());
		}
	}
	
	public boolean HasParent() { return record.ParentID != null; }
	public boolean IsClosed() { return record.Status == Constants.STATUS_CLOSED; }
	public boolean StepsToReproduceProvided() { return record.Steps_to_Reproduce__c != null; }
	public boolean ProductSetVersionProvided() { return record.Product_Set_Version__c != null; }
	public boolean ProductSetModuleVersionProvided() {
		return (record.Product_Set_Module__c == null || record.Product_Set_Module_Version__c != null);
	}
	
}