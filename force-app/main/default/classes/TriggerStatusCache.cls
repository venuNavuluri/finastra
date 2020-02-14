public class TriggerStatusCache
{
	private static Map<string, boolean> theCache;
	
	public static boolean GetStatus(string triggerName)
	{
		if (triggerName == null) {
			throw new CommonFunctions.CustomException('Trigger name can not be null!');
		}
		if (theCache == null) {
			theCache = new Map<string , boolean>();
			for (TriggerStatus__c rec : TriggerStatus__c.getAll().values()) {
				theCache.put(rec.Trigger_Name__c.toUpperCase(), rec.Status__c);
			}
		}
		return theCache.get(triggerName.toUpperCase());
	}
	
}