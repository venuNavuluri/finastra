@IsTest
private class CPQ_Populate_Net_Customer_Uplift_Test {


	static testMethod void NetCustomerUpliftIsCopied() {

		//GIVEN

		//data is created

		Uplift__c uplift_before = [
			SELECT Id, Net_Customer_Uplift_Copy__c, NCU__c
			FROM Uplift__c
			LIMIT 1
		];

		//WHEN

		//setting override value which is referenced by uplift formula
		uplift_before.Override__c = 20;
		update uplift_before;


		//THEN

		Uplift__c uplift_after =
		[
			SELECT Id, Net_Customer_Uplift_Copy__c, NCU__c
			FROM Uplift__c
			WHERE Id = :uplift_before.Id
			LIMIT 1
		];
        
        system.debug('## uplift_after '+uplift_after);

		system.assertEquals(
			uplift_after.Net_Customer_Uplift_Copy__c,
			uplift_after.NCU__c,
			String.format(
				'Uplift has not been copied into the new field. Expected {0}, actual {1}',
				new String[] {
					String.valueOf(uplift_after.Net_Customer_Uplift_Copy__c),
					String.valueOf(uplift_after.NCU__c)
				}
			)
		);
	}

	@TestSetup
	static void createData() {

		Uplift_TestUtils.SetupBasicScenario();

	}
}