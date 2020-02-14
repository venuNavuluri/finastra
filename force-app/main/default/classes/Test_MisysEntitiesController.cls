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
	Created Date: 18/11/2013
	Description: This is the test class for testing MisysEntitiesController class.
*/
@isTest
private class Test_MisysEntitiesController {

    static testMethod void myUnitTest() {
	    Account account = TestUtility.sampleAccount();
	    insert account;
	    
	    Contact contact1 = TestUtility.sampleContact();
	    contact1.AccountId = account.Id;
	    insert contact1;
	    Contact contact2 = TestUtility.sampleContact();
	    contact2.LastName = 'TestCon2';
	    contact2.AccountId = account.Id;
	    insert contact2;
	    Contact contact3 = TestUtility.sampleContact();
	    contact3.LastName = 'TestCon3';
	    contact3.AccountId = account.Id;
	    insert contact3;
	    Contact contact4 = TestUtility.sampleContact();
	    contact4.LastName = 'TestCon4';
	    contact4.AccountId = account.Id;
	    insert contact4;
	    Contact contact5 = TestUtility.sampleContact();
	    contact5.LastName = 'TestCon5';
	    contact5.AccountId = account.Id;
	    insert contact5;

	    Contact contact6 = TestUtility.sampleContact();
	    contact6.LastName = 'TestCon6';
	    contact6.AccountId = account.Id;
	    insert contact6;
	    Contact contact7 = TestUtility.sampleContact();
	    contact7.LastName = 'TestCon7';
	    contact7.AccountId = account.Id;
	    insert contact7;
	    Contact contact8 = TestUtility.sampleContact();
	    contact8.LastName = 'TestCon8';
	    contact8.AccountId = account.Id;
	    insert contact8;
	    Contact contact9 = TestUtility.sampleContact();
	    contact9.LastName = 'TestCon9';
	    contact9.AccountId = account.Id;
	    insert contact9;
	    Contact contact10 = TestUtility.sampleContact();
	    contact10.LastName = 'TestCon10';
	    contact10.AccountId = account.Id;
	    insert contact10;
	    
		Billing_Entity__c misysEntity = new Billing_Entity__c(Name = 'Test1', Entity_Status__c = 'Contracting Entity', 
		Primary_signatory__c = contact1.Id, Preferred_signatory_1__c = contact2.Id, Preferred_signatory_2__c = contact3.Id,
		Preferred_signatory_3__c = contact4.Id, Preferred_signatory_4__c = contact5.Id, Second_signatory__c = contact6.Id,
		Alternative_signatory_1__c = contact7.Id, Alternative_signatory_2__c = contact8.Id, Alternative_signatory_3__c = contact9.Id,
		Alternative_signatory_4__c = contact10.Id);
		insert misysEntity;

		Billing_Entity__c misysEntity2 = new Billing_Entity__c(Name = 'Test2', Entity_Status__c = 'Contracting Entity', 
		Primary_signatory__c = contact1.Id, Preferred_signatory_1__c = contact2.Id, Preferred_signatory_2__c = contact3.Id,
		Preferred_signatory_3__c = contact4.Id, Preferred_signatory_4__c = contact5.Id, Second_signatory__c = contact6.Id,
		Alternative_signatory_1__c = contact7.Id, Alternative_signatory_2__c = contact8.Id, Alternative_signatory_3__c = contact9.Id,
		Alternative_signatory_4__c = contact10.Id);
		insert misysEntity2;
		
		system.assertEquals(new MisysEntitiesController().getMisysEntities().size(), 2);
    }
}