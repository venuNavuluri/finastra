public with sharing class CapiUtils
{
	public static void UpdateProfileDetails(Profile_details__c[] profDetailsRecs)
	{
		if (profDetailsRecs == null) { return; }
		List<string> whiteSpaceKeys = new List<string>();
		for (Profile_details__c pd : profDetailsRecs) {
			whiteSpaceKeys.add(MisysStringUtils.nvl(pd.InstitutionFootprint__c).toUpperCase());
		}
		
		Map<string, string> whiteSpaceMap = getWhiteSpaceMap(whiteSpaceKeys);
			System.debug('@@@ whiteSpaceMap: ' + whiteSpaceMap);
		for (Profile_details__c pd : profDetailsRecs) {
			System.debug('@@@ key: ' + MisysStringUtils.nvl(pd.InstitutionFootprint__c).toUpperCase());
			pd.Whitespace__c = whiteSpaceMap.get(MisysStringUtils.nvl(pd.InstitutionFootprint__c).toUpperCase());
			System.debug('@@@ pd.Whitespace__c: ' + pd.Whitespace__c);
		}
		
	}
	
	private static Map<string, Id> getWhiteSpaceMap(List<string> whiteSpaceKeys)
	{
		System.debug('@@@ whiteSpaceKeys: ' + whiteSpaceKeys);
		Map<string, Id> theMap = new Map<string, string>();
		
		Profile_Whitespace__c[] wsRecords = [select Id, Name, Product__c from Profile_Whitespace__c where Name in :whiteSpaceKeys];
		System.debug('@@@ wsRecords: ' + wsRecords);
		for (Profile_Whitespace__c ws : wsRecords) {
			theMap.put(ws.Name, ws.Id);
		}
		
		
		
		
/*		
		for (Profile_Whitespace__c[] wsRecords : [select Id, Name, Product__c from Profile_Whitespace__c where Name in :whiteSpaceKeys]) {
			System.debug('@@@ wsRecords: ' + wsRecords);
			for (Profile_Whitespace__c ws : wsRecords) {
				theMap.put(ws.Name, ws.Id);
			}
		}
*/
		return theMap;
	}
}