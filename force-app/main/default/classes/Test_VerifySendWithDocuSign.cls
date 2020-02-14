/*
  Created By: Abhinit Kohar
  Created Date: 12/11/2013
  Description: This is the test class for testing the VerifySendWithDocuSign class.
*/
@isTest
private class Test_VerifySendWithDocuSign {

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
      insert testOpp1;

      test.startTest();
      system.assertEquals(VerifySendWithDocuSign.verifyReuirements(testOpp1.Id), false);
      OpportunityContactRole ocr = new OpportunityContactRole(ContactId = contact2.Id, OpportunityId = testOpp1.Id, 
      Role = 'Customer Signatory');
      insert ocr;
      OpportunityContactRole ocr1 = new OpportunityContactRole(ContactId = contact2.Id, OpportunityId = testOpp1.Id, 
      Role = 'Primary signatory');
      insert ocr1;
      system.assertEquals(VerifySendWithDocuSign.verifyReuirements(testOpp1.Id), true);
      test.stopTest();
    }
}