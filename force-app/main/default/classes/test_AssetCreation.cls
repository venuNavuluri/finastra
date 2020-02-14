@isTest(seeAllData=true)
public with sharing class test_AssetCreation
{
	public static testmethod void DoTest()
	{
		if (Label.Test_AssetWizard != 'TRUE') { return; }
		CCRT__c testCCRT = TestUtility.sampleCCRT();
		testCCRT.Name = 'Test CCRT';
		testCCRT.Client_Site_Number__c = '12345';
		insert testCCRT;
		
		Account testAcct = TestUtility.sampleAccount();
		testAcct.CCRT_entry__c = testCCRT.Id;
		insert testAcct;
		
		Account testAcct2 = TestUtility.sampleAccount();
		insert testAcct2;
		
		Opportunity opp = TestUtility.sampleOpportunity(testAcct);
		opp.PS_Pricing_Details__c = 'blah';
		opp.CurrencyIsoCode = 'USD';
		insert opp;
		
		//AK - Changes for IS RLF Asset
		list<Product2> productList = new list<Product2>();
		for(Product2 prod2 : [Select Id From Product2 where name = 'Almonde : Base Platform' and (IsAsset__c = true or Is_RLF_Asset__c = true)]){
			prod2.Is_RLF_Asset__c = true;
			productList.add(prod2);
		}
		if(productList != null && productList.size() > 0){
			update productList;
		}
		
		PricebookEntry[] almondPBE = [
			select Id
			from PricebookEntry
			where Pricebook2Id in (select Id from Pricebook2 where Name = 'Misys')
			and Product2Id in (Select Id From Product2 where name = 'Almonde : Base Platform' and (IsAsset__c = true or Is_RLF_Asset__c = true))
			and CurrencyIsoCode = 'USD'
		];
		
		
		OpportunityLineItem oli = new OpportunityLineItem(
			OpportunityId = opp.Id,
			PricebookEntryId = almondPBE[0].Id,
			Quantity = 1,
			TotalPrice = 100,
			Pearl_Item__c = true
		);
		insert oli;
		
		Contract testContract = TestUtility.sampleContract(testAcct.Id);
		testContract.Misys_Opportunity__c = opp.Id;
		insert testContract;
		
		Test.startTest();
			PageReference acctPage = Page.WizAssetCreationAccountSelect;
			Test.setCurrentPage(acctPage);
			ApexPages.currentPage().getParameters().put('Id', testContract.id);

			WizAssetCreationController controller = new WizAssetCreationController();
			controller.cancel();

			Test.setCurrentPage(acctPage);
			ApexPages.currentPage().getParameters().put('Id', testContract.id);
			controller = new WizAssetCreationController();
			Opportunity oppty = controller.getOpportunity();
			
			controller.MakeBasicAccountSelection();
			WACAccountListWrapper alw = controller.GetAccountListWrapper();
			controller.GetAccountSearchDummyObject().Account__c = testAcct2.Id;
			controller.IncludeAccountChildren = true;
			boolean childrenIncluded = controller.IncludeAccountChildren;
			controller.AddAccount();
			controller.LocationIdToDelete = testAcct2.Id;
			controller.DeleteLocationInstance();
			PageReference envPage = controller.AccountSelectFinished();
			
			Test.setCurrentPage(envPage);
			// Production is selected by default...
			for (PickableEnvironment env : controller.getEnvironments()) {
				env.Selected = true;
			}
			acctPage = controller.AccountSelect();
			envPage = controller.AccountSelectFinished();
			
			
			PageReference prodPage = controller.EnvironmentSelectFinished();
			OpportunityLineItem[] olis = controller.getOLIs();
			PickableProductSet[] pss = controller.getProductSets();

			// exercise it a little
			string dummyName = pss[0].GetNonNullName();
			pss[0].ToggleExpanded();
			boolean expanded = pss[0].getIsExpanded();
			pss[0].UpdateSelection();
			pss[0].TickleAllProducts();
			boolean hasSelectedProds = pss[0].GetHasSelectedProducts();
			string color1 = pss[0].GetCoverageColorCode();
			string color2 = pss[0].GetAssetizingActionColorCode();
			double myBefore = pss[0].GetRemainingBefore();
			double myAfter = pss[0].GetRemainingAfter();

			pss[0].Products[0].Selected = true;
			PageReference amountAllocationPage = controller.AmountsAllocation();
			WACAccountWithSystem[] pairs = controller.GetAccountAndSystemPairs();
			string accountAndSystemName = pairs[0].GetMyId();
			Double sumLoading = controller.GetSumLoadingPercentage();
			PageReference assetSummaryPage = controller.CreateAssets();
			
		Test.stopTest();		
	}
}