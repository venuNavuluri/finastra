public class PSPHelper 
{ 
    public List<Case> uniqueCases; 
    public BusinessHours globalBH;
    public Set<ID> businessHoursIds;
    public Map<String,Case_Status_Mapping__c> mapCSM;
    public Map<ID,List<CaseHistory>> mapCaseIdCaseHistory;
    public Map<String, List<Business_Hours_in_Use__c>> mapAccountSLA_BH;   
    public Map<ID,BusinessHours> mapBusinessHours;
    public Map<ID,SLA__c> mapSLA;
   // public Map<ID,Case> updatedCases;

    public BusinessHours getGlobalBH()
    {
        return globalBH;        
    }
    public Set<ID> getBusinessHoursIds()
    {
        return businessHoursIds;        
    }
    public Map<String,Case_Status_Mapping__c> getMapCSM()
    {
        return mapCSM;
    }
    public Map<ID,List<CaseHistory>> getMapCaseIdCaseHistory()
    {
        return mapCaseIdCaseHistory;
    }
    public Map<String, List<Business_Hours_in_Use__c>> getMapAccountSLA_BH()
    {
        return mapAccountSLA_BH;
    }
    public Map<ID,BusinessHours> getMapBusinessHours()
    {
        return mapBusinessHours;
    }
    public Map<ID,SLA__c> getMapSLA()
    {
        return mapSLA;
    }

    // constructor
    public PSPHelper(List<Case> lstUniqueCases)
    {
        businessHoursIds = new Set<ID>();   
        uniqueCases = lstUniqueCases;
    
        //System.debug('uniqueCases : ' + uniqueCases);
        
        //globalBH = [select Id,Name from BusinessHours where Name = 'GLOBAL 24*7 GMT'];
        
        mapCSM = CaseStatusMapping.getCaseStatusMappings();
        
        setCaseHistory();
        
        System.debug('going to go into setAccountSLA_BH()');
        setAccountSLA_BH();
        
        setBusinessHours();
    }
    
    private void setCaseHistory()
    {
        //System.debug('in setCaseHistory');
        
        mapCaseIdCaseHistory = new Map<ID,List<CaseHistory>>();
        
        //System.debug('uniqueCases : ' + uniqueCases);
        
        Set<ID> caseIds = new Set<ID>();
        for(Case c : uniqueCases)
        {
            caseIds.add(c.Id);
        }
        
        //System.debug('caseIds.size() : ' + caseIds.size());
        //System.debug('caseIds : ' + caseIds);
        
        //JRB 2012-09 Updated to use MetricsStatus for Case Metrics calculations instead of the Status field.  Case Status is now kept in both 
        //	Status and SubStatus, and MetricsStatus is a combination of these fields and is set in CaseTrigger.  Status is included for historical calculations.
        //List<CaseHistory> lstCaseHistory = [select Id, OldValue, NewValue, Field, CaseId, CreatedDate from 
        //                                    CaseHistory where CaseId in : caseIds and Field 
        //                                    in ('Status','Case_Category__c','BusinessHours__c') and IsDeleted=false order 
        //                                    by CaseId, CreatedDate asc, Field desc];
		List<CaseHistory> lstCaseHistory = [select Id, OldValue, NewValue, Field, CaseId, CreatedDate from 
                                            CaseHistory where CaseId in : caseIds and Field 
                                            in ('Status','MetricsStatus__c','Case_Category__c','BusinessHours__c') and IsDeleted=false order 
                                            by CaseId, CreatedDate asc, Field desc];                                            
        //System.debug('lstCaseHistory : ' + lstCaseHistory);
        
        for(CaseHistory ch : lstCaseHistory)
        {
            //System.debug('lstCaseHistoryNitin : ' + ch);
            if(mapCaseIdCaseHistory.containsKey(ch.CaseId))
            {
                mapCaseIdCaseHistory.get(ch.CaseId).add(ch);
            }
            else
            {
                List<CaseHistory> lstCH = new List<CaseHistory>();
                lstCH.add(ch);
                mapCaseIdCaseHistory.put(ch.CaseId, lstCH);
            }
        }
        //System.debug('case history size : ' + mapCaseIdCaseHistory.size());
        //System.debug('case history keys : ' + mapCaseIdCaseHistory.keySet());
    }

    private void setBusinessHours()
    {
        if(businessHoursIds.size() > 0)
        {
            mapBusinessHours = new Map<ID,BusinessHours>([select Id from BusinessHours where Id in :businessHoursIds]);
        }
    }

    private void setAccountSLA_BH()
    {
        mapAccountSLA_BH = new Map<String,List<Business_Hours_in_Use__c>>();
    
        Set<ID> uniqueSLAs = new Set<ID>();
            
        for(Case uniqueCase: uniqueCases)
        {
            System.debug('uniqueCase.11SLA__c : ' + uniqueCase.SLA__c);
            System.debug('uniqueCase.11SLA__c : ' + uniqueCase.Original_SLA__c);
            if(uniqueCase.SLA__c != null)
            {
                if(!uniqueSLAs.contains(uniqueCase.SLA__c))
                {
                    uniqueSLAs.add(uniqueCase.SLA__c);
                }
            }
            if(uniqueCase.Original_SLA__c != null)
            {
                if(!uniqueSLAs.contains(uniqueCase.Original_SLA__c))
                {
                    uniqueSLAs.add(uniqueCase.Original_SLA__c);
                }
            }
        }
                
        if(uniqueSLAs.size() > 0)
        {
            mapSLA = new Map<ID,SLA__c>([select Id, Name, X24_7_Add_on__c, Solution_Target_Time_Medium__c, Solution_Target_Time_Low__c, Solution_Target_Time_High__c, Solution_Target_Time_Critical__c, Solution_Target_Low_Value__c, Solution_Target_Medium_Value__c, Solution_Target_High_Value__c, Solution_Target_Critical_Value__c, Resolution_Target_Medium_Value__c, Resolution_Target_Low_Value__c, Resolution_Target_High_Value__c, Resolution_Target_Critical_Value__c from SLA__c where Id in :uniqueSLAs]);
            
            if(!mapSLA.isEmpty())
            {
                System.debug('mapSLA.size() : ' + mapSLA.size());
                
                //List<Business_Hours_in_Use__c> lstBusinessHoursInUse = [select Id, SLA__c, Business_Hours__c, Account__c, Account__r.Id, SLA__r.Id from Business_Hours_in_Use__c where SLA__c in :mapSLA.keySet()];
                
                //System.debug('lstBusinessHoursInUse.size() : ' + lstBusinessHoursInUse.size());
                    
                //for(Business_Hours_in_Use__c bhiu : lstBusinessHoursInUse)
                
                for(Business_Hours_in_Use__c bhiu : [select Id, SLA__c, Business_Hours__c, Account__c, Account__r.Id, SLA__r.Id from Business_Hours_in_Use__c where SLA__c in :mapSLA.keySet()])
                {
                    //System.debug('Limits.getHeapSize() : ' + Limits.getHeapSize());
                    //System.debug('Limits.getLimitHeapSize() : ' + Limits.getLimitHeapSize());
                    
                    //if(Limits.getHeapSize() < Limits.getLimitHeapSize())
                    try
                    {
                        String sAccountSLA = String.valueOf(bhiu.Account__r.Id) + String.valueOf(bhiu.SLA__r.Id);
                        List<Business_Hours_in_Use__c> lstBHIU;
                        
                        if(!businessHoursIds.contains(bhiu.Business_Hours__c))
                        {
                            businessHoursIds.add(bhiu.Business_Hours__c);
                        }
                        
                        if(mapAccountSLA_BH.containsKey(sAccountSLA))
                        {
                            mapAccountSLA_BH.get(sAccountSLA).add(bhiu); 
                        }
                        else
                        {
                            lstBHIU = new List<Business_Hours_in_Use__c>();
                            lstBHIU.add(bhiu);
                            //mapAccountSLA_BH.put(sAccountSLA, lstBHIU); 
                        }
                    }catch(Exception e){
                    	system.debug('Error in PSPHelper.setAccountSLA_BH in BHIU for loop: '+e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
                    	ScheduledCommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),'Apex Error: PSPHelper','setAccount_SLA',e);
                    }
                }
            }
        }  
    }
	 
	public static Case_Status_Mapping__c getCSM(Map<String,Case_Status_Mapping__c> mapCSM, String statusValue)
	{
		Case_Status_Mapping__c csm = new Case_Status_Mapping__c();
		
		//First check if the whole statusValue is in the map keys
		if(mapCSM.containsKey(statusValue)){
			csm = mapCSM.get(statusValue);
		
		//Then check if the statusValue is a combined status with a dash
		}else if(statusValue != null && statusValue.contains('-')){
			
			//If so, split the statusValue and check for the first part of the string in the map
			String[] splitStatus = statusValue.split('-');
			if(mapCSM.containsKey(splitStatus[0])){
				csm = mapCSM.get(splitStatus[0]);
			}
		}//else{
			
		//	//If the statusValue is not in the map, return a blank record
		//	csm = new Case_Status_Mapping__c();
		//}
		
		return csm;		
	} 
	
}