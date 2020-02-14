public class AccountAssetViewCE {

	public List<Location_of_Use__c> listLOUs {get;set;}
	public Account acct;

	public AccountAssetViewCE(ApexPages.StandardController stdController)
	{
		//Get the current record
		acct = (Account)stdController.getRecord();
		system.debug('Account = '+acct);
		
		//listLOUs = [select Id, Name, CCRT__r.Name, CCRT__r.Account__r.Name, CCRT__r.Account__r.Site, Contract_Asset__c, Client_Asset__c, Product_Set__c from location_of_use__c where contract_asset__r.client_asset__r.product_set__c = :suppEnt.Product_Set__c];
		listLOUs = [select Id, Name, CCRT__r.Name, Client_Asset__c, Asset_Account_Site__c, Product_Set__c, Customer_Advocate__c, Environment_s__c from location_of_use__c where CCRT__r.Account__r.Id = :acct.Id order by Product_Set__c, Client_Asset__c];
		
	}


}