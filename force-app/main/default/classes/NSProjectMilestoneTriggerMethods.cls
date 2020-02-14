/*
	Created By: Abhinit Kohar
	Created Date: 14/03/2014
	Description: This class holds the support methods for NSProjectmilestoneTrigger trigger.
*/
public class NSProjectMilestoneTriggerMethods {
	//This method unchecks the Synced to NS falg if any of the field values got updated.
	public static void checkForUpdates(map<Id, NS_Project_Milestone__c> newMap, map<Id, NS_Project_Milestone__c> oldMap){
		if(trigger.isUpdate && trigger.isBefore){
			for(NS_Project_Milestone__c projMilestone : newMap.values()){
				if(newMap.get(projMilestone.Id).End_Date__c != oldMap.get(projMilestone.Id).End_Date__c || 
					newMap.get(projMilestone.Id).Finish_No_Later_Than_Date__c != oldMap.get(projMilestone.Id).Finish_No_Later_Than_Date__c ||
					newMap.get(projMilestone.Id).Milestone__c != oldMap.get(projMilestone.Id).Milestone__c ||
					newMap.get(projMilestone.Id).NS_Project__c != oldMap.get(projMilestone.Id).NS_Project__c ||
					newMap.get(projMilestone.Id).Start_Date__c != oldMap.get(projMilestone.Id).Start_Date__c ||
					newMap.get(projMilestone.Id).Constraint_Type__c != oldMap.get(projMilestone.Id).Constraint_Type__c ||
					newMap.get(projMilestone.Id).Status__c != oldMap.get(projMilestone.Id).Status__c){
						
					projMilestone.Synced_To_NS__c = false;
				}
			}
		}
	}

}