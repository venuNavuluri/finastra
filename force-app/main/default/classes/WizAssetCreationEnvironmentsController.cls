public class WizAssetCreationEnvironmentsController
{
	PickableEnvironment[] environments;
	public PickableEnvironment[] getEnvironments()
	{
		PickableEnvironment[] listToSort = new PickableEnvironment[]{};
		if (environments == null) {
			environments = new PickableEnvironment[]{};
			for (Environment__c env : EnvironmentUtils.GetAllEnvironments()) {
				if (env.Active__c) {
					if (env.DevName__c == 'PROD') {
						environments.add(new PickableEnvironment(env.DevName__c, env.Name, true));
					}
					else {
						listToSort.add(new PickableEnvironment(env.DevName__c, env.Name, false));
					}
				}
			}
			listToSort.sort();
			environments.addAll(listToSort);
		}
		return environments;
	}
	
	public WizAssetCreationEnvironmentsController()
	{
	}

	public string ValidateEnvironments()
	{
		for (PickableEnvironment env : getEnvironments()) {
			if (env.Selected) { return null; }
		}
		return 'You must select at least one environment!';
	}
}