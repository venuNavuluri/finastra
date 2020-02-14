public class IntegrationLog_Opportunity
{

    public static void processWFRLFINFO(List<Integration_Log__c> IntLogWFRLFINFO, Set<Id> idsWFRLFINFO)
    {
        system.debug('IntLogWFRLFINFO = ' + IntLogWFRLFINFO);
        map<Id,Opportunity> oppsToBeUpdated = new map<Id,Opportunity>([select Id, Length_of_RLF_Holiday__c, RLF_Reduction_Amount_GBP__c, EDD_FLAG__c, EDD_Exempt_Flag__c, RPA__c from Opportunity where Id in :idsWFRLFINFO]);
        
        if(oppsToBeUpdated.keySet().size() > 0)
        {
            List<Opportunity> updatedOpps = new List<Opportunity>();
            Opportunity iOpp;
            //map<String,Integration_Log__c> mapRecIdToLog = new map<String,Integration_Log__c>();
            map<Id,List<Integration_Log__c>> mapRecIdToLogList = new map<Id,List<Integration_Log__c>>();
            map<Id,Integration_Log__c> mapRecIdToLatestLog = new map<Id,Integration_Log__c>();
            List<Integration_Log__c> intLogNoUpdates = new List<Integration_Log__c>();
            
            //Loop through list of Integration Logs and find the latest update for each record to process (there could be multiple updates)
            sortUpdateLogs(IntLogWFRLFINFO, oppsToBeUpdated, mapRecIdToLatestLog, intLogNoUpdates);
            system.debug('JRB   mapRecIdToLatestLog: '+mapRecIdToLatestLog);
            system.debug('JRB   intLogNoUpdates: '+intLogNoUpdates);
            
            //get the cost centers and create a map of internal Id and cost centre
            map<string, NS_Cost_Centre__c> costCentreMap = new map<string, NS_Cost_Centre__c>();
            for(NS_Cost_Centre__c costCentre : [select id, NS_Cost_Centre_Internal_Id__c from NS_Cost_Centre__c where Is_Inactive__c = false]){
                costCentreMap.put(costCentre.NS_Cost_Centre_Internal_Id__c, costCentre);
            }
    
            //loop through list and apply the changes from the latest log for the opportunity
            for(Integration_Log__c intLog : mapRecIdToLatestLog.values())
            {
                system.debug('intLog = ' + intLog);
                iOpp = oppsToBeUpdated.get(intLog.SFDC_Id__c);
                
                if(intLog.RecordTypeId != Label.Integration_RecTypeId_PPOPPLINEH){
                    iOpp.Length_of_RLF_Holiday__c = intLog.NumField1__c;
                    iOpp.RLF_Reduction_Amount_GBP__c = intLog.NumField2__c;
                    //AK - 967168 - Add the below for this SRR
                    iOpp.RPA__c = intLog.RPA_Rate__c;
                    iOpp.EDD_Flag__c = intLog.EDD_Flag__c;
                    iOpp.EDD_Exempt_Flag__c = intLog.EDD_Exempt_Flag__c;
                    
                    //AK - Adding the below fields as part of the PPOPLINEH changes
                } else if(intLog.RecordTypeId == Label.Integration_RecTypeId_PPOPPLINEH){
                    
                    iOpp.ILF_Sold_Value__c = intLog.Numfield4__c;
                    iOpp.RLF_Sold_Value__c = intLog.Numfield5__c;
                    iOpp.PS_Sold_Value__c = intLog.Numfield6__c;
                    iOpp.FED_Sold_Value__c = intLog.Numfield7__c;
                    iOpp.FEDRLF_Sold_Value__c = intLog.Numfield8__c;
                    iOpp.PSS_Sold_Value__c = intLog.Numfield9__c;
                    iOpp.RA2_Sold_Value__c = intLog.Numfield10__c;
                    iOpp.RA2RLF_Sold_Value__c = intLog.Numfield11__c;
                    iOpp.INTINC_Sold_Value__c = intLog.Numfield12__c;
                    iOpp.INPROP_Sold_Value__c = intLog.Numfield13__c;
                    iOpp.ILF_Pearl_CO_Value__c = intLog.Numfield14__c;
                    iOpp.RLF_Pearl_CO_Value__c = intLog.Numfield15__c;
                    iOpp.PS_Pearl_CO_Value__c = intLog.Numfield16__c;
                    iOpp.FED_Pearl_CO_Value__c = intLog.Numfield17__c;
                    iOpp.FEDRLF_Pearl_CO_Value__c = intLog.Numfield18__c;
                    iOpp.PSS_Pearl_CO_Value__c = intLog.Numfield19__c;
                    iOpp.RA2_Pearl_CO_Value__c = intLog.Numfield20__c;
                    iOpp.RA2RLF_Pearl_CO_Value__c = intLog.Numfield21__c;
                    iOpp.INTINC_Pearl_CO_Value__c = intLog.Numfield22__c;
                    iOpp.INPROP_Pearl_CO_Value__c = intLog.Numfield23__c;
                    iOpp.ILF_Manual_CO_Value__c = intLog.Numfield24__c;
                    iOpp.RLF_Manual_CO_Value__c = intLog.Numfield25__c;
                    iOpp.PS_Manual_CO_Value__c = intLog.Numfield26__c;
                    iOpp.FED_Manual_CO_Value__c = intLog.Numfield27__c;
                    iOpp.FEDRLF_Manual_CO_Value__c = intLog.Numfield28__c;
                    iOpp.PSS_Manual_CO_Value__c = intLog.Numfield29__c;
                    iOpp.RA2_Manual_CO_Value__c = intLog.Numfield30__c;
                    iOpp.RA2RLF_Manual_CO_Value__c = intLog.Numfield31__c;
                    iOpp.INTINC_Manual_CO_Value__c = intLog.Numfield32__c;
                    iOpp.INPROP_Manual_CO_Value__c = intLog.Numfield33__c;
                    iOpp.RLF_Holiday_CO_Value__c = intLog.Numfield34__c;
                    iOpp.RLF_Holiday_Manual_CO_Value__c = intLog.Numfield35__c;
                    iOpp.ILF_Pearl_Explanation__c = intLog.LongString1__c;
                    iOpp.RLF_Pearl_Explanation__c = intLog.LongString2__c;
                    iOpp.PS_Pearl_Explanation__c = intLog.LongString3__c;
                    iOpp.FED_Pearl_Explanation__c = intLog.LongString4__c;
                    iOpp.FEDRLF_Pearl_Explanation__c = intLog.LongString5__c;
                    iOpp.PSS_Pearl_Explanation__c = intLog.LongString6__c;
                    iOpp.RA2_Pearl_Explanation__c = intLog.LongString7__c;
                    iOpp.RA2RLF_Pearl_Explanation__c = intLog.LongString8__c;
                    iOpp.INTINC_Pearl_Explanation__c = intLog.LongString9__c;
                    iOpp.INPROP_Pearl_Explanation__c = intLog.LongString10__c;
                    iOpp.ILF_Manual_Notes__c = intLog.LongString11__c;
                    iOpp.RLF_Manual_Notes__c = intLog.LongString12__c;
                    iOpp.PS_Manual_Notes__c = intLog.LongString13__c;
                    iOpp.FED_Manual_Notes__c = intLog.LongString14__c;
                    iOpp.FEDRLF_Manual_Notes__c = intLog.LongString15__c;
                    iOpp.PSS_Manual_Notes__c = intLog.LongString16__c;
                    iOpp.RA2_Manual_Notes__c = intLog.LongString17__c;
                    iOpp.RA2RLF_Manual_Notes__c = intLog.LongString18__c;
                    iOpp.INTINC_Manual_Notes__c = intLog.LongString19__c;
                    iOpp.INPROP_Manual_Notes__c = intLog.LongString20__c;
                    iOpp.PFT_Audit_History__c = intLog.LongString21__c;
                    iOpp.Rev_Recognition_Date__c = intLog.DateField1__c;
                    
                     // SD-1444926
                    iOpp.Accretive_RLF_percentage__c = intLog.Numfield38__c;
                    
                    // This field will enable teams to be able to identify opportunities which required processing of third party products without having to search through the underlying opportunity products.
                    if(intLog.NumField37__c != null && intLog.NumField37__c.intValue().format() == '1')
                         {
                         iOpp.Third_Party_Content__c= true;
                         } 
                    else if (intLog.NumField37__c != null && intLog.NumField37__c.intValue().format() == '0')
                        {
                            iOpp.Third_Party_Content__c= false;
                        }
                        
                        
                    if(intLog.NumField2__c != null && intLog.NumField2__c.intValue().format() == '1'){
                        iOpp.Pearl_Identified_issues__c = true;
                    } else {
                        iOpp.Pearl_Identified_issues__c = false;
                    }
                   // iOpp.RPA__c = intLog.NumField3__c;
                   iOpp.Expected_LI_From_Pearl__c = intLog.NumField3__c;
                    iOpp.Pearl_Amount__c = intLog.NumField1__c;
                    //AK-adding fields for the PS Practice
                    iOpp.PS_Practice_Name__c = intLog.GenString4__c;
                    
                    //Marina's requirement 6/Jan/17 - asked for SD number as well
                    iOpp.PS_Practice__c = intLog.GenString4__c;
                    
                    iOpp.PS_Practice_Unique_Code__c = intLog.GenString5__c;
                   
                    //AM - Added this code to hold the rollups, this will depend on if its a big opportunity (..)
                    
                    if(intLog.GenString6__c == 'Yes')
                    iOpp.Rollup_Calculate_Batch_Hold__c = true;
                    else
                    iOpp.Rollup_Calculate_Batch_Hold__c = false;
                    
                    iOpp.Pearl_Opp_Stop_Close__c = intLog.GenString2__c;
                    if(intLog.Numfield36__c != null && costCentreMap != null && costCentreMap.containsKey(intLog.Numfield36__c.intValue().format())){
                        iOpp.PS_Cost_Centre_Internal_Id__c = intLog.Numfield36__c.intValue().format();
                        iOpp.PS_Cost_Centre__c = costCentreMap.get(intLog.Numfield36__c.intValue().format()).Id;
                    }
                }
                
                

                updatedOpps.add(iOpp);
                //mapRecIdToLog.put(intLog.SFDC_Id__c,intLog);
                if(mapRecIdToLogList.keySet().contains(iOpp.Id))
                {
                    mapRecIdToLogList.get(iOpp.Id).add(intLog);
                }else{
                    mapRecIdToLogList.put(iOpp.Id,new List<Integration_Log__c>{intLog});
                }
            }
            system.debug('mapRecIdToLogList:'+mapRecIdToLogList);
            
            //Loop through the list of logs that required no opp update and set the flag as processed
            for(Integration_Log__c i : intLogNoUpdates)
            {
                i.isSuccess__c = true;
                i.Message__c = 'No update made - more recent update submitted in same batch';
            }
            
            //Save the results and update success flag
            try
            {
                Database.SaveResult[] results = Database.update(updatedOpps,false);
                IntegrationLogUtils.updateSaveResults(results,updatedOpps,mapRecIdToLogList);
            }
            catch(Exception e)
            {
                System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
            }
        }
    }
    
    public static void sortUpdateLogs(List<Integration_Log__c> intLog, map<Id,sObject> recsToBeUpdated, map<Id,Integration_Log__c> mapRecIdToLatestLog, List<Integration_Log__c> intLogNoUpdates)
    {
        for(Integration_Log__c thisLog : IntLog)
        {
            //If the Rec referenced by the current Log is in the list of Recs retrieved for update...
            if(recsToBeUpdated.containsKey(thisLog.SFDC_Id__c))
            {
                //If the Rec Id has already been added to the map with a corresponding Log Id
                if(mapRecIdToLatestLog.containsKey(thisLog.SFDC_Id__c))
                {
                    //Check if the Log Id on the current log is greater than the Log Id in the map for the Rec
                    if(thisLog.External_Id__c > mapRecIdToLatestLog.get(thisLog.SFDC_Id__c).External_Id__c)
                    {
                        //If current Log Id is greater, then the data on this log record should processed.  Replace this log Id in the map.
                        intLogNoUpdates.add(mapRecIdToLatestLog.get(thisLog.SFDC_Id__c));
                        mapRecIdToLatestLog.put(thisLog.SFDC_Id__c,thisLog);
                    }else{
                        intLogNoUpdates.add(thisLog);
                    }
                }else{
                    mapRecIdToLatestLog.put(thisLog.SFDC_Id__c,thisLog);
                }
            }
        }
    }
    
}