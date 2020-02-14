/*
	Created By: Abhinit Kohar
	Created Date: 29/10/2014
	Description: This class holds the support methods for NSSubscriptionItemTrigger trigger.
*/
public class NSSubscriptionItemTriggerMethods {

	public static void updateSubscriptionItem(map<id, NS_Subscription_Item__c> oldMap, map<id, NS_Subscription_Item__c> newMap, list<NS_Subscription_Item__c> newList){
        //populate Billing Mode, Co Term, Termination Method, Billing Method and Status map for getting the internal ids
        map<string, string> listTableMap = new map<string, string>();
        for(NS_List_Table__c listTable : [select id, name, NS_Internal_Id__c, NS_List_Name__c from NS_List_Table__c where NS_List_Name__c = 'BillingMethod' 
        									or NS_List_Name__c = 'CoTerm' or NS_List_Name__c = 'SubscriptionStatus' or NS_List_Name__c = 'TerminationMethod'
        									or NS_List_Name__c = 'VendorBillingScheduleTrigger' or NS_List_Name__c = 'RBBillingStartTrigger']) {
        										
            if(listTable.NS_List_Name__c == 'BillingMethod') {
                listTableMap.put(listTable.name + 'BillingMethod', listTable.NS_Internal_Id__c);
                listTableMap.put(listTable.NS_Internal_Id__c + 'BillingMethod', listTable.name);
            } else if(listTable.NS_List_Name__c == 'CoTerm') {
                listTableMap.put(listTable.name + 'CoTerm', listTable.NS_Internal_Id__c);
                listTableMap.put(listTable.NS_Internal_Id__c + 'CoTerm', listTable.name);
            } else if(listTable.NS_List_Name__c == 'SubscriptionStatus') {
                listTableMap.put(listTable.name + 'SubscriptionStatus', listTable.NS_Internal_Id__c);
                listTableMap.put(listTable.NS_Internal_Id__c + 'SubscriptionStatus', listTable.name);
            } else if(listTable.NS_List_Name__c == 'TerminationMethod') {
                listTableMap.put(listTable.name + 'TerminationMethod', listTable.NS_Internal_Id__c);
                listTableMap.put(listTable.NS_Internal_Id__c + 'TerminationMethod', listTable.name);
            } else if(listTable.NS_List_Name__c == 'VendorBillingScheduleTrigger') {
                listTableMap.put(listTable.name + 'VendorBillingScheduleTrigger', listTable.NS_Internal_Id__c);
                listTableMap.put(listTable.NS_Internal_Id__c + 'VendorBillingScheduleTrigger', listTable.name);
            } else if(listTable.NS_List_Name__c == 'RBBillingStartTrigger') {
                listTableMap.put(listTable.name + 'RBBillingStartTrigger', listTable.NS_Internal_Id__c);
                listTableMap.put(listTable.NS_Internal_Id__c + 'RBBillingStartTrigger', listTable.name);
            }
        }
        
        for(NS_Subscription_Item__c subItem : newList){
	        if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate) && subItem.Update_From_NS__c == true) {
	        	if(subItem.Billing_Method_Internal_Id__c != null && listTableMap.containsKey(subItem.Billing_Method_Internal_Id__c + 'BillingMethod')){
	        		subItem.Billing_Method__c = listTableMap.get(subItem.Billing_Method_Internal_Id__c + 'BillingMethod');
	        	} else {
	        		subItem.Billing_Method__c = null;
	        	}
	        	if(subItem.Co_Term_Internal_Id__c != null && listTableMap.containsKey(subItem.Co_Term_Internal_Id__c + 'CoTerm')){
	        		subItem.Co_Term__c = listTableMap.get(subItem.Co_Term_Internal_Id__c + 'CoTerm');
	        	} else {
	        		subItem.Co_Term__c = null;
	        	}
	        	if(subItem.Status_Internal_Id__c != null && listTableMap.containsKey(subItem.Status_Internal_Id__c + 'SubscriptionStatus')){
	        		subItem.Status__c = listTableMap.get(subItem.Status_Internal_Id__c + 'SubscriptionStatus');
	        	} else {
	        		subItem.Status__c = null;
	        	}
	        	if(subItem.Termination_Method_Internal_Id__c != null && listTableMap.containsKey(subItem.Termination_Method_Internal_Id__c + 'TerminationMethod')){
	        		subItem.Termination_Method__c = listTableMap.get(subItem.Termination_Method_Internal_Id__c + 'TerminationMethod');
	        	} else {
	        		subItem.Termination_Method__c = null;
	        	}
	        	if(subItem.SB_Vendor_BSch_Trigger_Internal_Id__c != null && listTableMap.containsKey(subItem.SB_Vendor_BSch_Trigger_Internal_Id__c + 'VendorBillingScheduleTrigger')){
	        		subItem.SB_Vendor_BSch_Trigger__c = listTableMap.get(subItem.SB_Vendor_BSch_Trigger_Internal_Id__c + 'VendorBillingScheduleTrigger');
	        	} else {
	        		subItem.SB_Vendor_BSch_Trigger__c = null;
	        	}
	        	if(subItem.SB_Billing_Start_Trigger_Internal_Id__c != null && listTableMap.containsKey(subItem.SB_Billing_Start_Trigger_Internal_Id__c + 'RBBillingStartTrigger')){
	        		subItem.SB_Billing_Start_Trigger__c = listTableMap.get(subItem.SB_Billing_Start_Trigger_Internal_Id__c + 'RBBillingStartTrigger');
	        	} else {
	        		subItem.SB_Billing_Start_Trigger__c = null;
	        	}
	        	subItem.Update_From_NS__c = false;
	        } else if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate) && subItem.Update_From_NS__c == false) {
	        	if(subItem.Billing_Method__c != null && listTableMap.containsKey(subItem.Billing_Method__c + 'BillingMethod')){
	        		subItem.Billing_Method_Internal_Id__c = listTableMap.get(subItem.Billing_Method__c + 'BillingMethod');
	        	} else {
	        		subItem.Billing_Method_Internal_Id__c = null;
	        	}
	        	if(subItem.Co_Term__c != null && listTableMap.containsKey(subItem.Co_Term__c + 'CoTerm')){
	        		subItem.Co_Term_Internal_Id__c = listTableMap.get(subItem.Co_Term__c + 'CoTerm');
	        	} else {
	        		subItem.Co_Term_Internal_Id__c = null;
	        	}
	        	if(subItem.Status__c != null && listTableMap.containsKey(subItem.Status__c + 'SubscriptionStatus')){
	        		subItem.Status_Internal_Id__c = listTableMap.get(subItem.Status__c + 'SubscriptionStatus');
	        	} else {
	        		subItem.Status_Internal_Id__c = null;
	        	}
	        	if(subItem.Termination_Method__c != null && listTableMap.containsKey(subItem.Termination_Method__c + 'TerminationMethod')){
	        		subItem.Termination_Method_Internal_Id__c = listTableMap.get(subItem.Termination_Method__c + 'TerminationMethod');
	        	} else {
	        		subItem.Termination_Method_Internal_Id__c = null;
	        	}
	        	if(subItem.SB_Vendor_BSch_Trigger__c != null && listTableMap.containsKey(subItem.SB_Vendor_BSch_Trigger__c + 'VendorBillingScheduleTrigger')){
	        		subItem.SB_Vendor_BSch_Trigger_Internal_Id__c = listTableMap.get(subItem.SB_Vendor_BSch_Trigger__c + 'VendorBillingScheduleTrigger');
	        	} else {
	        		subItem.SB_Vendor_BSch_Trigger_Internal_Id__c = null;
	        	}
	        	if(subItem.SB_Billing_Start_Trigger__c != null && listTableMap.containsKey(subItem.SB_Billing_Start_Trigger__c + 'RBBillingStartTrigger')){
	        		subItem.SB_Billing_Start_Trigger_Internal_Id__c = listTableMap.get(subItem.SB_Billing_Start_Trigger__c + 'RBBillingStartTrigger');
	        	} else {
	        		subItem.SB_Billing_Start_Trigger_Internal_Id__c = null;
	        	}
	        	subItem.Update_From_NS__c = false;
	        }
	        
        }
	}

}