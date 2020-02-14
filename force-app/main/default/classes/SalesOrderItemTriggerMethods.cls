public class SalesOrderItemTriggerMethods {

	public static void populateSalesOrderItem(map<id, Sales_Order_Item__c> oldMap, map<id, Sales_Order_Item__c> newMap, list<Sales_Order_Item__c> newList){
		map<string, string> listTableMap = new map<string, string>();
		for(NS_List_Table__c listTable : [select id, name, NS_Internal_Id__c, NS_List_Name__c from NS_List_Table__c where NS_List_Name__c = 'SubscriptionStatus']){
			if(listTable.NS_List_Name__c == 'SubscriptionStatus'){
				listTableMap.put(listTable.name + 'SubscriptionStatus', listTable.NS_Internal_Id__c);
				listTableMap.put(listTable.NS_Internal_Id__c + 'SubscriptionStatus', listTable.name);
			}
		}
		system.debug('ListTableMap = ' + listTableMap);

		for(Sales_Order_Item__c soItem : newList){
			if(soItem.NS_Primary_Sub_Item_Status_Internal_Id__c != null && listTableMap.containsKey(soItem.NS_Primary_Sub_Item_Status_Internal_Id__c + 'SubscriptionStatus')){
				soItem.NS_Primary_Sub_Item_Status__c = listTableMap.get(soItem.NS_Primary_Sub_Item_Status_Internal_Id__c + 'SubscriptionStatus');
			} 
		}
	}
}