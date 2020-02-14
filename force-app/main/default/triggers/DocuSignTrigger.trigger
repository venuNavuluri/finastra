/*
	Created By: Abhinit Kohar
	Created Date: 14/11/2013
	Description: This is for creating the Contract record if the Status is Completed.
*/
trigger DocuSignTrigger on dsfs__DocuSign_Status__c (before update) {
	if(trigger.isBefore){
		DocuSignTriggerMethods.createContract(trigger.newMap, trigger.oldMap);
	}
}