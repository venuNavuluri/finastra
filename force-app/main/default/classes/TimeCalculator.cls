global class TimeCalculator 
{   
    private static PSPHelper localPspHelper;
    
    public static PSPHelper getPSPHelper(List<Case> lstCases)
    {
        if(localPspHelper == null)
        {
            localPspHelper = new PSPHelper(lstCases); 
        }       
        return localPspHelper;
    }
    
    public static void CalculateTimesNew(List<ID> caseIDs)
    {   
        Map<ID,Case> mapCases = new Map<ID,Case>();
        
        Set<ID> uniqueCaseIDs = new Set<ID>();
        
        uniqueCaseIDs.addAll(caseIDs);

        System.debug('uniqueCaseIDs : ' + uniqueCaseIDs);

        Map<ID,Case> uniqueCases = new Map<ID,Case>([Select c.Process_Me__c, 
        													c.AccountId, 
        													c.CreatedDate, 
        													c.ClosedDate, 
        													c.Time_Object__c, 
        													c.SLA__c, 
        													c.IsClosed, 
        													c.Priority,
        													c.Severity__c,	//JRB 2012-09 
        													c.Case_Category__c, 
        													c.Status, 
        													c.MetricsStatus__c,
        													c.Category__c, 
        													c.Sub_status__c, 
        													c.Business_Hours_in_Use__c, 
        													c.Business_Hours_in_Use__r.Business_Hours__c, 
        													c.Business_Hours_in_Use__r.Normal_Working_Day_Length__c,
        													c.Original_Priority__c,
        													c.Original_SLA__c,
        													c.Original_Business_Hours_in_Use__c,
        													c.Original_Business_Hours_in_Use__r.Business_Hours__c,
        													Original_Business_Hours_in_Use__r.Normal_Working_Day_Length__c,
        													c.Workaround_Time_Stamp__c 
        													from Case c 
        													where c.Time_Object__c != null and c.Id in :uniqueCaseIDs]);
        
        System.debug('uniqueCases.size() : ' + uniqueCases.size());
        System.debug('uniqueCases.Values() : ' + uniqueCases.Values());
        
        PSPHelper pspHelper = new PSPHelper(uniqueCases.Values());
        
        try
        {
            //CaseTriggerMethods.SetCaseElapsedTime(uniqueCases.Values(), pspHelper);
            CaseTriggerMethods.SetCaseSolutionTime(uniqueCases, pspHelper);
            CaseTriggerMethods.SetCaseSolutionBreachTime(uniqueCases.Values(), pspHelper);
            CaseTriggerMethods.SetCaseRespondedTime(uniqueCases, pspHelper);
        }
        catch(Exception e)
        {
            System.debug('--------------------------------Exception in Scheduler From MISYS----------------------------');
            //CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),'Apex Batch job failure','CalculateTimesNew',e);
            System.debug('Exception: '+e);
        }
    }

    //JRB  18-Jul-2011
    //This method is used specifically for the batch processing routine.
    //It is the same as CalculateTimesNew except that the SOQL query is not run here.  It is run in the class 
    // that sets up the batch job.
    public static void CalculateTimesBatch(List<Case> lCases)
    {   
        Map<ID,Case> uniqueCases = new Map<ID,Case>();
        
        Set<ID> uniqueCaseIDs = new Set<ID>();
        
        //Build the Map and the case id list
        for(Case iCase : lCases)
        {
            uniqueCaseIDs.add(iCase.Id);
            uniqueCases.put(iCase.Id,iCase);
        }

        System.debug('uniqueCaseIDs : ' + uniqueCaseIDs);
        System.debug('uniqueCases.size() : ' + uniqueCases.size());
        System.debug('uniqueCases.Values() : ' + uniqueCases.Values());
        
        PSPHelper pspHelper = new PSPHelper(uniqueCases.Values());
        
        try
        {
            //CaseTriggerMethods.SetCaseElapsedTime(uniqueCases.Values(), pspHelper);
            CaseTriggerMethods.SetCaseSolutionTime(uniqueCases, pspHelper);
            CaseTriggerMethods.SetCaseSolutionBreachTime(uniqueCases.Values(), pspHelper);
            CaseTriggerMethods.SetCaseRespondedTime(uniqueCases, pspHelper);
        }
        catch(Exception e)
        {
            System.debug('--------------------------------Exception in Scheduler From MISYS----------------------------');            
            //CommonFunctions.sendEmailErrorNotice(Label.Apex_Error_Emails.split(';'),'Apex Batch job failure','CalculateTimesBatch',e);
            System.debug('Exception: '+e);
        }
    }
        
    public static void PerformCalculation(List<Case> uniqueCases, String calculationType, Map<ID,Time_Object__c> uniqueTimeObjects, Map<ID,SLA__c> mapSLA, Map<String, List<Business_Hours_in_Use__c>> mapAccountSLA_BH, Map<ID,BusinessHours> mapBusinessHours, BusinessHours globalBH, Map<String,Case_Status_Mapping__c> mapCSM, Map<ID,List<CaseHistory>> mapCaseIdCaseHistory)
    {        
            System.debug('uniqueCases : ' + uniqueCases);
            System.debug('mapSLA : ' + mapSLA);
            System.debug('mapBusinessHours : ' + mapBusinessHours);
            System.debug('globalBH : ' + globalBH);
            System.debug('mapCSM : ' + mapCSM);
            System.debug('mapCaseIdCaseHistory : ' + mapCaseIdCaseHistory);
            
            for(Case uniqueCase: uniqueCases)
            {
                if(mapSLA != null && !mapSLA.isEmpty() && mapSLA.get(uniqueCase.SLA__c) != null)
                {
                    SLA__c caseSLA = mapSLA.get(uniqueCase.SLA__c);
                    Long elapsedTime = 0;
                    if(caseSLA != null)
                    {
                        BusinessHours caseBH = mapBusinessHours.get(uniqueCase.Business_Hours_in_Use__r.Business_Hours__c);// = mapBusinessHours.get(mapSLA.get(uniqueCase.SLA__c).Business_Hours__c);
                           if(caseBH != null)
                            {
                               if(calculationType == 'Responded')
                                {
                                    calculateResponseTime(uniqueCase, uniqueTimeObjects.get(uniqueCase.Time_Object__c), mapCaseIdCaseHistory, mapCSM, globalBH, caseBH);                                    
                                }
                                if(calculationType == 'SolutionTime')
                                {
                                    System.debug('going to calculate solution time');
                                    calculateSolutionTime(uniqueCase, uniqueTimeObjects.get(uniqueCase.Time_Object__c), mapCaseIdCaseHistory, mapCSM, globalBH, caseBH);
        
                                    //if(uniqueCase.IsClosed == true && uniqueTimeObjects.get(uniqueCase.Time_Object__c).Process_Closed_Case__c == false)
                                    //if(uniqueCase.Process_Me__c == 'True' && uniqueTimeObjects.get(uniqueCase.Time_Object__c).Process_Closed_Case__c == false)
                                    if(uniqueCase.IsClosed == true && uniqueTimeObjects.get(uniqueCase.Time_Object__c).Process_Closed_Case__c == true)
                                    {
                                        // also calculate the X10 days 
                                        Double normalWorkingDayLength = uniqueCase.Business_Hours_in_Use__r.Normal_Working_Day_Length__c;
                                        Double d10WorkingDaysInSec = 10 * normalWorkingDayLength * 60 * 60 * 1000;
                                        System.debug('d10WorkingDaysInSec : ' + d10WorkingDaysInSec);
                                        uniqueTimeObjects.get(uniqueCase.Time_Object__c).X10_Working_Days__c = BusinessHours.add(caseBH.id, uniqueCase.ClosedDate, d10WorkingDaysInSec.longValue());
                                        System.debug('uniqueCase.ClosedDate : ' + uniqueCase.ClosedDate);
                                        System.debug('uniqueTimeObjects.get(uniqueCase.Time_Object__c).X10_Working_Days__c : ' + uniqueTimeObjects.get(uniqueCase.Time_Object__c).X10_Working_Days__c);
                                        
                                        
                                        // now set the Processed Flag for the closed case so that it wont be picked up again
                                        uniqueTimeObjects.get(uniqueCase.Time_Object__c).Process_Closed_Case__c = false;
                                    }
                                    else if(uniqueTimeObjects.get(uniqueCase.Time_Object__c).Process_Closed_Case__c == false)
                                    {
                                        uniqueTimeObjects.get(uniqueCase.Time_Object__c).Process_Closed_Case__c = true;
                                    } 
                                    
                                    /* Previous code is commented by Nitin
                                    if(uniqueCase.IsClosed == true)
                                    {
                                        // also calculate the X10 days 
                                        Double normalWorkingDayLength = uniqueCase.Business_Hours_in_Use__r.Normal_Working_Day_Length__c;
                                        Double d10WorkingDaysInSec = 10 * normalWorkingDayLength * 60 * 60 * 1000;
                                        System.debug('d10WorkingDaysInSec : ' + d10WorkingDaysInSec);
                                        uniqueTimeObjects.get(uniqueCase.Time_Object__c).X10_Working_Days__c = BusinessHours.add(caseBH.id, uniqueCase.ClosedDate, d10WorkingDaysInSec.longValue());
                                        System.debug('uniqueCase.ClosedDate : ' + uniqueCase.ClosedDate);
                                        System.debug('uniqueTimeObjects.get(uniqueCase.Time_Object__c).X10_Working_Days__c : ' + uniqueTimeObjects.get(uniqueCase.Time_Object__c).X10_Working_Days__c);
                                        
                                        
                                        // now set the Processed Flag for the closed case so that it wont be picked up again
                                        uniqueTimeObjects.get(uniqueCase.Time_Object__c).Process_Closed_Case__c = true;
                                    }
                                    else
                                    {
                                        if(uniqueTimeObjects.get(uniqueCase.Time_Object__c).Process_Closed_Case__c == true)
                                        {
                                            uniqueTimeObjects.get(uniqueCase.Time_Object__c).Process_Closed_Case__c = false;
                                        }
                                    } */
                                } 
                            }
                        //}
                    }
                }
            }
    }
    
    private static void calculateSolutionTime(Case objCase, Time_Object__c objTime, Map<ID,List<CaseHistory>> mapCaseIdCaseHistory, Map<String,Case_Status_Mapping__c> mapCSM, BusinessHours globalBH, BusinessHours caseBH)
    {    
            System.debug('in calculateSolutionTime');
            
            //System.debug('mapCSM : ' + mapCSM);
            //System.debug('mapCaseIdCaseHistory : ' + mapCaseIdCaseHistory);
            System.debug('objCase.Id : '+ objCase.Id);
			
			//Set the case Priority based on a lookup.  
	        //If the field or values change for Priority/Severity, it can be adjusted here
	        String casePriority = CaseServices.getPriorityFromSeverity(objCase.Severity__c);
	        String caseOriginalPriority = CaseServices.getPriorityFromSeverity(objCase.Original_Priority__c);
			        
            if(objTime != null)
            {
                List<CaseHistory> lstCH = new List<CaseHistory>();
                Integer i = 1;
                DateTime dtLastStatusChange = objCase.CreatedDate; 
                Long bucketTime = 0;
    
                Long misysTime = 0;
                Long misysSolutionTime = 0;
                Long misysResolutionTime = 0;
                Long customerTime = 0;
                Long timeAwaitingCustomer = 0;
                Long timeAwaitingCustomerAcceptance = 0;
                Long elapsedTime = 0;
                Long closedTime = 0;
    
                Long timeInL1 = 0;
                Long timeInL2 = 0;
                Long timeInL3 = 0;
                Long timeInWorkaround= 0;
                Long originalTimeInWorkaround= 0;
                Long TotalCaseHistoryTime = 0;
                
                
                String caseBusinessHour = null;
                String caseCategory = '';
                String initialCaseCategory = '';
                //List<CaseHistory> lCaseH = new List<CaseHistory>(); 
                
                Integer iCountCaseCategory = 0;
                
                if(objCase.Case_Category__c != null)
                {
                    caseCategory = objCase.Case_Category__c;
                }
    
                System.debug('is case history empty?');         
                System.debug('mapCaseIdCaseHistory.containsKey(objCase.Id) : ' + mapCaseIdCaseHistory.containsKey(objCase.Id));
                
                Boolean bNoHistory = true;
                /* 
                    If any existing record is updated then immediatlly Original fields will populated with the existing values.
                    and we need to calculate the time on the basis of the Business Hours which was align with the record at that time which is now
                    in the Original fields. we should not use the current Business hours for calculating the previous time bucket
                    because it may be possible that the current SLA or business hour also changed at this time 
                */ 
                if(caseBH != null && caseBH.Id != null)
                    caseBusinessHour = caseBH.Id;
                else if(objCase.Original_Business_Hours_in_Use__c != null && objCase.Original_Business_Hours_in_Use__r.Business_Hours__c != null)
                    caseBusinessHour = objCase.Original_Business_Hours_in_Use__r.Business_Hours__c;
                    
                if(!mapCaseIdCaseHistory.isEmpty() && mapCaseIdCaseHistory.containsKey(objCase.Id))
                {
                    
                    System.debug('case history is NOT empty?');
                                
                    
                    //if(mapCaseIdCaseHistory.containsKey(objCase.Id))
                    //{
                        lstCH = mapCaseIdCaseHistory.get(objCase.Id);
                        List<CaseHistory> lstCHBH = mapCaseIdCaseHistory.get(objCase.Id);
    					system.debug('TimeCalculator.calculateSolutionTime - lstCHBH (Case History for Case) : '+lstCH);
    					
                        String lastStatus = '';
                        
                        
                        System.debug('caseCategory : ' + caseCategory);
                        Integer iCounter = 0;
                        if(lstCH.size() > 0)
                        {
                            // first get the initial case category
                            if(lstCH.size() == 1)
                            {
                                bNoHistory = true;
                            }
                            for(CaseHistory ch : lstCH)
                            {
                                System.debug('lstCH---Nitin----- : ' + ch);
                                if(ch.Field == 'Case_Category__c')
                                {
                                    if(lstCH.size() == 2)
                                    {
                                        bNoHistory = true;
                                    }
                                    
                                    if(initialCaseCategory == '')
                                    {
                                        initialCaseCategory = String.valueOf(ch.OldValue);
                                    }
                                    
                                    iCountCaseCategory++;
                                }
                            }
                            
                            if(initialCaseCategory != '')
                            {
                                caseCategory = initialCaseCategory;
                            }
                            
                            System.debug('Initial Case Category : ' + caseCategory);
                            
                            iCounter = 0;
                            for(CaseHistory ch : lstCH)
                            {
                                System.debug('From1 : ' + dtLastStatusChange);
                                System.debug('To1 : ' + ch.createdDate);
                                System.debug('Old Status1 : ' + String.valueOf(ch.OldValue));
                                System.debug('New Status1 : ' + String.valueOf(ch.NewValue));
                                System.debug('caseBusinessHour1--->'+caseBusinessHour);
                                System.debug('ch.Field--->'+ch.Field);
                                
                                if(ch.Field == 'BusinessHours__c')
                                {
                                    if(ch.NewValue != null && ch.OldValue != null)
                                    {
                                        System.debug('dtLastStatusChange 1: ' + dtLastStatusChange);
                                        System.debug('ch.createdDate : ' + ch.createdDate);
                                        caseBusinessHour = String.valueOf(ch.NewValue);
                                        if(iCounter > 0)
                                            bucketTime += BusinessHours.diff(String.valueOf(ch.OldValue), dtLastStatusChange, ch.createdDate);
                                        else
                                            bucketTime = BusinessHours.diff(String.valueOf(ch.OldValue), dtLastStatusChange, ch.createdDate);
                                        dtLastStatusChange = ch.CreatedDate;
                                        iCounter++;
                                    }
                                    else if(ch.NewValue != null)
                                        caseBusinessHour = String.valueOf(ch.NewValue);
                                }   
                                else if(ch.Field == 'Case_Category__c')
                                {
                                    caseCategory = String.valueOf(ch.NewValue);
                                    System.debug('caseCategory : ' + caseCategory);
                                }
                                //Status fields changed on date below.  To prevent double-counting if both Status and MetricStatus history are 
                                //	tracked, the date criteria is included. 
                                else if((ch.Field == 'Status' && ch.CreatedDate < datetime.newInstance(2012,9,29,18,0,0)) || (ch.Field == 'MetricsStatus__c'))
                                {
                                	   
                                    bNoHistory = false;                                 
                                    String sOldStatus = String.valueOf(ch.OldValue);
                                    String sNewStatus = String.valueOf(ch.NewValue);
                                    System.debug('bucketTime : ' + bucketTime);
                                    
                                    /*
                                        IsBHAgain variable is used if two CaseHistory Records for Business Hours are found one after other.
                                        then calculate the interval between these two records and add this into the next coming Status.                                    
                                    */                
                                    if(iCounter > 0)
                                    {
                                        System.debug('bucketTime 1: '+ bucketTime);
                                        bucketTime += BusinessHours.diff(caseBusinessHour, dtLastStatusChange, ch.createdDate);
                                        System.debug('bucketTime 2: '+ bucketTime);
                                        iCounter = 0;
                                    }
                                    else
                                    {
                                        iCounter = 0;
                                        bucketTime = BusinessHours.diff(caseBusinessHour, dtLastStatusChange, ch.createdDate);
                                    }
                                    System.debug('bucketTime : ' + bucketTime);
                                    //bucketTime = (bucketTime / 1000) / 60;
                                    bucketTime = (bucketTime / 1000);
                                    TotalCaseHistoryTime += bucketTime;
                
                                    System.debug('From : ' + dtLastStatusChange);
                                    System.debug('To : ' + ch.createdDate);
                                    System.debug('bucketTime : ' + bucketTime);                         
                                    System.debug('Old Status : ' + sOldStatus);
                                    System.debug('New Status : ' + sNewStatus);
                                    System.debug('caseBusinessHour--->'+caseBusinessHour);
                                    //System.debug(i + ' Bucket is ' + mapCSM.get(sOldStatus).Solution_Time__c);
                                    System.debug(i + ' Bucket is ' + PSPHelper.getCSM(mapCSM,sOldStatus).Solution_Time__c);
                                    
                                    if(sOldStatus == 'Closed' && sNewStatus != '')
                                    {
                                        System.debug('this is closed bucket, hence ignore');
                                        closedTime += bucketTime;
                                        Long timeWorkaroundToClose = 0;
                                        
                                        if(objTime.Original_Workaround_Time_Stamp__c != null)
                                        {
                                            timeWorkaroundToClose = BusinessHours.diff(caseBusinessHour,objTime.Original_Workaround_Time_Stamp__c , dtLastStatusChange);
                                            timeWorkaroundToClose = timeWorkaroundToClose/1000;
                                            if(objCase.Workaround_Time_Stamp__c > dtLastStatusChange)
                                                originalTimeInWorkaround = bucketTime;
                                            else if(objCase.Workaround_Time_Stamp__c < dtLastStatusChange)
                                                originalTimeInWorkaround = 0;
                                        }
                                        else
                                            originalTimeInWorkaround = bucketTime;
                                        
                                        if(objCase.Workaround_Time_Stamp__c != null)
                                        {
                                            if(objCase.Workaround_Time_Stamp__c > dtLastStatusChange)
                                                timeInWorkaround = bucketTime + timeWorkaroundToClose;
                                            else if(objCase.Workaround_Time_Stamp__c < dtLastStatusChange)
                                                timeInWorkaround = 0;
                                        }
                                        else
                                            timeInWorkaround = bucketTime + timeWorkaroundToClose;
                                        lastStatus = '';
                                    }
                                    else
                                    {
                                        //system.debug('Nitin>>>>'+mapCSM.get(sOldStatus).Solution_Time__c + '------' + bucketTime);
                                        system.debug('Nitin>>>>'+PSPHelper.getCSM(mapCSM,sOldStatus).Solution_Time__c + '------' + bucketTime);
                                        //if(mapCSM.get(sOldStatus).Solution_Time__c == 'Misys')
                                        if(PSPHelper.getCSM(mapCSM,sOldStatus).Solution_Time__c == 'Misys')
                                        {
                                            misysTime += bucketTime;
                                            //misysResolutionTime += bucketTime;
                                            misysSolutionTime += bucketTime;    
                                                
                                            //if(objCase.Case_Category__c == 'Support Request')
                                            if(caseCategory == 'Support Request' || caseCategory == 'Incident')
                                            {
                                                //misysSolutionTime += bucketTime;  
                                                misysResolutionTime += bucketTime;
                                            }
                                            //if(mapCSM.get(sOldStatus).Time_Bucket__c == 'L1')
                                            if(PSPHelper.getCSM(mapCSM,sOldStatus).Time_Bucket__c == 'L1')
                                            {
                                                timeInL1 += bucketTime;
                                            }
                                            //else if(mapCSM.get(sOldStatus).Time_Bucket__c == 'L2')
                                            else if(PSPHelper.getCSM(mapCSM,sOldStatus).Time_Bucket__c == 'L2')
                                            {                                               
                                                timeInL2 += bucketTime;
                                                system.debug('NNNNNNNNNNNNNNNNNNNNNNNNNNNNNN1'+timeInL2);
                                            }
                                            //else if(mapCSM.get(sOldStatus).Time_Bucket__c == 'L3')
                                            else if(PSPHelper.getCSM(mapCSM,sOldStatus).Time_Bucket__c == 'L3')
                                            {
                                                timeInL3 += bucketTime;
                                            }
                                        }
                                        //else if(mapCSM.get(sOldStatus).Solution_Time__c == 'Customer')
                                        else if(PSPHelper.getCSM(mapCSM,sOldStatus).Solution_Time__c == 'Customer')
                                        {
                                            customerTime += bucketTime;
                                            // new reporting requirements to break down Time With Customer
                                            if (sOldStatus.startsWith('Awaiting Client')) timeAwaitingCustomer += bucketTime;
                                            if (sOldStatus.startsWith('Solution Provided')) timeAwaitingCustomerAcceptance += bucketTime;
                                        }
                                        lastStatus = sNewStatus;
                                    }
                                                
                                    //if(i == lstCH.size() - iCountCaseCategory)
                                    //{
                                        System.debug('setting last status');
                                        //lastStatus = String.valueOf(ch.NewValue);
                                        //lastStatus = sNewStatus;
                                    //}
                                        
                                    i++;
                                    dtLastStatusChange = ch.CreatedDate;
                                }
                            }   
                                    
                            System.debug('lastStatus : ' + lastStatus);
                            
                            // now calculate the last chunck
                            
                            // first check if the status was ever touched
                            if(lastStatus != '')
                            {
                                //System.debug('Last Status Is Closed? : ' + mapCSM.get(lastStatus).SFDC_Closed_Flag__c);
                                System.debug('Last Status Is Closed? : ' + PSPHelper.getCSM(mapCSM,lastStatus).SFDC_Closed_Flag__c);
                                
                                DateTime dt = DateTime.Now();
                                    
                                Long lTime = BusinessHours.diff(caseBusinessHour, dtLastStatusChange, dt);
                                //lTime  = lTime / 1000 / 60;
                                lTime  = lTime / 1000;
                                System.debug('XXXXX : ' + lTime );
                                
                                if(iCounter > 0)
                                {
                                    System.debug('bucketTime 1: '+ bucketTime);
                                    bucketTime += BusinessHours.diff(caseBusinessHour, dtLastStatusChange, dt);
                                    System.debug('bucketTime 2: '+ bucketTime);
                                    iCounter = 0;
                                }
                                else
                                {
                                    iCounter = 0;
                                    bucketTime = BusinessHours.diff(caseBusinessHour, dtLastStatusChange, dt);
                                }
                                
                                //System.debug('XXXXXNNNNNNN : ' + lTime );
                                //bucketTime = BusinessHours.diff(caseBusinessHour, dtLastStatusChange, dt);
                                //bucketTime = (bucketTime / 1000) / 60;
                                bucketTime = (bucketTime / 1000);
                                
                                //if(mapCSM.get(lastStatus).SFDC_Closed_Flag__c != null)
                                if(PSPHelper.getCSM(mapCSM,lastStatus).SFDC_Closed_Flag__c != null)
                                {                                   
                                    //if(mapCSM.get(lastStatus).SFDC_Closed_Flag__c == false)
                                    if(PSPHelper.getCSM(mapCSM,lastStatus).SFDC_Closed_Flag__c == false)
                                    {
                                        TotalCaseHistoryTime += bucketTime;
                                        System.debug('From Bydefault : ' + dtLastStatusChange);
                                        System.debug('To : ' + dt);
                                        System.debug('bucketTime : ' + bucketTime);                         
                                        System.debug('Last Status : ' + lastStatus);
                                        //System.debug(i + ' Bucket is ' + mapCSM.get(lastStatus).Solution_Time__c);
                                        System.debug(i + ' Bucket is ' + PSPHelper.getCSM(mapCSM,lastStatus).Solution_Time__c);
                                        
                                        //if(mapCSM.get(lastStatus).Solution_Time__c == 'Misys')
                                        if(PSPHelper.getCSM(mapCSM,lastStatus).Solution_Time__c == 'Misys')
                                        {
                                            misysTime += bucketTime;    
                                            //misysResolutionTime += bucketTime;
                                            misysSolutionTime += bucketTime;    
                                                
                                            //if(objCase.Case_Category__c == 'Support Request')
                                            if(caseCategory == 'Support Request' || caseCategory == 'Incident')
                                            {
                                                //misysSolutionTime += bucketTime;
                                                misysResolutionTime += bucketTime;
                                            }
        
                                            //if(mapCSM.get(lastStatus).Time_Bucket__c == 'L1')
                                            if(PSPHelper.getCSM(mapCSM,lastStatus).Time_Bucket__c == 'L1')
                                            {
                                                timeInL1 += bucketTime;
                                            }
                                            //else if(mapCSM.get(lastStatus).Time_Bucket__c == 'L2')
                                            else if(PSPHelper.getCSM(mapCSM,lastStatus).Time_Bucket__c == 'L2')
                                            {                                               
                                                timeInL2 += bucketTime;
                                                System.debug('NNNNNNNNNNNNNNNNNNNNNNNNNNNNNN1'+timeInL2);
                                            }
                                            //else if(mapCSM.get(lastStatus).Time_Bucket__c == 'L3')
                                            else if(PSPHelper.getCSM(mapCSM,lastStatus).Time_Bucket__c == 'L3')
                                            {
                                                timeInL3 += bucketTime;
                                            }
                                        }
                                        //else if(mapCSM.get(lastStatus).Solution_Time__c == 'Customer')
                                        else if(PSPHelper.getCSM(mapCSM,lastStatus).Solution_Time__c == 'Customer')
                                        {
                                            customerTime += bucketTime;
                                            // new reporting requirements to break down Time With Customer
                                            if (lastStatus.startsWith('Awaiting Client')) timeAwaitingCustomer += bucketTime;
                                            if (lastStatus.startsWith('Solution Provided')) timeAwaitingCustomerAcceptance += bucketTime;
                                        }
                                    }
                                    /*else if(mapCSM.get(lastStatus).SFDC_Closed_Flag__c == true)
                                    {
                                        closedTime += bucketTime;
                                    }*/
                                }
                            }
                                
                            System.debug('misysTime : ' + misysTime);
                            System.debug('customerTime : ' + customerTime);
                        }
                        else
                        {
                            bNoHistory = true;                            
                        }
                    //}
                }
                else
                {
                    bNoHistory = true;              
                }
                
                if(bNoHistory == true && caseBusinessHour != null)
                {
                    System.debug('no history');
                    System.debug('objCase.Status : ' + objCase.Status);
                    system.debug('TimeCalculator.CalculateSolutionTime - objCase.MetricsStatus__c : ' + objCase.MetricsStatus__c);
                    
                    // no status found
                    Long l = BusinessHours.diff(caseBusinessHour, objCase.CreatedDate, DateTime.Now());
                    //l = (l/1000)/60;
                    l = (l/1000);
                    System.debug('l : ' + l);
                    TotalCaseHistoryTime += l;                        
                    //if(mapCSM.get(objCase.Status).Solution_Time__c == 'Misys')
                    //if(mapCSM.get(objCase.MetricsStatus__c).Solution_Time__c == 'Misys')
                    String statusSolutionTime = PSPHelper.getCSM(mapCSM,objCase.MetricsStatus__c).Solution_Time__c;
                    system.debug('csm1');
                    if(statusSolutionTime == 'Misys')
                    {
                        misysTime += l; 
                        //misysResolutionTime += l;
                        misysSolutionTime += l;
                        
                        //if(objCase.Case_Category__c == 'Support Request')
                        if(caseCategory == 'Support Request' || caseCategory == 'Incident')
                        {
                            //misysSolutionTime += l;   
                            misysResolutionTime += l;
                        }
                        
                        //if(mapCSM.get(objCase.Status).Time_Bucket__c == 'L1')
                        if(PSPHelper.getCSM(mapCSM,objCase.MetricsStatus__c).Time_Bucket__c == 'L1')
                        {
                            timeInL1 += l;
                        }
                        //else if(mapCSM.get(objCase.Status).Time_Bucket__c == 'L2')
                        else if(PSPHelper.getCSM(mapCSM,objCase.MetricsStatus__c).Time_Bucket__c == 'L2')
                        {
                            timeInL2 += l;
                        }
                        //else if(mapCSM.get(objCase.Status).Time_Bucket__c == 'L3')
                        else if(PSPHelper.getCSM(mapCSM,objCase.MetricsStatus__c).Time_Bucket__c == 'L3')
                        {
                            timeInL3 += l;
                        }
						system.debug('csm2');                        
                    }
                    //else if(mapCSM.get(objCase.Status).Solution_Time__c == 'Customer')
                    else if(statusSolutionTime == 'Customer')
                    {
                        customerTime += l;
                        // new reporting requirements to break down Time With Customer
                        if (objCase.MetricsStatus__c.startsWith('Awaiting Client')) timeAwaitingCustomer += bucketTime;
                        if (objCase.MetricsStatus__c.startsWith('Solution Provided')) timeAwaitingCustomerAcceptance += bucketTime;
                    }
                    system.debug('csm3');
                }                
                
                System.debug('objTime : '+ objTime);
                System.debug('timeInL1 : '+timeInL1);
                System.debug('timeInL2 : '+timeInL2);
                System.debug('timeInL3 : '+timeInL3);
                System.debug('misysSolutionTime : '+misysSolutionTime);
                System.debug('misysResolutionTime : '+misysResolutionTime);
                System.debug('customerTime : '+customerTime);
                System.debug('closedTime : '+closedTime);
                //System.debug('elapsedTime : '+(misysSolutionTime + customerTime - closedTime));
                
                // Change made for new Business Hours
                    //elapsedTime = BusinessHours.diff(caseBH.Id, objCase.CreatedDate, DateTime.now());
                    //elapsedTime = elapsedTime/1000;
                    //elapsedTime = elapsedTime - closedTime;
                elapsedTime = TotalCaseHistoryTime - closedTime;
                System.debug('elapsedTime : '+ elapsedTime);
                
                
                //objTime.Misys_Solution_Time__c = misysTime;
                
                // only update the Solution time in case some value is calculated
                // If condition is placed here because if a case is created in office hours and later changed to
                // a out of office hours then the existing values should not replaced with zero.
                //if(!(misysSolutionTime == 0 && (objTime.Misys_Solution_Time__c != null)))
                    objTime.Misys_Solution_Time__c = misysSolutionTime;
                //if(!(misysResolutionTime == 0 && (objTime.Misys_Resolution_Time__c != null)))
                    objTime.Misys_Resolution_Time__c = misysResolutionTime;
                //if(!(customerTime == 0 && (objTime.Customer_Case_Time__c != null)))
                    objTime.Customer_Case_Time__c = customerTime;
                	// new reporting requirements to break down Time With Customer
					objTime.Time_Awaiting_Customer__c = timeAwaitingCustomer;
					objTime.Time_Awaiting_Customer_Acceptance__c = timeAwaitingCustomerAcceptance;
                //if(!(closedTime == 0 && (objTime.Case_at_Closed_Status_Time__c != null)))
                    objTime.Case_at_Closed_Status_Time__c  = closedTime;
                //if(!(elapsedTime == 0 && (objTime.Elapsed_Time__c != null)))
                    objTime.Elapsed_Time__c = elapsedTime;
                //if(!(timeInL1 == 0 && (objTime.Time_in_L1__c != null)))
                    objTime.Time_in_L1__c = timeInL1;
                //if(!(timeInL2 == 0 && (objTime.Time_in_L2__c != null)))
                    objTime.Time_in_L2__c = timeInL2;
                //if(!(timeInL3 == 0 && (objTime.Time_in_L3__c != null)))
                    objTime.Time_in_L3__c = timeInL3;
                //if(objCase.Priority != objCase.Original_Priority__c && objTime.Original_Priority_Resolution_Time__c == null)
                //    objTime.Original_Priority_Resolution_Time__c = misysResolutionTime;
                if(casePriority != caseOriginalPriority && objTime.Original_Priority_Resolution_Time__c == null)
                    objTime.Original_Priority_Resolution_Time__c = misysResolutionTime;
                
                // Calculate the Workaround Time.
                calculateWorkaroundTime(objCase, objTime, mapCaseIdCaseHistory,mapCSM, globalBH, caseBH,timeInWorkaround);
                // Calculate the Original Workaround Fields
                if(objTime.Original_Workaround_Time_Stamp__c != null && objTime.Original_Priority_Time_To_Workaround__c == null && objCase.Original_Business_Hours_in_Use__c != null)
                {
                    Long OriginalTimeWorkaround = BusinessHours.diff(objCase.Original_Business_Hours_in_Use__r.Business_Hours__c, objCase.CreatedDate, objTime.Original_Workaround_Time_Stamp__c);
                    OriginalTimeWorkaround = (OriginalTimeWorkaround / 1000);
                    OriginalTimeWorkaround = OriginalTimeWorkaround - originalTimeInWorkaround;
                    objTime.Original_Priority_Time_To_Workaround__c = OriginalTimeWorkaround;
                }
                else
                    objTime.Original_Priority_Time_To_Workaround__c =  null;
            }
    }
    
    private static void calculateResponseTime(Case uniqueCase, Time_Object__c uniqueTimeObjects, Map<ID,List<CaseHistory>> mapCaseIdCaseHistory, Map<String,Case_Status_Mapping__c> mapCSM, BusinessHours globalBH, BusinessHours caseBH)
    {
        if(uniqueTimeObjects != null && uniqueTimeObjects.PSP2_Date_Time_Responded__c != null && uniqueTimeObjects.Response_Time__c == null)
        {
            List<CaseHistory> lstCH = new List<CaseHistory>();
            if(!mapCaseIdCaseHistory.isEmpty() && mapCaseIdCaseHistory.containsKey(uniqueCase.Id))
            {
                DateTime priviousDateTime,PriviousRDateTime;
                Long lBucketTimes = 0,lBucketTimesPriv = 0;
                String NewBH = null,priviousBH = null;
                
                lstCH = mapCaseIdCaseHistory.get(uniqueCase.Id);
                priviousDateTime = uniqueCase.CreatedDate;
                PriviousRDateTime = uniqueCase.CreatedDate;
                if(uniqueCase.Original_Business_Hours_in_Use__c != null && uniqueCase.Original_Business_Hours_in_Use__r.Business_Hours__c != null)
                    priviousBH = uniqueCase.Original_Business_Hours_in_Use__r.Business_Hours__c;
                else
                    priviousBH = caseBH.Id;
                
                for(CaseHistory ch : lstCH)
                { 
                    if(ch.CreatedDate >= uniqueTimeObjects.PSP2_Date_Time_Responded__c)
                    {
                        break;
                    }
                    else if(ch.Field == 'BusinessHours__c')
                    {   
                        if(ch.OldValue != null) 
                            priviousBH = String.valueOf(ch.OldValue);
                        if(ch.NewValue != null)
                            NewBH = String.valueOf(ch.NewValue);
                        lBucketTimesPriv = lBucketTimes;
                        PriviousRDateTime = priviousDateTime;
                        lBucketTimes += BusinessHours.diff(priviousBH, priviousDateTime, ch.CreatedDate);
                        priviousDateTime = ch.CreatedDate;
                    } 
                }               
                if(uniqueTimeObjects.Response_Time__c == null)
                {
                    if(NewBH != null)
                        lBucketTimes += BusinessHours.diff(NewBH, priviousDateTime, uniqueTimeObjects.PSP2_Date_Time_Responded__c);
                    else if(priviousBH != null)
                        lBucketTimes = BusinessHours.diff(priviousBH, uniqueCase.CreatedDate, uniqueTimeObjects.PSP2_Date_Time_Responded__c);
                    if(lBucketTimes > 0)
                        lBucketTimes = (lBucketTimes / 1000);                             
                    uniqueTimeObjects.Response_Time__c = lBucketTimes;
                }
                if(uniqueTimeObjects.Original_Response_Time__c == null && uniqueTimeObjects.Response_Time__c != null)
                    uniqueTimeObjects.Original_Response_Time__c = uniqueTimeObjects.Response_Time__c;
                
                /*
                //elapsedTime = BusinessHours.diff(caseBH.Id, uniqueCase.CreatedDate, uniqueTimeObjects.get(uniqueCase.Time_Object__c).Date_Time_Responded__c);
                elapsedTime = BusinessHours.diff(caseBH.Id, uniqueCase.CreatedDate, uniqueTimeObjects.get(uniqueCase.Time_Object__c).PSP2_Date_Time_Responded__c);
                System.debug('elapsedTime Responded A : ' + elapsedTime);
                //elapsedTime = (elapsedTime / 1000) / 60;
                elapsedTime = (elapsedTime / 1000);
                System.debug('elapsedTime Responded B : ' + elapsedTime);
                uniqueTimeObjects.get(uniqueCase.Time_Object__c).Response_Time__c = elapsedTime;
                if(uniqueTimeObjects.Original_Response_Time__c == null)
                    uniqueTimeObjects.Original_Response_Time__c = lBucketTimesPriv;*/
            }
        } 
    }
    
    private static void calculateWorkaroundTime(Case uniqueCase, Time_Object__c uniqueTimeObjects, Map<ID,List<CaseHistory>> mapCaseIdCaseHistory, Map<String,Case_Status_Mapping__c> mapCSM, BusinessHours globalBH, BusinessHours caseBH,Long ClosedTime)
    {
        system.debug('Nitin----uniqueCase.Workaround_Time_Stamp__c-->'+uniqueCase.Workaround_Time_Stamp__c);
        if(uniqueTimeObjects != null && uniqueCase.Workaround_Time_Stamp__c != null)
        {
            List<CaseHistory> lstCH = new List<CaseHistory>();
            if(!mapCaseIdCaseHistory.isEmpty() && mapCaseIdCaseHistory.containsKey(uniqueCase.Id))
            {
                DateTime priviousDateTime,PriviousRDateTime;
                Long lBucketTimes = 0,lBucketTimesPriv = 0;
                String NewBH = null,priviousBH = null;
                
                lstCH = mapCaseIdCaseHistory.get(uniqueCase.Id);
                priviousDateTime = uniqueCase.CreatedDate;
                PriviousRDateTime = uniqueCase.CreatedDate;
                if(uniqueCase.Original_Business_Hours_in_Use__c != null && uniqueCase.Original_Business_Hours_in_Use__r.Business_Hours__c != null)
                    priviousBH = uniqueCase.Original_Business_Hours_in_Use__r.Business_Hours__c;
                else
                    priviousBH = caseBH.Id;
                
                for(CaseHistory ch : lstCH)
                { 
                    if(ch.CreatedDate >= uniqueCase.Workaround_Time_Stamp__c)
                    {
                        break;
                    }
                    else if(ch.Field == 'BusinessHours__c')
                    {   
                        if(ch.OldValue != null) 
                            priviousBH = String.valueOf(ch.OldValue);
                        if(ch.NewValue != null)
                            NewBH = String.valueOf(ch.NewValue);
                        lBucketTimesPriv = lBucketTimes;
                        PriviousRDateTime = priviousDateTime;
                        lBucketTimes += BusinessHours.diff(priviousBH, priviousDateTime, ch.CreatedDate);
                        priviousDateTime = ch.CreatedDate;
                    } 
                }
                
                if(NewBH != null)
                    lBucketTimes += BusinessHours.diff(NewBH, priviousDateTime, uniqueCase.Workaround_Time_Stamp__c);
                else if(priviousBH != null)
                    lBucketTimes = BusinessHours.diff(priviousBH, uniqueCase.CreatedDate, uniqueCase.Workaround_Time_Stamp__c);
                if(lBucketTimes > 0)
                    lBucketTimes = ((lBucketTimes - ClosedTime) / 1000);                             
                
                system.debug('Nitin---NewBH-->'+NewBH);
                system.debug('Nitin---lBucketTimes-->'+lBucketTimes);
                system.debug('Nitin---priviousDateTime-->'+priviousDateTime);
                system.debug('Nitin---uniqueCase.Workaround_Time_Stamp__c-->'+uniqueCase.Workaround_Time_Stamp__c);
                system.debug('Nitin---NewBH-->'+NewBH);
                
                uniqueTimeObjects.Time_To_Workaround__c = lBucketTimes;
            }
        } 
    }
    
    public static void CalculateOriginalFields(List<Case> uniqueCases, Map<ID,Time_Object__c> uniqueTimeObjects, Map<ID,SLA__c> mapSLA, Map<String, List<Business_Hours_in_Use__c>> mapAccountSLA_BH, Map<ID,BusinessHours> mapBusinessHours, BusinessHours globalBH, Map<String,Case_Status_Mapping__c> mapCSM, Map<ID,List<CaseHistory>> mapCaseIdCaseHistory)
    {
        for(Case uniqueCase: uniqueCases)
        {
            if(mapSLA != null && !mapSLA.isEmpty() && mapSLA.get(uniqueCase.Original_SLA__c) != null)
            {
                SLA__c caseSLA = mapSLA.get(uniqueCase.Original_SLA__c);
                Long elapsedTime = 0;
                if(caseSLA != null)
                {                   
                   BusinessHours caseBH = mapBusinessHours.get(uniqueCase.Original_Business_Hours_in_Use__r.Business_Hours__c);
                   if(caseBH != null)
                   {                    
                       elapsedTime = BusinessHours.diff(caseBH.Id, uniqueCase.CreatedDate, DateTime.now());
                       elapsedTime = (elapsedTime / 1000);
                       if(uniqueTimeObjects.get(uniqueCase.Time_Object__c).Original_Response_Time__c == null)
                            uniqueTimeObjects.get(uniqueCase.Time_Object__c).Original_Response_Time__c = elapsedTime;
                   }
                }
            }
        }
    }

    //JRB 15-Jul-2011:  Method no longer used anywhere in code.  Code uses CalculateTimesNew method below instead.
    /*
    WebService static void CalculateTimes(List<ID> caseIDs)
    {   
        Map<ID,Case> mapCases = new Map<ID,Case>();
        
        Set<ID> uniqueCaseIDs = new Set<ID>();
        
        for(ID caseID : caseIDs)
		{
            uniqueCaseIDs.add(caseID);
        }

        System.debug('uniqueCaseIDs : ' + uniqueCaseIDs);

        Map<ID,Case> uniqueCases = new Map<ID,Case>([Select c.Process_Me__c, c.AccountId, c.CreatedDate, c.ClosedDate, c.Time_Object__c, c.SLA__c, c.IsClosed, c.Priority, c.Case_Category__c, c.Status, c.Category__c, c.Sub_status__c, c.Business_Hours_in_Use__c, c.Business_Hours_in_Use__r.Business_Hours__c, c.Business_Hours_in_Use__r.Normal_Working_Day_Length__c,c.Original_Priority__c,c.Original_SLA__c,c.Original_Business_Hours_in_Use__c,c.Original_Business_Hours_in_Use__r.Business_Hours__c,Original_Business_Hours_in_Use__r.Normal_Working_Day_Length__c,c.Workaround_Time_Stamp__c from Case c where c.Time_Object__c != null and c.Id in :uniqueCaseIDs]);
        
        System.debug('uniqueCases.size() : ' + uniqueCases.size());
        System.debug('uniqueCases.Values() : ' + uniqueCases.Values());
        
        
        PSPHelper pspHelper = new PSPHelper(uniqueCases.Values());

        //CaseTriggerMethods.SetCaseElapsedTime(uniqueCases.Values(), pspHelper);
        CaseTriggerMethods.SetCaseSolutionTime(uniqueCases, pspHelper);
        CaseTriggerMethods.SetCaseSolutionBreachTime(uniqueCases.Values(), pspHelper);
        CaseTriggerMethods.SetCaseRespondedTime(uniqueCases, pspHelper);
    }
    */
    
    /*
    WebService static void CalculateElapsedTimes(List<ID> caseIDs)
    {
        Map<ID,Case> mapCases = new Map<ID,Case>();
        
        Set<ID> uniqueCaseIDs = new Set<ID>();
        
        for(ID caseID : caseIDs)
        {
            uniqueCaseIDs.add(caseID);
        }

        Map<ID,Case> uniqueCases = new Map<ID,Case>([Select c.Process_Me__c, c.AccountId, c.CreatedDate, c.Time_Object__c, c.SLA__c, c.IsClosed, c.Priority, c.Case_Category__c, c.Status, c.Category__c, c.Sub_status__c, c.Business_Hours_in_Use__c, c.Business_Hours_in_Use__r.Business_Hours__c, c.Business_Hours_in_Use__r.Normal_Working_Day_Length__c from Case c where c.Time_Object__c != null and c.Id in :uniqueCaseIDs]);
        
        PSPHelper pspHelper = new PSPHelper(uniqueCases.Values());
        System.debug('pspHelper.getMapCaseIdCaseHistory() : ' + pspHelper.getMapCaseIdCaseHistory());

        CaseTriggerMethods.SetCaseElapsedTime(uniqueCases.Values(), pspHelper);
        CaseTriggerMethods.SetCaseSolutionTime(uniqueCases, pspHelper);
        CaseTriggerMethods.SetCaseSolutionBreachTime(uniqueCases.Values(), pspHelper);
        CaseTriggerMethods.SetCaseRespondedTime(uniqueCases, pspHelper);
        
    }
    */
    
}