public with sharing class CreateInvoiceRegisterController
{
	private Billing_Group__c TheRecord { get; set; }
	public string OpptyNumberToSearch { get; set; }
	public Opportunity TheOppty { get; set; }

	public CreateInvoiceRegisterController(ApexPages.StandardController stdController)
	{
		string recordId = stdController.getRecord().Id;
		TheRecord = [select id, Name from Billing_Group__c where Id = :recordId];
		 
	}
	
	public PageReference Search()
	{
		Opportunity[] srchResults = [select id, name, Order_Number__c  from Opportunity where Order_Number__c = :OpptyNumberToSearch];
		if (srchResults.size() > 0) {
			TheOppty = srchResults[0];
		}
		else {
			TheOppty = null;
		}
			
		return null;
	}

	public PageReference CreateWithoutOppty()
	{
		PageReference pageRef = Page.RedirectWithVariables;
		pageRef.getParameters().put('retURL', '/' + TheRecord.Id);
		pageRef.getParameters().put('object', 'Invoice_Register__c');
		pageRef.getParameters().put('IR_Billing_Group__c', TheRecord.Name);
		pageRef.getParameters().put('ID_' + 'IR_Billing_Group__c', TheRecord.Id);

		return pageRef;
	}
	
	public PageReference Create()
	{
		PageReference pageRef = CreateWithoutOppty();
		
		pageRef.getParameters().put('IR_Opportunity__c', TheOppty.Name);
		pageRef.getParameters().put('ID_' + 'IR_Opportunity__c', TheOppty.Id);
//		pageRef.getParameters().put('Name', TheRecord.Name + '-' + TheOppty.Order_Number__c);

		return pageRef;
	}
}