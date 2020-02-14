/**
 * Test coverage class for the ContractTriggerHandlerHandler
 */
@IsTest
public with sharing class ContractTriggerHandlerTest {

    public static testMethod void testCPIFieldsUpdate()
    {
        //Set up test data
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        insert testAccount;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opp ';
        testOpp.AccountId = testAccount.Id;
        testOpp.StageName = 'Suspect';
        testOpp.CurrencyIsoCode = 'GBP';
        testOpp.CloseDate = system.today()+7;
        testOpp.ContractID__c = '1234';
        testOpp.Term_Estimate_Months__c = 30;
        testOpp.Deliver_Contracts__c = datetime.now().dateGmt();
        insert testOpp;
        
		SBQQ__Quote__c testQuote = new SBQQ__Quote__c();
        testQuote.SBQQ__Primary__c = true;
        testQuote.SBQQ__Type__c = 'Quote';
        testQuote.SBQQ__Status__c = 'Draft';
        testQuote.SBQQ__Account__c = testAccount.Id;
        testQuote.SBQQ__ExpirationDate__c = testOpp.CloseDate;
        testQuote.SBQQ__Opportunity2__c = testOpp.Id;
        testQuote.SBQQ__StartDate__c = Date.today();
        testQuote.SBQQ__SubscriptionTerm__c = 12;
        testQuote.Standard_Index__c = 'Standard Rate';
        testQuote.Additional_Increase__c = 5;
        testQuote.CPI__c = 'US CPI-U';
        testQuote.CPI_Index_Type__c = 'CAP';
        testQuote.Maximum_Rate__c = 6 ;
        testQuote.Minimum_Rate__c = 1;
        testQuote.No_CPI__c = false;
        testQuote.Use_Existing_CPI__c = true;
        testQuote.Apply_Standard_CPI__c= false;
        insert testQuote;
            
        testOpp.SBQQ__PrimaryQuote__c = testQuote.Id;
        update testOpp;
        Contract testContract = new Contract();
		testContract.SBQQ__Opportunity__c = testOpp.Id;
        testContract.AccountId = testAccount.Id;
 
        //Run the actions to test the before insert trigger
		insert testContract;
 
        //Verify the test results
        Contract contractAfter = [select id, Standard_Index__c, Additional_Increase__c, CPI__c, CPI_Index_Type__c, Maximum_Rate__c, Minimum_Rate__c, No_CPI__c, Use_Existing_CPI__c, Apply_Standard_CPI__c from Contract where Id = :testContract.Id];
		System.assertEquals(contractAfter.Standard_Index__c, 'Standard Rate');
		System.assertEquals(contractAfter.Additional_Increase__c, 5);
		System.assertEquals(contractAfter.CPI__c, 'US CPI-U');
		System.assertEquals(contractAfter.CPI_Index_Type__c, 'CAP');
		System.assertEquals(contractAfter.Maximum_Rate__c, 6);
		System.assertEquals(contractAfter.Minimum_Rate__c, 1);
		System.assertEquals(contractAfter.No_CPI__c, false);
		System.assertEquals(contractAfter.Use_Existing_CPI__c, true);
		System.assertEquals(contractAfter.Apply_Standard_CPI__c, false);
    }

}