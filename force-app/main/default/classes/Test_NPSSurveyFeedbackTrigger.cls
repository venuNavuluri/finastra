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
@isTest
private class Test_NPSSurveyFeedbackTrigger {

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
        insert testAcc;
        
        list<NPSSurveyFeedback__c> npsList = new list<NPSSurveyFeedback__c>();
        
        NPSSurveyFeedback__c nps1 = new NPSSurveyFeedback__c(Name = 'Test1', Account__c = testAcc.Id, Contact__c = contact.Id, Survey_Wave__c = 'NPS Jan 2014', Survey_Status__c = 'Completed', NPS_Score__c = 6);
        NPSSurveyFeedback__c nps2 = new NPSSurveyFeedback__c(Name = 'Test2', Account__c = testAcc.Id, Contact__c = contact.Id, Survey_Wave__c = 'NPS Jun 2014', Survey_Status__c = 'Completed', NPS_Score__c = 7);
        NPSSurveyFeedback__c nps3 = new NPSSurveyFeedback__c(Name = 'Test3', Account__c = testAcc.Id, Contact__c = contact.Id, Survey_Wave__c = 'NPS Jan 2015', Survey_Status__c = 'Completed', NPS_Score__c = 7);
        NPSSurveyFeedback__c nps4 = new NPSSurveyFeedback__c(Name = 'Test4', Account__c = testAcc.Id, Contact__c = contact.Id, Survey_Wave__c = 'NPS Jan 2015', Survey_Status__c = 'Completed');
        NPSSurveyFeedback__c nps5 = new NPSSurveyFeedback__c(Name = 'Test5', Account__c = testAcc.Id, Contact__c = contact.Id, Survey_Wave__c = 'NPS Jan 2014', Survey_Status__c = 'Completed');
        NPSSurveyFeedback__c nps6 = new NPSSurveyFeedback__c(Name = 'Test6', Account__c = testAcc.Id, Contact__c = contact.Id, Survey_Wave__c = 'NPS Jun 2014', Survey_Status__c = 'Completed');
        
        npsList.add(nps1);
        npsList.add(nps2);
        npsList.add(nps3);
        npsList.add(nps4);
        npsList.add(nps5);
        npsList.add(nps6);
        
        insert npsList;
        
        Account account = [select Survey_Score_1__c, Survey_Score_2__c, Survey_Score_3__c from Account where Id = :testAcc.Id];
        system.assertEquals(account.Survey_Score_1__c, 3.5);
        
        NPSSurveyFeedback__c npsDel = new NPSSurveyFeedback__c(Id = nps1.Id);
        delete npsDel;
        
    }
}