public class OpportunityServices 
{

    //Pull out CR To Parent Valid Stage custom setting
    public static Set<String> getCRToParentValidStages(){
    	Set<String> validStages = new Set<String>();
    	for(CR_To_Parent_Valid_Stage__c vStage : [SELECT Stage_Name__c FROM CR_To_Parent_Valid_Stage__c]){
    		if(vStage.Stage_Name__c !=null)
    			validStages.add(vStage.Stage_Name__c);
    	}
    	return validStages;
    }
    
    public static void copyChangeOrderOLIsToParentOpportunity(map<Id,Opportunity> mapOpps)
    {
    	if(mapOpps.size() > 0)
    	{
    		List<OpportunityLineItem> clonedOLIs = new List<OpportunityLineItem>();
    		SavePoint sp2;
    		
	    	//Get the OLIs for the Opps into a list
	    	list<OpportunityLineItem> allOLIsToClone = [select Id, 
	    													   PricebookEntryId,
	    													   OpportunityId,
	    													   Quantity,
	    													   TotalPrice,
	    													   Original_OLI_Id__c,
	    													   CR_Line_Item_Added_To_Parent__c 
	    													   from OpportunityLineItem 
	    													   where PricebookEntry.Product2.Type__c = :Label.OpenAir_PS_Product_Filter 
	    													   and OpportunityId in :mapOpps.keySet()];
	    	
	    	sp2 = Database.setSavepoint();
	    	
	    	if(allOLIsToClone.size() > 0)
	    	{
	    		for(OpportunityLineItem oli1 : allOLIsToClone){
	    			//Optimistically, update the OLIs before they are cloned
	    			oli1.Original_OLI_Id__c = oli1.Id;
	    			oli1.Original_Opp_Id__c = oli1.OpportunityId;
	    			oli1.CR_Line_Item_Added_To_Parent__c = true;
	    			//Set new OLIs
	    			OpportunityLineItem parentOLI = OpportunityServices.cloneFromCROLItems(oli1);
	    			if(mapOpps.get(oli1.OpportunityId).Original_Opportunity__c!=null){
	    				parentOLI.OpportunityId = mapOpps.get(oli1.OpportunityId).Original_Opportunity__c;
	    				clonedOLIs.add(parentOLI);	
	    			} 
	    		}
	    		update allOLIsToClone;
	    		//G.B 13.03.2013 Remove this as it is firing issues, too many fields requested
	    		//clonedOLIs = CloningServices.cloneRecordsInBulk(allOLIsToClone, false);
	    		if(!clonedOLIs.isEmpty())
	    			insert clonedOLIs;
	    	}
	    	system.debug('OpportunityServices.copyChangeOrderOLIsToParentOpportunity - clonedOLIs: '+clonedOLIs);
	    	
	    	/*if(clonedOLIs != null && clonedOLIs.size() > 0)
	    	{
	    		for(OpportunityLineItem oli2 : clonedOLIs){
	    			oli2.OpportunityId = mapOpps.get(oli2.OpportunityId).Original_Opportunity__c;
	    			oli2.Added_By_Change_Order__c = true;
	    			oli2.CR_Total_Amount__c = oli2.TotalPrice;
	    			oli2.TotalPrice = null;
	    			oli2.UnitPrice = 0;
	    		}
	    		insert clonedOLIs;
	    	}else{
	    		Database.rollback(sp2);
	    	}*/
    	}
    }
    // Clone an opportunity line item from 
    private static OpportunityLineItem cloneFromCROLItems(OpportunityLineItem crOLI){
    	OpportunityLineItem parentOLI = crOLI.clone(false);
	    parentOLI.CR_Total_Amount__c = crOLI.TotalPrice;
	    parentOLI.Quantity = crOLI.Quantity;
	    parentOLI.PricebookEntryId = crOLI.PricebookEntryId;
	    parentOLI.Added_By_Change_Order__c = true;
	    //parentOLI.TotalPrice = null;
	    parentOLI.TotalPrice = 0;
	    parentOLI.CR_Line_Item_Added_To_Parent__c= false;
	    return  parentOLI; 
    }
    
    public static void getChangeOrderOLIsForDelete(map<Id,Opportunity> mapClosedOpps){
    	
    	
    	//For the ones with OLIs pushed to the parent, get the OLI records to send for deletion	
    	List<OpportunityLineItem> listOLIs = [select Id, CR_Line_Item_Added_To_Parent__c, OpportunityId, Opportunity.Order_Number__c from OpportunityLineItem where OpportunityId in :mapClosedOpps.keySet()];
    
    	system.debug('OpportunityServices.getChangeOrderOLIsForDelete - listOLIs: '+listOLIs);
    	
    	Boolean isSuccess = deleteChangeOrderOLIsOnParentOpportunity(listOLIs);
    	system.debug('@@@@isSuccess'+isSuccess);
    	//If successful, send a notice to PS Operations
    	if(isSuccess)
    	{
    		
			//Notify PS
			//List<String> toAddr = new String[]{Label.CR_Opps_EmailNoticeAddress};
			List<String> toAddr = new String[]{Label.CR_Opps_EmailNoticeAddress};
			String mailSubj = Label.CR_Opp_EmailNoticeSubject;
			String processName = Label.CR_Opp_EmailNoticeProcessName;
			String action = Label.CR_Opp_EmailNoticeNextAction;
    		sendCRTOParentEmailNotice(toAddr,mailSubj,processName,mapClosedOpps.values());
    		/*for(Opportunity lostOpp : mapClosedOpps.values())
    		{
    			//Notify PS Ops of the Closed/Lost Opp(s).
    			List<String> toAddr = new String[]{Label.CR_Opps_EmailNoticeAddress};
				String mailSubj = Label.CR_Opp_EmailNoticeSubject;
				String processName = Label.CR_Opp_EmailNoticeProcessName;
				String action = Label.CR_Opp_EmailNoticeNextAction;
				String recId = lostOpp.Id;
				
				//Customize the action string
				action = action.replace('**OppNumber**',lostOpp.Order_Number__c);
				system.debug('OpportunityServices.getChangeOrderOLIsForDelete - Mail Action: '+action);
				CommonFunctions.sendEmailNoticeBasic(toAddr, mailSubj, processName, action, recId);
		    					
    		}*/
    	}
    		
    }
    
