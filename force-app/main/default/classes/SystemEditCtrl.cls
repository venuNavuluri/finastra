public with sharing class SystemEditCtrl
{
	Id systemId;
	
	public string PageMessage { get; set;}
	public string SystemPostfix { get; set;}
	public System__c TheSystem { get; set; }
	private MisysStringUtils.SystemName theName;

	public SystemEditCtrl(ApexPages.StandardController stdController)
	{
		systemId = stdController.getRecord().Id;
		if (systemId == null) {
			TheSystem = new System__c();
		}
		else {
			TheSystem = [
				select Id, Name, Environment2__c, Account__c
				from System__c where id = :systemId
			];
			theName = new MisysStringUtils.SystemName(TheSystem.Name);
		}
		SystemPostfix = theName.GetInstanceName();
	}

	public List<SelectOption> GetEnvironments()
	{
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption('', '--None--'));
		for (Environment__c env : [select Id, Name, DevName__c from Environment__c])
		{
			options.add(new SelectOption(env.DevName__c, env.Name));
		}
		return options;
	}
	
	public PageReference Save()
	{
		if (theName.isValid()) {
			theName.SetInstanceName(SystemPostfix);
			theName.SetEnvironment(TheSystem.Environment2__c);
			TheSystem.Name = theName.GetName();
		}
		if (TheSystem.Environment2__c == null) {
			PageMessage = 'Environment is mandatory!';
			return null;
		}
		upsert TheSystem;
		return getSystemDetailPage();
	}

	public PageReference Cancel()
	{
		return getSystemDetailPage();
	}

	public void TestSetData(string envDevName, string customName)
	{
		TheSystem.Environment2__c = envDevName;
		SystemPostfix = customName;
	}
	
	private PageReference getSystemDetailPage()
	{
		return new PageReference('/' + systemId);
	}
}