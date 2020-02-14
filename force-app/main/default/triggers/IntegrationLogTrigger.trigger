trigger IntegrationLogTrigger on Integration_Log__c (after insert, before insert) {

	if(Trigger.isInsert && Trigger.isBefore){
		IntegrationLog.ProcessIntegrations(Trigger.new);
	}
		

}