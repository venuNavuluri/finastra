public class ALM_System_Parameters {
	
	// Exception class - to be thrown if there are config errors
	public class ConfigException extends Exception {}
	
	// The current system (production, sandbox etc)
	private static String CURRENT_SYSTEM;
	
	// Set of needed parameters
	private static Map<String,String> PARAMETERS;
	
	// Initialise once only (hence static)
	static {
		
		// Read in the system name - will only be 1 but do as a list to prevent a crash
		// if config is not correct - in which case throw an exception
		List<System_Parameter__c> sysNames = [Select Value__c From System_Parameter__c Where Name = 'CURRENT_SYSTEM' Limit 1];
		if (sysNames.size() != 1) {
			throw new ConfigException(Label.NO_SYS_NAME);
		}
		CURRENT_SYSTEM = sysNames[0].value__c;
		
		// Pull in all parameters for this system or All systems !  Shift them into the static list of parameters
		List<System_Parameter__c> params = [Select Name, Value__c From System_Parameter__c Where Applicable_Server__c in ('All',:CURRENT_SYSTEM)];
		PARAMETERS = new Map<String,String>();
		for (System_Parameter__c param : params) {
			PARAMETERS.put(param.Name, param.Value__c);
		} // end loop through parameters
	} // end of static block
	
	// Return the requested parameter
	public static String getParam(String pName) {
		return PARAMETERS.get(pName);
	} // end getParam
} // end of class