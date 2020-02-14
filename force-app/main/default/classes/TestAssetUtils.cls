public with sharing class TestAssetUtils
{
	public static Billing_Group__c SampleBillingGroup(Billing_Entity__c be)
	{
		return new Billing_Group__c(BG_Misys_Billing_Entity__c = be.id);
	}
	
	public static Billing_Entity__c SampleBillingEntity()
	{
		return new Billing_Entity__c();
	}

	public static Billing_Entity__c createBillingEntity()
	{
		Billing_Entity__c be = SampleBillingEntity();
		insert be;
		return be;
	}
	
	public static Billing_Group__c createBillingGroup()
	{
		return createBillingGroup(createBillingEntity());
	}
	
	public static Billing_Group__c createBillingGroup(Billing_Entity__c be)
	{
		Billing_Group__c bg = SampleBillingGroup(be);
		insert bg;
		return bg;
	}
	
}