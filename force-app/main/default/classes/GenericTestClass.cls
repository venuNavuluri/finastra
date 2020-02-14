@isTest
private class GenericTestClass 
{
/*	static testmethod void AccountTests()
	{
		AccountTriggerMethods_Test.testAccountOwnerChangeAddSharing();
		AccountTriggerMethods_Test.testSetAccountSharing();
	}

// ********************************************************************* //
	
	static testmethod void CaseTests()	
	{	
		CaseTriggerMethods.testCreateTimeObjectForNewCase();
		CaseTriggerMethods.testCaseCalculations();
		CaseTriggerMethods.testCaseCalculationsWithAccountChange();
		CaseTriggerMethods.test1();
	}

// ********************************************************************* //

	static testmethod void TimeCalculatorTests_1()	
	{
		TimeCalculator.testTimeCalculator_1();
	}	
	
	static testmethod void TimeCalculatorTests_2()	
	{
		TimeCalculator.testTimeCalculator_2();
	}	
	
// ********************************************************************* //
	
	static testmethod void OppTests()	
	{	
		//testOppStatusTrigger.testTrigger();
	}
	
// ********************************************************************* //
*/
	static testmethod void TargetedReleaseTests()	
	{
        /*
		string testEmail = 'joe.talos@misys.com.blah';
		
		User usr = TestUtility.sampleUser();
		usr.Email = testEmail;
		usr.IsActive = true;
		usr.UserRoleId = [select Id from UserRole where Name = 'System Administration'].Id;
		insert usr;
		*/
		
		//System.runAs(usr) {
			Case customerCase = TestUtility.sampleCase();
			
			Account a = TestUtility.createAccount('Test Account');
			customerCase.AccountId = a.Id;
			
			insert customerCase;
            
			Case testCase = TestUtility.sampleCase();
			testCase.AccountId = a.Id;
			insert testCase;
        	
			Targeted_Release__c tr = TestUtility.sampleTargetedRelease(testCase);
			insert tr;	
	
			tr.Scheduled_Delivery_Date__c = Date.today().addMonths(1);
			tr.Customer_Case__c = customerCase.Id;
			tr.L3_Status__c = 'Unconfirmed';
			tr.Delivery_Reference__c = 'blah';
			tr.Resolution_Type__c = 'blah';
			tr.Resolution_Details__c = 'blah';
			tr.Component__c = 'blah';
			update tr;
		//}
	}	

/*
// ********************************************************************* //
	
	static testmethod void UserTests()	
	{	
		//UserTriggerMethods.testPortalUserCreated();
		UserTriggerMethods.testUpdateUserContactLicenseFlag_Map();
		UserTriggerMethods.testUserUpdateToContact();
		UserTriggerMethods.testUserUpdateToContact_Map();
		UserTriggerMethods.validateContactTrigger();
	}

// ********************************************************************* //
*/
}