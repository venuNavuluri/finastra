trigger NPSSurveyFeedbackTrigger on NPSSurveyFeedback__c (after delete, after insert, after update, after undelete) {
	if(trigger.isAfter){
		if(trigger.isInsert || trigger.isUpdate || trigger.isUndelete){
			NPSSurveyFeedbackTriggerMethods.rollupSurveyScores(trigger.new);
		}
		if(trigger.isDelete){
			NPSSurveyFeedbackTriggerMethods.rollupSurveyScores(trigger.old);
		}
	}
}