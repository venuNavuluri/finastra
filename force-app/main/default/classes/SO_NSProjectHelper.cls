/**
 * @File Name          : SO_NSProjectHelper.cls
 * @Description        : 
 * @Author             : venu.navuluri@finastra.com
 * @Group              : 
 * @Last Modified By   : venu.navuluri@finastra.com
 * @Last Modified On   : 22/05/2019, 16:28:07
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 * 
 *==============================================================================
 * 1.0    22/05/2019, 16:28:07   venu.navuluri@finastra.com     Initial Version
**/
public class SO_NSProjectHelper {
    
    public static Map<String, NS_Project__c> createNSProject(Map<String, String> sotype_subId_Map, Map<String, SBQQ__Subscription__c> subs_map, Map<String, NS_Currency__c> nsCurrencyMap, Map<String, NS_Cost_Centre__c> NsCostCentermap, Map<String, String> nsProdMap){
        
        List<NS_Project__c> projectList = new List<NS_Project__c>();
        system.debug('in proj creation => '+sotype_subId_Map);
        boolean ilfCreated = false, psCreated = false;
        
        for(String s: sotype_subId_Map.keySet()){
            if(s.contains('ILF')){
                system.debug('ILF sub =>'+subs_map.get(sotype_subId_Map.get(s)));
                projectList.add(ILFPackage_ListInit.addNSProject(subs_map.get(sotype_subId_Map.get(s)), nsCurrencyMap, NsCostCentermap, nsProdMap, s));
                ilfCreated = true;
            } else if(s.contains('PS')){                
                projectList.add(PSPackage_ListInit.addNSProject(subs_map.get(sotype_subId_Map.get(s)), nsCurrencyMap, NsCostCentermap, nsProdMap, s));                  
                psCreated = true;
            } 
        }
        
        if(projectList.size() > 0){
            try{
                upsert projectList;
            } Catch (Exception Ex){
                system.debug('Error! NS Project creation failed! '+Ex.getMessage());
            }
        }
        
        //system.debug('Project LIst inserted => '+projectList);
        
        Map<String, NS_Project__c> bg_proj_map = new Map<String, NS_Project__c>();//[SELECT Id, Billing_Group__c, Opportunity_Billing_Schedule__c, Deferred_Account_Type__c, Project_Cost_Centre__c, Project_Product__c, NS_Deferred_Revenue_Account_Internal_Id__c FROM NS_Project__c WHERE ID IN: projectList]);
        Map<Id, Id> bsch_nsproj_map = new Map<Id,Id>();
        for(NS_Project__c p: [SELECT Id, Name, Billing_Group__c, Opportunity_Billing_Schedule__c, Deferred_Account_Type__c, Project_Cost_Centre__c, Project_Product__c, NS_Deferred_Revenue_Account_Internal_Id__c, PS_Practice_Name__c, PS_Practice_Unique_Code__c, Project_Type__c FROM NS_Project__c WHERE ID IN: projectList]){             
            bg_proj_map.put(p.Project_Type__c, p);
            bsch_nsproj_map.put(p.Opportunity_Billing_Schedule__c, p.Id);
            system.debug('obs => '+p.Opportunity_Billing_Schedule__c);
        }
        
        // Proj Mileston creation
        NS_Project_Milestone__c projMilestone; List<Id> obsItemIds = new List<Id>();
        
        List<NS_Project_Milestone__c> projMileList = new List<NS_Project_Milestone__c>();
        //for(String s: bg_proj_map.keyset())
        for (Opportunity_Billing_Schedule_Item__c obsItem: [SELECT Id, Name, Opportunity_Billing_Schedule__r.Opportunity__r.Contract_Start_Date__c, Opportunity_Billing_Schedule__r.Opportunity__r.CloseDate, Line_Drop_Dead_Date__c, Line_Estimated_Completion_Date__c,
                                                            Line_Milestone_Sequence__c, Narrative__c, Opportunity_Billing_Schedule__r.Opportunity__r.CurrencyIsoCode
                                                            FROM Opportunity_Billing_Schedule_Item__c WHERE Opportunity_Billing_Schedule__c =: bsch_nsproj_map.keySet()]) {            
                                                                system.debug('proj mileston in loop '+obsItem.Id);
                                                                projMileList.add(ILFPackage_ListInit.addNSProjectMilestone(obsItem, bsch_nsproj_map.get(obsItem.Opportunity_Billing_Schedule__c)));//bg_proj_map.get(s).Id));
                                                                obsItemIds.add(obsItem.Id);
                                                            }
        
        if(projMileList.size() > 0){            
            try{
                insert projMileList;               
            } Catch (Exception Ex){
                system.debug('milestones insertion faile'+ex.getMessage());
                
            }
        }
        
        // creating NS_Customer_Billing_Schedule__c
        List < NS_Customer_Billing_Schedule__c > cbsList = new List < NS_Customer_Billing_Schedule__c > ();
        NS_Customer_Billing_Schedule__c cbs;
        for (NS_Project_Milestone__c projectMilestone: [select id, name, NS_Project__c, Opportunity_Billing_Schedule_Item__c, NS_Project__r.Deferred_Account_Type__c, Opportunity_Billing_Schedule_Item__r.Line_Amount__c, Opportunity_Billing_Schedule_Item__r.Line__c, Opportunity_Billing_Schedule_Item__r.Line_Drop_Dead_Date__c, Opportunity_Billing_Schedule_Item__r.Line_Estimated_Completion_Date__c, Opportunity_Billing_Schedule_Item__r.Line_Milestone_Sequence__c, Opportunity_Billing_Schedule_Item__r.CurrencyIsoCode, Opportunity_Billing_Schedule_Item__r.Opportunity_Billing_Schedule__r.Name, Opportunity_Billing_Schedule_Item__r.Line_Amount_for_Milestone__c, Opportunity_Billing_Schedule_Item__r.Opportunity_Billing_Schedule__r.Opportunity__r.CloseDate from NS_Project_Milestone__c where Opportunity_Billing_Schedule_Item__c in: obsItemIds]) {
            cbsList.add(ILFPackage_ListInit.addNSCustomerBillingSchedule(projectMilestone));
        }
        
        if(cbsList.size() > 0) {            
            try{
                insert cbsList;
            } Catch (Exception Ex){
                system.debug('NS Billing Schedule insertion failed'+ex.getMessage());
            }
        }
        
        return bg_proj_map;
    }
    
