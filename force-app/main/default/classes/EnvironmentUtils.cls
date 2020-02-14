public class EnvironmentUtils
{
	public static final string ProductionEnvName = 'PROD';
	public static final string DREnvName = 'DR';
	public static final string HotStandbyEnvName = 'HOT';
	public static final string ColdStandbyEnvName = 'COLD';
	public static final string TestEnvName = 'TEST';
	
	public static final string DisplayProductionEnvName = 'Production';
	public static final string DisplayDREnvName = 'Disaster Recovery';
	public static final string DisplayHotStandbyEnvName = 'Hot Standby';
	public static final string DisplayColdStandbyEnvName = 'Cold Standby';
	public static final string DisplayTestEnvName = 'Test';
	
	private static Map<Id, string> envIdToDevNameMap;
	private static Map<Id, string> getEnvIdToDevNameMap() {
		if (envIdToDevNameMap == null) { Init();	}
		return envIdToDevNameMap;
	}
	private static Map<string, Id> envNameToIdMap;
	private static Map<string, Id> getEnvNameToIdMap() {
		if (envNameToIdMap == null) { Init(); }
		return envNameToIdMap;
	}
	private static Map<string, Id> envDevNameToIdMap;
	private static Map<string, Id> getEnvDevNameToIdMap() {
		if (envDevNameToIdMap == null) { Init(); }
		return envDevNameToIdMap;
	}
	private static Environment__c[] allEnvironments;
	public static Environment__c[] GetAllEnvironments()
	{
		if (allEnvironments == null) { Init();}
		return allEnvironments;
	}
	
	private static void Init()
	{
		envIdToDevNameMap = new Map<Id, string>();
		envNameToIdMap = new Map<string, Id>();
		envDevNameToIdMap = new Map<string, Id>();
		allEnvironments = [select Id, Name, DevName__c, Active__c from Environment__c];
		for (Environment__c env : allEnvironments) {
			envIdToDevNameMap.put(env.Id, env.DevName__c);
			envNameToIdMap.put(env.Name, env.Id);
			envDevNameToIdMap.put(env.DevName__c, env.Id);
		}
	}
	
	public static String GetEnvironmentDevName(Id envId)
	{
		return getEnvIdToDevNameMap().get(envId);
	}
	
	public static Id GetEnvironmentId(string envName)
	{
		return getEnvNameToIdMap().get(envName);
	}
	
	public static Id GetEnvironmentIdByDevName(string envDevName)
	{
		return getEnvDevNameToIdMap().get(envDevName);
	}
	
	/*
	public static String getEnvShortName(String env)
	{
		String shortName = '';
		
		if (env == DisplayProductionEnvName) { return ProductionEnvName; }
		if (env == DisplayDREnvName) { return DREnvName; }
		if (env == DisplayHotStandbyEnvName) { return HotStandbyEnvName; }
		if (env == DisplayColdStandbyEnvName) { return ColdStandbyEnvName; }
		if (env == DisplayTestEnvName) { return TestEnvName; }
		return null;
	}
	*/

}