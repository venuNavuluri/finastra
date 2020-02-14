@isTest
public with sharing class test_CreateInvoiceRegisterController
{
	public static testmethod void testCreateInvoiceRegister()
	{
		Billing_Entity__c billE = TestAssetUtils.SampleBillingEntity();
		insert billE;
		
		Billing_Group__c billGr = TestAssetUtils.SampleBillingGroup(billE);
		insert billGr;
		
		Opportunity oppty = TestUtility.sampleOpportunity();
		insert oppty;
		
		Opportunity refreshedOppty = [select id, Order_Number__c, name from Opportunity where id = :oppty.id];
		
		Test.startTest();
			PageReference testPage = Page.CreateInvoiceRegister;
			testPage.getParameters().put('id', billGr.Id);
			Test.setCurrentPage(testPage);
			
			//Instantiate the controller and capture the account and contact selected to verify later.
			ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(billGr);
			CreateInvoiceRegisterController ctrl = new CreateInvoiceRegisterController(std);
			ctrl.OpptyNumberToSearch = refreshedOppty.Order_Number__c;
			ctrl.Search();
			ctrl.Create();
		Test.stopTest();
	}

}