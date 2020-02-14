/*
	Created By: Abhinit Kohar
	Created Date: 11/09/2014
	Description: This class holds the support methods for NSSubscriptionTrigger trigger.
*/
public class NSSubscriptionTriggerMethods {
	
	public static void populateNSSubscription(map<id, NS_Subscriptions__c> oldMap, map<id, NS_Subscriptions__c> newMap, list<NS_Subscriptions__c> newList){
		map<string, string> listTableMap = new map<string, string>();
		for(NS_List_Table__c listTable : [select id, name, NS_Internal_Id__c, NS_List_Name__c from NS_List_Table__c where 
											NS_List_Name__c = 'BillingMode' or NS_List_Name__c = 'BillingTransaction' or 
											NS_List_Name__c = 'SubscriptionStatus' or NS_List_Name__c = 'TerminationMethod' or 
											NS_List_Name__c = 'TransactionCategory' or NS_List_Name__c = 'HoldBillingReason']){
												
			if(listTable.NS_List_Name__c == 'BillingMode'){
				listTableMap.put(listTable.name + 'BillingMode', listTable.NS_Internal_Id__c);
				listTableMap.put(listTable.NS_Internal_Id__c + 'BillingMode', listTable.name);
			} else if(listTable.NS_List_Name__c == 'BillingTransaction'){
				listTableMap.put(listTable.name + 'BillingTransaction', listTable.NS_Internal_Id__c);
				listTableMap.put(listTable.NS_Internal_Id__c + 'BillingTransaction', listTable.name);
			} else if(listTable.NS_List_Name__c == 'SubscriptionStatus'){
				listTableMap.put(listTable.name + 'SubscriptionStatus', listTable.NS_Internal_Id__c);
				listTableMap.put(listTable.NS_Internal_Id__c + 'SubscriptionStatus', listTable.name);
			} else if(listTable.NS_List_Name__c == 'TerminationMethod'){
				listTableMap.put(listTable.name + 'TerminationMethod', listTable.NS_Internal_Id__c);
				listTableMap.put(listTable.NS_Internal_Id__c + 'TerminationMethod', listTable.name);
			} else if(listTable.NS_List_Name__c == 'TransactionCategory'){
				listTableMap.put(listTable.name + 'TransactionCategory', listTable.NS_Internal_Id__c);
				listTableMap.put(listTable.NS_Internal_Id__c + 'TransactionCategory', listTable.name);
			} else if(listTable.NS_List_Name__c == 'HoldBillingReason'){
				listTableMap.put(listTable.name + 'HoldBillingReason', listTable.NS_Internal_Id__c);
				listTableMap.put(listTable.NS_Internal_Id__c + 'HoldBillingReason', listTable.name);
			}
			
		}
		system.debug('ListTableMap = ' + listTableMap);
		
		for(NS_Subscriptions__c sub : newList){
			if(sub.Billing_Mode_Internal_Id__c != null && listTableMap.containsKey(sub.Billing_Mode_Internal_Id__c + 'BillingMode')){
				sub.Billing_Mode__c = listTableMap.get(sub.Billing_Mode_Internal_Id__c + 'BillingMode');
			} else {
				sub.Billing_Mode__c = null;
			}
			if(sub.Billing_Transaction_Internal_Id__c != null && listTableMap.containsKey(sub.Billing_Transaction_Internal_Id__c + 'BillingTransaction')){
				sub.Billing_Transaction__c = listTableMap.get(sub.Billing_Transaction_Internal_Id__c + 'BillingTransaction');
			} else {
				sub.Billing_Transaction__c = null;
			}
			if(sub.Status_Internal_Id__c != null && listTableMap.containsKey(sub.Status_Internal_Id__c + 'SubscriptionStatus')){
				sub.Status__c = listTableMap.get(sub.Status_Internal_Id__c + 'SubscriptionStatus');
			} else {
				sub.Status__c = null;
			}
			if(sub.Termination_Method_Internal_Id__c != null && listTableMap.containsKey(sub.Termination_Method_Internal_Id__c + 'TerminationMethod')){
				sub.Termination_Method__c = listTableMap.get(sub.Termination_Method_Internal_Id__c + 'TerminationMethod');
			} else {
				sub.Termination_Method__c = null;
			}
			if(sub.SB_Transaction_Category_Internal_Id__c != null && listTableMap.containsKey(sub.SB_Transaction_Category_Internal_Id__c + 'TransactionCategory')){
				sub.SB_Transaction_Category__c = listTableMap.get(sub.SB_Transaction_Category_Internal_Id__c + 'TransactionCategory');
			} else {
				sub.SB_Transaction_Category__c = null;
			}
			if(sub.Hold_Billing_Reason_Internal_Id__c != null && listTableMap.containsKey(sub.Hold_Billing_Reason_Internal_Id__c + 'HoldBillingReason')){
				sub.Hold_Billing_Reason__c = listTableMap.get(sub.Hold_Billing_Reason_Internal_Id__c + 'HoldBillingReason');
			} else {
				sub.Hold_Billing_Reason__c = null;
			}
		}
	}

}