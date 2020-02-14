public class CaseServices {

  	//Look up the default value for Priority based on the given Severity 
  	public static String getPriorityFromSeverity(String caseSeverity)
  	{
  		//String newPriority = 'Medium';
  		String newPriority = caseSeverity;
  	
  		//Set the Priority based on the Severity field.
	    system.debug('CaseService.getPriorityFromSeverity - caseSeverity = '+caseSeverity);
	    if(caseSeverity != null && caseSeverity != '')
	    {
		    if(Case_Severity_Defaults__c.getInstance(caseSeverity) != null)
		    {
		    	newPriority = Case_Severity_Defaults__c.getInstance(caseSeverity).Priority__c;
		    	system.debug('CaseService.getPriorityFromSeverity - newPriority = '+newPriority);
		    }
	    }
	    	
	    return newPriority;
  	}
	
	public static String getSeverityForPriority(String casePriority)
	{
		String caseSeverity = '';
		
		if(casePriority == 'Critical')
		{
			caseSeverity = '1 - Critical';
		}else if(casePriority == 'High') {
			caseSeverity = '2 - High';
		}else if(casePriority == 'Medium') {
			caseSeverity = '3 - Medium';
		}else if(casePriority == 'Low') {
			caseSeverity = '4 - Low';
		}else{
			caseSeverity = casePriority;
		}
		
		return caseSeverity;
		
	}
	
	public static string getSystemStatusFromEnvironment(String Env)
	{
		//Return a System Status value for the given Environment value
	 	String systemStatus = '';
	 	
	 	if(Env == 'Production')
	 		systemStatus = 'Live';
	 	else if(Env == 'Test')
	 		systemStatus = 'Test';
	 	else if(Env == 'Implementation')
	 		systemStatus = 'Implementation';
	 	else if(Env == 'Disaster Recovery')
	 		systemStatus = 'Disaster Recovery (DR)';
	 	else
	 		systemStatus = Env;
	 		
	 	return systemStatus;
	}
	
	//runs before insert and update
    public static void updateUserLookupFromOwnerOnCase(List<Case> newCases)
    {
    	Map<ID, List<Case>> mapOwnerIDToCases = new Map<ID, List<Case>>();
    	for(Case c: newCases)
    	{
    		List<Case> cases;
    		if(mapOwnerIdToCases.containsKey(c.OwnerID))
    			cases = mapOwnerIdToCases.get(c.OwnerID);
    		else
    			cases = new List<Case>();
    		
    		cases.add(c);
    		mapOwnerIdToCases.put(c.OwnerID, cases);
    	}
    	
    	for(User u: [Select ID, FirstName, LastName, Domain_Username__c from User where id in: mapOwnerIdToCases.keySet()])
    	{
    		if(mapOwnerIDToCases.containsKey(u.id))
    		{
    			for(Case c: mapOwnerIdToCases.get(u.id)){
    				c.Case_Owner_User_Lookup__c = c.OwnerID;
    				//c.Analyst_Id__c = c.OwnerId;
    				//c.Case_Owner_JIRA__c = u.FirstName+'.'+u.LastName;
    				c.Case_Owner_JIRA__c = u.Domain_Username__c;
    			}
    		}
    	}
    	
    }

	public static final String sObjectName = 'Case';
	public static Map<String, RecordType> recordTypesNameMap
    {
        get
        {
            if(recordTypesNameMap == null)
            	recordTypesNameMap = GenericServices.getRecordTypesNameMapBySObject(sObjectName);
            
            return recordTypesNameMap;
        }
        
        private set;
    }

    public static Set<String> specialEngineeringStatuses
    {
    	get
    	{
    		if(specialEngineeringStatuses == null)
    		{
    			specialEngineeringStatuses = new Set<String>();
    			specialEngineeringStatuses.add(Constants.STATUS_CLOSED);
    			specialEngineeringStatuses.add(Constants.STATUS_FIXED);
    			specialEngineeringStatuses.add(Constants.SUB_STATUS_WAITING_ON_CS_PS);
    		}
    		
    		return specialEngineeringStatuses;
    	}
    	
    	private set;
    }
    
    //runs on after update
    public static void closeAndUpdateChildCases(Map<ID, Case> newMap, Map<ID, Case> oldMap)
    {
        Set<ID> qualifiedEngineeringCaseIDs = new Set<ID>();
        for(Case c: newMap.values())
        {
            system.debug('CaseServices.closeAndUpdateChildCases - c.RecordTypeId = '+c.RecordTypeId);
            if(c.RecordTypeID == recordTypesNameMap.get(Constants.ENGINEERING_CASE_RECORD_TYPE).id
            //if(c.RecordTypeID == Constants__c.getValues('ENGINEERING_CASE_RECORD_TYPE').Value__c
               && c.Status != null  
               //&& (GenericServices.caseCloseStatuses.contains(c.Status)) 
               && (!GenericServices.caseCloseStatuses.contains(oldMap.get(c.id).Status))
               )
            {
                qualifiedEngineeringCaseIDs.add(c.id);    
            }
        }
        
        List<Case> childCasesToUpdate = new List<Case>();
        if(qualifiedEngineeringCaseIDs.size() > 0)
        {
            for(Case c: [Select ID, ParentID, Status, Severity__c, Priority,
            			JIRA_ID__c, JIRA_ID_2__c, JIRA_ID_3__c, Waiting_For_CS_PS__c,
            			Engineering_Target_Release_Qtr__c, JIRA_ID_2_Target_Release_Date__c, 
            			JIRA_ID_3_Target_Release_Date__c,Engineering_Target_Release__c,
            			JIRA_ID_2_Target_Release_Version__c, JIRA_ID_3_Target_Release_Version__c,
            			Closure_Resolution_Details__c, Case_Closure_Reason__c , Steps_To_Reproduce__c
            			from Case where ParentID in: qualifiedEngineeringCaseIDs])
            {
                Case engineeringCase = newMap.get(c.ParentID);
                c.Severity__c = engineeringCase.Severity__c;
                c.Priority = engineeringCase.Priority;
                c.JIRA_ID__c = engineeringCase.JIRA_ID__c;
                c.JIRA_ID_2__c = engineeringCase.JIRA_ID_2__c;
                c.JIRA_ID_3__c = engineeringCase.JIRA_ID_3__c;
                c.Engineering_Target_Release_Qtr__c = engineeringCase.Engineering_Target_Release_Qtr__c;
                c.JIRA_ID_2_Target_Release_Date__c = engineeringCase.JIRA_ID_2_Target_Release_Date__c;
                c.JIRA_ID_3_Target_Release_Date__c = engineeringCase.JIRA_ID_3_Target_Release_Date__c;
                c.Engineering_Target_Release__c = engineeringCase.Engineering_Target_Release__c;
                c.JIRA_ID_2_Target_Release_Version__c = engineeringCase.JIRA_ID_2_Target_Release_Version__c;
                c.JIRA_ID_3_Target_Release_Version__c = engineeringCase.JIRA_ID_3_Target_Release_Version__c;
                //legacy cases do not have steps to reproduce which throws teh validation error
                if(GenericServices.isNullOrEmpty(c.Steps_To_Reproduce__c))
                	c.Steps_To_Reproduce__c = System.label.This_is_a_legacy_case_so_no_steps_to_reproduce_were_included;
                
                if(GenericServices.caseCloseStatuses.contains(engineeringCase.Status))
                {
                	//c.Status = engineeringCase.Status;
                	//c.Resolution_Type__c = engineeringCase.Resolution_Type__c;
                	c.Case_Closure_Reason__c = engineeringCase.Case_Closure_Reason__c;
                	//c.Case_Closure_Comments__c = engineeringCase.Case_Closure_Comments__c;
                	c.Closure_Resolution_Details__c = engineeringCase.Closure_Resolution_Details__c;
                }
                
                if(engineeringCase.Sub_Status__c == 'Development')
                {
                	c.Sub_Status__c = engineeringCase.Sub_Status__c;
                }
                
                if(specialEngineeringStatuses.contains(engineeringCase.Status) || 
                	(engineeringCase.Sub_Status__c != '' && specialEngineeringStatuses.contains(engineeringCase.Sub_Status__c)))
                {
                	c.Waiting_For_CS_PS__c = true;
                }
                childCasesToUpdate.add(c);
            }
            
            update childCasesToUpdate;
        }
    }
	
    public static void updateCaseSurveyContact(List<Case> caseSurveysSent)
    {
    	//Input:  List of cases where the CaseSurveySent flag has been updated
    	//Action:  Update the related Case contact with the CaseSurveyCounter and CaseSurveyDate fields
    	
    	//Set<Id> surveyContactIds = new Set<Id>();
    	map<Id,Integer> surveyContacts = new map<Id,Integer>();
    	
    	//Get the list of Contact Ids related to the updated Cases.
    	for(Case c : caseSurveysSent)
    	{
    		if(surveyContacts.keySet().contains(c.contactId))
    		{
    			surveyContacts.put(c.ContactId,surveyContacts.get(c.ContactId)+1);
    		}else{
    			surveyContacts.put(c.ContactId,1);
    		}
    	}
    	system.debug('CaseServices.updateCaseSurveyContact - surveyContacts: '+surveyContacts);
    	
    	//Get the Contact records to be updated
    	map<Id,Contact> contactsToUpdate = new map<Id,Contact>([select Id, CaseSurveyDate__c from Contact where Id in :surveyContacts.keySet()]);
    	system.debug('CaseServices.updateCaseSurveyContact - contactsToUpdate: '+contactsToUpdate);
    	
    	for(Id conId : surveyContacts.keySet())
    	{
    		if(contactsToUpdate.keySet().contains(conId))
    		{
    			contactsToUpdate.get(conId).CaseSurveyDate__c = date.today();
    		}
    	}
    	update contactsToUpdate.values();
    }
    
    //Update the CS Case Manager on a new case
    public static void checkCSCaseManager(list<Case> casesNew)
    {
    	//Updates the CS Case Manager depending on the case type
    	
   		//get list of values for updated case values
   		map<Case,String> newCaseToCaseManager = getCSCaseManager(casesNew);
   		
   		//loop through and update values
   		for(Case newCase : casesNew){
   			newCase.CS_Case_Manager__c = newCaseToCaseManager.get(newCase);
   		}     	
    }
    
    //Determine if the CS Case Manager needs to be updated on an updated case
   	public static void checkCSCaseManager(map<Id,Case> casesNew, map<Id,Case> casesOld)
   	{
   		//Checks if the CS Case Manager field needs to be updated.  An update is needed for new cases and when the Product Set is updated on a case.
   		
   		list<Case> casesToUpdate = new list<Case>();
   		list<Case> casesCheckValue = new list<Case>();
   		
   		for(Case c : casesNew.values()){
   			//if field is blank, add to list to update
   			if(c.CS_Case_Manager__c == null || c.CS_Case_Manager__c == ''){
   				casesToUpdate.add(c);
   			}
   			
   			//if Product Set is changed, add to list to get value for old case
   			if(c.Product_Set__c != casesOld.get(c.Id).Product_Set__c){
   				casesCheckValue.add(casesOld.get(c.Id));
   			}
   		}
   		
   		//get list of values for old case value
   		map<Case,String> oldCaseToCustAdvocate = getCSCaseManager(casesCheckValue);
   		
   		//loop through changed case list
   		for(Case oldCase : casesOld.values()){
   			//if lookup value equals current value, then add to list to update current value
   			if(oldCase.CS_Case_Manager__c == oldCaseToCustAdvocate.get(oldCase)){
   				casesToUpdate.add(casesNew.get(oldCase.Id));
   			}else{
   				//if not, then someone has manually updated this, and we need to leave it
   			}
   		}
   		
   		//get list of values for updated case values
   		map<Case,String> newCaseToCaseManager = getCSCaseManager(casesToUpdate);
   		
   		//loop through and update values
   		for(Case newCase : casesToUpdate){
   			newCase.CS_Case_Manager__c = newCaseToCaseManager.get(newCase);
   		}
   		
   		//if not new, not blank, and not updated, then no change is made. 
   		
   	}
   	
   	private static map<Case,String> getCSCaseManager(list<Case> caseList)
   	{
   		//Given a list of cases, this determines the CS Case Manager for each and returns a map with the Case Id and CS Case Manager value
   		
   		map<Case,String> caseToCSCM = new map<Case,String>();
   		list<Case> casesUseDefault = new list<Case>();
   		
   		set<Id> setProductSetIds = new set<Id>();
   		for(Case thisCase : caseList)
   		{
   			if(thisCase.Product_Set__c != null){
   				setProductSetIds.add(thisCase.Product_Set__c);
   			}
   		}
   		system.debug('CaseServices.getCSCaseManager - setProductSetIds: '+setProductSetIds);
   		
   		map<Id,Product_Set__c> relatedProductSets = new map<Id,Product_Set__c>([select Id, Name, Customer_Advocate__c, Customer_Advocate__r.Name from Product_Set__c where Id in :setProductSetIds]);
   		system.debug('CaseServices.getCSCaseManager - relatedProductSets: '+relatedProductSets);
   		
   		//Add all cases to the map to be returned to prevent nulls from being returned
   		for(Case cs : caseList){
   			caseToCSCM.put(cs,'');
   		}
   			
   		//Get the list of case types which will always use the default case manager
   		//String defaultCMCaseTypes = Label.CaseType_UseDefaultCaseManager;
   
   		//loop through the incoming case list
   		for(Case c : caseList)
   		{
   			//if the case type is one that always uses the default, add it to a list to retrieve later
   			//if(defaultCMCaseTypes.contains(c.RecordTypeId)){
   			//	casesUseDefault.add(c);
   			//}
   			
   			//lookup the Customer Advocate on the related Product Set record
   			if(relatedProductSets.keySet().contains(c.Product_Set__c)){
   				if(relatedProductSets.get(c.Product_Set__c).Customer_Advocate__c != null){
   					//if it has a value, add the Id and value to the map
   					caseToCSCM.put(c,relatedProductSets.get(c.Product_Set__c).Customer_Advocate__r.Name);
   				}else{
   					//if blank, add to the list to get the default value
   					//casesUseDefault.add(c);
   					caseToCSCM.put(c,Label.CaseManager_NoCustomerAdvocate);
   				}
   			}
   		}
   		system.debug('CaseServices.getCSCaseManager - 1 - caseToCSCM: '+caseToCSCM);
   			
   		//if the default value case list size has records,
   		//if(casesUseDefault.size() > 0){
   			//get the default for the current user from the Custom Setting
   			//CS_Case_Manager__c caseManager = CS_Case_Manager__c.getInstance();
   			
   			
   			
   			//loop through the cases and set the default
   			//for(Case iCase : casesUseDefault){
   			//	//get the default for the current user from the Custom Setting and set the value in the map
   			//	caseToCSCM.put(iCase,caseManager.Case_Manager__c);
   			//}
   		//} 
   		
   		//Loop back through the Case list and set the default for any where the Product Set was not found
   		for(Case ca : caseToCSCM.keySet()){
   			if(caseToCSCM.get(ca) == ''){
   				caseToCSCM.put(ca,Label.CaseManager_NoProductSet);
   			}
   		}
   		system.debug('CaseServices.getCSCaseManager - 2 - caseToCSCM: '+caseToCSCM);
		   			
   		//return the map
   		return caseToCSCM;
   	}
    
	
/* CaseServices class - code from Turaz org below
*
* 11/08/2011 - Naushad Sunnivohra (Bluewolf)
* Services class for static level methods for Case object. 
*   
*/	

	/******

    *****/

    

}