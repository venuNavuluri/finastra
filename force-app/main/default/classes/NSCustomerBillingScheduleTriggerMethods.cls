public class NSCustomerBillingScheduleTriggerMethods {
	
	public static void updateSyncFlag(map<id, NS_Customer_Billing_Schedule__c> oldMap, map<id, NS_Customer_Billing_Schedule__c> newMap, list<NS_Customer_Billing_Schedule__c> newList){
		if(trigger.isBefore && trigger.isUpdate){
			for(NS_Customer_Billing_Schedule__c cbs : newList){
				if((oldMap.get(cbs.Id).Project__c != newMap.get(cbs.Id).Project__c) 
					|| (oldMap.get(cbs.Id).Name != newMap.get(cbs.Id).Name)
					|| (oldMap.get(cbs.Id).Line_Milestone__c != newMap.get(cbs.Id).Line_Milestone__c)
					|| (oldMap.get(cbs.Id).Initial_Amount__c != newMap.get(cbs.Id).Initial_Amount__c) 
					|| (oldMap.get(cbs.Id).Initial_Payment_Terms__c != newMap.get(cbs.Id).Initial_Payment_Terms__c)
					|| (oldMap.get(cbs.Id).Line_Amount__c != newMap.get(cbs.Id).Line_Amount__c) 
					|| (oldMap.get(cbs.Id).Line_Comment__c != newMap.get(cbs.Id).Line_Comment__c)
					|| (oldMap.get(cbs.Id).Line_Drop_Dead_Date__c != newMap.get(cbs.Id).Line_Drop_Dead_Date__c) 
					|| (oldMap.get(cbs.Id).Line_Estimated_Completion_Date__c != newMap.get(cbs.Id).Line_Estimated_Completion_Date__c)
					|| (oldMap.get(cbs.Id).Line_Milestone_Sequence__c != newMap.get(cbs.Id).Line_Milestone_Sequence__c)
					|| (oldMap.get(cbs.Id).Line_Payment_Terms__c != newMap.get(cbs.Id).Line_Payment_Terms__c)
					|| (oldMap.get(cbs.Id).Public__c != newMap.get(cbs.Id).Public__c) 
					|| (oldMap.get(cbs.Id).Sales_Order__c != newMap.get(cbs.Id).Sales_Order__c)){
						
					cbs.Synced_To_NS__c = false;
				}
			}
		}
	}
}