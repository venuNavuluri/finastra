public class AddChangeRequestToParent_CE {

	public Opportunity opp;
	public boolean isValid = true;
	final String DML_EXCEPTION = 'System.DmlException';
	ApexPages.StandardController stdCtr;
	public AddChangeRequestToParent_CE(ApexPages.StandardController stdController){
		stdCtr = stdController;
		//Get the current record
		opp = [SELECT Id,
					  OLIs_Pushed_To_Parent__c,
					  IsClosed,
					  Original_Opportunity__c,
					  IsWon
					  FROM Opportunity 
					  WHERE Id =:stdController.getId() LIMIT 1];
	
	}

	public PageReference CopyOLIs()
	{
		SavePoint sp1;
		PageReference pr = new PageReference('/'+opp.Id);
		
		//Verify the requirements are met for running the copy
		if(validateCopy() == true)
		{
			//Add the Opp to a map
			map<Id,Opportunity> oppMap = new map<Id,Opportunity>();
			oppMap.put(opp.Id,opp);
			system.debug('AddChangeRequestToParent_CE.CopyOLIs - oppMap: '+oppMap);
			
			//Set a savepoint in case the update fails and the change needs to be rolled back.
			sp1 = Database.setSavepoint();
			
			try{
				//Optimistically set the flag on the CR opp to indicate it has been pushed to the Parent Opp.
				opp.OLIs_Pushed_To_Parent__c = true;
				update opp;
				//Copy all CR line items and add them to the parent
				OpportunityServices.copyChangeOrderOLIsToParentOpportunity(oppMap);
			}catch(Exception e1){
				Database.rollback(sp1);
				//Catch pricebook integrity exception if itis the only exception
				if(e1.getTypeName()== DML_EXCEPTION && StatusCode.FIELD_INTEGRITY_EXCEPTION == e1.getDmlType(0)){
					ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,Label.Price_Book_Entry_Integration_Exception));
				}else	
					ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,e1.getMessage()));
				pr = null;
			}
		}else{
			pr = null;
		}
		
		return pr;
	}

	public boolean validateCopy()
	{
		isValid = true;
		
		if(opp.Original_Opportunity__c==null){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, Label.Missing_Parent_Opportunity));
			isValid = false;
		}else{
			//Check if the parent stage is valid
			
			Opportunity parentOpp = [SELECT Id,
										    IsClosed,
										    IsWon,
										    StageName 
										    FROM 
										    Opportunity 
										    WHERE Id = :opp.Original_Opportunity__c LIMIT 1];
			system.debug('AddChangeRequestToParent_CE.ValidateCopy - parentOpp.isClosed,parentOpp.isWon: '+parentOpp.isClosed+','+parentOpp.isWon);
			if(!(parentOpp.isWon || OpportunityServices.getCRToParentValidStages().contains(parentOpp.StageName)))
			{
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, Label.CR_Opp_Parent_Not_Valid_Stage));
				isValid = false;
			}
		}
		//Check if already pushed to parent
		if(opp.OLIs_Pushed_To_Parent__c == true && isValid)
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, Label.CR_Opp_Already_Pushed_To_Parent));
			isValid = false;
		}
		system.debug('AddChangeRequestToParent_CE.ValidateCopy - opp.OLIs_Pushed_To_Parent__c: '+opp.OLIs_Pushed_To_Parent__c);
		
		//G.B 13.03.2013 add validation rule on the CR Opportunity Stage
		if(!opp.IsWon && isValid){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL, Label.CR_Opp_Not_Won));
			isValid = false;
		}
		
		return isValid;
	}
	// Return the current opportunty
	public PageReference returnToOpp(){
		return stdCtr.cancel();
	}
	
	public boolean getIsError()
	{
		return !(isValid);
	}

}