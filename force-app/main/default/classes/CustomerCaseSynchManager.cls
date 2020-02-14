public with sharing class CustomerCaseSynchManager
{
	public static string NOT_A_DEFECT_FIX_TYPE = 'NOT A DEFECT';
	public static string ENHANCEMENT_FIX_TYPE = 'ENHANCEMENT';
	public static string SUPPORT_REQ_CASE_CAT = 'Support Request';
	public static string ENHANCEMENT_CASE_CAT = 'Enhancement Request';
	public static string ENGINEERING_LM_RECORD_TYPE = '01220000000UaPeAAK';
	public static string ENGINEERING_TURAZ_RECORD_TYPE = '01220000000UYSjAAO';
	
	Map<Id, Case> newMap;
	Map<Id, Case> oldMap;
	
	public CustomerCaseSynchManager(Map<Id, Case> pNewMap, Map<Id, Case> pOldMap)
	{
		newMap = pNewMap;
		oldMap = pOldMap;
	}
	
	public void Execute()
	{
		List<Id> involvedParentIds = updateParents();
		updateChildren(involvedParentIds);
	}
	
	private List<Id> updateParents()
	{
		List<Id> involvedParentIds = new List<Id>();
		// build a map from the new changed EngineeringCases to map to the children
		for (Case oneParent : newMap.values()) {
			Case oldParent = oldMap.get(oneParent.Id);
			// only need it, if engineering case and the Resolution_Type__c field changed to 'Not a defect' or 'Enhancement'
			if ((
					oneParent.RecordTypeId == ENGINEERING_LM_RECORD_TYPE ||
					oneParent.RecordTypeId == ENGINEERING_TURAZ_RECORD_TYPE
				) && // engineering record type
				oneParent.Resolution_Type__c != null &&
				oneParent.Resolution_Type__c != oldParent.Resolution_Type__c
			) {
				if (oneParent.Resolution_Type__c.toUpperCase() == NOT_A_DEFECT_FIX_TYPE) {
					// change the parent's case category
					oneParent.Case_Category__c = SUPPORT_REQ_CASE_CAT;
					involvedParentIds.add(oneParent.Id);
				}
				else if (oneParent.Resolution_Type__c.toUpperCase() == ENHANCEMENT_FIX_TYPE) {
					oneParent.Case_Category__c = ENHANCEMENT_CASE_CAT;
					involvedParentIds.add(oneParent.Id);
				}
			}
		}
		return involvedParentIds;
	}
	
	private void updateChildren(List<Id> parentIds)
	{
		Map<Id, Case[]> involvedChildrenMap = new Map<Id, Case[]>();
		if (parentIds.size() == 0) { return; }
		Case[] children = [select Id, Case_Category__c, ParentId from Case where ParentId in :parentIds];
		for (Case oneChild : children) {
			oneChild.Case_Category__c = newMap.get(oneChild.ParentId).Case_Category__c;
		}
		update children;
	}

}