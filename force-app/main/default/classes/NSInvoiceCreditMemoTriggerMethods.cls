/*
	Created By: Abhinit Kohar
	Created Date: 24/11/2014
	Description: This class holds the support methods for NSInvoiceCreditMemoTrigger trigger.
*/
public class NSInvoiceCreditMemoTriggerMethods {

	public static void populateNSInvoiceCreditMemo(map<id, NS_Invoice_Credit_Memo__c> oldMap, map<id, NS_Invoice_Credit_Memo__c> newMap, list<NS_Invoice_Credit_Memo__c> newList){
		map<string, string> listTableMap = new map<string, string>();
		for(NS_List_Table__c listTable : [select id, name, NS_Internal_Id__c, NS_List_Name__c from NS_List_Table__c where 
											NS_List_Name__c = 'TransactionCategory' or NS_List_Name__c = 'InvoiceCreditBody' or 
											NS_List_Name__c = 'PdfDocStatus']){
												
			if(listTable.NS_List_Name__c == 'TransactionCategory'){
				listTableMap.put(listTable.name + 'TransactionCategory', listTable.NS_Internal_Id__c);
				listTableMap.put(listTable.NS_Internal_Id__c + 'TransactionCategory', listTable.name);
			} else if(listTable.NS_List_Name__c == 'InvoiceCreditBody'){
				listTableMap.put(listTable.name + 'InvoiceCreditBody', listTable.NS_Internal_Id__c);
				listTableMap.put(listTable.NS_Internal_Id__c + 'InvoiceCreditBody', listTable.name);
			} else if(listTable.NS_List_Name__c == 'PdfDocStatus'){
				listTableMap.put(listTable.name + 'PdfDocStatus', listTable.NS_Internal_Id__c);
				listTableMap.put(listTable.NS_Internal_Id__c + 'PdfDocStatus', listTable.name);
			}
			
		}
		system.debug('ListTableMap = ' + listTableMap);
		
		//set for holding the Return Authorisation Ids
		set<id> raIds = new set<id>();
		//list of Credit memos
		list<NS_Invoice_Credit_Memo__c> cmList = new list<NS_Invoice_Credit_Memo__c>();
		
		for(NS_Invoice_Credit_Memo__c invoice : newList){
			if(invoice.Credit_Memo_No__c != null){
				cmList.add(invoice);
				if(invoice.Return_Authorisation__c != null){
					raIds.add(invoice.Return_Authorisation__c);
				}
				
				//put the negative values for credit memo fields
				if(invoice.Discount__c != null){
				    if(trigger.isInsert){
				        invoice.Discount__c = - invoice.Discount__c;
				    }else if(trigger.isUpdate && invoice.Discount__c!=oldMap.get(invoice.id).Discount__c){
				         invoice.Discount__c = - invoice.Discount__c;
				    }
				}
				if(invoice.Sub_Total__c != null){
				    if(trigger.isInsert){
                       invoice.Sub_Total__c = - invoice.Sub_Total__c;
                    }else if(trigger.isUpdate && invoice.Sub_Total__c!=oldMap.get(invoice.id).Sub_Total__c){
                       invoice.Sub_Total__c = - invoice.Sub_Total__c;
                    }
				}
				if(invoice.Tax_Total__c != null){
				    if(trigger.isInsert){
                       invoice.Tax_Total__c = - invoice.Tax_Total__c;
                    }else if(trigger.isUpdate && invoice.Tax_Total__c!=oldMap.get(invoice.id).Tax_Total__c){
                       invoice.Tax_Total__c = - invoice.Tax_Total__c;
                    }
				}
				if(invoice.Total__c != null){
				    if(trigger.isInsert){
                       invoice.Total__c = - invoice.Total__c;
                    }else if(trigger.isUpdate && invoice.Total__c!=oldMap.get(invoice.id).Total__c){
                       invoice.Total__c = - invoice.Total__c;
                    }
				}
			}
			
			if(invoice.Transaction_Category_Internal_Id__c != null && listTableMap.containsKey(invoice.Transaction_Category_Internal_Id__c + 'TransactionCategory')){
				invoice.Transaction_Category__c = listTableMap.get(invoice.Transaction_Category_Internal_Id__c + 'TransactionCategory');
			} else {
				invoice.Transaction_Category__c = null;
			}
			if(invoice.Invoice_Credit_Body_Internal_Id__c != null && listTableMap.containsKey(invoice.Invoice_Credit_Body_Internal_Id__c + 'InvoiceCreditBody')){
				invoice.Invoice_Credit_Body__c = listTableMap.get(invoice.Invoice_Credit_Body_Internal_Id__c + 'InvoiceCreditBody');
			} else {
				invoice.Invoice_Credit_Body__c = null;
			}
			if(invoice.PDF_Doc_Status_Internal_Id__c != null && listTableMap.containsKey(invoice.PDF_Doc_Status_Internal_Id__c + 'PdfDocStatus')){
				invoice.PDF_Doc_Status__c = listTableMap.get(invoice.PDF_Doc_Status_Internal_Id__c + 'PdfDocStatus');
			} else {
				invoice.PDF_Doc_Status__c = null;
			}
			//Set the currency
			if(invoice.NS_Currency_Name__c != null && invoice.NS_Currency_Name__c != ''){
				invoice.CurrencyIsoCode = invoice.NS_Currency_Name__c;
			}
			//Get rid of the Sales Order which don't have internal ids against them
			if(invoice.Sales_Order_Internal_Id__c == null || invoice.Sales_Order_Internal_Id__c == ''){
				invoice.Sales_Order__c = null;
			}
		}
		
		if(raIds != null && raIds.size() > 0){
			//map containing the RA id and sales order id
			map<id, id> raSOIdMap = new map<id, id>();
			for(NS_Return_Authorisation__c ra : [select id, Sales_Order__c from NS_Return_Authorisation__c where id in : raIds and Sales_Order__c != null]){
				raSOIdMap.put(ra.Id, ra.Sales_Order__c);
			}
			system.debug('raSOIdMap = ' + raSOIdMap);

			if(raSOIdMap != null && raSOIdMap.size() > 0){
				for(NS_Invoice_Credit_Memo__c cm : cmList){
					if(raSOIdMap.containsKey(cm.Return_Authorisation__c)){
						cm.Sales_Order__c = raSOIdMap.get(cm.Return_Authorisation__c);
					}
				}
			}
		}
	}

}