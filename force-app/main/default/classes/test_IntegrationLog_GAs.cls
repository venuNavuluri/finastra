public class test_IntegrationLog_GAs
{
	private static Integration_Log__c createGAsIL(Id prodId)
	{
		Integration_Log__c ilProd = new Integration_Log__c();
		ilProd.SFDC_Id__c = prodId;
		ilProd.NumField18__c = 1;
		ilProd.DateField2__c = DateTime.newInstance(2014, 1, 25);
		ilProd.DateField3__c = DateTime.newInstance(2015, 2, 20);
		ilProd.RecordTypeId = TestIntegrationLogUtils.GetIntLogProductGARecTypeId();
		return ilProd;
	}

	public static testmethod void testIntegration_PMPRODGAS()
	{
		List<Integration_Log__c> testLogs = new List<Integration_Log__c>();
		
		Product2 prod = TestUtility.sampleProduct();
		prod.GA__c = false;
		prod.GA_Avail_Date__c = Date.newInstance(2000, 12, 19);
		prod.GA_Estimated_Date__c = Date.newInstance(2000, 11, 18);
		insert prod;
		
		//Run the process for the test
		Test.startTest();
		system.RunAs(TestIntegrationLogUtils.GetIntegrationUser()){
			// create product
			Integration_Log__c ilProdGA = createGAsIL(prod.Id);
			insert ilProdGA;
			
			// verify success
			Integration_Log__c ilInserted = TestIntegrationLogUtils.QueryIL(ilProdGA.Id);
			System.assert(ilInserted.isSuccess__c);
			System.assertEquals(ilInserted.Status__c,'Success');
			
			// query inserted product
			Product2 updatedProd = TestIntegrationLogUtils.QueryProdById(prod.Id);
			System.AssertEquals(true, updatedProd.GA__c);
			System.AssertEquals(ilProdGA.DateField2__c, updatedProd.GA_Estimated_Date__c);
			System.AssertEquals(ilProdGA.DateField3__c, updatedProd.GA_Avail_Date__c);
			
		}
		Test.stopTest();
	}
}