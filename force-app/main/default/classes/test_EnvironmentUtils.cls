@isTest
public class test_EnvironmentUtils
{
	public static testMethod void doTest()
	{
		Environment__c env = new Environment__c(Name='Production', DevName__c = 'PROD', Active__c = true);
		insert env;
		
		string devName = EnvironmentUtils.GetEnvironmentDevName(env.Id);
		string envId = EnvironmentUtils.GetEnvironmentId('Production');
		string envIdByDevName = EnvironmentUtils.GetEnvironmentIdByDevName('PROD');
	}
}