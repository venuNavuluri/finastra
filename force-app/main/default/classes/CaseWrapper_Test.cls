@isTest
private with sharing class CaseWrapper_Test {

	static testmethod void testCaseWrapper(){
        // AC 14/Jul/09 - System Asserts added at recommendation of Salesforce
		Case testCase = new Case(Subject='Test subject');
		CaseWrapper cw = new CaseWrapper(testCase);
		cw.Selected = true;
		System.assertEquals(cw.internalCase.Subject,'Test subject'); 
        
	}

}