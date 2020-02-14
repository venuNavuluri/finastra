// Created by: Venu Navuluri
// This test class is created for to inactivate contractasset trigger

@isTest
private class ContractAssetTrigger_Test {
   
    static testMethod void TestCA()
    { 
       Account acct = TestUtility.createAccount('Test1');
	   System__c sys = TestUtility.createSystem(acct); 
        Test.startTest();
       Contract_Asset__c ca = TestUtility.sampleContractAsset(null, sys.Id, acct.Id);
  	   ca.Name ='Test ca';
	   insert ca;
       ca = [select Id, Name from Contract_Asset__c where Id = :ca.Id];
       System.assertEquals(ca.Name, 'Test ca'); 
        	Test.stopTest();
    }
	
}