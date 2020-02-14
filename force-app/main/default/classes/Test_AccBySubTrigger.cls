/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
 /*
 	Created By: Abhinit Kohar
 	Created Date: 29/01/2014
 	Description: This is the test class for testing AccBySubTrigger, AccBySubTriggerMethods, CCRTTriggerMethods and AccountTriggerMethods (updateAcctBySub method).
 */
@isTest
private class Test_AccBySubTrigger {

    static testMethod void myUnitTest() {
        CCRT__c testCCRT = TestUtility.sampleCCRT();
        testCCRT.Client_Site_Number__c = '12456';
        testCCRT.Client_Name_in_normal_use__c = 'Test Client Test Client Test Client Test Client Test Client';
        testCCRT.Client_Location__c = 'Test Client location Test Client location Test Client location Test Client location';
        insert testCCRT;
        
        Contact contact = TestUtility.sampleContact();
        insert contact;

        Account testAcc = TestUtility.sampleAccount();
        testAcc.CCRT_entry__c = testCCRT.Id;
        testAcc.NS_Cash_Accounting__c = true;
        testAcc.Website = 'test.com';
        testAcc.AP_Access_URL__c = 'test.com';
        testAcc.Customer_AP_Contact__c = contact.Id;
        testAcc.Customer_Invoice_Approval__c = contact.Id;
        testAcc.NS_Credit_Limit__c = 11.0;
        insert testAcc;
        
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 1', Default_Billing__c = true, Account__c = testAcc.Id, Bill_to_Contact__c = contact.Id);
        insert btst;
        Bill_To_Ship_To__c btst2 = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 2', Default_Billing__c = false, Account__c = testAcc.Id, Bill_to_Contact__c = contact.Id);
        insert btst2;
        
		Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '1');
		insert misysEntity;
		
		Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id);
		insert accBySub;
		
		Acct_By_Sub__c accBySub1 = [select id, NS_Customer_Id__c, NS_Cash_Accounting__c from Acct_By_Sub__c where id = :accBySub.Id];
		system.assertEquals('12456-Test1', accBySub1.NS_Customer_Id__c);
		system.assertEquals(true, accBySub1.NS_Cash_Accounting__c);
		system.assertEquals(2, [select id from NS_Customer_Address__c where Acct_By_Sub__c = :accBySub.Id].size());
		
		testCCRT.Client_Site_Number__c = '14785';
		update testCCRT;
        testAcc.NS_Customer_Specific_Billing_Other__c = 'test';
//		testAcc.NS_Cash_Accounting__c = false;
		update testAcc;

		Acct_By_Sub__c accBySub1_1 = [select id, NS_Customer_Id__c, NS_Cash_Accounting__c from Acct_By_Sub__c where id = :accBySub.Id];
		system.assertEquals('14785-Test1', accBySub1_1.NS_Customer_Id__c);
		//system.assertEquals(false, accBySub1_1.NS_Cash_Accounting__c);

        CCRT__c testCCRT1 = TestUtility.sampleCCRT();
        testCCRT1.Client_Site_Number__c = '124567';
        insert testCCRT1;

        Contact contact1 = TestUtility.sampleContact();
        insert contact1;

        Account testAcc2 = TestUtility.sampleAccount();
        testAcc2.CCRT_entry__c = testCCRT1.Id;
        testAcc2.Website = 'http://test.com';
        testAcc2.AP_Access_URL__c = 'http://test.com';
        testAcc2.Customer_AP_Contact__c = contact1.Id;
        testAcc2.Customer_Invoice_Approval__c = contact1.Id;
        insert testAcc2;
		Billing_Entity__c misysEntity2 = new Billing_Entity__c(Name = 'Test2', NS_Subsidiary_InternalId__c = '2');
		insert misysEntity2;
		
		accBySub.Misys_Entity__c = misysEntity2.Id;
		accBySub.Account__c = testAcc2.Id;
		update accBySub;

		Acct_By_Sub__c accBySub2 = [select id, NS_Customer_Id__c from Acct_By_Sub__c where id = :accBySub.Id];
		system.assertEquals(0, [select id from NS_Customer_Address__c where Acct_By_Sub__c = :accBySub.Id].size());
    }
}