    public static boolean deleteChangeOrderOLIsOnParentOpportunity(list<OpportunityLineItem> lOppLineItems)
    {
    	Boolean deleteSuccess = false;
    	Database.DeleteResult[] delResult;
    	map<Id,list<Database.Error>> mapOLItoError = new map<Id,list<Database.Error>>();
    	set<Id> sDeleteFailed_Opps = new set<Id>();
    	map<Id,OpportunityLineItem> mapOLIs = new map<Id,OpportunityLineItem>(); 
    	
    	if(lOppLineItems.size() > 0){
    		
    		set<Id> setOLI_Ids = new set<Id>();
    		
    		//Loop through the OLIs and pull out the ones that have been pushed to the Parent opp.  The others can be ignored since nothing needs to happen for them.
    		for(OpportunityLineItem o1 : lOppLineItems){
    			if(o1.CR_Line_Item_Added_To_Parent__c == true){
    				setOLI_Ids.add(o1.Id);
    			}
    			mapOLIs.put(o1.Id,o1);
    		}
    		system.debug('OpportunityServices.deleteChangeOrderOLIsOnParentOpportunty - setOLI_Ids: '+setOLI_Ids);
    		system.debug('OpportunityServices.deleteChangeOrderOLIsOnParentOpportunty - mapOLIs: '+mapOLIs);
    		
    		Map<Id,OpportunityLineItem> mapOLIsToDelete;
    		list<OpportunityLineItem> lOLIsToDelete = new list<OpportunityLineItem>();
    		
    		//If any OLIs were found, the cooresponding line item needs to selected from the Parent Opp for deletion
    		if(setOLI_Ids.size() > 0){
    			mapOLIsToDelete = new map<Id,OpportunityLineItem>([select Id,
    																	  Original_OLI_Id__c,
    																	  OpportunityId,
    																	  Opportunity.Order_Number__c
    																	  from OpportunityLineItem where Added_By_Change_Order__c = true and Original_OLI_Id__c in :setOLI_Ids]);
    			lOLIsToDelete.addAll(mapOLIsToDelete.values());														  
    		}
    		
    		system.debug('OpportunityServices.deleteChangeOrderOLIsOnParentOpportunty - mapOLIsToDelete: '+mapOLIsToDelete);
    		system.debug('OpportunityServices.deleteChangeOrderOLIsOnParentOpportunty - lOLIsToDelete: '+lOLIsToDelete);
    		
    		if(lOLIsToDelete.size() > 0){
				//use Database.Delete here with the allOrNone option = false, so that if one fails, the others can still be deleted
    			delResult = Database.delete(lOLIsToDelete,false);
    			
    			//Check if any deletes were not successful
    			integer c = 0;
    			for(Database.DeleteResult dr : delResult){
    				//If not successful, get the OLI Id and associated errors
    				if(dr.isSuccess() == false){
    					mapOLItoError.put(lOLIsToDelete.get(c).Id,dr.getErrors());
    				}
    				c++;
    			}
    			system.debug('OpportunityServices.deleteChangeOrderOLIsOnParentOpportunty - mapOLItoError: '+mapOLItoError);
    			
    			map<Id,String> mapOppIdToOppNumber = new map<Id,String>();
    			map<Id,String> mapOppIdToErrorMsg = new map<Id,String>();
		    	if(mapOLItoError.keySet().size() > 0){
					//Errors were found...need to get a list of the Opportunities for which it failed and return those.
						
					//Get the set of unique opportunities affected by the failed deletion
					for(Id iDel : mapOLItoError.keySet()){
						Id oID = mapOLIsToDelete.get(iDel).OpportunityId;
						sDeleteFailed_Opps.add(oID);
						mapOppIdToOppNumber.put(oID,mapOLIsToDelete.get(iDel).Opportunity.Order_Number__c);
						string errorList = String.join(mapOLIToError.get(iDel),';');
						mapOppIdToErrorMsg.put(oID,errorList);
					}
					system.debug('OpportunityServices.deleteChangeOrderOLIsOnParentOpportunty - sDeleteFailed_Opps: '+sDeleteFailed_Opps);
		    	}else{
		    		deleteSuccess = true;
		    	}
	    		
		    	if(sDeleteFailed_Opps.size() > 0){
		    		List<CommonFunctions.CustomException> exceptionsList = new List<CommonFunctions.CustomException>();
		    		//Notify PS OPs of the error in deletion - they will need to follow up with sales ops
					//List<String> toAddr = new String[]{Label.CR_Opps_EmailNoticeAddress};
					List<String> toAddr = new String[]{Label.CR_Opps_EmailNoticeAddress};
					String mailSubj = Label.CR_Opp_ErrorMailSubject;
					String methodName = 'OpportunityServices.deleteChangeOrderOLIsOnParentOpportunity';
		    		for(Id df : sDeleteFailed_Opps)
						exceptionsList.add(new CommonFunctions.CustomException(mapOppIdToErrorMsg.get(df)));
		    		if(!exceptionsList.isEmpty())
		    			sendMassErrorsEmailFriendly(toAddr, mailSubj, methodName,exceptionsList);
		    	}
    		}
    	}
    	return deleteSuccess;
    }
    
    
    public static void sendCRTOParentEmailNotice(List<String> toAddresses, String mailSubject, String processName, List<Opportunity> crOppsList)
	{
		//Use format below to populate the list of toAddresses
		//List<String> toAddr = Label.Apex_Error_Emails.split(';');
		
		//Verify there is available email capacity for the current Apex transaction to ensure that we won't exceed our daily email limits when sending this email
		Boolean bNoEmail = false;
		try{
			Messaging.reserveSingleEmailCapacity(1);
		}catch(Exception e1){
			System.debug('In sendEmailErrorNotice, Error='+e1.getTypeName() + ' - ' + e1.getCause() + ': ' + e1.getMessage());
			bNoEmail = true;
		}

		if(!bNoEmail && crOppsList!=null && !crOppsList.isEmpty())
		{
			String sfdcUrl = URL.getSalesforceBaseUrl().toExternalForm();
			system.debug('JRB:  sendEmailNoticeBasic function');
			system.debug('JRB:  toAddresses = '+toAddresses);
			system.debug('JRB:  mailSubject = '+mailSubject);
			system.debug('JRB:  processName = '+processName);
			system.debug('JRB:  RecordId = '+crOppsList);

	     	//Create the email to send
	     	List<Messaging.SingleEmailMessage> mailToSend = new List<Messaging.SingleEmailMessage>();
	     	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	     	mail.setToAddresses(toAddresses);
	     	mail.setSubject(mailSubject);
	     	String sHTML = '';
	     	sHTML += 'Process Name: '+processName;
	     	sHTML += '<br /><br />'; 
	     	for(Opportunity opp:crOppsList){
		     	sHTML += '<a href=/'+sfdcUrl+'/'+opp.Id+'>'+opp.Name+'</a>';
		     	sHTML += '<br />';
	     	}
	     	sHTML += '<br />';
	     	sHTML += 'Sent by an automated process in Apex class OpportunityServices.sendCRTOParentEmailNotice()';
	     	mail.setHtmlBody(sHTML);
	     	mailToSend.add(mail);
	     	
	     	//Send the email
		 	try{
        		Messaging.sendEmail(mailToSend,false);
        	}catch(Exception e2){
        		system.debug('Error sending email: '+e2.getTypeName() + ' - ' + e2.getCause() + ': ' + e2.getMessage());
        	}			
		}		
	}
    
    //G.B 14.03.2013 extend sendErrorEmailFriendly methods
	public static void sendMassErrorsEmailFriendly(List<String> toAddresses, String mailSubject, String methodName, List<Exception> excpList){
		//Use format below to populate the list of toAddresses
		
		//Verify there is available email capacity for the current Apex transaction to ensure that we won't exceed our daily email limits when sending this email
		Boolean bNoEmail = false;
		try{
			Messaging.reserveSingleEmailCapacity(1);
		}catch(Exception e1){
			System.debug('In sendEmailErrorNotice, Error='+e1.getTypeName() + ' - ' + e1.getCause() + ': ' + e1.getMessage());
			bNoEmail = true;
		}

		if(excpList!=null && !bNoEmail && !excpList.isEmpty())
		{
			system.debug('JRB:  sendErrorEmailFriendly function');
			system.debug('JRB:  toAddresses = '+toAddresses);
			system.debug('JRB:  mailSubject = '+mailSubject);
			system.debug('JRB:  methodName = '+methodName);

	     	//Create the email to send
	     	List<Messaging.SingleEmailMessage> mailToSend = new List<Messaging.SingleEmailMessage>();
	     	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	     	mail.setToAddresses(toAddresses);
	     	mail.setSubject(mailSubject);
	     	String sHTML = '';
	     	sHTML += 'Technical Details:<br />';
	     	sHTML += 'Errors have occurred in <b>'+methodName+'</b>.  See details below.'; 
	     	//with record Id <b>'+recordId+'</b>
	     	sHTML += '<br /><br />';
	     	for(Exception excp :excpList){
		     	sHTML += excp.getTypeName() + ' - ' + excp.getCause() + ': ' + excp.getMessage();
		     	sHTML += '<br />';
	     	}
	     	sHTML += '<br />';
	     	sHTML += 'Sent by an automated process in Apex class OpportunityServices.sendMassErrorsEmailFriendly()';
	     	mail.setHtmlBody(sHTML);
	     	mailToSend.add(mail);
	     	
	     	//Send the email
		 	try{
        		Messaging.sendEmail(mailToSend,false);
        	}catch(Exception e2){
        		system.debug('Error sending email: '+e2.getTypeName() + ' - ' + e2.getCause() + ': ' + e2.getMessage());
        	}			
		}		
		
	}
	
    
    public static void createProjectFromOpportunity(Map<ID, Opportunity> newMap, Map<ID, Opportunity> oldMap)
    {
    	List<Opportunity> validOpptysForProjectCreation = new List<Opportunity>();
    	for(Opportunity oppty: newMap.values())
    	{
    		if(oppty.Pushed_to_OpenAir__c == true && oldMap.get(oppty.id).Pushed_To_OpenAir__c != true && oppty.SF_Project_Already_Created__c != true)
    		{
    			oppty.SF_Project_Already_Created__c = true;
    			validOpptysForProjectCreation.add(oppty);
    		}
    	}
    	
    	List<Project__c> projectsToInsert = new List<Project__c>();
    	for(Opportunity oppty: validOpptysForProjectCreation)
    	{
    		Project__c prj = new Project__c();
    		prj.Account__c = oppty.AccountId;
    		prj.Opportunity__c = oppty.id;
    		prj.Name = oppty.Name;
    		prj.Active_Project__c = true;
    		projectsToInsert.add(prj);
    	}
    	
    	//insert the new project
    	if(projectsToInsert.size() > 0)
    		insert projectsToInsert;
    }
    
    
    /* Code from Turaz Org written originally by BlueWolf */
    
