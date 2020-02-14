public class WizAssetCreationController implements IWACMainController
{
	WizAssetCreationAccountsController acctCtrl;
	WizAssetCreationEnvironmentsController envCtrl;
	WizAssetCreationProductController prodCtrl;
	WizAssetCreationAmtsAllocationController amtsAllocationCtrl;
	Contract contract;
	Opportunity opportunity;
	public string ThePageMessage { get; set; }

	// Account related operations
	public void DeleteLocationInstance() { acctCtrl.DeleteLocationInstance();	}
	public void AddAccount() { acctCtrl.AddAccount(); }
	public void AddCcrt() { acctCtrl.AddCcrt(); }
	public Client_Asset__c GetAccountSearchDummyObject() { return acctCtrl.GetAccountSearchDummyObject(); }
	public Location_of_Use__c GetCcrtSearchDummyObject() { return acctCtrl.GetCcrtSearchDummyObject(); }
	public WizAssetCreationAccountsController.LocationInstance[] getAccounts() { return acctCtrl.getAccounts(); }
	public WizAssetCreationAccountsController.LocationInstance[] getCcrts() { return acctCtrl.getCcrts(); }
	public WACAccountListWrapper GetAccountListWrapper() { return new WACAccountListWrapper(getAccounts()); }
	public WACAccountListWrapper GetCcrtListWrapper() { return new WACAccountListWrapper(getCcrts()); }
	public boolean IncludeAccountChildren {
		get { return acctCtrl.IncludeAccountChildren; }
		set { acctCtrl.IncludeAccountChildren = value; }
	}
	public string LocationIdToDelete {
		get { return acctCtrl.LocationIdToDelete; }
		set { acctCtrl.LocationIdToDelete = value; }
	}
	public void MakeBasicAccountSelection() { acctCtrl.MakeBasicAccountSelection(); }
	
	// Environments wizard page properties
	public PickableEnvironment[] getEnvironments() { return envCtrl.getEnvironments(); }
	
	// Product wizard page properties
	public OpportunityLineItem[] getOLIs() { return prodCtrl.getOLIs(); }
	public PickableProductSet[] getProductSets() { return prodCtrl.getProductSets(); }
	public WACProductSetListWrapper GetWrappedProductSets() { return new WACProductSetListWrapper(getProductSets()); }
	
	public Contract getContract()
	{
		if(contract == null) contract = new Contract();
		return contract;
	}
	
	public Opportunity getOpportunity() {
		if(opportunity == null) opportunity = new Opportunity();
		return opportunity;
	}
	
	// Amount allocation wizard page properties
	public WACAccountWithSystem[] GetAccountAndSystemPairs() {
		return amtsAllocationCtrl.GetAccountAndSystemPairs();
	}
	public void UpdateOLIInfoFields() {
		Double loading = (amtsAllocationCtrl == null ? 0 : amtsAllocationCtrl.GetSumLoadingPercentage());
		prodCtrl.UpdateOLIInfoFields(loading);
	}
	public Double GetSumLoadingPercentage() { return amtsAllocationCtrl.GetSumLoadingPercentage(); }
	public string AssetizationBase {
		get { return (amtsAllocationCtrl == null ? 'remaining' : amtsAllocationCtrl.AssetizationBase); }
		set { amtsAllocationCtrl.AssetizationBase = value; }
	}
	public boolean AssetizeByRemainingAmount() { return AssetizationBase == 'remaining'; }
	
	
	/*************** IWACMainController *************************************************/	
	public void SetPageMessage(string msg) { ThePageMessage = msg; }
	public Id GetContractAccountId() { return getContract().AccountId; }
	public Id GetContractOpportunityId() { return getContract().Misys_Opportunity__c; }

	/*************** Constructor *************************************************/	
	public WizAssetCreationController()
	{
		String contractId = ApexPages.currentPage().getParameters().get('Id');
		contract = [
			select Id, ContractNumber,
			Misys_Opportunity__c, Misys_Opportunity__r.Order_Number__c, Misys_Opportunity__r.Name, Misys_Opportunity__r.CurrencyISOCode,
			Account.Name, Account.Site, Account.Country__c, AccountId, StartDate, Contract_Expiry_Date__c,
			RLF_Earliest_Review_Date__c,
			Recurring_Fees_percent__c,
			//xxxAnnual_Maintenance_Increase_CAP_Exp_Date__c,
			Recurring_Fees_Index__c,
			Recurring_Fees_Index_Type__c,
			Rate_Increase_Cap_Value__c,
			Rate_Increase_Floor__c, 
			Recurring_Fees_Review_Month__c
			from Contract
			where Id = :contractId
		];
		
		prodCtrl = new WizAssetCreationProductController(this);
		if (prodCtrl.getOLIs().size() == 0) {
			if (prodCtrl.getAssetOLIs().size() == 0) {
				ThePageMessage = 'Contract does not contain any assets, no further action required.';
			}
			else {
				ThePageMessage = 'Opportunity contains items that need to be pushed from Pearl before assetization can commence.';
			}
		}
		if (ThePageMessage == null) { checkProductData(); }
		acctCtrl = new WizAssetCreationAccountsController(this);
		acctCtrl.clearSearchAccount();
		envCtrl = new WizAssetCreationEnvironmentsController();
		
		if (contract.Misys_Opportunity__c == null) {
			ThePageMessage = 'This contract does not have an opportunity assigned!';
		}
}
	
	/*************** Wizard navigation *************************************************/	
	public PageReference Debug() {
		for (WACAccountWithSystem bucket : amtsAllocationCtrl.GetAccountAndSystemPairs()) {
			System.debug('###£ ' + bucket.GetMyId() + ' - ' + bucket.LoadingPercentage);
		}
		return null;
	}

	public PageReference cancel()
	{
		PageReference contractPage = new ApexPages.StandardController(contract).view();
		contractPage.setRedirect(true);
		return contractPage; 
	}
	
	public PageReference EnvironmentSelectFinished()
	{
		string error = envCtrl.ValidateEnvironments();
		if (error != null) {
			ThePageMessage = error;
			return null;
		}
		ThePageMessage = null;
		return ProductSelect();
	}

	public PageReference ProductSelect()
	{
		amtsAllocationCtrl = null;
		UpdateOLIInfoFields();
		acctCtrl.clearSearchAccount();
		return Page.WizAssetCreationProductSelect;
	}

	public PageReference AccountSelectFinished()
	{
		if (prodCtrl.getOLIs().size() == 0) {
			System.debug(LoggingLevel.ERROR, 'WizAssetCreationController - No assetizable OLIs in AssetWizard!');
			return null;
		}
		string error = checkProductData();
		if (!al.StringUtils.IsEmpty(error)) {
			System.debug(LoggingLevel.ERROR, 'WizAssetCreationController - Error in product data in AssetWizard: ' + error);
			return null;
		}
		error = acctCtrl.validateAccounts();
		if (error != null) {
			ThePageMessage = error;
			System.debug(LoggingLevel.ERROR, 'WizAssetCreationController - Invalid account setup in AssetWizard: ' + error);
			return null;
		}
		return EnvironmentSelect();
	}
	
	private string checkProductData()
	{
		string error = '';
		Set<string> noLicenceGroupProducts = new Set<string>();
		for (OpportunityLineItem oli : prodCtrl.getOLIs()) {
			if (MisysStringUtils.GetLicenceGroup(oli.PriceBookEntry.Product2) == null) {
				noLicenceGroupProducts.add(oli.PriceBookEntry.Product2.Name);
			}
		}
		if (noLicenceGroupProducts.size() > 0) {
			error += '   No "Licence Group" marked on product(s): ';
			for (string pName : noLicenceGroupProducts) {
				error += ('<' + pName + '> ');
			}
			error += '!';
		}
		ThePageMessage = error;
		return error;
	}
	
	public PageReference EnvironmentSelect() {
		ThePageMessage = null;
		acctCtrl.clearSearchAccount();
		return Page.WizAssetCreationEnvironmentSelect;
	}
	
	public PageReference AccountSelect() {
		acctCtrl.clearSearchAccount();
		return Page.WizAssetCreationAccountSelect;
	}
	
	public PageReference AmountsAllocation() {
		
		if (getOLIsToAssetize().size() == 0) {
			ThePageMessage = 'No products selected. Please select products to generate!';
			return null;
		}
		
		amtsAllocationCtrl = new WizAssetCreationAmtsAllocationController(this, acctCtrl.getAccounts(), envCtrl.getEnvironments());
		UpdateOLIInfoFields();
		ThePageMessage = null;
		return Page.WizAssetCreationAmountsAllocation;
	}
	
	private PickableOLI[] getOLIsToAssetize()
	{
		PickableOLI[] OLIsToAssetize = new PickableOLI[]{};
		for (PickableProductSet ps : prodCtrl.getProductSets()) {
			for (PickableOLI prod : ps.Products) {
				if (prod.Selected) { OLIsToAssetize.add(prod); }
			}
		}
		return OLIsToAssetize;
	}
	
	public PageReference CreateAssets()
	{
		PickableOLI[] OLIsToAssetize = getOLIsToAssetize();

		Set<PickableEnvironment> systems = 
			new Set<PickableEnvironment>();
		for (PickableEnvironment env : envCtrl.getEnvironments()) {
			if (env.Selected) { systems.add(env); }
		}
		
		Set<Id> assetLocations = new Set<Id>{};
		Set<Id> useLocations = new Set<Id>{};
		for (WizAssetCreationAccountsController.LocationInstance acct : acctCtrl.getAccounts()) {
			assetLocations.add(acct.TheAccount.Id);
		}
		for (WizAssetCreationAccountsController.LocationInstance ccrt : acctCtrl.getCcrts()) {
			useLocations.add(ccrt.TheCcrt.Id);
		}
		
		SavePoint sp = Database.setSavepoint();
		try {
			AssetMaintenanceManager assetMgr = new AssetMaintenanceManager(
				OLIsToAssetize, systems, contract, assetLocations, useLocations, amtsAllocationCtrl.GetLoadingMap(),
				AssetizeByRemainingAmount() ?
				AssetMaintenance_AssetUtils.AssetizingBase.REMAINING :
				AssetMaintenance_AssetUtils.AssetizingBase.CONTRACTED 
			);
			assetMgr.CreateAssets();
		}
		catch (Exception e) {
			Database.rollback(sp);
			throw e;
		}
		
		PageReference pr = Page.AssetSummary;
		pr.getParameters().put('Id', contract.Id);
		return pr;
	}
	
}