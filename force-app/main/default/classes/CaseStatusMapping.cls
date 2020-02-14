public class CaseStatusMapping 
{
    public static Map<String,Case_Status_Mapping__c> getCaseStatusMappings()
    {
        Map<String,Case_Status_Mapping__c> mapCaseStatusMappings = new Map<String,Case_Status_Mapping__c>();
        
        List<Case_Status_Mapping__c> lstCSM = [select 
                                                    Time_Bucket__c, 
                                                    Status_Code_ID__c, 
                                                    Solution_Time__c, 
                                                    SFDC_IsActive__c, 
                                                    SFDC_Default_Status__c, 
                                                    SFDC_Closed_Flag__c, 
                                                    Resolution_Time_Status__c, 
                                                    PSP_Status_Code__c, 
                                                    Name, 
                                                    Misys_Group__c, 
                                                    L3_Status__c, 
                                                    L2_Status__c, 
                                                    L1_Status__c, 
                                                    IsDeleted, 
                                                    InSupportProcess__c, 
                                                    CaseStatus_LastModifiedDate__c 
                                                From 
                                                    Case_Status_Mapping__c];
                                                    
        System.debug('lstCSM : ' + lstCSM);
                                                    
        if(lstCSM.size() > 0)
        {
            for(Case_Status_Mapping__c csm : lstCSM)
            {
                system.debug('NitinYes----->'+csm.Name);
                mapCaseStatusMappings.put(csm.Name, csm);
            }   
        }                                                   
        
        
        System.debug('mapCaseStatusMappings.get(L2 - Under Analysis) : ' + mapCaseStatusMappings.get('L2 - Under Analysis'));
        //System.debug('mapCaseStatusMappings.get(L2 – Under Analysis).Solution_Time__c : ' + mapCaseStatusMappings.get('L2 – Under Analysis').Solution_Time__c);
        
        
        return mapCaseStatusMappings;
    }
    
}