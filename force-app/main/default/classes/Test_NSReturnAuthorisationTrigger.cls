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
	Created Date: 01/12/2014
	Description: This is the test class for testing NSReturnAuthorisationTrigger and NSReturnAuthorisationTriggerMethods class.
*/ 
@isTest
private class Test_NSReturnAuthorisationTrigger {

    static testMethod void myUnitTest() {
    	list<NS_List_Table__c> nsList = new list<NS_List_Table__c>();
    	
        NS_List_Table__c nsListTable1 = new NS_List_Table__c(Name = 'Contract Amendment', NS_Internal_Id__c = '1', NS_List_Name__c = 'CreditNoteSpecificReason');
        NS_List_Table__c nsListTable2 = new NS_List_Table__c(Name = 'RLF', NS_Internal_Id__c = '2', NS_List_Name__c = 'TransactionCategory');
        NS_List_Table__c nsListTable3 = new NS_List_Table__c(Name = 'Approved', NS_Internal_Id__c = '2', NS_List_Name__c = 'ApprovalStatus');
        NS_List_Table__c nsListTable4 = new NS_List_Table__c(Name = 'RLF', NS_Internal_Id__c = '2', NS_List_Name__c = 'InvoiceCreditBody');
        
        nsList.add(nsListTable1);
        nsList.add(nsListTable2);
        nsList.add(nsListTable3);
        nsList.add(nsListTable4);
        
        insert nsList;
        
        NS_Return_Authorisation__c retAuth = new NS_Return_Authorisation__c(Credit_NoteSpecific_Reason_Internal_Id__c = '1', Transaction_Category_Internal_Id__c = '2', Approval_Status_Internal_Id__c = '2', Invoice_Credit_Body_Internal_Id__c = '2');
        insert retAuth;
        
        retAuth = [select name, Credit_NoteSpecific_Reason__c from NS_Return_Authorisation__c where id = :retAuth.Id];
        
        system.assertEquals('Contract Amendment', retAuth.Credit_NoteSpecific_Reason__c);
        
        retAuth.Credit_NoteSpecific_Reason_Internal_Id__c = null;
        retAuth.Transaction_Category_Internal_Id__c = null;
        retAuth.Approval_Status_Internal_Id__c = null;
        retAuth.Invoice_Credit_Body_Internal_Id__c = null;
        
        update retAuth;
    }
}