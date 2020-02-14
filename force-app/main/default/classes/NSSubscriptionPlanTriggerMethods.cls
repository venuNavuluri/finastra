public class NSSubscriptionPlanTriggerMethods {
	
	public static void updateSubscriptionPlan(map<id, NS_Subscription_Plan__c> oldMap, map<id, NS_Subscription_Plan__c> newMap, list<NS_Subscription_Plan__c> newList){
        //populate Billing Mode, Co Term, Termination Method, Billing Method and Status map for getting the internal ids
        map<string, string> listTableMap = new map<string, string>();
        for(NS_List_Table__c listTable : [select id, name, NS_Internal_Id__c, NS_List_Name__c from NS_List_Table__c where NS_List_Name__c = 'BillingMethod' 
        									or NS_List_Name__c = 'BillingMode' or NS_List_Name__c = 'CoTerm' or NS_List_Name__c = 'SubscriptionPlanStatus' 
        									or NS_List_Name__c = 'TerminationMethod']) {
        										
            if(listTable.NS_List_Name__c == 'BillingMethod') {
                listTableMap.put(listTable.name + 'BillingMethod', listTable.NS_Internal_Id__c);
                listTableMap.put(listTable.NS_Internal_Id__c + 'BillingMethod', listTable.name);
            } else if(listTable.NS_List_Name__c == 'BillingMode') {
                listTableMap.put(listTable.name + 'BillingMode', listTable.NS_Internal_Id__c);
                listTableMap.put(listTable.NS_Internal_Id__c + 'BillingMode', listTable.name);
            } else if(listTable.NS_List_Name__c == 'CoTerm') {
                listTableMap.put(listTable.name + 'CoTerm', listTable.NS_Internal_Id__c);
                listTableMap.put(listTable.NS_Internal_Id__c + 'CoTerm', listTable.name);
            } else if(listTable.NS_List_Name__c == 'SubscriptionPlanStatus') {
                listTableMap.put(listTable.name + 'SubscriptionPlanStatus', listTable.NS_Internal_Id__c);
                listTableMap.put(listTable.NS_Internal_Id__c + 'SubscriptionPlanStatus', listTable.name);
            } else if(listTable.NS_List_Name__c == 'TerminationMethod') {
                listTableMap.put(listTable.name + 'TerminationMethod', listTable.NS_Internal_Id__c);
                listTableMap.put(listTable.NS_Internal_Id__c + 'TerminationMethod', listTable.name);
            }
        }
        
        for(NS_Subscription_Plan__c subPlan : newList){
	        if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate) && subPlan.Update_From_NS__c == true) {
	        	if(subPlan.Billing_Method_Internal_Id__c != null && listTableMap.containsKey(subPlan.Billing_Method_Internal_Id__c + 'BillingMethod')){
	        		subPlan.Billing_Method__c = listTableMap.get(subPlan.Billing_Method_Internal_Id__c + 'BillingMethod');
	        	} else {
	        		subPlan.Billing_Method__c = null;
	        	}
	        	if(subPlan.Billing_Mode_Internal_Id__c != null && listTableMap.containsKey(subPlan.Billing_Mode_Internal_Id__c + 'BillingMode')){
	        		subPlan.Billing_Mode__c = listTableMap.get(subPlan.Billing_Mode_Internal_Id__c + 'BillingMode');
	        	} else {
	        		subPlan.Billing_Mode__c = null;
	        	}
	        	if(subPlan.Co_Term_Internal_Id__c != null && listTableMap.containsKey(subPlan.Co_Term_Internal_Id__c + 'CoTerm')){
	        		subPlan.Co_Term__c = listTableMap.get(subPlan.Co_Term_Internal_Id__c + 'CoTerm');
	        	} else {
	        		subPlan.Co_Term__c = null;
	        	}
	        	if(subPlan.Status_Internal_Id__c != null && listTableMap.containsKey(subPlan.Status_Internal_Id__c + 'SubscriptionPlanStatus')){
	        		subPlan.Status__c = listTableMap.get(subPlan.Status_Internal_Id__c + 'SubscriptionPlanStatus');
	        	} else {
	        		subPlan.Status__c = null;
	        	}
	        	if(subPlan.Termination_Method_Internal_Id__c != null && listTableMap.containsKey(subPlan.Termination_Method_Internal_Id__c + 'TerminationMethod')){
	        		subPlan.Termination_Method__c = listTableMap.get(subPlan.Termination_Method_Internal_Id__c + 'TerminationMethod');
	        	} else {
	        		subPlan.Termination_Method__c = null;
	        	}
	        	subPlan.Update_From_NS__c = false;
	        } else if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate) && subPlan.Update_From_NS__c == false) {
	        	if(subPlan.Billing_Method__c != null && listTableMap.containsKey(subPlan.Billing_Method__c + 'BillingMethod')){
	        		subPlan.Billing_Method_Internal_Id__c = listTableMap.get(subPlan.Billing_Method__c + 'BillingMethod');
	        	} else {
	        		subPlan.Billing_Method_Internal_Id__c = null;
	        	}
	        	if(subPlan.Billing_Mode__c != null && listTableMap.containsKey(subPlan.Billing_Mode__c + 'BillingMode')){
	        		subPlan.Billing_Mode_Internal_Id__c = listTableMap.get(subPlan.Billing_Mode__c + 'BillingMode');
	        	} else {
	        		subPlan.Billing_Mode_Internal_Id__c = null;
	        	}
	        	if(subPlan.Co_Term__c != null && listTableMap.containsKey(subPlan.Co_Term__c + 'CoTerm')){
	        		subPlan.Co_Term_Internal_Id__c = listTableMap.get(subPlan.Co_Term__c + 'CoTerm');
	        	} else {
	        		subPlan.Co_Term_Internal_Id__c = null;
	        	}
	        	if(subPlan.Status__c != null && listTableMap.containsKey(subPlan.Status__c + 'SubscriptionPlanStatus')){
	        		subPlan.Status_Internal_Id__c = listTableMap.get(subPlan.Status__c + 'SubscriptionPlanStatus');
	        	} else {
	        		subPlan.Status_Internal_Id__c = null;
	        	}
	        	if(subPlan.Termination_Method__c != null && listTableMap.containsKey(subPlan.Termination_Method__c + 'TerminationMethod')){
	        		subPlan.Termination_Method_Internal_Id__c = listTableMap.get(subPlan.Termination_Method__c + 'TerminationMethod');
	        	} else {
	        		subPlan.Termination_Method_Internal_Id__c = null;
	        	}
	        	subPlan.Update_From_NS__c = false;
	        }
	        
        }
	}

}