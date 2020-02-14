public class TaskTriggerMethods {

	public static void updateCaseSurveyDate(List<Task> taskSurveyEmails)
	{
		//get the CaseIds to be updated
		Map<Id,Id> mapTaskToCase = new Map<Id,Id>();
		for(Task t1 : taskSurveyEmails)
		{
			mapTaskToCase.put(t1.Id,t1.WhatId);
		}
		
		//select the Case records to be updated
		Map<Id,Case> casesToUpdate = new Map<Id,Case>([select Id, Case_Satisfaction_Survey_Sent__c from Case where Id in :mapTaskToCase.values()]);
		
		//update the survey date field
		for(Task t2 : taskSurveyEmails)
		{
			Case c = casesToUpdate.get(mapTaskToCase.get(t2.Id));
			if(c.Case_Satisfaction_Survey_Sent__c == null || t2.ActivityDate > c.Case_Satisfaction_Survey_Sent__c)
				c.Case_Satisfaction_Survey_Sent__c  = t2.ActivityDate;
			system.debug('Case after update: '+c);
		}
		
		//commit the change
		try{
			update casesToUpdate.values();
		}catch(Exception e){
			System.debug('Error updating Cases: '+e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
			CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),'Apex Error in Case Survey Date update','TaskTriggerMethods.updateCaseSurveyDate',e);
		}
	}

}