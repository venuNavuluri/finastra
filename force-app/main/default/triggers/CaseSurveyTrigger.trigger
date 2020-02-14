trigger CaseSurveyTrigger on Case_Survey__c (after insert) 
{
	CaseSurveyServices.markSurveyReceivedOnContactOnCase(Trigger.newMap);
}