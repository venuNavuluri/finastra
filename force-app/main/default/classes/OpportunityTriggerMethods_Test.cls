@isTest
private class OpportunityTriggerMethods_Test {
	private static  testMethod void testNotifyGSCentral() {
		Id licensesWithOrWithoutPSRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Licenses with/without PS').getRecordTypeId();
        Opportunity testOpp = TestUtility.sampleOpportunity();
		testOpp.RecordTypeId=licensesWithOrWithoutPSRecordTypeId;
		testOpp.StageName='4. Develop';
		testOpp.PS_Stage__c='2. Check';
        testOpp.PS_Risk_Category__c='High';
		insert testOpp;
		System.assertNotEquals(null,testOpp.id);
		testOpp.Notify_GS__c=true;
		Integer beforeCount = Limits.getEmailInvocations();
		Test.startTest();
		update testOpp;
		Integer afterCount = Limits.getEmailInvocations();
		Test.stopTest();

		Organization thisOrg = [select isSandbox from Organization];
        if(thisOrg.isSandbox) {
            System.assert(afterCount>beforeCount,'Should have been sent mail');
        } 
		

	}
	private static testMethod void testNotifyPSDealCaptain() {
		Id licensesWithOrWithoutPSRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Licenses with/without PS').getRecordTypeId();
        Opportunity testOpp = TestUtility.sampleOpportunity();
		testOpp.RecordTypeId=licensesWithOrWithoutPSRecordTypeId;
		testOpp.StageName='4. Develop';
		testOpp.PS_Stage__c='2. Check';
		testOpp.PS_Risk_Category__c='High';
		insert testOpp;
		System.assertNotEquals(null,testOpp.id);
		testOpp.Notify_GS__c=true;
		testOpp.PS_Deal_Captain__c=UserInfo.getUserId();
		Integer beforeCount = Limits.getEmailInvocations();
		Test.startTest();
		update testOpp;
		Integer afterCount = Limits.getEmailInvocations();
		Test.stopTest();
		Organization thisOrg = [select isSandbox from Organization];
        if(thisOrg.isSandbox) {
            System.assert(afterCount>beforeCount,'Should have been sent mail');
        } 
	}
}