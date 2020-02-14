public abstract class RUMContractAssetBase extends RollUpManager
{
	public RUMContractAssetBase(List<Contract_Asset__c> triggerList, Map<Id, Contract_Asset__c> oldMap)
	{
		List<RollUpChild> theChildren = new List<RollUpChild>();
		Map<Id, RollUpChild> theOldMap = new Map<Id, RollUpChild>();
		for (Contract_Asset__c ca : triggerList) {
			theChildren.add(createRollUpChild(ca));
			if (oldMap != null) { theOldMap.put(ca.Id, createRollUpChild(oldMap.get(ca.Id))); }
		}
		SetParentIds(theChildren, theOldMap);	
	}
	

}