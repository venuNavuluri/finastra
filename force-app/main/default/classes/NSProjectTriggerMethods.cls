/*
    Created By: Abhinit Kohar
    Created Date: 11/03/2014
    Description: This class holds the support methods for NSProjectTrigger trigger.
*/
public class NSProjectTriggerMethods{

    private static final String Open_Air_Project_Stage = 'OpenAirProjectStage';
    private static final String SFDC_Opp_Forecast_Category = 'SFDCOppForecastCategory';
    private static final String Open_Air_Project_Template = 'OpenAirProjectTemplate';
    private static final String Project_Category = 'ProjectCategory';
    private static final String Project_Status = 'ProjectStatus';
    private static final String PS_Practice_Name = 'PSPracticeName';

    public static void populateInternalIds(list<NS_Project__c> nsProjectsList, map<Id, NS_Project__c> newMap, map<Id, NS_Project__c> oldMap){
        //populate Country Risk Rating and customer risk rating map for getting the internal ids
        map<string, string> listTableMap = new map<string, string>();
        for(NS_List_Table__c listTable : [
                select id, name, NS_Internal_Id__c, NS_List_Name__c
                from NS_List_Table__c
                where NS_List_Name__c = :Open_Air_Project_Stage or
                NS_List_Name__c = :SFDC_Opp_Forecast_Category or NS_List_Name__c = :Open_Air_Project_Template or
                NS_List_Name__c = :Project_Category or NS_List_Name__c = :Project_Status or NS_List_Name__c = :PS_Practice_Name
        ]){

            if(listTable.NS_List_Name__c == Open_Air_Project_Stage){
                listTableMap.put(listTable.name + Open_Air_Project_Stage, listTable.NS_Internal_Id__c);
            } else if(listTable.NS_List_Name__c == SFDC_Opp_Forecast_Category){
                listTableMap.put(listTable.name + SFDC_Opp_Forecast_Category, listTable.NS_Internal_Id__c);
            } else if(listTable.NS_List_Name__c == Open_Air_Project_Template){
                listTableMap.put(listTable.name + Open_Air_Project_Template, listTable.NS_Internal_Id__c);
            } else if(listTable.NS_List_Name__c == Project_Category){
                listTableMap.put(listTable.name + Project_Category, listTable.NS_Internal_Id__c);
            } else if(listTable.NS_List_Name__c == Project_Status){
                listTableMap.put(listTable.name + Project_Status, listTable.NS_Internal_Id__c);
            } else if(listTable.NS_List_Name__c == PS_Practice_Name){
                listTableMap.put(listTable.name + PS_Practice_Name, listTable.NS_Internal_Id__c);
            }
        }

        for(NS_Project__c project : nsProjectsList){

            if(trigger.isBefore && trigger.isInsert){
                project.Synced_To_NS__c = false;
            }
            if(project.Customer__c != null){
                project.Subsidiary__c = project.Subsidiary_Text__c;
            }
            if(project.OpenAir_Project_Stage__c != null && listTableMap.containsKey(project.OpenAir_Project_Stage__c + Open_Air_Project_Stage)){
                project.OpenAir_Project_Stage_Internal_Id__c = listTableMap.get(project.OpenAir_Project_Stage__c + Open_Air_Project_Stage);
            } else{
                project.OpenAir_Project_Stage_Internal_Id__c = null;
            }
            if(project.SFDC_Opportunity_Category__c != null && listTableMap.containsKey(project.SFDC_Opportunity_Category__c + SFDC_Opp_Forecast_Category)){
                project.SFDC_Opportunity_Category_Internal_Id__c = listTableMap.get(project.SFDC_Opportunity_Category__c + SFDC_Opp_Forecast_Category);
            } else{
                project.SFDC_Opportunity_Category_Internal_Id__c = null;
            }
            if(project.OA_Project_Template__c != null && listTableMap.containsKey(project.OA_Project_Template__c + Open_Air_Project_Template)){
                project.OA_Project_Template_Internal_Id__c = listTableMap.get(project.OA_Project_Template__c + Open_Air_Project_Template);
            } else{
                project.OA_Project_Template_Internal_Id__c = null;
            }
            if(project.Project_Category__c != null && listTableMap.containsKey(project.Project_Category__c + Project_Category)){
                project.Project_Category_Internal_Id__c = listTableMap.get(project.Project_Category__c + Project_Category);
            } else{
                project.Project_Category_Internal_Id__c = null;
            }
            if(project.NS_Project_Status__c != null && listTableMap.containsKey(project.NS_Project_Status__c + Project_Status)){
                project.Project_Status_Internal_Id__c = listTableMap.get(project.NS_Project_Status__c + Project_Status);
            } else{
                project.Project_Status_Internal_Id__c = null;
            }
            if(project.PS_Practice_Name__c != null && listTableMap.containsKey(project.PS_Practice_Name__c + PS_Practice_Name)){
                project.PS_Practice_Name_Internal_Id__c = listTableMap.get(project.PS_Practice_Name__c + PS_Practice_Name);
            } else{
                project.PS_Practice_Name_Internal_Id__c = null;
            }
            if(trigger.isUpdate && trigger.isBefore){
                checkForUpdates(project, newMap, oldMap);
            }
        }
    }
    public static void notifyPipelineProjectCreation(list<NS_Project__c> nsProjectsList){
        List<NS_Project__c> pipelineProjects = new List<NS_Project__c>();
        for(NS_Project__c nsProj:nsProjectsList) {
            if(OppPipelineUtil.PIPELINE_DEFFERED_NAME==nsProj.Deferred_Account_Type__c) {
                pipelineProjects.add(nsProj);
            }
        }


        if(!pipelineProjects.isEmpty()) {
            for(NS_Project__c pipelineProject: pipelineProjects ) {
                OppPipelineUtil.sendEmail(OppPipelineUtil.GS_MAIL_BOX,pipelineProject.ID,OppPipelineUtil.PIPELINE_PROJECT_CREATED_TEMPLATE);
            }
        }

    }
    //populate NS Project if the project is created from opportunity
    public static void populateNSProjectFromOpportunity(list<NS_Project__c> nsProjectsList){

        Set<ID> optyId = new Set<ID>();
        Set<ID> acctId = new Set<ID>();
        for(NS_Project__c nsProj : nsProjectsList /*Trigger.new*/){
            if(nsProj.Trickle_Opportunity_Data__c == true){
                if(nsProj.Opportunity__c != null)
                    optyId.add(nsProj.Opportunity__c);
            }
        }
        Map<ID, Opportunity> optyMap = new Map<ID, Opportunity>([
                select    id
                        , PS_Cost_Centre__c
                        , Order_Number__c
                        , CurrencyIsoCode
                        , StageName
                        , AccountId
                        , War_project_approval_status__c
                        , CloseDate
                        , ForecastCategoryName
                        , Probability
                        , PS_Top_Opportunity__c
                        , PS_Forecast_Probability__c
                        , OA_Project_Manager__c
                        , Service_Sub_Type__c
                        , Service_Type__c
                        , OA_Project_Director__c
                        , PS_FC_Start_Date2__c
                        , Project_Template__c
                        , PS_Practice_Name__c
                        , PS_Practice_Unique_Code__c
                        , NS_Project_Service_Type__c
                        , GTM_Next_Action_Owner__c
                        , MainProduct__c
                        , OwnerId
                        , Original_Opportunity_Number__c
                        , Entity__c
                from Opportunity
                where id in :optyId
        ]);

        for(Opportunity opp : optyMap.values()){
            acctId.add(opp.AccountId);
        }
        Id gscCostCentreId;
        try{
            gscCostCentreId = [select id from NS_Cost_Centre__c where name = 'A510 SFO - GSC' and Is_Inactive__c = false limit 1].Id;
        }catch(Exception e){
            gscCostCentreId = 'a3620000000GwNLAA0';
        }

        Map<ID, Account> accountMap = new Map<ID, Account>([select id,name, NS_Finance_Region__c,NS_Currency__c from Account where id in :acctId]);

        for(NS_Project__c nsProj : nsProjectsList /*Trigger.new*/){
            if(nsProj.Trickle_Opportunity_Data__c == true){

                if(optyMap.get(nsProj.Opportunity__c) != null){


                    Opportunity opportunity = optyMap.get(nsProj.Opportunity__c);
                    if(nsProj.Deferred_Account_Type__c == 'PS'){

                        if(optyMap.get(nsProj.Opportunity__c).War_project_approval_status__c > 0){ // At least one WAR project should be approved

                            // nsProj.Project_Cost_Centre__c = optyMap.get(nsProj.Opportunity__c).PS_Cost_Centre__c;

                            nsProj.Opportunity_Number__c = opportunity.Order_Number__c;
                            nsProj.CurrencyIsoCode = opportunity.CurrencyIsoCode;
                            nsProj.Project_Type__c = 'PS';

                            nsProj.Project_Name__c = opportunity.Order_Number__c + ' -PS';


                            if(accountMap.get(opportunity.AccountId) != null){
                                Account acc = accountMap.get(opportunity.AccountId);
                                nsProj.Project_Region__c = acc.NS_Finance_Region__c;
                                nsProj.NS_Primary_Currency__c = acc.NS_Currency__c;
                            }

                            // project.Subsidiary__c = acctBySub.Misys_Entity__c;
                            nsProj.SFDC_Opportunity_Stage__c = opportunity.StageName;
                            nsProj.SFDC_Opportunity_Close_date__c = opportunity.CloseDate;
                            nsProj.SFDC_Opportunity_Category__c = opportunity.ForecastCategoryName;
                            nsProj.SFDC_Opportunity_Probability__c = opportunity.Probability;
                            nsProj.PS_Top_Opportunity__c = opportunity.PS_Top_Opportunity__c;
                            nsProj.PS_Forecast_Probability__c = opportunity.PS_Forecast_Probability__c;
                            nsProj.OpenAir_Project_Stage__c = 'Pending - PM';
                            //   nsProj.Customer__c = acctBySub.Id;
                            //   project.Deferred_Account_Type__c = psType;
                            //  nsProj.Export_to_OpenAir__c = true;
                            nsProj.Project_Owner__c = UserInfo.getUserId() ; // opportunity.OA_Project_Manager__c;
                            nsProj.Project_Director__c = opportunity.OA_Project_Director__c;

                            nsProj.Project_Start_Date__c = opportunity.PS_FC_Start_Date2__c;
                            nsProj.OA_Project_Template__c = opportunity.Project_Template__c;
                            nsProj.NS_Project_Status__c = 'In Progress';
                            nsProj.PS_Practice_Name__c = opportunity.PS_Practice_Name__c;
                            nsProj.PS_Practice_Unique_Code__c = opportunity.PS_Practice_Unique_Code__c;
                            nsProj.NS_Project_Service_Type__c = opportunity.NS_Project_Service_Type__c;

                            //do we need to add the two below to GSC?
                            nsProj.NS_Deferred_Revenue_Account_Internal_Id__c = '1256';
                            nsProj.OpenAir_Project_Stage_Internal_Id__c = '3';
                            if(opportunity.PS_Cost_Centre__c != null){
                                nsProj.Project_Cost_Centre__c = opportunity.PS_Cost_Centre__c;
                            }

                            /*
                              if(opportunity.PS_Cost_Centre__c != null){
                                  project.Project_Cost_Centre__c = opportunity.PS_Cost_Centre__c;
                              } else if(ccMap.containsKey(psType)){
                                  project.Project_Cost_Centre__c = ccMap.get(psType).Id;
                              }
                             */
                        }// End War_project_approval_status__c

                        else{
                            nsProj.addError('No WAR project approved for this opportunity');
                        }
                    }

                    // Mapping for GSC - kept it as changes will be easier to make if PS and GSC are kept seperate
                    else if(nsProj.Deferred_Account_Type__c == 'GSC'){
                        if(accountMap.get(opportunity.AccountId) != null){
                            Account acc = accountMap.get(opportunity.AccountId);
                            nsProj.Project_Name__c = opportunity.Order_Number__c + '-' + acc.name + '-' + opportunity.MainProduct__c;
                            nsProj.Customer_Form_Id__c = '57';
                            nsProj.NS_Primary_Currency__c = acc.NS_Currency__c;
                            nsProj.Project_Region__c = acc.NS_Finance_Region__c;
                        }
                        //GSC
                        nsProj.Opportunity_Number__c = opportunity.Order_Number__c;
                        nsProj.CurrencyIsoCode = opportunity.CurrencyIsoCode;
                        nsProj.Project_Type__c = 'GSC';
                        nsProj.Project_Owner__c = opportunity.GTM_Next_Action_Owner__c;
                        nsProj.Project_Director__c = opportunity.GTM_Next_Action_Owner__c;
                        nsProj.GSC_Project_Manager__c = opportunity.GTM_Next_Action_Owner__c;
                        nsProj.OA_Project_Template__c = 'GSC - Opportunity Pursuit - TEMPLATE'; //opportunity.Project_Template__c;
                        nsProj.SFDC_Opportunity_Stage__c = opportunity.StageName;
                        nsProj.OA_Project_Template_Internal_Id__c = '12';
                        nsProj.SFDC_Opportunity_Category__c = opportunity.ForecastCategoryName;
                        nsProj.SFDC_Opportunity_Probability__c = opportunity.Probability;
                        nsProj.OpenAir_Project_Stage__c = 'Presales';
                        nsProj.Project_Cost_Centre__c = gscCostCentreId; //A510 Sales En-BSG

                        // nsProj.Project_Cost_Centre_Internal_Id__c = 73;
                        if(opportunity.Service_Type__c != null && opportunity.Service_Sub_Type__c != null)
                            nsProj.NS_Project_Service_Type__c = opportunity.Service_Type__c + '-' + opportunity.Service_Sub_Type__c; else if(opportunity.Service_Type__c != null)
                            nsProj.NS_Project_Service_Type__c = opportunity.Service_Type__c;

                        /* if(opportunity.PS_Cost_Centre__c != null)
                          {
                              nsProj.Project_Cost_Centre__c = opportunity.PS_Cost_Centre__c;
                           }*/

                    }
                    else if (nsProj.Deferred_Account_Type__c == OppPipelineUtil.PIPELINE_DEFFERED_NAME) {
                            nsProj.Opportunity_Number__c = opportunity.Order_Number__c;
                            nsProj.CurrencyIsoCode = opportunity.CurrencyIsoCode;
                            nsProj.Project_Type__c = OppPipelineUtil.PIPELINE_DEFFERED_NAME;

                            nsProj.Project_Name__c = opportunity.Order_Number__c + ' -' + OppPipelineUtil.PIPELINE_DEFFERED_NAME;


                            if(accountMap.get(opportunity.AccountId) != null){
                                Account acc = accountMap.get(opportunity.AccountId);
                                nsProj.Project_Region__c = acc.NS_Finance_Region__c;
                                nsProj.NS_Primary_Currency__c = acc.NS_Currency__c;
                            }

                            nsProj.SFDC_Opportunity_Stage__c = opportunity.StageName;
                            nsProj.SFDC_Opportunity_Close_date__c = opportunity.CloseDate;
                            nsProj.SFDC_Opportunity_Category__c = opportunity.ForecastCategoryName;
                            nsProj.SFDC_Opportunity_Probability__c = opportunity.Probability;
                            nsProj.PS_Top_Opportunity__c = opportunity.PS_Top_Opportunity__c;
                            nsProj.PS_Forecast_Probability__c = opportunity.PS_Forecast_Probability__c;
                            nsProj.OpenAir_Project_Stage__c = OppPipelineUtil.PIPELINE_DEFFERED_NAME;
                            nsProj.Project_Owner__c = opportunity.OwnerId;//UserInfo.getUserId() ; // opportunity.OA_Project_Manager__c;
                            nsProj.Project_Director__c = opportunity.OA_Project_Director__c;

                            nsProj.Project_Start_Date__c = opportunity.PS_FC_Start_Date2__c;
                            nsProj.OA_Project_Template__c = opportunity.Project_Template__c;
                            nsProj.NS_Project_Status__c = 'In Progress';
                            nsProj.PS_Practice_Name__c = opportunity.PS_Practice_Name__c;
                            nsProj.PS_Practice_Unique_Code__c = opportunity.PS_Practice_Unique_Code__c;
                            if(opportunity.Service_Type__c != null && opportunity.Service_Sub_Type__c != null) {
                                nsProj.NS_Project_Service_Type__c = opportunity.Service_Type__c + '-' + opportunity.Service_Sub_Type__c;
                            } else if(opportunity.Service_Type__c != null) {
                                nsProj.NS_Project_Service_Type__c = opportunity.Service_Type__c;
                            }
                            
                            nsProj.NS_Deferred_Revenue_Account_Internal_Id__c = '1256';
                            nsProj.OpenAir_Project_Stage_Internal_Id__c = '3';
                            if(opportunity.PS_Cost_Centre__c != null){
                                nsProj.Project_Cost_Centre__c = opportunity.PS_Cost_Centre__c;
                            }
                            nsProj.SFDC_Original_Opportunity_Number__c = opportunity.Original_Opportunity_Number__c;
                            nsProj.Subsidiary__c = opportunity.Entity__c;
                            if(nsProj.Customer__c==null) {
                                nsProj.Customer__c.addError('Customer is Mandatory');
                            }
                            if(nsProj.Project_Product__c==null) {
                                nsProj.Project_Product__c.addError('Project Product is Mandatory');
                            }
   
                    }
                }
                nsProj.Trickle_Opportunity_Data__c = false;
            }
        }

    }
    //This method unchecks the Synced to NS falg if any of the field values got updated.
    private static void checkForUpdates(NS_Project__c project, map<Id, NS_Project__c> newMap, map<Id, NS_Project__c> oldMap){
        if(newMap.get(project.Id).Billing_Contact__c != oldMap.get(project.Id).Billing_Contact__c ||
                newMap.get(project.Id).Clarity_Project_Id__c != oldMap.get(project.Id).Clarity_Project_Id__c || newMap.get(project.Id).Customer_Form_Id__c != oldMap.get(project.Id).Customer_Form_Id__c || newMap.get(project.Id).Export_to_OpenAir__c != oldMap.get(project.Id).Export_to_OpenAir__c ||
                newMap.get(project.Id).GSC_Project_Manager__c != oldMap.get(project.Id).GSC_Project_Manager__c ||
                newMap.get(project.Id).NS_Primary_Currency__c != oldMap.get(project.Id).NS_Primary_Currency__c ||
                newMap.get(project.Id).OA_Project_Template__c != oldMap.get(project.Id).OA_Project_Template__c ||
                newMap.get(project.Id).OpenAir_Project_Stage__c != oldMap.get(project.Id).OpenAir_Project_Stage__c ||
                newMap.get(project.Id).Opportunity_Number__c != oldMap.get(project.Id).Opportunity_Number__c ||
                newMap.get(project.Id).Project_Category__c != oldMap.get(project.Id).Project_Category__c ||
                newMap.get(project.Id).Project_Cost_Centre__c != oldMap.get(project.Id).Project_Cost_Centre__c ||
                newMap.get(project.Id).Project_Director__c != oldMap.get(project.Id).Project_Director__c ||
                newMap.get(project.Id).Project_Hierarchy_Node__c != oldMap.get(project.Id).Project_Hierarchy_Node__c ||
                newMap.get(project.Id).Project_Name__c != oldMap.get(project.Id).Project_Name__c ||
                newMap.get(project.Id).Project_Owner__c != oldMap.get(project.Id).Project_Owner__c ||
                newMap.get(project.Id).Project_Product__c != oldMap.get(project.Id).Project_Product__c ||
                newMap.get(project.Id).Project_Region__c != oldMap.get(project.Id).Project_Region__c ||
                newMap.get(project.Id).Project_Start_Date__c != oldMap.get(project.Id).Project_Start_Date__c ||
                newMap.get(project.Id).SFDC_Opportunity_Category__c != oldMap.get(project.Id).SFDC_Opportunity_Category__c || newMap.get(project.Id).SFDC_Opportunity_Close_date__c != oldMap.get(project.Id).SFDC_Opportunity_Close_date__c || newMap.get(project.Id).SFDC_Opportunity_Stage__c != oldMap.get(project.Id).SFDC_Opportunity_Stage__c || newMap.get(project.Id).SFDC_Original_Opportunity_Number__c != oldMap.get(project.Id).SFDC_Original_Opportunity_Number__c || newMap.get(project.Id).Subsidiary__c != oldMap.get(project.Id).Subsidiary__c || newMap.get(project.Id).NS_Project_Status__c != oldMap.get(project.Id).NS_Project_Status__c || newMap.get(project.Id).SFDC_Opportunity_Probability__c != oldMap.get(project.Id).SFDC_Opportunity_Probability__c || newMap.get(project.Id).PS_Top_Opportunity__c != oldMap.get(project.Id).PS_Top_Opportunity__c || newMap.get(project.Id).PS_Forecast_Probability__c != oldMap.get(project.Id).PS_Forecast_Probability__c || newMap.get(project.Id).NS_Project_Status__c != oldMap.get(project.Id).NS_Project_Status__c || newMap.get(project.Id).Customer__c != oldMap.get(project.Id).Customer__c){
            project.Synced_To_NS__c = false;
        }
    }
}