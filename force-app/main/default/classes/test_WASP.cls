@isTest
public class test_WASP
{
	public static testmethod void dotest()
	{
		Account acct = TestUtility.sampleAccount();
		insert acct;
		
		Account_Plan__c wasp = new Account_Plan__c();
		wasp.Account__c = acct.Id;
		wasp.Planning_Year__c = FinanceUtils.GetCurrentFiscalYearStart().year().format();
		insert wasp;
		
		Opportunity oppty1 = TestUtility.sampleOpportunity(acct);
		oppty1.Amount = 100;
		oppty1.AccountPlan__c = wasp.Id;
		insert oppty1;
		
		Opportunity oppty2 = TestUtility.sampleOpportunity(acct);
		oppty2.Amount = 400;
		oppty2.AccountPlan__c = wasp.Id;
		insert oppty2;
		
		oppty1.Amount = 200;
		update oppty1;
	}
}