    /* JRB Code not yet active
    
    //standard recordType map properties
    public static final String sObjectApiName = 'Opportunity';
    public static Map<String, RecordType> recordTypesNameMap
    {
        get
        {
            if(recordTypesNameMap == null)
            {
                recordTypesNameMap = GenericServices.getRecordTypesNameMapBySObject(sObjectApiName);
            }
            return recordTypesNameMap;
        }
        
        private set;
    }
    
    //this boolean heps to ensure the update to opportunity from the trigger doesnt reinitiate it. 
    public static Boolean isOpportunityTriggerRunning
    {
        get
        {
            if(isOpportunityTriggerRunning == null)
                isOpportunityTriggerRunning = false;
            
            return isOpportunityTriggerRunning;
        }
        private set;
    }
    
    
    public static void copyChangeOrderOLIsToParentOpportunity(Map<ID, Opportunity> newMap, Map<ID, Opportunity> oldMap)
    {
        if(!isOpportunityTriggerRunning)
        {
            Map<ID, Opportunity> opptyMap = new Map<ID, Opportunity>();
            for(Opportunity oppty: newMap.values())
            {
                if(oppty.Original_Opportunity__c != null &&
                   //oppty.Order_Type__c == Constants.ORDER_TYPE_CHANGE_ORDER &&
                   oppty.RecordTypeID == recordTypesNameMap.get(Constants.OPPORTUNITY_RECORD_TYPE_CHANGE_ORDER).id && 
                   oppty.Finance_Review__c == Constants.FINANCE_REVIEW_APPROVED &&
                   oldMap.get(oppty.id).Finance_Review__c != Constants.FINANCE_REVIEW_APPROVED
                   )
                {
                    opptyMap.put(oppty.id, oppty);
                }
            }
            
            if(opptyMap.size() > 0)
            {
                isOpportunityTriggerRunning = true;
                List<OpportunityLineItem> allOLIsToClone = [Select Id, OpportunityID 
                                                            from OpportunityLineItem 
                                                            where OpportunityID in: opptyMap.keySet()];
                
                List<OpportunityLineItem> clonedOLIs = CloningServices.cloneRecordsInBulk(allOLIsToClone, false);
                
                if(clonedOLIs != null && clonedOLIs.size() > 0)
                {
                    for(OpportunityLineItem oli: clonedOLIs)
                    {
                        Opportunity originalParent = opptyMap.get(oli.OpportunityID);
                        oli.OpportunityID = originalParent.Original_Opportunity__c;
                        oli.Added_By_Change_Order__c = true;
                        oli.TotalPrice = null;
                    }
                    
                    insert clonedOLIs;
                }
            }
        }
    }
    JRB */
        
    
    
