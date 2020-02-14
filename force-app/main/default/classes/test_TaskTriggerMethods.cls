@isTest
private class test_TaskTriggerMethods {

	static testmethod void testUpdateCaseSurveyDate()
	{
		//Set up the test data
		Case testCase = TestUtility.sampleCase();
		insert testCase;
		Task testTaskEmail = TestUtility.sampleTask();
		testTaskEmail.WhatId = testCase.Id;
		testTaskEmail.ActivityDate = system.today();
		testTaskEmail.Description = 'test test ' + Label.Case_Survey_Date_Code + ' test test';
		
		//Run the test
		Test.startTest();
		insert testTaskEmail;
		Test.stopTest();
		
		//Verify the results
		Case afterTest = [select Id, Case_Satisfaction_Survey_Sent__c from Case where Id = :testCase.Id];
		system.assertEquals(afterTest.Case_Satisfaction_Survey_Sent__c,testTaskEmail.ActivityDate);
	}

}