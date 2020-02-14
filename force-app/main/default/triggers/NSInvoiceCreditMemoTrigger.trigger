trigger NSInvoiceCreditMemoTrigger on NS_Invoice_Credit_Memo__c (before insert, before update) {
	NSInvoiceCreditMemoTriggerMethods.populateNSInvoiceCreditMemo(trigger.oldMap, trigger.newMap, trigger.new);
}