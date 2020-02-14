global class ce4sfStep_CloudExtendHookupTest implements ce4sf20_001.IAeAutomatedStepService
{
	private static ce4sf20_001.AeServiceDescription service;
	
	static
	{
		service = new ce4sf20_001.AeServiceDescription();
		service.namespaceQualifier = ce4sf20_001.AeServiceDescription.getNamespacePrefixForClass('ce4sfStep_CloudExtendHookupTest');
		service.name = 'ce4sfStep_CloudExtendHookupTest';
		service.displayName = 'CloudExtendHookupTest';
		service.description = 'Service class test for CE';

		service.addInputParameterDesc('myInput1', 'string', true);
		service.addInputParameterDesc('myInput2', 'string', true);

		service.addOutputParameterDesc('myOutput1', 'string');

	}
	
	global ce4sf20_001.AeServiceDescription describe()
	{
		return service;
	}

	global ce4sf20_001.AeServiceResponse invoke(ce4sf20_001.AeServiceRequest aRequest) 
	{
		Map<String, Object> params = aRequest.getTypedParameterMap(service.getInputParameterMap());
		for (string key : params.keySet()) {
			System.debug('@@@ key: [' + key + '] value:[' + (String)params.get(key) + ']');
		}

		ce4sf20_001.AeServiceResponse retVal = new ce4sf20_001.AeServiceResponse();
		retVal.addParameter('myOutput1', 'WOO-HOOOO! You\'ve just made a successful CloudExtend-to-SFDC service call!');
		return retVal;
	}
	
}