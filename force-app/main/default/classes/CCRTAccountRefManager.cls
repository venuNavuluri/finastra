public class CCRTAccountRefManager
{
	private Map<Id, CCRT__c> oldMap;
	private CCRT__c[] triggerNew, triggerOld;
	
	public CCRTAccountRefManager(CCRT__c[] pTriggerNew, CCRT__c[] pTriggerOld, Map<Id, CCRT__c> pOldMap)
	{
		triggerNew = pTriggerNew;
		triggerOld = pTriggerOld;
		oldMap = pOldMap;
	}
	
	public void Execute()
	{
		if (trigger.IsUpdate) {
			doUpdate();
		}
		else if (trigger.IsInsert || trigger.IsUndelete) {
			doInsert();
		}
		else if (trigger.IsDelete) {
			doDelete();
		}
	}
	
	private void doUpdate()
	{
		Set<Id> newAcctIds = new Set<Id>();
		Set<Id> oldAcctIds = new Set<Id>();
		for (CCRT__c ccrt : triggerNew) {
			Id oldAcctId = oldMap.get(ccrt.Id).Account__c;
			if (ccrt.Account__c != null) {
				newAcctIds.add(ccrt.Account__c);
			}
			if (oldAcctId != null) {
				oldAcctIds.add(oldAcctId);
			}
		}
		Map<Id, Account> newAccountMap = new Map<Id, Account>([select Id, CCRT_Entry__c from Account where id in :newAcctIds]); 
		Map<Id, Account> oldAccountMap = new Map<Id, Account>([select Id, CCRT_Entry__c from Account where id in :oldAcctIds]);
		for (CCRT__c oldCcrt : oldMap.values()) { // clear out the old account to CCRT references
			if (oldCcrt.Account__c != null) {
				oldAccountMap.get(oldCcrt.Account__c).CCRT_Entry__c = null;
			}
		}
		for (CCRT__c newCcrt : triggerNew) { // set the new account to CCRT references
			if (newCcrt.Account__c != null) {
				newAccountMap.get(newCcrt.Account__c).CCRT_Entry__c = newCcrt.Id;
			}
		}
		update oldAccountMap.values();
		update newAccountMap.values();
	}
	
	private void doInsert()
	{
		Set<Id> newAcctIds = new Set<Id>();
		for (CCRT__c ccrt : triggerNew) {
			if (ccrt.Account__c != null) {
				newAcctIds.add(ccrt.Account__c);
			}
		}
		Map<Id, Account> newAccountMap = new Map<Id, Account>([select Id, CCRT_Entry__c from Account where id in :newAcctIds]); 
		for (CCRT__c ccrt : triggerNew) {
			if (ccrt.Account__c != null) {
				newAccountMap.get(ccrt.Account__c).CCRT_Entry__c = ccrt.Id;
			}
		}
		update newAccountMap.values();
	}
	
	private void doDelete()
	{
		Set<Id> oldAcctIds = new Set<Id>();
		for (CCRT__c ccrt : triggerOld) {
			if (ccrt.Account__c != null) {
				oldAcctIds.add(ccrt.Account__c);
			}
		}
		Map<Id, Account> oldAccountMap = new Map<Id, Account>([select Id, CCRT_Entry__c from Account where id in :oldAcctIds]); 
		for (CCRT__c ccrt : triggerOld) {
			if (ccrt.Account__c != null) {
				oldAccountMap.get(ccrt.Account__c).CCRT_Entry__c = null;
			}
		}
		update oldAccountMap.values();
	}
	
}