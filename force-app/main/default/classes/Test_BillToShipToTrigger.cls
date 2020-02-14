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
 	Description: This is the test class for BillToShipToTrigger and BillToShipToTriggerMethods.
 */
@isTest
private class Test_BillToShipToTrigger {

    static testMethod void myUnitTest() {
        CCRT__c testCCRT = TestUtility.sampleCCRT();
        testCCRT.Client_Site_Number__c = '12456';
        insert testCCRT;

        Contact contact = TestUtility.sampleContact();
        insert contact;
        
        Account testAcc = TestUtility.sampleAccount();
        testAcc.CCRT_entry__c = testCCRT.Id;
        testAcc.Customer_AP_Contact__c = contact.Id;
        testAcc.Customer_Invoice_Approval__c = contact.Id;
        insert testAcc;
        
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 1', Default_Billing__c = true, Account__c = testAcc.Id, Bill_to_Contact__c = contact.Id);
        insert btst;
        Bill_To_Ship_To__c btst2 = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 2', Default_Billing__c = false, Account__c = testAcc.Id, Bill_to_Contact__c = contact.Id);
        insert btst2;
        
		Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '1');
		insert misysEntity;
		
		Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id);
		insert accBySub;
		
		contact.NS_Internal_Id__c = '1245';
		contact.FirstName = 'Test flag';
		update contact;
		
		Acct_By_Sub__c accBySub1 = [select id, NS_Customer_Id__c from Acct_By_Sub__c where id = :accBySub.Id];
		system.assertEquals('12456-Test1', accBySub1.NS_Customer_Id__c);
		system.assertEquals(2, [select id from NS_Customer_Address__c where Acct_By_Sub__c = :accBySub.Id].size());

        Bill_To_Ship_To__c btst3 = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 3', Default_Billing__c = false, Account__c = testAcc.Id, Bill_to_Contact__c = contact.Id);
        insert btst3;
        Bill_To_Ship_To__c btst4 = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 4', Default_Billing__c = false, Account__c = testAcc.Id);
        insert btst4;
        system.assertEquals(4, [select id from NS_Customer_Address__c where Acct_By_Sub__c = :accBySub.Id].size());
        
        Contact contact1 = TestUtility.sampleContact();
        insert contact1;

        btst3.Bill_To_Street_1__c = 'Street 1';
        btst3.Bill_To_Street_2__c = 'Street 2';
        btst3.Bill_To_Street_3__c = 'Street 3';
        btst3.Bill_To_City__c = 'City 3';
        btst3.Bill_To_Name__c = 'Bill to name';
        btst3.Bill_To_Attention__c = 'Bill to attention';
        btst3.Bill_To_State_Province__c = 'State 3';
        btst3.Bill_To_Zip_Postal_Code__c = '1234';
        btst3.Phone__c = '123414578';
        btst3.Bill_to_Contact__c = contact1.Id;
   //     btst3.Default_Billing__c = true;
        btst3.Default_Shipping__c = true;
        update btst3;
        
        delete btst3;
        system.assertEquals(3, [select id from NS_Customer_Address__c where Acct_By_Sub__c = :accBySub.Id].size());
    }
}