    public static Map<String, NS_Project__c> NSProjectCreation(Map<String, String> soType_sub_max, Map<String, SBQQ__Subscription__c> maxSub_map, Map<String, NS_Currency__c> nsCurrencyMap){
      
        List<NS_Project__c> projectList = new List<NS_Project__c>();
        system.debug('in proj creation => '+soType_sub_max);
        boolean ilfProjCreated = false, psProjCreated = false;
        
        for(String s: soType_sub_max.keySet()){
            if(s.contains('ILF')){
                system.debug('ILF sub =>'+maxSub_map.get(soType_sub_max.get(s)));
                projectList.add(ILF_SOCreation.addNSProject(maxSub_map.get(soType_sub_max.get(s)), nsCurrencyMap));
                ilfProjCreated = true;
            } 
            else if(s.contains('GS')){                
                projectList.add(PS_SOCreation.addNSProject(maxSub_map.get(soType_sub_max.get(s)), nsCurrencyMap));                  
                psProjCreated = true;
            } 
            system.debug('NS proj creation size => '+projectList.size());
        }
        
        if(projectList.size() > 0){
            try{
                insert projectList;
                system.debug('project list' +projectList);
                system.debug('project list' +projectList.size());
            } Catch (Exception Ex){
                system.debug('Error! NS Project creation failed! '+Ex.getMessage());
            }
        }
         Map<String, NS_Project__c> ns_proj_map = new Map<String, NS_Project__c>();

          Map<Id, Id> obs_nsproj_map = new Map<Id,Id>();
        for(NS_Project__c p: [SELECT Id, Name, Billing_Group__c, Opportunity_Billing_Schedule__c, Deferred_Account_Type__c, Project_Cost_Centre__c, Project_Product__c,NS_Cost_Centre_Internal_ID__c,NS_Project_Product_Internal_Id__c, NS_Deferred_Revenue_Account_Internal_Id__c, PS_Practice_Name__c, PS_Practice_Unique_Code__c, Project_Type__c FROM NS_Project__c WHERE ID IN: projectList]){             
            ns_proj_map.put(p.Project_Type__c, p);
            obs_nsproj_map.put(p.Opportunity_Billing_Schedule__c, p.Id);
            system.debug('obs => '+p.Opportunity_Billing_Schedule__c);
        }
        
        // Proj Mileston creation
        NS_Project_Milestone__c projMilestone; 
        List<Id> obsItemIds = new List<Id>();
        
        List<NS_Project_Milestone__c> projMileList = new List<NS_Project_Milestone__c>();
        //for(String s: bg_proj_map.keyset())
        for (Opportunity_Billing_Schedule_Item__c obsItem: [SELECT Id, 
                                                                   Name, 
                                                                   Opportunity_Billing_Schedule__r.Opportunity__r.Contract_Start_Date__c, 
                                                            	   Opportunity_Billing_Schedule__r.Opportunity__r.CloseDate, Line_Drop_Dead_Date__c, 
                                                            	   Line_Estimated_Completion_Date__c,
                                                                   Line_Milestone_Sequence__c, Narrative__c, 
                                                            	   Opportunity_Billing_Schedule__r.Opportunity__r.CurrencyIsoCode
                                                            FROM Opportunity_Billing_Schedule_Item__c 
                                                            WHERE Opportunity_Billing_Schedule__c =: obs_nsproj_map.keySet()]) 
         												   {            
                                                                system.debug('proj mileston in loop '+obsItem.Id);
                                                                projMileList.add(ILF_SOCreation.addNSProjectMilestone(obsItem, obs_nsproj_map.get(obsItem.Opportunity_Billing_Schedule__c)));//bg_proj_map.get(s).Id));
                                                                obsItemIds.add(obsItem.Id);
                                                            }
        system.debug('milestone list' +projMileList.size()) ;
        
        if(projMileList.size() > 0){            
            try{
                insert projMileList;               
            } Catch (Exception Ex){
                system.debug('milestones insertion faile'+ex.getMessage());
                
            }
        }
        
        // creating NS_Customer_Billing_Schedule__c
        List < NS_Customer_Billing_Schedule__c > cbsList = new List < NS_Customer_Billing_Schedule__c > ();
        NS_Customer_Billing_Schedule__c cbs;
        for (NS_Project_Milestone__c projectMilestone: [select id, name, NS_Project__c, Opportunity_Billing_Schedule_Item__c, NS_Project__r.Deferred_Account_Type__c, Opportunity_Billing_Schedule_Item__r.Line_Amount__c, Opportunity_Billing_Schedule_Item__r.Line__c, Opportunity_Billing_Schedule_Item__r.Line_Drop_Dead_Date__c, Opportunity_Billing_Schedule_Item__r.Line_Estimated_Completion_Date__c, Opportunity_Billing_Schedule_Item__r.Line_Milestone_Sequence__c, Opportunity_Billing_Schedule_Item__r.CurrencyIsoCode, Opportunity_Billing_Schedule_Item__r.Opportunity_Billing_Schedule__r.Name, Opportunity_Billing_Schedule_Item__r.Line_Amount_for_Milestone__c, Opportunity_Billing_Schedule_Item__r.Opportunity_Billing_Schedule__r.Opportunity__r.CloseDate from NS_Project_Milestone__c where Opportunity_Billing_Schedule_Item__c in: obsItemIds]) {
            cbsList.add(ILF_SOCreation.addNSCustomerBillingSchedule(projectMilestone));
        }
        
        if(cbsList.size() > 0) {            
            try{
                insert cbsList;
            } Catch (Exception Ex){
                system.debug('NS Billing Schedule insertion failed'+ex.getMessage());
            }
        }
         
     return ns_proj_map;
    }
    
}