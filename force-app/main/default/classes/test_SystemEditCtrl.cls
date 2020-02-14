@isTest
public class test_SystemEditCtrl
{
	static private System__c testSystem;
	
	static private void setUp()
	{
		Account acct = TestUtils.getAccount('TestAcct');
		acct.Site = 'Site';
		insert acct;
		
		testSystem = TestUtils.getSystem(acct, 'TestAcct-Site');
		testSystem.Environment2__c = 'TEST';
		insert testSystem;
	}
	
	static testmethod void test_CaseChangeAsset_Simple()
	{
		setUp();
		Test.startTest();
			PageReference testPage = Page.SystemEdit;
			testPage.getParameters().put('id', testSystem.Id);
			Test.setCurrentPage(testPage);
			
			ApexPages.Standardcontroller std = new ApexPages.Standardcontroller(testSystem);
			SystemEditCtrl ctrl = new SystemEditCtrl(std);

			ctrl.GetEnvironments();
			ctrl.Cancel();
			ctrl.TestSetData('PROD', 'prod1');
			ctrl.Save();

		Test.stopTest();
	}

}