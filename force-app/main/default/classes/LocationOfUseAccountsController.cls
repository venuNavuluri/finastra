public with sharing class LocationOfUseAccountsController
{
	Id parentAccountId;
	
    public List<Schema.FieldSetMember> getDisplayFields()
    {
        return SObjectType.Account.FieldSets.LocationsOfUseFields.getFields();
    }
	
	public LocationOfUseAccountsController(ApexPages.StandardController stdController)
	{
		parentAccountId = stdController.getRecord().Id;
	}
	
	private Set<Id> getLouCcrtIds()
	{
		Set<Id> louCcrtIds = new Set<Id>();
		for (Location_of_Use__c lou : [
			select CCRT__c, CCRT__r.Account__c
			from Location_of_Use__c
			where Contract_Asset__r.Account__c = :parentAccountId
			and CCRT__c != null
		]) {
			louCcrtIds.add(lou.CCRT__c);
		}
		return louCcrtIds;
	}
	
	private string getIdCsvList(Set<Id> Ids)
	{
		string csv = '(';
		for (Id oneId : Ids) {
			csv += ('\'' + oneId + '\'' + ', ');
		}
		csv = csv.substring(0, csv.length() - 2);
		csv += ')';
		return csv;
	}
	
	public Account[] GetLocationOfUseAccounts()
	{
      	String query = 'SELECT ';
        for(Schema.FieldSetMember f : getDisplayFields()) {
            query += f.getFieldPath() + ', ';
        }
        Set<Id> ccrtIds = getLouCcrtIds();
        if (ccrtIds.size() == 0) { return new Account[]{}; }
        query += ('Id FROM Account WHERE CCRT_Entry__c IN ' + getIdCsvList(ccrtIds));
        System.debug('GetLocationOfUseAccounts query: ' + query);
        Account[] qResult = Database.query(query);
        System.debug('GetLocationOfUseAccounts #of results: ' + qResult.size());
        return qResult;
	}
	
}