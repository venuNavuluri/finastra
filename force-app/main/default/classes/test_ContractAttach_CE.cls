@isTest
public with sharing class test_ContractAttach_CE
{
	static testmethod void testCases()
	{
		Opportunity oppty = TestUtility.sampleOpportunity();
		insert oppty;
		
		oppty = [select Id, Client_Signed_Contract_Attached__c from Opportunity where Id = :oppty.Id];
		System.Assert(!oppty.Client_Signed_Contract_Attached__c);
		
		PageReference pageRef = createPage(oppty);
		ContractAttach_CE ctrl = new ContractAttach_CE(new ApexPages.StandardController(oppty));
		exerciseNoContract(ctrl);

		oppty = [select Id, Client_Signed_Contract_Attached__c from Opportunity where Id = :oppty.Id];
		System.Assert(oppty.Client_Signed_Contract_Attached__c);

		pageRef = createPage(oppty);
		ctrl = new ContractAttach_CE(new ApexPages.StandardController(oppty));
		if (ctrl.getOpportunityHasContract()) {
			exerciseHasContract(ctrl);
		}
		
		pageRef = createPage(oppty);
		ctrl = new ContractAttach_CE(new ApexPages.StandardController(oppty));
		PageReference pr = ctrl.Cancel();
		System.assertEquals('/' + oppty.Id, pr.getUrl());		
	}
	
	static private PageReference createPage(Opportunity oppty)
	{
		PageReference pageRef = Page.ContractAttach;
		pageRef.getParameters().put('id', oppty.id);
		System.Test.setCurrentPage(pageRef);
		
		return pageRef;
	}
	
	static private void exerciseNoContract(ContractAttach_CE ctrl)
	{
		ctrl.ConfirmCreateNew = true;
		ctrl.ConfirmContractDocument = true;
		ctrl.CreateContractAndUploadDoc();
	}

	static private void exerciseHasContract(ContractAttach_CE ctrl)
	{
		ctrl.ConfirmCreateNew = true;
		ctrl.ConfirmContractDocument = true;
		ctrl.OpportunityContracts[0].Selected = true;
		ctrl.UploadDocToExistingContract();
	}

}