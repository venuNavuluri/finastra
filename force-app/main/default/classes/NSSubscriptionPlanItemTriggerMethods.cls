public class NSSubscriptionPlanItemTriggerMethods {
	
	public static void updateSubscriptionPlanItem(map<id, NS_Subscription_Plan_Item__c> oldMap, map<id, NS_Subscription_Plan_Item__c> newMap, list<NS_Subscription_Plan_Item__c> newList){
        //populate Billing Mode, Co Term, Termination Method, Billing Method and Status map for getting the internal ids
        map<string, string> listTableMap = new map<string, string>();
        for(NS_List_Table__c listTable : [select id, name, NS_Internal_Id__c, NS_List_Name__c from NS_List_Table__c where NS_List_Name__c = 'BillingMethod' 
        									or NS_List_Name__c = 'Unit']) {
        										
            if(listTable.NS_List_Name__c == 'BillingMethod') {
                listTableMap.put(listTable.name + 'BillingMethod', listTable.NS_Internal_Id__c);
                listTableMap.put(listTable.NS_Internal_Id__c + 'BillingMethod', listTable.name);
            } else if(listTable.NS_List_Name__c == 'Unit') {
                listTableMap.put(listTable.name + 'Unit', listTable.NS_Internal_Id__c);
                listTableMap.put(listTable.NS_Internal_Id__c + 'Unit', listTable.name);
            }
        }
        
        for(NS_Subscription_Plan_Item__c subPlanItem : newList){
	        if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate) && subPlanItem.Update_From_NS__c == true) {
	        	if(subPlanItem.NS_Billing_Method_Internal_Id__c != null && listTableMap.containsKey(subPlanItem.NS_Billing_Method_Internal_Id__c + 'BillingMethod')){
	        		subPlanItem.Billing_Method__c = listTableMap.get(subPlanItem.NS_Billing_Method_Internal_Id__c + 'BillingMethod');
	        	} else {
	        		subPlanItem.Billing_Method__c = null;
	        	}
	        	if(subPlanItem.NS_Unit_Internal_Id__c != null && listTableMap.containsKey(subPlanItem.NS_Unit_Internal_Id__c + 'Unit')){
	        		subPlanItem.Unit__c = listTableMap.get(subPlanItem.NS_Unit_Internal_Id__c + 'Unit');
	        	} else {
	        		subPlanItem.Unit__c = null;
	        	}
	        	subPlanItem.Update_From_NS__c = false;
	        } else if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate) && subPlanItem.Update_From_NS__c == false) {
	        	if(subPlanItem.Billing_Method__c != null && listTableMap.containsKey(subPlanItem.Billing_Method__c + 'BillingMethod')){
	        		subPlanItem.NS_Billing_Method_Internal_Id__c = listTableMap.get(subPlanItem.Billing_Method__c + 'BillingMethod');
	        	} else {
	        		subPlanItem.NS_Billing_Method_Internal_Id__c = null;
	        	}
	        	if(subPlanItem.Unit__c != null && listTableMap.containsKey(subPlanItem.Unit__c + 'Unit')){
	        		subPlanItem.NS_Unit_Internal_Id__c = listTableMap.get(subPlanItem.Unit__c + 'Unit');
	        	} else {
	        		subPlanItem.NS_Unit_Internal_Id__c = null;
	        	}
	        	subPlanItem.Update_From_NS__c = false;
	        }
	        
        }
	}

}