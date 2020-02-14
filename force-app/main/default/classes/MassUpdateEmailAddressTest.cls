@isTest 
public class MassUpdateEmailAddressTest {
	
    @testSetup
    static void initData() {
        Contact[] contacts = new Contact[]{};
        for(Integer i = 0; i<10; i++) {
            contacts.add(new Contact(LastName = 'Test'+i,Email = 'test@test.com', Alternative_Email__c='test123@test.com'));
        }
        insert Contacts;
        Lead[] leads = new Lead[]{};
        for(Integer i = 0; i<10; i++) {
            leads.add(new Lead(Company = 'TestComp', LastName = 'Test'+i, Salutation = 'Mr.', Email = 'testlead@test.com', Employee_Email__c = 'test342@test.com', Assistant_Email__c='test123@test.com'));
        }
        insert Leads;
   	}
	@isTest static void verifyMassUpdateContactBatchRun() {
        Test.startTest();
        	MassUpdateEmailAddress.executeDataMaskingJob();
        Test.stopTest();
        Contact[] contacts = [SELECT Email, Alternative_Email__c FROM Contact];
        system.assertEquals(10, contacts.size(), 'Contacts are not inserted in datasetup');
        for(Contact eachContact : contacts) {
			system.assertEquals('xxx@xxxx.xxx', eachContact.Email, 'Emails are not masked!');
			system.assertEquals('xxx@xxxx.xxx', eachContact.Alternative_Email__c, 'Alternative_Email__c are not masked!');
        }
        Lead[] leads = [SELECT Email, Employee_Email__c, Assistant_Email__c FROM Lead];
        system.assertEquals(10, leads.size(), 'leads are not inserted in datasetup');
        for(Lead eachLead : leads) {
			system.assertEquals('xxx@xxxx.xxx', eachLead.Email, 'Emails are not masked!');
			system.assertEquals('xxx@xxxx.xxx', eachLead.Assistant_Email__c, 'Assistant_Email__c are not masked!');
			system.assertEquals('xxx@xxxx.xxx', eachLead.Employee_Email__c, 'Employee_Email__c are not masked!');
        }
    }
}