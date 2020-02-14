trigger CommunityHomePageContentTrigger on Community_Homepage_CMS__c (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update) {

	string HomepageContentId;
	boolean IsLeadContent;
	string PageToDisplay;

		if (Trigger.isBefore) {
	    	if(Trigger.isDelete) {
	    		for (Community_Homepage_CMS__c cms_content : Trigger.old) {
	    			HomepageContentId = cms_content.Id;
	    			IsLeadContent = cms_content.Is_Lead_Feature__c;   
	    			PageToDisplay = cms_content.Page_to_Display__c; 			
	    		}
	    		if(IsLeadContent) {
	    			List<Community_Homepage_CMS__c> cmsList = [SELECT Id, Is_Lead_Feature__c FROM Community_Homepage_CMS__c WHERE Id <> : HomepageContentId  AND Page_to_Display__c <> :PageToDisplay ORDER BY createdDate DESC];
	    			if(!cmsList.isEmpty()) {
	    				cmsList[0].Is_Lead_Feature__c = true;
	    				update cmsList[0];
	    			}
	    		}
	    	}
	    
		} else {
	    	//call handler.after method
	    	for(Community_Homepage_CMS__c cms_content : trigger.New) {
	    		if(cms_content.Is_Lead_Feature__c){
	    			HomepageContentId = cms_content.Id;
	    			PageToDisplay = cms_content.Page_to_Display__c;
	    			Integer n=0;
	    			try {
	    					List<Community_Homepage_CMS__c> cmsList = [SELECT Id, Is_Lead_Feature__c FROM Community_Homepage_CMS__c WHERE Id <> : HomepageContentId AND Is_Lead_Feature__c = true AND Page_to_Display__c = :PageToDisplay];
	    					if(!cmsList.isEmpty()) {
	    						cmsList[0].Is_Lead_Feature__c = false;
	    						update cmsList[0];
	    			}
	    				} catch (DMLException e) {

	    				}
	    		}
	    	}
		}
}