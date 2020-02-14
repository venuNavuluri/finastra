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
    Created Date: 15/11/2013
    Description: This is the test class for testing DocuSignTrigger trigger and DocuSignTriggerMethods class.
 */
@isTest
private class Test_DocuSignTrigger {

    static testMethod void myUnitTest() {
        
        Account account = TestUtility.sampleAccount();
        insert account;
      
        Contact contact1 = TestUtility.sampleContact();
        contact1.AccountId = account.Id;
        insert contact1;
        Contact contact2 = TestUtility.sampleContact();
        contact2.AccountId = account.Id;
        contact2.LastName = 'TestCon2';
        insert contact2;
     
        Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', Entity_Status__c = 'Contracting Entity', 
        Primary_signatory__c = contact1.Id);
        insert misysEntity;

        Opportunity testOpp1 = TestUtility.sampleOpportunity();
        testOpp1.Entity__c = misysEntity.Id;
        testOpp1.Approval_Status__c = 'Approved';
        testOpp1.Is_PearlMastered__c = true;
		testOpp1.Contractual_Billing_Address__c = 'blah';
		testOpp1.Contractual_Shipping_Address__c = 'more blah';
        insert testOpp1;
        
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__Company__c = account.Id, dsfs__Opportunity__c = testOpp1.Id, dsfs__Envelope_Status__c = 'Sent');
        insert dsStatus;
        Attachment att = new Attachment(parentId = dsStatus.Id, name = 'Test', Body = Blob.valueOf('This is the test attachment'));
        insert att;
        
        test.startTest();
        dsStatus.dsfs__Envelope_Status__c = 'Completed';
        update dsStatus;
        system.assertEquals(dsStatus.Id, [select id, DocuSignId__c from Contract where DocuSignId__c = :dsStatus.Id].DocuSignId__c);
        test.stopTest();
    }
}