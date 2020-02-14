trigger ProjectInformationTrigger on Project_Information__c (before delete) {

	if(Trigger.IsBefore){
		if(Trigger.IsDelete){

			//Prevent the NONE option record from being deleted
			for(Project_Information__c p : trigger.old){
				if(p.Id == Label.Project_Information_NONE_Id || (Test.IsRunningTest() == true && p.Name == 'PRJNONE')){
					p.addError(Label.Project_Information_NONE_error);
				}
			}			
		}
	}
}