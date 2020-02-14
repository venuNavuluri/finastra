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
	Created Date: 24/11/2014
	Description: This is the test class for testing NSInvoiceCreditMemoTrigger and NSInvoiceCreditMemoTriggerMethods class.
*/ 
@isTest
private class Test_NSInvoiceCreditMemoTrigger {

    static testMethod void myUnitTest() {
    	list<NS_List_Table__c> nsList = new list<NS_List_Table__c>();
    	
        NS_List_Table__c nsListTable1 = new NS_List_Table__c(Name = 'RLF', NS_Internal_Id__c = '2', NS_List_Name__c = 'TransactionCategory');
        NS_List_Table__c nsListTable2 = new NS_List_Table__c(Name = 'RLF', NS_Internal_Id__c = '2', NS_List_Name__c = 'InvoiceCreditBody');
        NS_List_Table__c nsListTable3 = new NS_List_Table__c(Name = 'Created', NS_Internal_Id__c = '1', NS_List_Name__c = 'PdfDocStatus');

        NS_List_Table__c nsListTable4 = new NS_List_Table__c(Name = 'Contract Amendment', NS_Internal_Id__c = '1', NS_List_Name__c = 'CreditNoteSpecificReason');
        NS_List_Table__c nsListTable5 = new NS_List_Table__c(Name = 'Approved', NS_Internal_Id__c = '2', NS_List_Name__c = 'ApprovalStatus');
        
        nsList.add(nsListTable1);
        nsList.add(nsListTable2);
        nsList.add(nsListTable3);
        nsList.add(nsListTable4);
        nsList.add(nsListTable5);
        
        insert nsList;
        
        NS_Invoice_Credit_Memo__c invoice = new NS_Invoice_Credit_Memo__c(Invoice_No__c = '123', Transaction_Category_Internal_Id__c = '2', Invoice_Credit_Body_Internal_Id__c = '2', PDF_Doc_Status_Internal_Id__c = '1',Credit_Memo_No__c='CM2016ZA20000027',Discount__c=100,Sub_Total__c=200,Tax_Total__c=300,Total__c=400);
        insert invoice;
        
        invoice = [select name, PDF_Doc_Status__c, Transaction_Category__c,Discount__c,Sub_Total__c,Tax_Total__c,Total__c,Credit_Memo_No__c from NS_Invoice_Credit_Memo__c where id = :invoice.Id];
        
        system.assertEquals('RLF', invoice.Transaction_Category__c);
        system.assertEquals('Created', invoice.PDF_Doc_Status__c);

        NS_Return_Authorisation__c retAuth = new NS_Return_Authorisation__c(NS_Invoice__c = invoice.Id, Credit_NoteSpecific_Reason_Internal_Id__c = '1', Transaction_Category_Internal_Id__c = '2', Approval_Status_Internal_Id__c = '2', Invoice_Credit_Body_Internal_Id__c = '2',Discount__c=100,Sub_Total__c=200,Tax_Total__c=300,Total__c=400);
        insert retAuth;
        
        invoice.Transaction_Category_Internal_Id__c = null;
        invoice.Invoice_Credit_Body_Internal_Id__c = null;
        invoice.PDF_Doc_Status_Internal_Id__c = null;
        invoice.Discount__c = 200;
        invoice.Sub_Total__c = 300;
        invoice.Tax_Total__c = 400;
        invoice.Total__c = 500;
        
        update invoice;
        
        retAuth = [select Discount__c,Sub_Total__c,Tax_Total__c,Total__c from NS_Return_Authorisation__c where id = :retAuth.Id];
        
        retAuth.Discount__c = 200;
        retAuth.Sub_Total__c = 300;
        retAuth.Tax_Total__c = 400;
        retAuth.Total__c = 500;
        
        update retAuth;

        NS_Invoice_Credit_Memo__c creditMemo = new NS_Invoice_Credit_Memo__c(Credit_Memo_No__c = '245', Return_Authorisation__c = retAuth.Id, Transaction_Category_Internal_Id__c = '2', Invoice_Credit_Body_Internal_Id__c = '2', PDF_Doc_Status_Internal_Id__c = '1');
        insert creditMemo;
        


    }
}