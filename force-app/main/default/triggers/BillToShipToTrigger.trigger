trigger BillToShipToTrigger on Bill_To_Ship_To__c (after update, after insert, before delete) {
	
	if(trigger.isAfter && trigger.isUpdate){
		BillToShipToTriggerMethods.updateNSCustomerAddress(trigger.newMap, trigger.oldMap);
	}
	if(trigger.isAfter && trigger.isInsert){
		BillToShipToTriggerMethods.createNSCustomerAddress(trigger.newMap);
	}
	if(trigger.isBefore && trigger.isDelete){
		BillToShipToTriggerMethods.delteNSCustomerAddress(trigger.oldMap);
	}
	
}