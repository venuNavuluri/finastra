trigger SalesOrderItemTrigger on Sales_Order_Item__c (before update) {
	SalesOrderItemTriggerMethods.populateSalesOrderItem(trigger.oldMap, trigger.newMap, trigger.new);
}