    /* JRB Code not yet active
    
    //holds the mapping from account to its corresponding entitlement that will be chosen from account for the new asset
    private static Map<Id, Entitlement> mapActToEntitlement = new Map<ID, Entitlement>();
    private static Map<ID, System__c> mapOLIToSystem = new Map<ID, System__c>();
    private static Boolean hasErrors = false;
    
    private static Map<ID, System__c> mapQuoteGroupToSystem = new Map<ID, System__c>();
    private static Map<ID, Additional_Environment__c> mapQuoteGroupToAE = new Map<ID, Additional_Environment__c>();
    
    //trigger entrance.     
    public static void createUpdateAssets(Map<ID, Opportunity> newMap, Map<ID, Opportunity> oldMap)
    {
    	//the trigger should only run on a single opportunity in response to a finance approved flag update
    	//opptys will/should never be finance approved in bulk. 
    	if(newMap.size() > 1)
    		return;
    	
        if(!isOpportunityTriggerRunning)
        {
            isOpportunityTriggerRunning = true;
            Map<ID, OpportunityLineItem> qualifiedOLIsMap = validateAssetCreation(newMap, oldMap);
            if(!hasErrors)
            {
            	if(qualifiedOLIsMap != null && qualifiedOLIsMap.size() > 0)
            	{
            		createUpdateAssets(qualifiedOLIsMap);
            	}
            }
        }
        
    }
   
    private static Map<ID, Opportunity> incomingNewMap;
    private static Set<ID> erroneousOpptys = new Set<ID>();
    public static void throwErrorMessageFromOLI(OpportunityLineItem oli, String errorMsg)
    {
    	if(oli == null || erroneousOpptys.contains(oli.OpportunityID))
    		return ;
    	
    	hasErrors = true;
    	if(!GenericServices.isNullOrEmpty(errorMsg))
    	{
	    	for(Opportunity oppty: incomingNewMap.values())
	    	{
	    		if(oli.OpportunityID == oppty.id)
	    		{
	    			oppty.addError(errorMsg);
	    		}
	    	}
    	}
    }
    
       
    //returns a list of valid OLIs that need to be processed for asset creation
    private static Map<ID, OpportunityLineItem> validateAssetCreation(Map<ID, Opportunity> newMap, Map<ID, Opportunity> oldMap)
    {
    	incomingNewMap = newMap;
    	
        Set<ID> qualifiedOpptyIDs = new Set<ID>();
        Map<ID, OpportunityLineItem> olisMap = new Map<ID, OpportunityLineItem>();
        Map<ID, OpportunityLineItem> oliMapToReturn = new Map<ID, OpportunityLineItem>();
        
        
        for(Opportunity oppty: newMap.values())
        {
            if(   (  oppty.Finance_Review__c == Constants.FINANCE_REVIEW_APPROVED )
               &&
                   (
                       oldMap.get(oppty.id).Finance_Review__c != Constants.FINANCE_REVIEW_APPROVED
                   )
               &&
                   (
                       oppty.RecordTypeID != OpportunityServices.recordTypesNameMap.get(Constants.OPPORTUNITY_RECORD_TYPE_CHANGE_ORDER).id
                   )
              )
            {
                if(oppty.Contract__c == null)
                {
                    oppty.addError('Opportunity doesnt have an associated Contract');
                    continue;
                }
                qualifiedOpptyIDs.add(oppty.id);
                
            }
        }
        
        if(qualifiedOpptyIDs.size() > 0)
        {
            for(OpportunityLineItem oli: [Select Id, OpportunityId, License_Metric__c, Rental__c, Access_Type__c,
                                        Quantity, Annual_Maintenance__c, Billing_Frequency__c, Enhancement__c,
                                        Rental_Amount__c, Scope__c, License_Metric_Quantity__c,
                                        Enhancement_Notes__c, Version__c, Opportunity.AccountID,
                                        Opportunity.Account.Name, Opportunity.Entitlement__r.Status__c,
                                        Opportunity.Deal_Term_In_Months__c,
                                        Opportunity.CloseDate, Opportunity.Go_Live_Date__c,
                                        Opportunity.Finance_Approved_Date__c,
                                        Opportunity.Finance_Review__c, Opportunity.Contract__c,
                                        Opportunity.FA_First_Pass_Complete__c, 
                                        PriceBookEntry.Product2ID, PriceBookEntry.Product2.Name, 
                                        PriceBookEntry.Product2.Asset_Name__c, PriceBookEntry.Product2.Asset_Created_For_Product__c,
                                        PriceBookEntry.Product2.Family, Asset__c,Opportunity.Order_Type__c,
                                        Quote_Group__c, Quote_Group__r.System__c, Quote_Group__r.Name, 
                                        Quote_Group__r.Administrators__c, Quote_Group__r.RecordTypeID, 
                                        Quote_Group__r.Authorized_Locations__c, 
                                        //Quote_Group__r.Type__c,
                                        Quote_Group__r.System_Type__c,
                                        Quote_Group__r.Authorized_Locations_Notes__c,
                                        Quote_Group__r.Infrastructure_Server_Required__c,
                                        Quote_Group__r.Off_Trading_Floor_Users__c, Quote_Group__r.Trade_Web_Access_Worksheet_Builder__c,
                                        Quote_Group__r.Additional_Environment__c, 
                                        Quote_Group__r.Concurrent_Users__c, Quote_Group__r.CPU_Users__c, Quote_Group__r.Custom_Instances__c,
                                        Quote_Group__r.Trade_Users__c, Quote_Group__r.Additional_Environment_Type__c,
                                        Quote_Group__r.System__r.Administrators__c, 
                                        Quote_Group__r.System__r.Authorized_Locations__c, 
                                        Quote_Group__r.System__r.Authorized_Locations_Notes__c,
                                        Quote_Group__r.System__r.Concurrent_Users__c, 
                                        Quote_Group__r.System__r.Infrastructure_Server_Required__c,
                                        Quote_Group__r.System__r.Off_Trading_Floor_Users__c, 
                                        Quote_Group__r.System__r.Type__c,
                                        Quote_Group__r.System__r.Trade_Web_Access_Worksheet_Builder__c, 
                                        Quote_Group__r.System__r.Of_CPUs__c,
                                        Quote_Group__r.System__r.Custom_Instances__c, 
                                        Quote_Group__r.System__r.Trader_Users__c,
                                        //Quote_Group__r.Additional_Environment__r.Administrators__c, 
                                        //Quote_Group__r.Additional_Environment__r.Name,
                                        //Quote_Group__r.Additional_Environment__r.Authorized_Locations__c,
                                        //Quote_Group__r.Additional_Environment__r.Authorized_Locations_Notes__c,
                                        //Quote_Group__r.Additional_Environment__r.Infrastructure_Server_Required__c,
                                        //Quote_Group__r.Additional_Environment__r.Off_Trading_Floor_Users__c,
                                        //Quote_Group__r.Additional_Environment__r.Concurrent_Users__c,
                                        //Quote_Group__r.Additional_Environment__r.CPU_Users__c,
                                        //Quote_Group__r.Additional_Environment__r.Custom_Instances__c,
                                        //Quote_Group__r.Additional_Environment__r.Trader_Users__c,	        			
                                        Term_Begin_Date__c, Term_End_Date__c,
                                        Asset__r.Maintenance_Status__c, Asset__r.Annual_Maintenance__c, 
                                        Asset__r.Previous_Annual_Maintenance__c, Asset__r.Term_Begin_Date__c, 
                                        Asset__r.Term_End_Date__c, Asset__r.Billing_Frequency__c, Asset__r.Name,
                                        Asset__r.Renewal_Notes__c, Asset__r.System__c, Asset__r.Quantity__c
                                        //Attribute__c, Attribute__r.Maintenance_Status__c, Attribute__r.Annual_Maintenance__c, 
                                        //Attribute__r.Previous_Annual_Maintenance__c, Attribute__r.Term_Begin_Date__c, 
                                        //Attribute__r.Term_End_Date__c, Attribute__r.Billing_Frequency__c, 
                                        //Attribute__r.Additional_Environment__c, Attribute__r.Quantity__c
                                        from OpportunityLineItem 
                                        where OpportunityID in: qualifiedOpptyIDs
                                        and PriceBookEntry.Product2.Asset_Created_For_Product__c =: true
                                        and 
                                        (	
                                        	Opportunity.Order_Type__c =: Constants.ORDER_TYPE_NEW_PRODUCT
                                        	OR
                                        	Opportunity.Order_Type__c in: GenericServices.validAssetUpdateOpptyOrderTypes
                                        )
                                        
                                        //(
                                        //	//if the order type is add-on, renewal or upgrade, all OLis should go through the finance approevd process
                                        //	Opportunity.Order_Type__c in: GenericServices.validAssetUpdateOpptyOrderTypes
                                        //	or
                                        //	(
                                        //		//if the order type is new Product...
                                        //		//only the OLIs under Primary quote group should go through the FA process in first Pass
                                        //		//only the OLIs under Additional quote group should go through the FA process in second Pass
                                        //		Opportunity.Order_Type__c =: Constants.ORDER_TYPE_NEW_PRODUCT
                                        //		and
                                        //		(
                                        //			(Opportunity.FA_First_Pass_Complete__c !=: true and Quote_Group__r.RecordTypeID =: QuoteGroupServices.recordTypesNameMap.get(Constants.QUOTE_GROUP_RECORD_TYPE_PRIMARY).id)
                                        //			or
                                        //			(Opportunity.FA_First_Pass_Complete__c =: true and Quote_Group__r.RecordTypeID =: QuoteGroupServices.recordTypesNameMap.get(Constants.QUOTE_GROUP_RECORD_TYPE_ADDITIONAL).id)
                                        //		)
                                        //	)
                                        //)
                                        
                                     ])
            {
                olisMap.put(oli.id, oli);
            }
            
            Map<ID, String> mapOliToEntitlementID = getOLIsToActiveEntitlementMap(olisMap);
            
            for(OpportunityLineItem oli: olisMap.values())
            {
            	if(oli.Asset__c == null) //populate entitlement and System only if creating a new asset
                {
                	if(oli.Quote_Group__c == null)
	                {
	                	throwErrorMessageFromOLI(oli, 'Quote Group is required on all Opportunity Products for Asset/System creation');
	                	continue;
	                }
                	
                	//if(oli.Quote_Group__r.RecordTypeID ==  QuoteGroupServices.recordTypesNameMap.get(Constants.QUOTE_GROUP_RECORD_TYPE_ADDITIONAL).id)
                	//{
                	//	if(oli.Asset__c == null)
                	//	{
                	//		throwErrorMessageFromOLI(oli, 'For a Quote Group Of Record Type \'Additional Environment\', an Asset lookup is required on the Opportunity Line Items (Product)');
                	//		continue;
                	//	}
                	//	
                	//	if(oli.Quote_Group__r.System__c == null)
                	//	{
                	//		throwErrorMessageFromOLI(oli, 'No System lookup exists on Quote Group of Record Type Additional Environment');
                	//		continue;
                	//	}
                	//}
                	
                    String entID = mapOLIToEntitlementID.get(oli.id);
                    if( entID == null) //null entID signifies that entitlement doesnt exist on account
                    {
                        mapActToEntitlement.put(oli.Opportunity.AccountID, createEntitlement(oli));
                        oliMapToReturn.put(oli.id, oli);
                        continue;
                    }
                    if(entID == '') //empty string entID signifies that either account has many active ents and none is chosen on oppty
                                    //or an inactive entitlement is chosen on oppty
                    {
                        if(oli.Opportunity.Entitlement__c == null)
                            newMap.get(oli.OpportunityID).addError('Account has multiple active entitlements. Please select an appropriate entitlement on Opportunity');
                        else
                            newMap.get(oli.OpportunityID).addError('An inactive entitlement is chosen on Opportunity. Please select an appropriate entitlement on Opportunity');
                        
                        hasErrors = true;
                        continue;
                    }
                    oli.Opportunity.Entitlement__c = entID;
                }
                                
                
                oliMapToReturn.put(oli.id, oli);
            }
            
            if(!hasErrors)
            {
		        if(mapActToEntitlement.size() > 0)
		            insert mapActToEntitlement.values();
		        
		        mapOLIToSystem = getOLIsToSystemMap(olisMap);
            }
        }
        
        return oliMapToReturn;
    }
    
    ///returns the map from Olis to its corresponding active Entitlements
    private static Map<ID, String> getOLIsToActiveEntitlementMap(Map<ID, OpportunityLineItem> olisMap)
    {
        Map<ID, String> mapOliToEntitlementID = new Map<ID, String>();
        Set<ID> accountIDs = new Set<ID>();
        for(OpportunityLineItem oli: olisMap.values())
            accountIDs.add(oli.Opportunity.AccountID);
        
        Map<ID, Entitlement> mapAccountToEntitlement = new Map<Id, Entitlement>();
        for(Account a: [ Select Id, (Select ID, Status, AccountID from Entitlements where Status__c =: 'Active') 
                            from Account where id in: accountIDs])
        {
            if(a.getSObjects('Entitlements') != null && a.getSObjects('Entitlements').size() > 0)
            {
                if(a.getSObjects('Entitlements').size() == 1)
                    mapAccountToEntitlement.put(a.id, (Entitlement)a.getSObjects('Entitlements')[0]);
                else
                    mapAccountToEntitlement.put(a.id, new Entitlement());
            }
            else
                mapAccountToEntitlement.put(a.id, null);
        }
        
        for(OpportunityLineItem oli: olisMap.values())
        {
            String entIDFromOppty = 
                    (oli.Opportunity.Entitlement__c == null || oli.Opportunity.Entitlement__r.Status__c != 'Active')?
                    null:oli.Opportunity.Entitlement__c;
            Entitlement entFromAccount = mapAccountToEntitlement.get(oli.Opportunity.AccountID);
            
            if(entFromAccount != null)
            {
                if(String.valueOf(entFromAccount.id) != null)
                {
                    mapOLIToEntitlementID.put(oli.id, entFromAccount.id); //exactly 1 active ents exist on account
                }
                else
                {
                    if(entIDFromOppty != null)
                        mapOliToEntitlementID.put(oli.id, entIDFromOppty); //more than 1 active ents on Account but 1 active one is chosen on oppty
                    else
                        mapOliToEntitlementID.put(oli.id, ''); //more than 1 active ents on Account but none selected on oppty
                }
            }
            else
               mapOLIToEntitlementID.put(oli.id, null); //no active ents exist on account
        }
        
        return mapOliToEntitlementID;
    }
    
    private static Map<ID, System__c> getOLIsToSystemMap(Map<ID, OpportunityLineItem> olisMap)
    {
    	Map<ID, System__c> olisToSystemMap = new Map<ID, System__c>();
    	List<System__c> systemsToUpsert = new List<System__c>();
    	List<Additional_Environment__c> sandboxAEsToUpsert = new List<Additional_Environment__c>();
       	for(OpportunityLineItem oli : olisMap.values())
        {
        	if(oli.Quote_Group__c != null)
            {
            	
            	//if(oli.Quote_Group__r.RecordTypeID == QuoteGroupServices.recordTypesNameMap.get(Constants.QUOTE_GROUP_RECORD_TYPE_PRIMARY).id)
            	{
            		if(oli.Quote_Group__r.System__c != null)
	            	{
	            		
	            		//update System
	            		System__c sys = oli.Quote_Group__r.System__r;
	            		olisToSystemMap.put(oli.id,  sys);
	            		
	            		//if(!mapQuoteGroupToSystem.containsKey(oli.Quote_Group__c))
	            		//{
		            	//	if(oli.Opportunity.Order_Type__c == Constants.ORDER_TYPE_ADD_ON)
		            	//	{
		            	//		if(sys.Administrators__c == null) sys.Administrators__c = 0;
		            	//		if(oli.Quote_Group__r.Administrators__c == null) oli.Quote_Group__r.Administrators__c = 0;
		            	//		sys.Administrators__c += oli.Quote_Group__r.Administrators__c;
		            	//		
		            	//		if(sys.Concurrent_Users__c == null) sys.Concurrent_Users__c = 0;
		            	//		if(oli.Quote_Group__r.Concurrent_Users__c == null) oli.Quote_Group__r.Concurrent_Users__c = 0;
		            	//		sys.Concurrent_Users__c += oli.Quote_Group__r.Concurrent_Users__c;
		            	//		
		            	//		if(sys.Off_Trading_Floor_Users__c == null) sys.Off_Trading_Floor_Users__c = 0;
		            	//		if(oli.Quote_Group__r.Off_Trading_Floor_Users__c == null) oli.Quote_Group__r.Off_Trading_Floor_Users__c = 0;
		            	//		sys.Off_Trading_Floor_Users__c += oli.Quote_Group__r.Off_Trading_Floor_Users__c;
		            	//		
		            	//		if(sys.Trade_Web_Access_Worksheet_Builder__c == null) sys.Trade_Web_Access_Worksheet_Builder__c = 0;
		            	//		if(oli.Quote_Group__r.Trade_Web_Access_Worksheet_Builder__c == null) oli.Quote_Group__r.Trade_Web_Access_Worksheet_Builder__c = 0;
		            	//		sys.Trade_Web_Access_Worksheet_Builder__c += oli.Quote_Group__r.Trade_Web_Access_Worksheet_Builder__c;
		            	//		
		            	//		if(sys.Of_CPUs__c == null) sys.of_CPUs__c = 0;
		            	//		if(oli.Quote_Group__r.CPU_Users__c == null) oli.Quote_Group__r.CPU_Users__c = 0;
		            	//		sys.Of_CPUs__c += oli.Quote_Group__r.CPU_Users__c;
		            	//		
		            	//		if(sys.Custom_Instances__c == null) sys.Custom_Instances__c = 0;
		            	//		if( oli.Quote_Group__r.Custom_Instances__c == null)  oli.Quote_Group__r.Custom_Instances__c = 0;
		            	//		sys.Custom_Instances__c += oli.Quote_Group__r.Custom_Instances__c;
		            	//		
		            	//		if(sys.Trader_Users__c == null) sys.Trader_Users__c = 0;
		            	//		if(oli.Quote_Group__r.Trade_Users__c == null) oli.Quote_Group__r.Trade_Users__c = 0;
		            	//		sys.Trader_Users__c += oli.Quote_Group__r.Trade_Users__c;
		            	//	}
		            	//	else
		            	//	{
			            //		sys.Administrators__c = oli.Quote_Group__r.Administrators__c;
			            //		sys.Concurrent_Users__c = oli.Quote_Group__r.Concurrent_Users__c;
			            //		sys.Infrastructure_Server_Required__c = oli.Quote_Group__r.Infrastructure_Server_Required__c;
					    //      sys.Off_Trading_Floor_Users__c = oli.Quote_Group__r.Off_Trading_Floor_Users__c;
					    //      sys.Trade_Web_Access_Worksheet_Builder__c = oli.Quote_Group__r.Trade_Web_Access_Worksheet_Builder__c;
			            //		sys.Of_CPUs__c = oli.Quote_Group__r.CPU_Users__c;
			            //		sys.Custom_Instances__c = oli.Quote_Group__r.Custom_Instances__c;
			            //		sys.Trader_Users__c = oli.Quote_Group__r.Trade_Users__c;
		            	//	}	
	            		//	
	            		//	mapQuoteGroupToSystem.put(oli.Quote_Group__c, sys);
		            	//	
		            	//	systemsToUpsert.add(sys);
		            	//	
	            		//}
	            		
	            		mapQuoteGroupToSystem.put(oli.Quote_Group__c, sys);
	            	}
	            	else
	            	{
	            		if(mapQuoteGroupToSystem.containsKey(oli.Quote_Group__c))
	            		{
	            			System__c sys = mapQuoteGroupToSystem.get(oli.Quote_Group__c);
	            			olisToSystemMap.put(oli.id, sys);
	            		}
	            		else
	            		{
	            			//create system
		            		System__c sys = new System__c();
		            		sys.Account__c = oli.Opportunity.AccountID;
		            		sys.Type__c = oli.Quote_Group__r.System_Type__c;
		            		sys.Name = oli.Opportunity.Account.Name + ' - System - '+oli.Quote_Group__r.System_Type__c;
		            		sys.Name = sys.Name.subString(0, Math.min(79, sys.Name.length()));
			                sys.Administrators__c = oli.Quote_Group__r.Administrators__c;
			                sys.Authorized_Locations__c = oli.Quote_Group__r.Authorized_Locations__c;
			                sys.Authorized_Locations_Notes__c = oli.Quote_Group__r.Authorized_Locations_Notes__c;
			                sys.Infrastructure_Server_Required__c = oli.Quote_Group__r.Infrastructure_Server_Required__c;
			                sys.Off_Trading_Floor_Users__c = oli.Quote_Group__r.Off_Trading_Floor_Users__c;
			                sys.Trade_Web_Access_Worksheet_Builder__c = oli.Quote_Group__r.Trade_Web_Access_Worksheet_Builder__c;
			                sys.Concurrent_Users__c = oli.Quote_Group__r.Concurrent_Users__c;
	            			sys.Of_CPUs__c = oli.Quote_Group__r.CPU_Users__c;
	            			sys.Custom_Instances__c = oli.Quote_Group__r.Custom_Instances__c;
	            			
	            			
			                if(mapActToEntitlement.containsKey(oli.Opportunity.AccountID))
			                    sys.Entitlement__c = mapActToEntitlement.get(oli.Opportunity.AccountID).id;
			                else
			                    sys.Entitlement__c = oli.Opportunity.Entitlement__c;
			                    
			                systemsToUpsert.add(sys);
			                
			                olisToSystemMap.put(oli.id, sys);
			                
			                mapQuoteGroupToSystem.put(oli.Quote_Group__c, sys);
	            		}
	            	}
            	}
            	//Additional Environments, Quote group with the Add Env RT and Attribute records are all going away
            	
            	//else if(oli.Quote_Group__r.RecordTypeID == QuoteGroupServices.recordTypesNameMap.get(Constants.QUOTE_GROUP_RECORD_TYPE_ADDITIONAL).id)
            	//{
            	//	if(oli.Quote_Group__r.System__c != null)
            	//	{
            	//		if(oli.Quote_Group__r.Additional_Environment__c != null)
            	//		{
            	//			System.debug('\n\nverified the additional env exists\n\n');
            	//			//update Additional Env
            	//			if(!mapQuoteGroupToAE.containsKey(oli.Quote_Group__c))
		        //    		{
		        //    			
		        //    			Additional_Environment__c sandboxAE = oli.Quote_Group__r.Additional_Environment__r;
			    //        		if(oli.Opportunity.Order_Type__c == Constants.ORDER_TYPE_ADD_ON)
			    //        		{
			    //        			System.debug('\n\ninside the update block\n\n');
			    //        			if(sandboxAE.Administrators__c == null) sandboxAE.Administrators__c = 0;
				//        			if(oli.Quote_Group__r.Administrators__c == null) oli.Quote_Group__r.Administrators__c = 0;
				//        			sandboxAE.Administrators__c += oli.Quote_Group__r.Administrators__c;
				//        			
				//        			if(sandboxAE.Off_Trading_Floor_Users__c == null) sandboxAE.Off_Trading_Floor_Users__c = 0;
				//        			if(oli.Quote_Group__r.Off_Trading_Floor_Users__c == null) oli.Quote_Group__r.Off_Trading_Floor_Users__c = 0;
				//        			sandboxAE.Off_Trading_Floor_Users__c += oli.Quote_Group__r.Off_Trading_Floor_Users__c;
				//        			
				//        			if(sandboxAE.Concurrent_Users__c == null) sandboxAE.Concurrent_Users__c = 0;
				//        			if(oli.Quote_Group__r.Concurrent_Users__c == null) oli.Quote_Group__r.Concurrent_Users__c = 0;
				//        			sandboxAE.Concurrent_Users__c += oli.Quote_Group__r.Concurrent_Users__c;
				//        			
				//        			if(sandboxAE.CPU_Users__c == null) sandboxAE.CPU_Users__c = 0;
				//        			if(oli.Quote_Group__r.CPU_Users__c == null) oli.Quote_Group__r.CPU_Users__c = 0;
				//        			sandboxAE.CPU_Users__c += oli.Quote_Group__r.CPU_Users__c;
				//        			
				//        			if(sandboxAE.Custom_Instances__c == null) sandboxAE.Custom_Instances__c = 0;
				//        			if(oli.Quote_Group__r.Custom_Instances__c == null) oli.Quote_Group__r.Custom_Instances__c = 0;
				//        			sandboxAE.Custom_Instances__c += oli.Quote_Group__r.Custom_Instances__c;
				//        			
				//        			if(sandboxAE.Trader_Users__c == null) sandboxAE.Trader_Users__c = 0;
				//        			if(oli.Quote_Group__r.Trade_Users__c == null) oli.Quote_Group__r.Trade_Users__c = 0;
				//        			sandboxAE.Trader_Users__c += oli.Quote_Group__r.Trade_Users__c;
				//        			
				//        			sandboxAEsToUpsert.add(sandboxAE);
				//        			
			    //        		}
			    //        		else
			    //        		{
			    //        			sandboxAE.Administrators__c = oli.Quote_Group__r.Administrators__c;
				//	                sandboxAE.Infrastructure_Server_Required__c = oli.Quote_Group__r.Infrastructure_Server_Required__c;
				//	                sandboxAE.Off_Trading_Floor_Users__c = oli.Quote_Group__r.Off_Trading_Floor_Users__c;
				//	                sandboxAE.Concurrent_Users__c = oli.Quote_Group__r.Concurrent_Users__c;
				//	       			sandboxAE.CPU_Users__c = oli.Quote_Group__r.CPU_Users__c;
				//        			sandboxAE.Custom_Instances__c = oli.Quote_Group__r.Custom_Instances__c;
				//        			sandboxAE.Trader_Users__c = oli.Quote_Group__r.Trade_Users__c;
				//        			
				//        			sandboxAEsToUpsert.add(sandboxAE);
			    //        		}
			    //        		mapQuoteGroupToAE.put(oli.Quote_Group__c, sandboxAE);
		        //    		}
		        //    		
            	//		}
            	//		else
            	//		{
            	//			if(mapQuoteGroupToAE.containsKey(oli.Quote_Group__c))
		        //    		{
		        //    			Additional_Environment__c ae = mapQuoteGroupToAE.get(oli.Quote_Group__c);
		        //    			System__c sys = new System__c(id = ae.System__c);
		        //    			olisToSystemMap.put(oli.id, sys);
		        //    		}
		        //    		else
		        //    		{
	            //				//create Additional environment
	            //				Additional_Environment__c sandboxAE = new Additional_Environment__c();
				//       			sandboxAE.Account__c = oli.Opportunity.AccountID;
				//				sandboxAE.System__c = oli.Quote_Group__r.System__c;
				//				sandboxAE.Name = oli.Opportunity.Account.Name + ' - ' +oli.Quote_Group__r.Additional_Environment_Type__c +' - Additional Environment';
		        //    			sandboxAE.Name = sandboxAE.Name.subString(0, Math.min(79, sandboxAE.Name.length()));
				//				sandboxAE.Type__c = oli.Quote_Group__r.Additional_Environment_Type__c;
				//	            sandboxAE.Administrators__c = oli.Quote_Group__r.Administrators__c;
				//	            sandboxAE.Authorized_Locations__c = oli.Quote_Group__r.Authorized_Locations__c;
				//	            sandboxAE.Authorized_Locations_Notes__c = oli.Quote_Group__r.Authorized_Locations_Notes__c;
				//	            sandboxAE.Infrastructure_Server_Required__c = oli.Quote_Group__r.Infrastructure_Server_Required__c;
				//	            sandboxAE.Off_Trading_Floor_Users__c = oli.Quote_Group__r.Off_Trading_Floor_Users__c;
				//	            sandboxAE.Concurrent_Users__c = oli.Quote_Group__r.Concurrent_Users__c;
				//				sandboxAE.CPU_Users__c = oli.Quote_Group__r.CPU_Users__c;
				//				sandboxAE.Custom_Instances__c = oli.Quote_Group__r.Custom_Instances__c;
				//				sandboxAE.Trader_Users__c = oli.Quote_Group__r.Trade_Users__c;
				//				sandboxAE.Cost_Percentage_Of_Base__c = 0;
				//				
				//				sandboxAEsToUpsert.add(sandboxAE);
				//				
				//				System__c sys = new System__c(id = sandboxAE.System__c);
				//				olisToSystemMap.put(oli.id, sys);
				//				mapQuoteGroupToSystem.put(oli.Quote_Group__c, sys);
				//				
				//				mapQuoteGroupToAE.put(oli.Quote_Group__c, sandboxAE);
		        //    		}
            	//		}
            	//	}
            	//	else
            	//		throwErrorMessageFromOLI(oli, 'No System lookup exists on Quote Group of record type Additional Environment');
            	//}
            	
            }
            else
            	throwErrorMessageFromOLI(oli, 'Opportunity Line Item (Product) doesnt have an associated Quote Group');
        }
        
        if(systemsToUpsert != null && systemsToUpsert.size() > 0)
        	upsert systemsToUpsert;
       	
       	// the parent child relatinship between quote systems do not exist any more. All Quote systems hang off from opptys
       	//So this piece of code is not required anymore
       	////now create additional sandbox environments
       	//for(Quote_Group__c sandboxQG: [Select ID, Name, Production_Quote_System__r.Opportunity__r.AccountID, 
       	//								Production_Quote_System__r.Opportunity__r.Account.Name, 
       	//								Production_Quote_System__r.Opportunity__r.Order_Type__c, 
       	//								Production_Quote_System__c,
       	//								Administrators__c, 
       	//								Authorized_Locations__c,
       	//								Infrastructure_Server_Required__c, Off_Trading_Floor_Users__c, 
       	//								Trade_Web_Access_Worksheet_Builder__c,
        //                                Additional_Environment__c, 
        //                                Additional_Environment__r.Administrators__c, 
        //                                Additional_Environment__r.Authorized_Locations__c,
        //                                Additional_Environment__r.Infrastructure_Server_Required__c,
        //                                Additional_Environment__r.Off_Trading_Floor_Users__c,
        //                                Additional_Environment__r.Concurrent_Users__c,
        //                                Additional_Environment__r.CPU_Users__c,
        //                                Additional_Environment__r.Custom_Instances__c,
        //                                Additional_Environment__r.Trader_Users__c,	
        //                                Concurrent_Users__c, CPU_Users__c, Custom_Instances__c,
        //                                Trade_Users__c
        //                                from Quote_Group__c 
        //                                where 
        //                                (	
        //                                	Production_Quote_System__c != null 
        //                                	AND
        //                                	(
        //                                		Production_Quote_System__c in: mapQuoteGroupToSystem.keySet()
        //                                		OR
        //                                		Production_Quote_System__c in: mapQuoteGroupToAE.keySet()
        //                                	)
        //                                	AND
        //                                	(
        //                                		ID not in: mapQuoteGroupToAE.keySet()
        //                                	) 
        //                                )
        //                                and RecordTypeID =: QuoteGroupServices.recordTypesNameMap.get(Constants.QUOTE_GROUP_RECORD_TYPE_ADDITIONAL).id ])
       	//{
       	//	//only if the additional environment has a parent(System__c record)
       	//	if(sandboxQG.Additional_Environment__c != null)
       	//	{
       	//		//update additional environments
       	//		Additional_Environment__c sandboxAE = sandboxQG.Additional_Environment__r;
        //		if(sandboxQG.Production_Quote_System__r.Opportunity__r.Order_Type__c == Constants.ORDER_TYPE_ADD_ON)
        //		{
        //			if(sandboxAE.Administrators__c == null) sandboxAE.Administrators__c = 0;
        //			if(sandboxQG.Administrators__c == null) sandboxQG.Administrators__c = 0;
        //			sandboxAE.Administrators__c += sandboxQG.Administrators__c;
        //			
        //			if(sandboxAE.Off_Trading_Floor_Users__c == null) sandboxAE.Off_Trading_Floor_Users__c = 0;
        //			if(sandboxQG.Off_Trading_Floor_Users__c == null) sandboxQG.Off_Trading_Floor_Users__c = 0;
        //			sandboxAE.Off_Trading_Floor_Users__c += sandboxQG.Off_Trading_Floor_Users__c;
        //			
        //			if(sandboxAE.Concurrent_Users__c == null) sandboxAE.Concurrent_Users__c = 0;
        //			if(sandboxQG.Concurrent_Users__c == null) sandboxQG.Concurrent_Users__c = 0;
        //			sandboxAE.Concurrent_Users__c += sandboxQG.Concurrent_Users__c;
        //			
        //			if(sandboxAE.CPU_Users__c == null) sandboxAE.CPU_Users__c = 0;
        //			if(sandboxQG.CPU_Users__c == null) sandboxQG.CPU_Users__c = 0;
        //			sandboxAE.CPU_Users__c += sandboxQG.CPU_Users__c;
        //			
        //			if(sandboxAE.Custom_Instances__c == null) sandboxAE.Custom_Instances__c = 0;
        //			if(sandboxQG.Custom_Instances__c == null) sandboxQG.Custom_Instances__c = 0;
        //			sandboxAE.Custom_Instances__c += sandboxQG.Custom_Instances__c;
        //			
        //			if(sandboxAE.Trader_Users__c == null) sandboxAE.Trader_Users__c = 0;
        //			if(sandboxQG.Trade_Users__c == null) sandboxQG.Trade_Users__c = 0;
        //			sandboxAE.Trader_Users__c += sandboxQG.Trade_Users__c;
        //		}
        //		else
        //		{
        //    		sandboxAE.Administrators__c = sandboxQG.Administrators__c;
	    //            sandboxAE.Authorized_Locations__c = sandboxQG.Authorized_Locations__c;
	    //            sandboxAE.Infrastructure_Server_Required__c = sandboxQG.Infrastructure_Server_Required__c;
	    //            sandboxAE.Off_Trading_Floor_Users__c = sandboxQG.Off_Trading_Floor_Users__c;
	    //            sandboxAE.Concurrent_Users__c = sandboxQG.Concurrent_Users__c;
        //			sandboxAE.CPU_Users__c = sandboxQG.CPU_Users__c;
        //			sandboxAE.Custom_Instances__c = sandboxQG.Custom_Instances__c;
        //			sandboxAE.Trader_Users__c = sandboxQG.Trade_Users__c;
        //		}	
    	//		sandboxAEsToUpsert.add(sandboxAE);
       	//	}
       	//	else
       	//	{
       	//		if(mapQuoteGroupToSystem.containsKey(sandboxQG.Production_Quote_System__c))
   		//		{
	    //   			//create additional environments
	    //   			Additional_Environment__c sandboxAE = new Additional_Environment__c();
	    //   			sandboxAE.Account__c = sandboxQG.Production_Quote_System__r.Opportunity__r.AccountID;
		//			sandboxAE.System__c = mapQuoteGroupToSystem.get(sandboxQG.Production_Quote_System__c).id;
		//			sandboxAE.Name = sandboxQG.Name;
		//            sandboxAE.Administrators__c = sandboxQG.Administrators__c;
		//            sandboxAE.Authorized_Locations__c = sandboxQG.Authorized_Locations__c;
		//            sandboxAE.Infrastructure_Server_Required__c = sandboxQG.Infrastructure_Server_Required__c;
		//            sandboxAE.Off_Trading_Floor_Users__c = sandboxQG.Off_Trading_Floor_Users__c;
		//            sandboxAE.Concurrent_Users__c = sandboxQG.Concurrent_Users__c;
		//			sandboxAE.CPU_Users__c = sandboxQG.CPU_Users__c;
		//			sandboxAE.Custom_Instances__c = sandboxQG.Custom_Instances__c;
		//			sandboxAE.Trader_Users__c = sandboxQG.Trade_Users__c;
		//			sandboxAE.Cost_Percentage_Of_Base__c = 0;
		//			
		//			sandboxAEsToUpsert.add(sandboxAE);
   		//		}
       	//	}
       	//}
       	//
       	
       	//if(sandboxAEsToUpsert.size() > 0)
       	//	upsert sandboxAEsToUpsert;
       	
       	
        return olisToSystemMap;
    }
    
    
    
    //calls the helper methods to first get the qualified OLIs. Processes the OLIs to create System, Entitlement and
    //asset objects under account. Also updates the OLI lookups with the new corresponding assets. Finally updates the
    //Opportunity with Fulfillment date. 
    private static void createUpdateAssets(Map<ID, OpportunityLineItem> qualifiedOLIsMap)
    {
        if(qualifiedOLIsMap.size() > 0)
        {
            List<OLIAssetWrapper> allOLIAssets = getOLIAssets(qualifiedOLIsMap);
            
            List<Troy_Asset__c> allAssetsToInsert = new List<Troy_Asset__c>();
            //List<Additional_Environment_Asset_Junction__c> allAttributesToInsert = new List<Additional_Environment_Asset_Junction__c>();
            for(OLIAssetWrapper oliAst: allOLIAssets)
            {
            	if(oliAst.ast != null)
                	allAssetsToInsert.add(oliAst.ast);
                //else if(oliAst.attribute != null)
                //	allAttributesToInsert.add(oliAst.attribute);
            } 
            
            if(allAssetsToInsert.size() > 0)  
            	upsert allAssetsToInsert;
            
            //if(allAttributesToInsert.size() > 0)
            //	upsert AllAttributesToInsert;
            
            List<Quote_Group__c> quoteGroupsToUpdate = new List<Quote_Group__c>();
            Set<ID> quoteGroupIDs = new Set<ID>();
            List<OpportunityLineItem> allOLIsToUpdate = new List<OpportunityLineItem>();
            Set<ID> opptyIDs = new Set<ID>();
            for(OLIAssetWrapper oliAst: allOLIAssets)
            {
            	OpportunityLineItem oli = oliAst.oli;
            	if(oliAst.ast != null)
            	{
                	oli.Asset__c = oliAst.ast.id;
                	
                	if(!quoteGroupIDs.contains(oli.Quote_Group__c))
                	{
                		Quote_Group__c qs = new Quote_Group__c(id = oli.Quote_Group__c);
                		qs.System__c = oliAst.ast.System__c;
                		quoteGroupsToUpdate.add(qs);
                		quoteGroupIDs.add(qs.id);
                	}              	
            	}
            	//if(oliAst.attribute != null)
            	//{
            	//	oli.Attribute__c = oliAst.attribute.id;
            	//}
            	
            	allOLIsToUpdate.add(oli);
            	opptyIDs.add(oli.OpportunityID);
            }
            update allOLIsToUpdate;
            update quoteGroupsToUpdate;
            
            List<Opportunity> allOpptysToUpdate = new List<Opportunity>();
            for(ID opptyid : opptyIDs)
            {
                Opportunity oppty = new Opportunity(id = opptyid);
                oppty.FA_First_Pass_Complete__c = true;
                allOpptysToUpdate.add(oppty);
            }
            update allOpptysToUpdate;
            
        }
    }
    
    
    //returns the OliAsset wrapper objects. The asset in the objects are either new assets or updated assets
    private static List<OLIAssetWrapper> getOLIAssets(Map<ID, OpportunityLineItem> oliMap)
    {
        List<OLIAssetWrapper> oliAssets = new List<OLIAssetWrapper>();
        if(oliMap != null )
        {
            for(OpportunityLineItem oli: oliMap.values())
            {
                Troy_Asset__c ast;
                //Additional_Environment_Asset_Junction__c aeaj;
                //if(oli.Quote_Group__r.RecordTypeID == QuoteGroupServices.recordTypesNameMap.get(Constants.QUOTE_GROUP_RECORD_TYPE_PRIMARY).id)
                {
                	if(oli.Asset__c == null)
                		ast = createAssetFromOLI(oli);
                	else
                		ast = updateAssetFromOLI(oli);
                }
                //
                //else if(oli.Quote_Group__r.RecordTypeID == QuoteGroupServices.recordTypesNameMap.get(Constants.QUOTE_GROUP_RECORD_TYPE_ADDITIONAL).id)
                //{
                //	if(oli.Asset__c != null)
                //	{
                //		if(oli.Attribute__c == null)
                //			aeaj = createAttributeFromOLI(oli);
                //		else
                //			aeaj = updateAttributeFromOLI(oli);
                //	}
                //}
                //
                OLIAssetWrapper oliAst = new OLIAssetWrapper();
                oliAst.oli = oli;
                oliAst.ast = ast;
                //oliAst.attribute = aeaj;
                System.debug('\n\noliAst = '+oliAst+'\n\n');
                oliAssets.add(oliAst);
            }
        }
        
        return oliAssets;
    }
    
    //copies fields from OLI to Asset for asset creation
    private static Troy_Asset__c createAssetFromOLI(OpportunityLineItem oli)
    {
        Troy_Asset__c ast = new Troy_Asset__c();
        ast.Account__c = oli.Opportunity.AccountID;
        ast.Name = oli.PriceBookEntry.Product2.Asset_Name__c;
        ast.Product__c = oli.PriceBookEntry.Product2ID;
        ast.Production_Version__c = oli.Version__c;
        ast.License_Metric__c = oli.License_Metric__c;
        ast.Quantity__c = oli.License_Metric_Quantity__c;
        ast.Scope__c = oli.Scope__c;
        ast.Contract__c = oli.Opportunity.Contract__c;
        ast.Term_Begin_Date__c = oli.Term_Begin_Date__c;
        ast.Term_End_Date__c = oli.Term_End_Date__c;
        ast.Rental__c = oli.Rental__c;
        ast.Access_Type__c = oli.Access_Type__c;
        ast.Annual_Maintenance__c = oli.Annual_Maintenance__c;	
        ast.Previous_Annual_Maintenance__c = 0;
        ast.Billing_Frequency__c = oli.Billing_Frequency__c;
        ast.Renewal_Notes__c = '';
        
        if(ast.Term_Begin_Date__c == null)
        	ast.Maintenance_Status__c = Constants.STATUS_PENDING_MAINTENANCE;
        else
        	ast.Maintenance_Status__c = Constants.STATUS_ON_MAINTENANCE;
        	
        ast.Go_Live_Date__c = oli.Opportunity.Go_Live_Date__c;
        ast.Enhancement__c = oli.Enhancement__c;
        ast.Customization_Engineering_Notes__c = oli.Enhancement_Notes__c;
        ast.At_Risk__c = '';
        ast.At_Risk_Notes__c = '';
        ast.Rental_Amount__c = oli.Rental_Amount__c;
        if(mapOLIToSystem.containsKey(oli.id))
            ast.System__c = mapOLIToSystem.get(oli.id).id;
        
        return ast;
    }
    
    //copied fields from OLIs to Assets for asset update and renewals
    
    private static Troy_Asset__c updateAssetFromOLI(OpportunityLineItem oli)
    {
        Troy_Asset__c ast = oli.Asset__r;
        //
        //if(oli.Opportunity.Order_Type__c == Constants.ORDER_TYPE_RENEWAL)
        //{
        //    ast.Term_Begin_Date__c = oli.Term_Begin_Date__c;
        //    ast.Term_End_Date__c = oli.Term_End_Date__c;
        //    if(ast.Term_Begin_Date__c == null)
	    //    	ast.Maintenance_Status__c = Constants.STATUS_PENDING_MAINTENANCE;
	    //    else
	    //    	ast.Maintenance_Status__c = Constants.STATUS_ON_MAINTENANCE;
        //    
	    //    ast.Previous_Annual_Maintenance__c = ast.Annual_Maintenance__c;
	    //    ast.Annual_Maintenance__c = oli.Annual_Maintenance__c;
	    //    ast.Quantity__c = oli.License_Metric_Quantity__c;
        //    ast.Billing_Frequency__c = oli.Billing_Frequency__c;
        //	ast.Renewal_Notes__c = '';
        //	
        //	
        //}
        //
        if(oli.Opportunity.Order_Type__c == Constants.ORDER_TYPE_ADD_ON)
        {
        	ast.Previous_Annual_Maintenance__c = ast.Annual_Maintenance__c;
	        
            if(oli.Annual_Maintenance__c == null) oli.Annual_Maintenance__c = 0;
            if(ast.Annual_Maintenance__c == null) ast.Annual_Maintenance__c = 0;
            ast.Annual_Maintenance__c += oli.Annual_Maintenance__c;
            
            if(oli.License_Metric_Quantity__c == null) oli.License_Metric_Quantity__c = 0;
            if(ast.Quantity__c == null) ast.Quantity__c = 0;
            ast.Quantity__c += oli.License_Metric_Quantity__c;
            
        }
        //    
        //else //upgrade
        //{
        //	ast.Previous_Annual_Maintenance__c = ast.Annual_Maintenance__c;
        //	ast.Annual_Maintenance__c = oli.Annual_Maintenance__c;
        //	ast.Production_Version__c = oli.Version__c;
        //}
        //
        
        return ast;
    }
    //
    //private static Additional_Environment_Asset_Junction__c createAttributeFromOLI(OpportunityLineItem oli)
    //{
    //	Additional_Environment_Asset_Junction__c aeaj = new Additional_Environment_Asset_Junction__c();
    //	aeaj.Account__c = oli.Opportunity.AccountID;
    //	aeaj.Name = oli.PriceBookEntry.Product2.Asset_Name__c + ' - Attribute - '+oli.Opportunity.Account.Name+' - '+oli.Quote_Group__r.Additional_Environment_Type__c;
    //	aeaj.Name = aeaj.Name.subString(0, Math.min(79, aeaj.Name.length()));
    //	aeaj.Troy_Asset__c = oli.Asset__c;
    //	aeaj.Version__c = oli.Version__c;
    //	aeaj.Quantity__c = oli.License_Metric_Quantity__c;
    //	aeaj.Scope__c = oli.Scope__c;
    //	aeaj.License_Metric__c = oli.License_Metric__c;
    //	aeaj.Term_Begin_Date__c = oli.Term_Begin_Date__c;
    //	aeaj.Term_End_Date__c = oli.Term_End_Date__c;
    //	
    //	if(aeaj.Term_Begin_Date__c == null)
    //    	aeaj.Maintenance_Status__c = Constants.STATUS_PENDING_MAINTENANCE;
    //    else
    //    	aeaj.Maintenance_Status__c = Constants.STATUS_ON_MAINTENANCE;
    //    	
    //	aeaj.Annual_Maintenance__c = oli.Annual_Maintenance__c;
    //	aeaj.Previous_Annual_Maintenance__c = 0;
    //	aeaj.Billing_Frequency__c = oli.Billing_Frequency__c;
    //	aeaj.Access_Type__c = oli.Access_Type__c;
    //	aeaj.Enhancement__c = oli.Enhancement__c;
    //	aeaj.Enhancement_Notes__c = oli.Enhancement_Notes__c;
    //	aeaj.Rental__c = oli.Rental__c;
    //	aeaj.Rental_Amount__c = oli.Rental_Amount__c;
    //	if(oli.Quote_Group__c != null && mapQuoteGroupToAE.containsKey(oli.Quote_Group__c))
    //	{
    //		aeaj.Additional_Environment__c = mapQuoteGroupToAE.get(oli.Quote_Group__c).id;
    //	}
    //	return aeaj;
    //}
    //
    //private static Additional_Environment_Asset_Junction__c updateAttributeFromOLI(OpportunityLineItem oli)
    //{
    //	Additional_Environment_Asset_Junction__c aeaj = oli.attribute__r;
    //    if(oli.Opportunity.Order_Type__c == Constants.ORDER_TYPE_RENEWAL)
    //    {
    //        aeaj.Term_Begin_Date__c = oli.Term_Begin_Date__c;
    //        aeaj.Term_End_Date__c = oli.Term_End_Date__c;
    //        
    //        if(aeaj.Term_Begin_Date__c == null)
	//        	aeaj.Maintenance_Status__c = Constants.STATUS_PENDING_MAINTENANCE;
	//        else
	//        	aeaj.Maintenance_Status__c = Constants.STATUS_ON_MAINTENANCE;
    //        aeaj.Previous_Annual_Maintenance__c = aeaj.Annual_Maintenance__c;
	//        
	//        aeaj.Annual_Maintenance__c = oli.Annual_Maintenance__c;
	//        
	//        aeaj.Quantity__c = oli.License_Metric_Quantity__c;
    //        aeaj.Billing_Frequency__c = oli.Billing_Frequency__c;
    //    	
    //    }
    //    else if(oli.Opportunity.Order_Type__c == Constants.ORDER_TYPE_ADD_ON)
    //    {
    //    	aeaj.Previous_Annual_Maintenance__c = aeaj.Annual_Maintenance__c;
	//        
    //        if(oli.Annual_Maintenance__c == null) oli.Annual_Maintenance__c = 0;
    //        if(aeaj.Annual_Maintenance__c == null) aeaj.Annual_Maintenance__c = 0;
    //        aeaj.Annual_Maintenance__c += oli.Annual_Maintenance__c;
    //        
    //        if(oli.License_Metric_Quantity__c == null) oli.License_Metric_Quantity__c = 0;
    //        if(aeaj.Quantity__c == null) aeaj.Quantity__c = 0;
    //        aeaj.Quantity__c += oli.License_Metric_Quantity__c;
    //        
    //        aeaj.Version__c = oli.Version__c;
    //    }    
    //    else //upgrade
    //    {
    //    	aeaj.Previous_Annual_Maintenance__c = aeaj.Annual_Maintenance__c;
    //    	aeaj.Annual_Maintenance__c = oli.Annual_Maintenance__c;
    //    	aeaj.Version__c = oli.Version__c;
    //    }
    //    
    //    
    //    return aeaj;
    //}
    //
    //creates an entitlement if one doesnt exist on account
    private static Entitlement createEntitlement(OpportunityLineItem oli)
    {
        String term = (oli.Opportunity.Deal_Term_In_Months__c == null)?'0':oli.Opportunity.Deal_Term_In_Months__c;
        Entitlement ent = new Entitlement();
        ent.AccountId = oli.Opportunity.AccountID;
        ent.Name = 'Entitlement -' +oli.Opportunity.Account.Name;
        ent.Name = ent.Name.subString(0, Math.min(255, ent.Name.length()));
        ent.StartDate = Date.Today();
        ent.EndDate = Date.Today().addMonths(Integer.valueOf(term));
        BusinessHours standardBH;
        try{
        standardBH = [Select Id from BusinessHours where name =: 'Default' limit 1];
        ent.BusinessHoursID = standardBH.id;
        }catch(Exception exc){ standardBH = null;}
        
        return ent;
    }
    
    //Wrapper obbject to maintain association between asset and OLI
    class OLIAssetWrapper
    {
        public OpportunityLineItem oli{get; set;}
        public Troy_Asset__c ast {get; set;}
        //public Additional_Environment_Asset_Junction__c attribute {get; set;}
    }
    JRB  */
}