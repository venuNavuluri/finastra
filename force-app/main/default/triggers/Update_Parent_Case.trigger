trigger Update_Parent_Case on Case (after update) {
    
    map<string,case> case_map = new map<String,Case>();
    
    for(case cs : trigger.new){
        
        system.debug('Old Value111111111111111111 '+trigger.oldMap.get(cs.id).Defect_Total_Reopen_Count__c);
        system.debug('New Value222222222222222222 '+cs.Defect_Total_Reopen_Count__c);
        
        if(trigger.oldMap.get(cs.id).Defect_Total_Reopen_Count__c!= cs.Defect_Total_Reopen_Count__c){
            system.debug('Old Value123456 '+trigger.oldMap.get(cs.id).Defect_Total_Reopen_Count__c);
            system.debug('New Value123456 '+cs.Defect_Total_Reopen_Count__c);
            
            case_map.put(string.valueof(cs.ParentId),cs);
        }
    }
     
    system.debug('@@@@@@@@@@@@@@@@@@@2'+ case_map.size());
    system.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+ case_map);
    list<case> to_update = new List<case>();
    if(case_map.size() > 0){
        for(case cc : [Select id,Case_Re_opened_By__c,Reason_Case_Reopened__c,Customer_Re_open_Count__c,
        PS_Re_open_Count__c,ESG_Re_open_Count__c,CS_Re_open_Count__c,Defect_Reopen_Date__c,NonDefect_Total_Reopen_Count__c,NonDefect_Reopen_Date__c
        from case where id in: case_map.keySet()]){
            case c = case_map.get(cc.id);
              cc.Case_Re_opened_By__c = c.Case_Re_opened_By__c;
             //cc.Re_open_Flag__c = true;
            cc.Reason_Case_Reopened__c =        c.Reason_Case_Reopened__c;
            cc.Customer_Re_open_Count__c =      c.Customer_Re_open_Count__c;
            cc.PS_Re_open_Count__c =            c.PS_Re_open_Count__c;
            cc.ESG_Re_open_Count__c=            c.ESG_Re_open_Count__c;
            cc.CS_Re_open_Count__c=             c.CS_Re_open_Count__c;
            cc.Defect_Reopen_Date__c=           c.Defect_Reopen_Date__c;
            cc.NonDefect_Total_Reopen_Count__c= c.NonDefect_Total_Reopen_Count__c;
            cc.NonDefect_Reopen_Date__c=        c.NonDefect_Reopen_Date__c;
            to_update.add(cc);
        }
        update to_update;
        case_map.clear();
    }
    
}