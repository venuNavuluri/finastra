/*
	Created By: Abhinit Kohar
	Created Date: 01/12/2014
	Description: This class holds the helper methods for NSReturnAuthorisationTrigger trigger.
*/
public class NSReturnAuthorisationTriggerMethods {

	public static void populateNSReturnAuthorisation(map<id, NS_Return_Authorisation__c> oldMap, map<id, NS_Return_Authorisation__c> newMap, list<NS_Return_Authorisation__c> newList){
		map<string, string> listTableMap = new map<string, string>();
		for(NS_List_Table__c listTable : [select id, name, NS_Internal_Id__c, NS_List_Name__c from NS_List_Table__c where 
											NS_List_Name__c = 'CreditNoteSpecificReason' or NS_List_Name__c = 'TransactionCategory' or NS_List_Name__c = 'ApprovalStatus' 
											or NS_List_Name__c = 'InvoiceCreditBody']){
												
			if(listTable.NS_List_Name__c == 'CreditNoteSpecificReason'){
				listTableMap.put(listTable.name + 'CreditNoteSpecificReason', listTable.NS_Internal_Id__c);
				listTableMap.put(listTable.NS_Internal_Id__c + 'CreditNoteSpecificReason', listTable.name);
			} else if(listTable.NS_List_Name__c == 'TransactionCategory'){
				listTableMap.put(listTable.name + 'TransactionCategory', listTable.NS_Internal_Id__c);
				listTableMap.put(listTable.NS_Internal_Id__c + 'TransactionCategory', listTable.name);
			} else if(listTable.NS_List_Name__c == 'ApprovalStatus'){
				listTableMap.put(listTable.name + 'ApprovalStatus', listTable.NS_Internal_Id__c);
				listTableMap.put(listTable.NS_Internal_Id__c + 'ApprovalStatus', listTable.name);
			} else if(listTable.NS_List_Name__c == 'InvoiceCreditBody'){
				listTableMap.put(listTable.name + 'InvoiceCreditBody', listTable.NS_Internal_Id__c);
				listTableMap.put(listTable.NS_Internal_Id__c + 'InvoiceCreditBody', listTable.name);
			}
			
		}
		system.debug('ListTableMap = ' + listTableMap);
		//set for holding the NS Invoice ids
		set<id> nsInvoiceIds = new set<id>();
		
		for(NS_Return_Authorisation__c retAuth : newList){
			if(retAuth.NS_Invoice__c != null){
				nsInvoiceIds.add(retAuth.NS_Invoice__c);
			}
			
			if(retAuth.Credit_NoteSpecific_Reason_Internal_Id__c != null && listTableMap.containsKey(retAuth.Credit_NoteSpecific_Reason_Internal_Id__c + 'CreditNoteSpecificReason')){
				retAuth.Credit_NoteSpecific_Reason__c = listTableMap.get(retAuth.Credit_NoteSpecific_Reason_Internal_Id__c + 'CreditNoteSpecificReason');
			} else {
				retAuth.Credit_NoteSpecific_Reason__c = null;
			}
			if(retAuth.Transaction_Category_Internal_Id__c != null && listTableMap.containsKey(retAuth.Transaction_Category_Internal_Id__c + 'TransactionCategory')){
				retAuth.Transaction_Category__c = listTableMap.get(retAuth.Transaction_Category_Internal_Id__c + 'TransactionCategory');
			} else {
				retAuth.Transaction_Category__c = null;
			}
			if(retAuth.Approval_Status_Internal_Id__c != null && listTableMap.containsKey(retAuth.Approval_Status_Internal_Id__c + 'ApprovalStatus')){
				retAuth.Approval_Status__c = listTableMap.get(retAuth.Approval_Status_Internal_Id__c + 'ApprovalStatus');
			} else {
				retAuth.Approval_Status__c = null;
			}
			if(retAuth.Invoice_Credit_Body_Internal_Id__c != null && listTableMap.containsKey(retAuth.Invoice_Credit_Body_Internal_Id__c + 'InvoiceCreditBody')){
				retAuth.Invoice_Credit_Body__c = listTableMap.get(retAuth.Invoice_Credit_Body_Internal_Id__c + 'InvoiceCreditBody');
			} else {
				retAuth.Invoice_Credit_Body__c = null;
			}
			//Set the currency
			if(retAuth.NS_Currency_Name__c != null && retAuth.NS_Currency_Name__c != ''){
				retAuth.CurrencyIsoCode = retAuth.NS_Currency_Name__c;
			}
			//put the negative values for credit memo fields
			if(retAuth.Discount__c != null){
                    if(trigger.isInsert){
                        retAuth.Discount__c = - retAuth.Discount__c;
                    }else if(trigger.isUpdate && retAuth.Discount__c!=oldMap.get(retAuth.id).Discount__c){
                         retAuth.Discount__c = - retAuth.Discount__c;
                    }
             }
		    if(retAuth.Sub_Total__c != null){
                    if(trigger.isInsert){
                        retAuth.Sub_Total__c = - retAuth.Sub_Total__c;
                    }else if(trigger.isUpdate && retAuth.Sub_Total__c!=oldMap.get(retAuth.id).Sub_Total__c){
                         retAuth.Discount__c = - retAuth.Sub_Total__c;
                    }
            }
            if(retAuth.Tax_Total__c != null){
                    if(trigger.isInsert){
                        retAuth.Tax_Total__c = - retAuth.Tax_Total__c;
                    }else if(trigger.isUpdate && retAuth.Tax_Total__c!=oldMap.get(retAuth.id).Tax_Total__c){
                         retAuth.Tax_Total__c = - retAuth.Tax_Total__c;
                    }
            }
            
		    if(retAuth.Total__c != null){
				  if(trigger.isInsert){
                        retAuth.Total__c = - retAuth.Total__c;
                    }else if(trigger.isUpdate && retAuth.Total__c!=oldMap.get(retAuth.id).Total__c){
                         retAuth.Total__c = - retAuth.Total__c;
                    }
			}
		}
		
		if(nsInvoiceIds != null && nsInvoiceIds.size() > 0){
			//map containing the invoice id and sales order id
			map<id, id> invoiceSOIdMap = new map<id, id>();
			for(NS_Invoice_Credit_Memo__c invoice : [select id, Sales_Order__c from NS_Invoice_Credit_Memo__c where id in : nsInvoiceIds and Sales_Order__c != null]){
				invoiceSOIdMap.put(invoice.Id, invoice.Sales_Order__c);
			}
			system.debug('invoiceSOIdMap = ' + invoiceSOIdMap);
			
			if(invoiceSOIdMap != null && invoiceSOIdMap.size() > 0){
				for(NS_Return_Authorisation__c ra : newList){
					if(invoiceSOIdMap.containsKey(ra.NS_Invoice__c)){
						ra.Sales_Order__c = invoiceSOIdMap.get(ra.NS_Invoice__c);
					}
				}
			}
		}
	}
}