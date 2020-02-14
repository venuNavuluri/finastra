trigger ProductSetTrigger on Product_Set__c (after delete, after insert, after update, after undelete) {
	ProductSetTriggerManager pstmgr = new ProductSetTriggerManager(trigger.oldMap, trigger.newMap);
	pstmgr.Execute();
}