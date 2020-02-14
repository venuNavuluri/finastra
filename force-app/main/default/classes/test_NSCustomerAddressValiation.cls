@isTest

public class test_NSCustomerAddressValiation

{
    private static testmethod void test() 
    {
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
        insert testAcc;
        
        Bill_To_Ship_To__c btst = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 1', Default_Billing__c = true, Account__c = testAcc.Id, Bill_to_Contact__c = contact.Id);
        insert btst;
        Bill_To_Ship_To__c btst2 = new Bill_To_Ship_To__c(Bill_To_Name__c = 'Test Name', Bill_To_Attention__c = 'Test Att', Bill_To_Street_1__c = 'Street 2', Default_Billing__c = false, Account__c = testAcc.Id, Bill_to_Contact__c = contact.Id);
        insert btst2;
        
        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', NS_Subsidiary_InternalId__c = '1');
        insert misysEntity;
        
        Acct_By_Sub__c accBySub = new Acct_By_Sub__c(Account__c = testAcc.Id, Misys_Entity__c = misysEntity.Id);
        insert accBySub;
        
        NS_Customer_Address__c ns_address = new NS_Customer_Address__c ();
        ns_address.Acct_By_Sub__c = accBySub.id;
        insert ns_address ;
        
        ns_address.Bill_To_Ship_To__c = btst.id;
        update ns_address;
    }

}