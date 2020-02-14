public class test_CreatePSChangeReqBtnRedirectCtrl
{
	public static testmethod void DoTheTest()
	{
		Opportunity opp = TestUtility.sampleOpportunity();
		opp.StageName = 'Closed Won';
		opp.Approval_Status__c = 'Approved';
		opp.PS_Pricing_Details__c = 'blah';
		opp.Is_PearlMastered__c = true;
		opp.Contractual_Billing_Address__c = 'blah';
		opp.Contractual_Shipping_Address__c = 'more blah';
		insert opp;
		
		Test.startTest();
			PageReference thePage = Page.CreatePSChangeRequestBtnRedirect;
			Test.setCurrentPage(thePage);
			ApexPages.currentPage().getParameters().put('id', opp.id);
			
			CreatePSChangeRequestBtnRedirectCtrl controller = new CreatePSChangeRequestBtnRedirectCtrl();
			string crOppCreateUrl = controller.RedirectUser().getUrl();
			String[] urlPieces = crOppCreateUrl.split('\\?');
			System.assertEquals('/006/e', urlPieces[0]);
		Test.stopTest();
	}
}