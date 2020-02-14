@isTest
private class SubscriptionCopyUtil_Test {
	private static testMethod void testCopyFieldValuesFromSovosTax() {
		Integer totalSubs = 5;
		Account acc = TestDataFactory.createAccount('Test');
		Contract con = TestDataFactory.createContract(acc, TestDataFactory.createOpportunity(acc));
		List<SBQQ__Subscription__c> subs = new List<SBQQ__Subscription__c>();
		SBQQ__Subscription__c sub;
		for(Integer i = 0; i < totalSubs; i++) {
			sub = TestDataFactory.createILF_Subscription(con, false);
			sub.Software_Delivery_Type__c = 'Electronic';
            sub.Delivery_Type__c = 'Electronic';
        	sub.Tax_Type__c = 'Maintenance';
        	sub.Sub_Type__c = 'Custom';
			subs.add(sub);
		}
		insert subs;
		TestDataFactory.createSovosTaxDetermination(true);

		for(SBQQ__Subscription__c tmpSub : subs) {
			System.assertEquals(null, tmpSub.TWE_Sovos_Code__c);
		}
		Test.startTest();
        
        Schema.SObjectType SObjectTypeObj = Schema.getGlobalDescribe().get('SBQQ__Subscription__c');
        Schema.FieldSet fieldSetObj = SObjectTypeObj.getDescribe().FieldSets.getMap().get('Query_Field_Set');
        List<Schema.FieldSetMember> queryFieldSet = fieldSetObj.getFields();
        string subQuery = 'SELECT Id, Billing_Group__c, ';
        for(Schema.FieldSetMember f : queryFieldSet) {
            subQuery += f.getFieldPath() + ', ';
        }
        subQuery += ' Billing_Status__c FROM SBQQ__Subscription__c';
        List<SBQQ__Subscription__c> updatedSubs = database.query(subQuery);
        
		updatedSubs = SubscriptionCopyUtil.copyFieldValuesFromSovosTax(updatedSubs);
        system.debug('##subs## '+updatedSubs);
        update updatedSubs; 
		
        Test.stopTest();
		
        updatedSubs = [Select Id, TWE_Sovos_Code__c from SBQQ__Subscription__c];
		system.debug('##subs updated## ' + updatedSubs);
		System.assertEquals(totalSubs, updatedSubs.size());
		for(SBQQ__Subscription__c tmpSub : updatedSubs) {
			System.assertEquals('1357924', tmpSub.TWE_Sovos_Code__c);
		}
	}
}