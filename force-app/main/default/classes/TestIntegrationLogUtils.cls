public class TestIntegrationLogUtils
{
	private static User integrationUser;
	private static RecordType rtPPOPPLINE;
	private static RecordType rtPPOPPMILE;
	private static RecordType rtPMPRODREC;
	private static RecordType rtPMPRODGAS;
	private static RecordType rtPMPBENTRY;
	private static Pricebook2 stdPB, nonstdPB, misysPB;

	public static Id GetStandardPricebookId()
	{
		/*
		if (stdPB == null) {
			stdPB = [select Id from Pricebook2 where IsStandard = true limit 1];
		}
		return stdPB.Id;
		*/
		return Test.getStandardPricebookId();
	}
	
	public static Id GetNonStandardPricebookId()
	{
		if (nonstdPB == null) {
			//nonstdPB = [select Id from Pricebook2 where IsStandard = false limit 1];
			nonstdPB = new Pricebook2(Name = 'Test');
		}
		return nonstdPB.Id;
	}
	
	public static Id GetMisysPricebookId()
	{
		if (misysPB == null) {
			//misysPB = [select Id from Pricebook2 where IsStandard = false and Name = 'Misys' limit 1];
			misysPB = new Pricebook2(Name = 'Misys');
			insert misysPB;
		}
		return misysPB.Id;
	}
	
	public static User GetIntegrationUser()
	{	
		if (integrationUser == null) {
			integrationUser = [select Id from User where Id = :Label.Informatica_Integration_UserId];
		}
		return integrationUser;
	}

	public static Id GetIntLogOLIRecTypeId()
	{
		if (rtPPOPPLINE == null) {
			rtPPOPPLINE = [select Id from Recordtype where sObjectType = 'Integration_Log__c' and DeveloperName = 'PPOPPLINE'];
		}
		return rtPPOPPLINE.Id;
	}
	
	public static Id GetIntLogMSRecTypeId()
	{
		if (rtPPOPPMILE == null) {
			rtPPOPPMILE = [select Id from Recordtype where sObjectType = 'Integration_Log__c' and DeveloperName = 'PPOPPMILE'];
		}
		return rtPPOPPMILE.Id;
	}
	
	public static Id GetIntLogProductRecTypeId()
	{
		if (rtPMPRODREC == null) {
			rtPMPRODREC = [select Id from Recordtype where sObjectType = 'Integration_Log__c' and DeveloperName = 'PMPRODREC'];
		}
		return rtPMPRODREC.Id;
	}
	
	public static Id GetIntLogProductGARecTypeId()
	{
		if (rtPMPRODGAS == null) {
			rtPMPRODGAS = [select Id from Recordtype where sObjectType = 'Integration_Log__c' and DeveloperName = 'PMPRODGAS'];
		}
		return rtPMPRODGAS.Id;
	}
	
	public static Id GetIntLogPricebookRecTypeId()
	{
		if (rtPMPBENTRY == null) {
			rtPMPBENTRY = [select Id from Recordtype where sObjectType = 'Integration_Log__c' and DeveloperName = 'PMPBENTRY'];
		}
		return rtPMPBENTRY.Id;
	}
	
	public static Opportunity refreshOpp(string oppId)
	{
		return [select Id, Pricebook2Id from Opportunity where Id = :oppId][0];
	}

	public static Acct_By_Sub__c GetSampleAcctBySub(Id acctId)
	{
		Acct_By_Sub__c abs = new Acct_By_Sub__c();
		abs.Account__c = acctId;
		insert abs;
		return abs;
	}
	
	public static Integration_Log__c QueryIL(Id ilId)
	{
		Integration_Log__c ilProd = [
			select isSuccess__c, Status__c, Message__c
			from Integration_Log__c where Id = :ilId
		];
		return ilProd;
	} 

	public static Product2 QueryProdById(string pId)
	{
		return queryProd(pId, true);
	}

	public static Product2 QueryProdByName(string pName)
	{
		return queryProd(pName, false);
	}

	private static Product2 queryProd(string filter, boolean byId)
	{
		List<sObject> productList = Database.query(
			'select Id, Name, Description, IsAsset__c, ' +
				'ProductCode, Product_Family_Misys__c, Product_Codes_Sun__c, ' +
				'IsActive, Payaway__c, Business_Area__c, ' +
				'Business_Area_Scope__c, IPR_Owner_Cognos__c, IPR_Owner_Sun__c, ' +
				'Coral_ProdNo__c, Coral_PCID__c, Date_Coral_Update__c, ' +
				'Family, Product_Set__c, Line_of_Business__c, ' +
				'Acct_By_Sub__c, NS_Item_Name__c, NS_Tax_Schedule__c, ' +
				'NS_Item_Category__c, NS_Item_Sub_Category_1__c, NS_Item_Sub_Category_2__c, ' +
				'NS_Cost_Centre__c, NS_Income_Account__c, NS_Deferred_Revenue_Acct__c, ' +
				'NS_Accrued_Income_Acct__c, NS_Rev_Rec_Template__c, NS_Expense_Acct__c, ' +
				'NS_Deferred_Expense_Acct__c, NS_Product_Dimension__c, NS_Item_Type__c, ' +
				'NS_IPR_Item_Code__c, UPID__c, ' +
				'NS_Item_Category_ID__c, NS_Item_Sub_Category_1_ID__c, NS_Item_Sub_Category_2_ID__c, ' +
				'NS_Cost_Centre_ID__c, NS_Income_Account_ID__c, ' +
				'NS_Deferred_Revenue_Acct_ID__c, NS_Accrued_Income_Acct_ID__c, NS_Rev_Rec_Template_ID__c, ' +
				'Display_Seq_Number__c, NS_Expense_Acct_ID__c, NS_Deferred_Expense_Acct_ID__c, ' +
				'GA__c, NS_Product_Dimension_ID__c, NS_Item_Type_ID__c, NS_IPR_Split_Percentage__c, ' +
				'NS_IPR_Item__c, NS_IPR_Item_Internal_ID__c, ' +
				'GA_Estimated_Date__c, GA_Avail_Date__c, Third_Party_Vendor_Description__c ' +
			'from Product2 where ' +
			(byId ? 'Id = \'' : 'Name = \'') + filter + '\''
		);
		
		Product2 p = (Product2)productList[0];
		return p;
	}

	
}