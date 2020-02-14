public with sharing class ALM_Targeted_Release_View_CE 
{
	public  Case                         customerCase     {get; set;}
	public  List<TargetedReleaseWrapper> targetedReleases {get; set;}
	public  boolean                      showTRList       {get; set;}                
	public  boolean                      saveEnabled      {get; set;}
	public  boolean                      refreshParent    {get; set;}
	public  boolean                      delinkAllowed    {get; set;}
  
	public ALM_Targeted_Release_View_CE(ApexPages.StandardController sc) 
	{
  	
  		customerCase = (Case)sc.getRecord();
  		customerCase = [SELECT issue_case__c, Targeted_Release_Lookup__c, Targeted_Fix_Date__c FROM case WHERE id = :customerCase.id];
    
	    targetedReleases = new List<TargetedReleaseWrapper>();
	    saveEnabled      = false;
	    refreshParent    = false;
	    delinkAllowed 	 = false;
         
	    if (customerCase.Issue_Case__c != null) 
    	{
   	  		Boolean bDoNotAllowSelectionOnTRClosed = false;
   	  
			for (Targeted_Release__c tr :  [SELECT id, name, customer_case__c, scheduled_delivery_date__c, project_type__c, Priority__c, L3_Status__c, Resolution_Type__c, Resolution_Details__c, Delivery_Reference__c, Component__c, CSFE_Issue_Id__c, (SELECT id, caseNumber FROM cases__r ORDER BY caseNumber)  FROM targeted_release__c WHERE case__c = :customerCase.Issue_Case__c ORDER BY createdDate ]) 
			{
				TargetedReleaseWrapper trw = new TargetedReleaseWrapper(tr);
	      	
		      	if(tr.Customer_Case__c == null)
		      	{
		      		trw.selectable = true;
		      	}
		      	else if(tr.Customer_Case__c == customerCase.Id)
		      	{
		      		trw.selectable = true;
		      	}
		      	
		      	for(Case c : tr.cases__r)
		      	{
		      		//if(tr.Customer_Case__c == customerCase.Id && tr.Id == customerCase.Targeted_Release_Lookup__c)
		      		if(c.Id == customerCase.Id && tr.Id == customerCase.Targeted_Release_Lookup__c)
	      			{
			      		trw.selected = true;
			      		//trw.selectable = true;
			      		
			      		if(tr.L3_Status__c != null && tr.L3_Status__c == 'Closed')
			      		{
			      			//trw.selectable = true;
			      			delinkAllowed = true;
			      		}
			      		else if(tr.Customer_Case__c != null)
			      		{
			      			trw.selectable = false;
			      			bDoNotAllowSelectionOnTRClosed = true;
			      		}
			      	}
		      	}
      	
      			targetedReleases.add(trw);
      		}	

	  		if(targetedReleases.size() > 0)
	  		{
			  	if(bDoNotAllowSelectionOnTRClosed)
			  	{
				  	for(TargetedReleaseWrapper trw : targetedReleases)
				  	{
				  		trw.selectable = false;
				  	}
			  	}
		  	}

	      	showTRList = (targetedReleases.size() > 0);
	    } 
		else 
    	{
    		showTRList = false;
    	}
	}

	public PageReference enableSave() 
	{		
  		saveEnabled = true;
  		return null;
  	}
  
  	public PageReference doSave() 
  	{
  		ID targetedReleaseID = null;
  		Date targetedFixDate = null;
  		
  		for (TargetedReleaseWrapper trw : targetedReleases) 
  		{
  	  		if (trw.selected) 
  	  		{
  	  			targetedReleaseID = trw.tr.id;
  	  			targetedFixDate = trw.tr.scheduled_delivery_date__c;
  	  		}	
  		}
  		
  		customerCase.Targeted_Release_Lookup__c = targetedReleaseID;
  		customerCase.Targeted_Fix_Date__c = targetedFixDate;
  		
  		ApexPages.Message errMsg;
  		try{
  			update customerCase;
  		}catch(Exception e) {
  			if(e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY')){
  				errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, Label.ALM_TR_Insufficient_Access_Save_Error);
  			}else{
  				errMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
  			}
  		}
  		
  		if(errMsg != null){
  			ApexPages.addMessage(errMsg);
  		}else{
  			refreshParent = true;
  		}
  		return null;
	}

  	public PageReference doCancel() 
  	{
  		refreshParent = true;
  		return null;
  	}

}