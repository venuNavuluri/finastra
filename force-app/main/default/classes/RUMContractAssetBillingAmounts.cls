public abstract class RUMContractAssetBillingAmounts extends RUMContractAssetBase
{
	public abstract class RUOWContractAsset extends RollUpChild
	{
		public RUOWContractAsset(Contract_Asset__c ca) { super(ca); }
	
		public Contract_Asset__c TheCA {
			get { return (Contract_Asset__c)TheSObject; }
			set { TheSObject = value; }
		}
	
		public override string getCurrencyCode() { return TheCA.CurrencyIsoCode; }
		public override Integer amountFieldCount() { return 2; }
		public override Decimal getAmount(Integer i) {
			if (i == 0) { return TheCA.CA_CY_Billing_Current_Amount__c; }
			else if (i == 1) { return TheCA.CA_CY_Billing_Previous_Amount__c; }
			return null;
		}
		public override boolean includeInRollUp() { return TheCA.CA_Billing_Group__c != null; }
		public override boolean isActive() { return (TheCA.CA_Billing_Status__c != 'Inactive Billing'); }		
	}
	
	public RUMContractAssetBillingAmounts(List<Contract_Asset__c> triggerList, Map<Id, Contract_Asset__c> oldMap)
	{
		super(triggerList, oldMap);
	}
	

}