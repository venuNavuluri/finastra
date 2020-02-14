/*
    Created By: Abhinit Kohar
    Creatd Date: 29/04/2014
    Description: This class implements a Web Service that can be invoked as an Automated Step from s Salesguide.
    The interface supports two operations
        describe : returns service metadata for inclusion as a service step in the guide designer
        invoke : implements the service call at runtime
*/
global class ce4sfStep_CreateILFPackage implements ce4sf20_001.IAeAutomatedStepService {
    
    // keep a static copy of the service description as this will not change     
    private static ce4sf20_001.AeServiceDescription sDescription;
    static {
       sDescription = new ce4sf20_001.AeServiceDescription();
       // namespace for this class
       sDescription.namespaceQualifier = ce4sf20_001.AeServiceDescription.getNamespacePrefixForClass('ce4sfStep_CreateILFPackage');
       // name of this class
       sDescription.name = 'ce4sfStep_CreateILFPackage';
       // service name displayed to users
       sDescription.displayName = 'Create ILF Package';
       // description of service displayed to users
       sDescription.description = 'CreateILFPackage web service that can be called from sales guides';
       
       // add input parameters
       sDescription.addInputParameterDesc('opportunityId', 'id', false);
       sDescription.addInputParameterDesc('acctBySubId', 'id', false);
       sDescription.addInputParameterDesc('contractId', 'id', false);
       sDescription.addInputParameterDesc('billToId', 'id', false);
       sDescription.addInputParameterDesc('shipToId', 'id', false);
       
       // Add output parameters
       sDescription.addOutputParameterDesc('responseBack', 'string');
    }

    // Runtime service invocation    
    global ce4sf20_001.AeServiceResponse invoke(ce4sf20_001.AeServiceRequest aRequest) {
       
       // get a map of name/value pairs from request
       Map<String,Object> params = aRequest.getTypedParameterMap(sDescription.getInputParameterMap());
       // get all parameters as their native Apex types
       Id opportunityId = (Id) params.get('opportunityId');
       Id acctBySubId = (Id) params.get('acctBySubId');
       Id contractId = (Id) params.get('contractId');
       Id billToId = (Id) params.get('billToId');
       Id shipToId = (Id) params.get('shipToId');
       
       // create a response
       ce4sf20_001.AeServiceResponse response = new ce4sf20_001.AeServiceResponse();
       if(opportunityId == null || acctBySubId == null || billToId == null || shipToId == null || contractId == null){
            response.addErrorInfo('Invalid request. Input values are missing in request.'); 
           return response;
       } else {
            //call the createILFPackage();
            boolean flag = false;
            boolean psFlag = false;
            String errMassage;
            System.Savepoint sp1 = Database.setSavepoint();
            try {
                Opportunity opportunity = [select id, name, Order_Number__c, StageName, CloseDate, ForecastCategoryName, Customer_PO__c, 
                                            Order_Type__c, PS_FC_Start_Date2__c, OA_Project_Director__c, OA_Project_Manager__c, OwnerId,
                                            Project_Template__c, CurrencyIsoCode, Probability, PS_Forecast_Probability__c, PS_Top_Opportunity__c,
                                            PS_Practice_Name__c, PS_Practice_Unique_Code__c, PS_Cost_Centre_Internal_Id__c, PS_Cost_Centre__c, NS_Project_Service_Type__c 
                                            from Opportunity where id = :opportunityId];
                Acct_By_Sub__c acctBySub = [select id, name, Misys_Entity__c, Account__r.NS_Finance_Region__c, Account__r.NS_Currency__c, Account__r.NS_Term__c, 
                                             Account__r.PO_Required__c, Invoice_Delivery_Post__c, Invoice_Delivery_Email__c, NS_Export_to_Openair__c,
                                             Account__r.Credit_Controller__c, NS_Invoice_Translation__c, NS_Invoice_Translation_Language__c,
                                             NS_Invoice_Translation_Language_Code__c
                                            from Acct_By_Sub__c where id = :acctBySubId];

                map<string, NS_Cost_Centre__c> ccMap = new map<string, NS_Cost_Centre__c>();
                //Using the internal ids of the cost centres instead of the names, as names can change
                //B110 PS Consulting = 86 - Jaff confirmed with marina that this is not used anymore
                //B210 PS Academy = 82
                //B510 FD FED Product Specific = 39
                //A110 Regional Sales = 61
                //C310 PSS Consulting = 116
                for(NS_Cost_Centre__c cc : [select id, name, NS_Cost_Centre_Internal_Id__c from NS_Cost_Centre__c where NS_Cost_Centre_Internal_Id__c = '82' 
                            or NS_Cost_Centre_Internal_Id__c = '116' or NS_Cost_Centre_Internal_Id__c = '39' or NS_Cost_Centre_Internal_Id__c = '61']){
                    if(cc.NS_Cost_Centre_Internal_Id__c == '61'){
                        ccMap.put('ILF', cc);
                    } else if(cc.NS_Cost_Centre_Internal_Id__c == '82'){
                        ccMap.put('PS', cc);
                        ccMap.put('AC', cc);
                    } else if(cc.NS_Cost_Centre_Internal_Id__c == '116'){
                        ccMap.put('PSS', cc);
                    } else if(cc.NS_Cost_Centre_Internal_Id__c == '39'){
                        ccMap.put('FED', cc);
                    }
                }

                Contract contract = [select id, StartDate, CustomerSignedDate, Sales_Order_Type__c, Memo__c from Contract where Id = :contractId];
                NS_Currency__c nsCurrency = [select id, Name, NS_Currency_Internal_Id__c from NS_Currency__c where Name = :opportunity.CurrencyIsoCode];

                system.debug('opportunity = ' + opportunity);
                system.debug('acctBySub = ' + acctBySub);
                system.debug('ccMap = ' + ccMap);
                system.debug('nsCurrency = ' + nsCurrency);
                system.debug('contract = ' + contract);

                map<String, NS_Account__c> defAccMap = new map<String, NS_Account__c>();
        
                for(NS_Account__c nsAcc : [select id, name from NS_Account__c where Account_Type__c = 'DEFERRED_REVENUE' or Account_Type__c = 'Deferred Revenue']){
                    String acctName = nsAcc.Name;
                    if(acctName.split(' - ').size() >= 2 ){
                        defAccMap.put(acctName.split(' - ')[1], nsAcc);
                    }
                    
                }
                
                if(contract.Sales_Order_Type__c != null){
                    set<String> salesOrderTypeSet = new set<String>();
                    for(String soType : contract.Sales_Order_Type__c.split(';')){
                        salesOrderTypeSet.add(soType);
                    }
                    //AK - taking away the RLF stuff as it is no more needed here, it will be processed in CreateRLFPackage
                    /*
                    if(salesOrderTypeSet != null && (salesOrderTypeSet.contains('ILF-ILF') || salesOrderTypeSet.contains('ILF-Hosting') 
                        || salesOrderTypeSet.contains('ILF-Leasing') || salesOrderTypeSet.contains('ILF-RA')
                        || salesOrderTypeSet.contains('RLF-RLF') || salesOrderTypeSet.contains('RLF-RA')
                        || salesOrderTypeSet.contains('RLF-Leasing') || salesOrderTypeSet.contains('RLF-Hosting'))){
                    */
                    if(salesOrderTypeSet != null && (salesOrderTypeSet.contains('ILF-ILF') || salesOrderTypeSet.contains('ILF-Hosting') 
                        || salesOrderTypeSet.contains('ILF-Leasing') || salesOrderTypeSet.contains('ILF-RA'))){

                        flag = createILFPackage(opportunity, acctBySub, contract, billToId, shipToId, ccMap.get('ILF'), defAccMap, nsCurrency);
                        system.debug('flag = ' + flag);
                    }
                    if(salesOrderTypeSet != null && (salesOrderTypeSet.contains('PS-FED') || salesOrderTypeSet.contains('PS-PS') || salesOrderTypeSet.contains('PS-AC') 
                        || salesOrderTypeSet.contains('PS-PSS'))){

                        psFlag = CreatePSPackage.createPackage(opportunity, acctBySub, contract, billToId, shipToId, ccMap, defAccMap, nsCurrency);
                        system.debug('psFlag = ' + psFlag);
                    }
                } else {
                    response.addParameter('responseBack', 'Please select the Sales Order Type on Contract');
                }

            } catch(Exception ex) {
                system.debug('exception = ' + ex.getStackTraceString());
                system.debug('exception 1 = ' + ex);
                errMassage = ex.getMessage();
                system.debug('errMassage = ' + errMassage);
                flag = false;
                psFlag = false;
                Database.rollback(sp1);
            }
            if(flag == true || psFlag == true){
                response.addParameter('responseBack', 'Package created successfully');
            } else {
                system.debug('errMassage1 = ' + errMassage);
                response.addParameter('responseBack', 'Package could not be created due to some errors - ' + errMassage);
            }
       }
       system.debug('response = ' + response);
       return response;
    }
    
    // Returns service metadata for inclusion in guide designer
    global ce4sf20_001.AeServiceDescription describe() {
       return sDescription;
    }
    
    private boolean createILFPackage(Opportunity opportunity, Acct_By_Sub__c acctBySub, Contract contract, id billToId, id shipToId, NS_Cost_Centre__c costCentre, map<String, NS_Account__c> defAccMap, NS_Currency__c nsCurrency){
        //set for ILF
        set<String> salesOrderTypeSet = new set<String>();
        //set for RLF
        //set<String> salesOrderTypeSetRLF = new set<String>();
        for(String soType : contract.Sales_Order_Type__c.split(';')){
            if(soType.split('-').size() >= 2 && soType.startsWith('ILF')){
                salesOrderTypeSet.add(soType.split('-')[1]);
            //} else if (soType.split('-').size() >= 2 && soType.startsWith('RLF')){
                //salesOrderTypeSetRLF.add(soType.split('-')[1]);
            } else {
                salesOrderTypeSet.add(soType);
            }
        }
        system.debug('salesOrderTypeSet = ' + salesOrderTypeSet);
        //system.debug('salesOrderTypeSetRLF = ' + salesOrderTypeSetRLF);
        set<id> obsIds = new set<id>();
        //map of OBS ids and olis
        map<id, list<OpportunityLineItem>> obsOLIMap = new map<id, list<OpportunityLineItem>>();
        map<id, list<Opportunity_Billing_Schedule_Item__c>> obsOBSIemsMap = new map<id, list<Opportunity_Billing_Schedule_Item__c>>();
        set<id> obsItemIds = new set<id>();
        list<OpportunityLineItem> oliList;
        list<OpportunityLineItem> opportunityLineItemList = new list<OpportunityLineItem>();
        map<id, OpportunityLineItem> updateOLIMap = new map<id, OpportunityLineItem>();
        set<string> nsProductInternalIds = new set<string>();
        set<String> subPlanKeys = new set<String>();
        set<String> thirdPartyCurrencyNames = new set<String>();
        set<string> costCentreIds = new set<string>();
        
        for(OpportunityLineItem oli : [Select Id, OpportunityId, SO_Grouping__c, Opportunity_Billing_Schedule__c, PricebookEntry.Product2.Id, 
                PricebookEntry.Product2.Name, GA__c, Quantity, TotalPrice, Processed__c, UnitPrice, Discount_Premium__c,
                PricebookEntry.Product2.NS_Product_Dimension__c, PricebookEntry.Product2.NS_Product_Dimension_ID__c, Fair_Value__c,
                PricebookEntry.Product2.NS_Create_3PP_Event__c, PricebookEntry.Product2.X3rd_Party_Product__c,
                PricebookEntry.Product2.Payaway__c, PricebookEntry.Product2.NS_3PP_Vendor_ID__c, PricebookEntry.Product2.UPID__c, 
                PricebookEntry.Product2.Vendor_BSch_Trigger__c, Fair_Value_Adjustment__c, Total_Chargeable_Hours__c, Subscription_Plan_Key__c, ThirdParty_Costs_PO_Ccy__c, 
                ThirdParty_Recurring_Costs_PO_Ccy__c, ThirdParty_PO_Currency__c, Licence_Band__c, NS_Deferred_Revenue_Acct_ID__c,
                PricebookEntry.Product2.NS_Cost_Centre_ID__c, License_Metric__c, location__c 
                From OpportunityLineItem where (SO_Grouping__c like 'ILF%') and Processed__c = false and OpportunityId = :opportunity.Id]){
                //From OpportunityLineItem where (SO_Grouping__c like 'ILF%' or SO_Grouping__c like 'RLF%') and Processed__c = false and OpportunityId = :opportunity.Id]){
                
                opportunityLineItemList.add(oli);
                if(oli.Subscription_Plan_Key__c != null){
                    subPlanKeys.add(oli.Subscription_Plan_Key__c);
                }
                if(oli.PricebookEntry.Product2.NS_Product_Dimension_ID__c != null){
                    nsProductInternalIds.add(oli.PricebookEntry.Product2.NS_Product_Dimension_ID__c);   
                }
                if(oli.ThirdParty_PO_Currency__c != null){
                    thirdPartyCurrencyNames.add(oli.ThirdParty_PO_Currency__c);
                }
                obsIds.add(oli.Opportunity_Billing_Schedule__c);
                if(obsOLIMap != null && obsOLIMap.containsKey(oli.Opportunity_Billing_Schedule__c)){
                    oliList = obsOLIMap.get(oli.Opportunity_Billing_Schedule__c);
                    oliList.add(oli);
                } else {
                    oliList = new list<OpportunityLineItem>();
                    oliList.add(oli);
                    obsOLIMap.put(oli.Opportunity_Billing_Schedule__c, oliList);
                }
                if(oli.PricebookEntry.Product2.NS_Cost_Centre_ID__c != null){
                    costCentreIds.add(oli.PricebookEntry.Product2.NS_Cost_Centre_ID__c);
                }
        }
        system.debug('subPlanKeys = ' + subPlanKeys);
        system.debug('obsOLIMap = ' + obsOLIMap);
        system.debug('thirdPartyCurrencyNames = ' + thirdPartyCurrencyNames);
        system.debug('costCentreIds = ' + costCentreIds);
        
        map<String, NS_Currency__c> nsCurrencyMap = new map<String, NS_Currency__c>();
        for(NS_Currency__c nsCurrency1 : [select id, Name, NS_Currency_Internal_Id__c from NS_Currency__c where Name in :thirdPartyCurrencyNames]){
            nsCurrencyMap.put(nsCurrency1.Name, nsCurrency1);
        }
        
        map<string, NS_Cost_Centre__c> costCentreMap = new map<string, NS_Cost_Centre__c>();
        for(NS_Cost_Centre__c costCentreP : [select id, name, NS_Cost_Centre_Internal_Id__c from NS_Cost_Centre__c where NS_Cost_Centre_Internal_Id__c in :costCentreIds]){
            costCentreMap.put(costCentreP.NS_Cost_Centre_Internal_Id__c, costCentreP);
        }
        
        system.debug('costCentreMap = ' + costCentreMap);

        list<Opportunity_Billing_Schedule_Item__c> obsItemList;
        
        for(Opportunity_Billing_Schedule_Item__c item : [select id, Name, Narrative__c, Line_Milestone_Sequence__c, Opportunity_Billing_Schedule__c, Line_Estimated_Completion_Date__c, Line_Drop_Dead_Date__c from Opportunity_Billing_Schedule_Item__c where Opportunity_Billing_Schedule__c in : obsIds]){
                if(obsOBSIemsMap != null && obsOBSIemsMap.containsKey(item.Opportunity_Billing_Schedule__c)){
                    obsItemList = obsOBSIemsMap.get(item.Opportunity_Billing_Schedule__c);
                    obsItemList.add(item);
                } else {
                    obsItemList = new list<Opportunity_Billing_Schedule_Item__c>();
                    obsItemList.add(item);
                    obsOBSIemsMap.put(item.Opportunity_Billing_Schedule__c, obsItemList);
                }
        }
        system.debug('obsOBSIemsMap = ' + obsOBSIemsMap);
        
        map<string, id> nsProdIntIdMap = new map<string, id>();
        
        if(nsProductInternalIds != null && nsProductInternalIds.size() > 0){
            for(NS_Product__c nsProduct : [select id, NS_Product_Internal_Id__c from NS_Product__c where NS_Product_Internal_Id__c in : nsProductInternalIds]){
                nsProdIntIdMap.put(nsProduct.NS_Product_Internal_Id__c, nsProduct.Id);
            }
        }
        system.debug('nsProdIntIdMap = ' + nsProdIntIdMap);
        
        //set<Date> fbDates = new set<Date>();
        map<id, Opportunity_Billing_Schedule__c> obsMap = new map<id, Opportunity_Billing_Schedule__c>([select id, name, Key__c, 
                        Subscription_Start_Type__c, Subscription_Option__c, Fixed_Billing_Date__c, 
                        Planned_Recurring_Billing_Start_Date__c, RLF_Start_Trigger__c
                        //Planned_Recurring_Billing_Start_Date__c, RLF_Start_Trigger__c, RF_Review_Month__c 
                        from Opportunity_Billing_Schedule__c where id in :obsIds]);
                                                                                        
        system.debug('obsMap = ' + obsMap);
        /*
        if(obsMap != null && obsMap.size() > 0){
            for(Opportunity_Billing_Schedule__c oppBS : obsMap.values()){
                if(oppBS.RF_Review_Month__c != null){
                    Integer year = Date.today().year() + 1;
                    string day = '1';
                    Integer month = getIntMonth(oppBS.RF_Review_Month__c);
                    string stringDate = year + '-' + month + '-' + day;
                    fbDates.add(date.valueOf(stringDate));
                }
            }
        }
        */
        
        //get the NS_Fixed_Billing_Date__c and populate the map
        /*
        map<Integer, NS_Fixed_Billing_Date__c> fbdMap = new map<Integer, NS_Fixed_Billing_Date__c>();
        if(fbDates != null && fbDates.size() > 0){
            for(NS_Fixed_Billing_Date__c fbd : [select id, name, NS_Internal_Id__c, Date__c from NS_Fixed_Billing_Date__c where Date__c in : fbDates]){
                fbdMap.put(fbd.Date__c.Month(), fbd);
            }
        }
        system.debug('fbDates = ' + fbDates);
        system.debug('fbdMap = ' + fbdMap);
        */

        map<String, NS_Subscription_Plan__c> subPlanKeySubPlanMap = new map<String, NS_Subscription_Plan__c>();
        set<id> subPlanIds = new set<id>();
        if(subPlanKeys != null && subPlanKeys.size() > 0){
            for(NS_Subscription_Plan__c subPlan : [select id, name, SubPlanKey__c from NS_Subscription_Plan__c where SubPlanKey__c in : subPlanKeys]){
                subPlanKeySubPlanMap.put(subPlan.SubPlanKey__c, subPlan);
                subPlanIds.add(subPlan.Id);
            }
        }
        system.debug('subPlanKeySubPlanMap = ' + subPlanKeySubPlanMap);
        
        map<String, NS_Subscription_Plan_Item__c> subPlanKeySubPlanItemMap = new map<String, NS_Subscription_Plan_Item__c>();
        if(subPlanIds != null && subPlanIds.size() > 0){
            for(NS_Subscription_Plan_Item__c subPlanItem : [select id, name, NS_Subscription_Plan__r.SubPlanKey__c from NS_Subscription_Plan_Item__c where NS_Subscription_Plan__c in : subPlanIds]){
                subPlanKeySubPlanItemMap.put(subPlanItem.NS_Subscription_Plan__r.SubPlanKey__c, subPlanItem);
            }
        }
        system.debug('subPlanKeySubPlanItemMap = ' + subPlanKeySubPlanItemMap);
        
        //Create projects based on the OLI's
        list<NS_Project__c> projList = new list<NS_Project__c>();
        NS_Project__c project;
        set<String> soGroupingSet = new set<String>();
        
        if(opportunityLineItemList != null && opportunityLineItemList.size() > 0){
            for(OpportunityLineItem oppLineItem : opportunityLineItemList){     
                if(!soGroupingSet.contains(oppLineItem.SO_Grouping__c) && oppLineItem.SO_Grouping__c.split('-').size() >= 2 && 
                    salesOrderTypeSet != null && salesOrderTypeSet.contains(oppLineItem.SO_Grouping__c.split('-')[1])){
                        
                    soGroupingSet.add(oppLineItem.SO_Grouping__c);
                    if(obsMap.containsKey(oppLineItem.Opportunity_Billing_Schedule__c)){
                        Opportunity_Billing_Schedule__c obs = obsMap.get(oppLineItem.Opportunity_Billing_Schedule__c);
                        project = new NS_Project__c();
                        project.Project_Name__c = opportunity.Order_Number__c + ' - ' + obs.Name;
                        project.NS_Primary_Currency__c = nsCurrency.Id;
                        project.CurrencyIsoCode = opportunity.CurrencyIsoCode;
                        project.Project_Region__c = acctBySub.Account__r.NS_Finance_Region__c; 
                        project.Subsidiary__c = acctBySub.Misys_Entity__c;
                        project.Opportunity_Number__c = opportunity.Order_Number__c;
                        project.SFDC_Opportunity_Stage__c = opportunity.StageName;
                        project.SFDC_Opportunity_Close_date__c = opportunity.CloseDate;
                        project.SFDC_Opportunity_Category__c = opportunity.ForecastCategoryName;
                        project.SFDC_Opportunity_Probability__c = opportunity.Probability;
                        project.PS_Top_Opportunity__c = opportunity.PS_Top_Opportunity__c;
                        project.PS_Forecast_Probability__c = opportunity.PS_Forecast_Probability__c;
                        project.Project_Type__c = 'ILF';
                        project.OpenAir_Project_Stage__c = 'ILF Only';
                        project.Customer__c = acctBySub.Id;
                        if(oppLineItem.PricebookEntry.Product2.NS_Cost_Centre_ID__c != null && costCentreMap != null && costCentreMap.containsKey(oppLineItem.PricebookEntry.Product2.NS_Cost_Centre_ID__c)){
                            project.Project_Cost_Centre__c = costCentreMap.get(oppLineItem.PricebookEntry.Product2.NS_Cost_Centre_ID__c).Id;
                        } else {
                            project.Project_Cost_Centre__c = costCentre.Id;
                        }
                        project.Opportunity_Billing_Schedule__c = obs.Id;
                        project.NS_Project_Status__c = 'In Progress';
                        project.Project_Start_Date__c = contract.CustomerSignedDate;
                        if(oppLineItem.SO_Grouping__c.split('-').size() >= 2 ){
                            project.Deferred_Account_Type__c = oppLineItem.SO_Grouping__c.split('-')[1];
                        }
                        if(oppLineItem.NS_Deferred_Revenue_Acct_ID__c != null){
                            project.NS_Deferred_Revenue_Account_Internal_Id__c = string.valueof(oppLineItem.NS_Deferred_Revenue_Acct_ID__c);
                        }
                        
                        if(obsOLIMap.containsKey(obs.Id)){
                            Double fairValue = 0.00;
                            String projProdInternalId = null;
                            for(OpportunityLineItem oppLine : obsOLIMap.get(obs.Id)){
                                if(fairValue < oppLine.Fair_Value__c && oppLine.SO_Grouping__c == oppLineItem.SO_Grouping__c){
                                    fairValue = oppLine.Fair_Value__c;
                                    projProdInternalId = oppLine.PricebookEntry.Product2.NS_Product_Dimension_ID__c;
                                    system.debug('projProdInternalId = ' + projProdInternalId);
                                } else if(fairValue == oppLine.Fair_Value__c && oppLine.SO_Grouping__c == oppLineItem.SO_Grouping__c 
                                            && projProdInternalId == null){
                                    projProdInternalId = oppLine.PricebookEntry.Product2.NS_Product_Dimension_ID__c;
                                    system.debug('projProdInternalId for zero value = ' + projProdInternalId);
                                }
                            }
                            if(projProdInternalId != null && nsProdIntIdMap != null && nsProdIntIdMap.containsKey(projProdInternalId)){
                                project.Project_Product__c = nsProdIntIdMap.get(projProdInternalId);
                            }
                        }
                        projList.add(project);
                    }
                }
            }
        }
    
        if(projList != null && projList.size() > 0){
            system.debug('projList = ' + projList);
            insert projList;
        }

        set<Id> projectIds = new set<Id>();
        if(projList != null && projList.size() > 0){
            for(NS_Project__c project1 : projList){
                projectIds.add(project1.Id);
            }
        }

        //Get the recently created projects
        map<id, id> projIdObsIdMap = new map<id, id>();
        
        system.debug('obsIds = ' + obsIds);

        //Create the Project Milestones based on the projects
        list<NS_Project_Milestone__c> projMileList = new list<NS_Project_Milestone__c>();
        NS_Project_Milestone__c projMilestone;
        
        projList = new list<NS_Project__c>();
        for(NS_Project__c nsProject : [select id, Opportunity_Billing_Schedule__c, Project_Product__c, Deferred_Account_Type__c, NS_Deferred_Revenue_Account_Internal_Id__c, Project_Cost_Centre__c 
                                        from NS_Project__c where id in :projectIds]){
            system.debug('nsProject = ' + nsProject);
            projIdObsIdMap.put(nsProject.Id, nsProject.Opportunity_Billing_Schedule__c);
            projList.add(nsProject);
            
            if(obsOBSIemsMap != null && obsOBSIemsMap.containsKey(nsProject.Opportunity_Billing_Schedule__c)){
                for(Opportunity_Billing_Schedule_Item__c obsItem: obsOBSIemsMap.get(nsProject.Opportunity_Billing_Schedule__c)){
                    projMilestone = new NS_Project_Milestone__c();
                    if(obsItem.Narrative__c != null){
                        projMilestone.Name = obsItem.Narrative__c;
                    } else {
                        projMilestone.Name = obsItem.Name;
                    }
                    if(obsItem.Line_Estimated_Completion_Date__c == null){
                        projMilestone.Start_Date__c = opportunity.CloseDate;
                        projMilestone.Finish_No_Later_Than_Date__c = opportunity.CloseDate;
                    } else {
                        projMilestone.Start_Date__c = obsItem.Line_Estimated_Completion_Date__c;
                        projMilestone.Finish_No_Later_Than_Date__c = obsItem.Line_Estimated_Completion_Date__c;
                    }
                    projMilestone.Constraint_Type__c = 'Fixed Start';
                    projMilestone.Status__c = 'In Progress';
                    projMilestone.Drop_Dead_Date__c = obsItem.Line_Drop_Dead_Date__c;
                    projMilestone.Sequence_Number__c = obsItem.Line_Milestone_Sequence__c;
                    projMilestone.Milestone__c = true;
                    projMilestone.Opportunity_Billing_Schedule_Item__c = obsItem.Id;
                    projMilestone.NS_Project__c = nsProject.Id;
                    projMilestone.CurrencyIsoCode = opportunity.CurrencyIsoCode;
                    projMileList.add(projMilestone);
                    obsItemIds.add(obsItem.Id);
                }
            }
        }
        if(projMileList != null && projMileList.size() > 0){
            system.debug('projMileList = ' + projMileList);
            insert projMileList;
        }
        
        //Map for Project and ProjectMilestones
        map<id, list<NS_Project_Milestone__c>> projProjMilestonesMap = new map<id, list<NS_Project_Milestone__c>>();
        list<NS_Project_Milestone__c> projMilestoneList;
        //Create the NS Customer Billing Schedule
        NS_Customer_Billing_Schedule__c cbs;
        list<NS_Customer_Billing_Schedule__c> cbsList = new list<NS_Customer_Billing_Schedule__c>();
        
        for(NS_Project_Milestone__c projectMilestone : [select id, name, NS_Project__c, Opportunity_Billing_Schedule_Item__c,
                                        NS_Project__r.Deferred_Account_Type__c,
                                        Opportunity_Billing_Schedule_Item__r.Line_Amount__c,
                                        Opportunity_Billing_Schedule_Item__r.Line__c, 
                                        Opportunity_Billing_Schedule_Item__r.Line_Drop_Dead_Date__c,
                                        Opportunity_Billing_Schedule_Item__r.Line_Estimated_Completion_Date__c,
                                        Opportunity_Billing_Schedule_Item__r.Line_Milestone_Sequence__c,
                                        Opportunity_Billing_Schedule_Item__r.CurrencyIsoCode,
                                        Opportunity_Billing_Schedule_Item__r.Opportunity_Billing_Schedule__r.Name,
                                        Opportunity_Billing_Schedule_Item__r.Line_Amount_for_Milestone__c 
                                        from NS_Project_Milestone__c where Opportunity_Billing_Schedule_Item__c in : obsItemIds]){
            
            cbs = new NS_Customer_Billing_Schedule__c();
            cbs.Name = projectMilestone.Opportunity_Billing_Schedule_Item__r.Opportunity_Billing_Schedule__r.Name + '-' + projectMilestone.NS_Project__r.Deferred_Account_Type__c;
            cbs.Project__c = projectMilestone.NS_Project__c;
            cbs.Line_Milestone__c = projectMilestone.Id;
            cbs.Line_Amount__c = projectMilestone.Opportunity_Billing_Schedule_Item__r.Line__c;
            cbs.Line_Milestone_Sequence__c = projectMilestone.Opportunity_Billing_Schedule_Item__r.Line_Milestone_Sequence__c;
            cbs.Opportunity_Billing_Schedule_Item__c = projectMilestone.Opportunity_Billing_Schedule_Item__c;
            cbs.CurrencyIsoCode = projectMilestone.Opportunity_Billing_Schedule_Item__r.CurrencyIsoCode;
            if(projectMilestone.Opportunity_Billing_Schedule_Item__r.Line_Estimated_Completion_Date__c == null){
                cbs.Line_Estimated_Completion_Date__c = opportunity.CloseDate;
            } else {
                cbs.Line_Estimated_Completion_Date__c = projectMilestone.Opportunity_Billing_Schedule_Item__r.Line_Estimated_Completion_Date__c;
            }
            
            cbs.Line_Drop_Dead_Date__c = projectMilestone.Opportunity_Billing_Schedule_Item__r.Line_Drop_Dead_Date__c;
            if(projectMilestone.Opportunity_Billing_Schedule_Item__r.Line_Amount_for_Milestone__c != null){
                cbs.Line_Comment__c = projectMilestone.Opportunity_Billing_Schedule_Item__r.CurrencyIsoCode + ' ' + projectMilestone.Opportunity_Billing_Schedule_Item__r.Line_Amount_for_Milestone__c.format();
            }
            
            cbsList.add(cbs);
            
            //populating the projProjMilestoneMap
            if(projProjMilestonesMap.containsKey(projectMilestone.NS_Project__c)){
                projMilestoneList = projProjMilestonesMap.get(projectMilestone.NS_Project__c);
                projMilestoneList.add(projectMilestone);
            } else {
                projMilestoneList = new list<NS_Project_Milestone__c>();
                projMilestoneList.add(projectMilestone);
                projProjMilestonesMap.put(projectMilestone.NS_Project__c, projMilestoneList);
            }
        }
        
        if(cbsList != null && cbsList.size() > 0){
            system.debug('cbsList = ' + cbsList);
            insert cbsList;
        }
        
        
        //Create Sales Orders for ILF
        Sales_Order__c salesOrder;
        list<Sales_Order__c> soList = new list<Sales_Order__c>();
        if(projList != null && projList.size() > 0){
            for(NS_Project__c nsProj : projList){
                salesOrder = new Sales_Order__c();
                salesOrder.NS_Form_Id__c = '126';
                salesOrder.NS_Project__c = nsProj.Id;
                salesOrder.Bill_To_Customer__c = acctBySub.Id;
                salesOrder.Opportunity__c = opportunity.Id;
                salesOrder.CurrencyIsoCode = opportunity.CurrencyIsoCode;
                salesOrder.NS_Cost_Centre__c = nsProj.Project_Cost_Centre__c;
                salesOrder.NS_Product__c = nsProj.Project_Product__c;
                salesOrder.NS_Term__c = acctBySub.Account__r.NS_Term__c;
                salesOrder.SO_Credit_Controller__c = acctBySub.Account__r.Credit_Controller__c;
                //AK commenting it out as the NS Deferred Revenue Account Internal Id is coming from OLI
                //if(defAccMap != null && defAccMap.containsKey(nsProj.Deferred_Account_Type__c)){
                  //  salesOrder.NS_Deferred_Revenue_Reclassification_Acc__c = defAccMap.get(nsProj.Deferred_Account_Type__c).Id;
                //}
                salesOrder.NS_Deferred_Rev_Rec_Acc_Internal_Id__c = nsProj.NS_Deferred_Revenue_Account_Internal_Id__c;
                salesOrder.NS_Currency__c = nsCurrency.Id;
                salesOrder.Contract__c = contract.Id;
                salesOrder.NS_Rev_Rec_on_Commit__c = true;
                salesOrder.NS_AutoCalculate_VSOE_Allocation__c = true;
                salesOrder.Price_Level__c = 'Custom';
                salesOrder.Invoice_Credit_Body__c = 'ILF';
                salesOrder.Order_Status__c = 'Pending Approval';
                salesOrder.Customer_PO_Number__c = opportunity.Customer_PO__c;
                salesOrder.Order_Date__c = opportunity.CloseDate;
                salesOrder.Order_Type__c = 'ILF';
                salesOrder.PO_Required__c = acctBySub.Account__r.PO_Required__c;
                salesOrder.Transaction_is_VSOE_Bundle__c = true;
                salesOrder.Primary_Sales_Person__c = opportunity.OwnerId;
                salesOrder.Contribution__c = 100;
                salesOrder.NS_To_Be_Printed__c = acctBySub.Invoice_Delivery_Post__c;
                salesOrder.NS_To_Be_Emailed__c = acctBySub.Invoice_Delivery_Email__c;
                salesOrder.NS_Billing_Address__c = billToId;
                salesOrder.NS_Shipping_Address__c = shipToId;
                salesOrder.Order_Start_Date__c = contract.StartDate;
                salesOrder.Order_End_Date__c = contract.StartDate;
                salesOrder.NS_Contract_Date__c = contract.CustomerSignedDate;
                salesOrder.Memo__c = contract.Memo__c;
                salesOrder.Order_Sub_Type__c = nsProj.Deferred_Account_Type__c;
                soList.add(salesOrder);
            }
        }
        
        set<id> salesOrderIds = new set<id>();
        if(soList != null && soList.size() > 0){
            system.debug('soList = ' + soList);
            insert soList;
            for(Sales_Order__c so : soList){
                salesOrderIds.add(so.id);
            }
        }
        
        //Get the recently created Sales Orders
        list<Sales_Order__c> salesOrderList = new list<Sales_Order__c>();
        map<id, Sales_Order__c> projIdSalesOrderMap1 = new map<id, Sales_Order__c>();
        //for(Sales_Order__c so : [select id, NS_Project__c, NS_Project__r.Opportunity_Billing_Schedule__c, NS_Project__r.Deferred_Account_Type__c, Order_Date__c, NS_Cash_Accounting__c from Sales_Order__c where NS_Project__c in :projIdObsIdMap.keySet()]){
        for(Sales_Order__c so : [select id, NS_Project__c, NS_Project__r.Opportunity_Billing_Schedule__c, NS_Project__r.Deferred_Account_Type__c, 
                                Order_Date__c, NS_Cash_Accounting__c, Order_Sub_Type__c, OBSId__c, Order_Start_Date__c, NS_Project__r.Name 
                                from Sales_Order__c where id in :salesOrderIds]){
            if(so.NS_Project__c != null){
                projIdSalesOrderMap1.put(so.NS_Project__c, so);
            } else {
                salesOrderList.add(so);
            }                       
        }
        
        //Update the recently created NS_Customer_Billing_Schedule__c with recently created Sales Order
        list<NS_Customer_Billing_Schedule__c> cbsUpdateList = new list<NS_Customer_Billing_Schedule__c>();
        for(NS_Customer_Billing_Schedule__c nsCBS : [select id, Project__c, Sales_Order__c from NS_Customer_Billing_Schedule__c where Project__c in :projIdObsIdMap.keySet()]){
            if(projIdSalesOrderMap1.containsKey(nsCBS.Project__c)){
                nsCBS.Sales_Order__c = projIdSalesOrderMap1.get(nsCBS.Project__c).Id;
                cbsUpdateList.add(nsCBS);
            }
        }
        
        if(cbsUpdateList != null && cbsUpdateList.size() > 0){
            update cbsUpdateList;
        }
        
        system.debug('projIdSalesOrderMap1 = ' + projIdSalesOrderMap1);

        //Create Sales Order Items for ILF
        list<NS_Vendor_Billing_Schedule__c> vbsList = new list<NS_Vendor_Billing_Schedule__c>();
        list<Sales_Order_Item__c> soiList = new list<Sales_Order_Item__c>();
        list<Sales_Order_Item__c> thirdPartySOIList = new list<Sales_Order_Item__c>();
        if(projIdSalesOrderMap1 != null && projIdSalesOrderMap1.size() > 0){
            for(Sales_Order__c salesOrder1 : projIdSalesOrderMap1.values()){
                Id obsId = salesOrder1.NS_Project__r.Opportunity_Billing_Schedule__c;
                system.debug('obsId = ' + obsId);
                system.debug('salesOrder1 = ' + salesOrder1);
                Sales_Order_Item__c soItem;
                Integer i = 1;
                for(OpportunityLineItem oppLineItem : obsOLIMap.get(obsId)){
                    system.debug('oppLineItem.SO_Grouping__c.split = ' + oppLineItem.SO_Grouping__c.split('-')[1]);
                    system.debug('salesOrder1.NS_Project__r.Deferred_Account_Type__c = ' + salesOrder1.NS_Project__r.Deferred_Account_Type__c);
                    if(oppLineItem.SO_Grouping__c.split('-')[1] == salesOrder1.NS_Project__r.Deferred_Account_Type__c){
                        oppLineItem.Processed__c = true;
                        updateOLIMap.put(oppLineItem.Id, oppLineItem);
                        soItem = new Sales_Order_Item__c();
                        soItem.Line__c = i++;
                        soItem.Sales_Order__c = salesOrder1.Id;
                        soItem.Name = oppLineItem.PricebookEntry.Product2.Name;
                        soItem.NS_Item__c = oppLineItem.PricebookEntry.Product2.Id;
                        soItem.Non_GA__c = oppLineItem.GA__c;
                        soItem.Software_Delivered__c = false;
                        soItem.Quantity__c = oppLineItem.Quantity;
                        soItem.Amount__c = oppLineItem.TotalPrice;
                        soItem.Rate__c = oppLineItem.UnitPrice;
                        soItem.Rev_Rec_Start_Date__c = salesOrder1.Order_Date__c;
                        soItem.Rev_Rec_End_Date__c = salesOrder1.Order_Date__c;
                        soItem.VSOE_Price__c = oppLineItem.Fair_Value__c;
                        soItem.VSOE_Allocation_Amount__c = oppLineItem.Fair_Value__c;
                        
                        soItem.Location__c = oppLineItem.Location__c;
                        soItem.License_Metric__c= oppLineItem.License_Metric__c;
                        
                        soItem.CurrencyIsoCode = opportunity.CurrencyIsoCode;
                        soItem.Description__c = oppLineItem.PricebookEntry.Product2.Name;
                        soItem.Discount__c = oppLineItem.Discount_Premium__c;
                        soItem.ThirdParty_Costs_PO_Ccy__c = oppLineItem.ThirdParty_Costs_PO_Ccy__c;
                        soItem.Create_3PP_Event__c = oppLineItem.PricebookEntry.Product2.NS_Create_3PP_Event__c;
                        if(nsCurrencyMap.containsKey(oppLineItem.ThirdParty_PO_Currency__c)){
                            soItem.ThirdParty_PO_Currency__c = nsCurrencyMap.get(oppLineItem.ThirdParty_PO_Currency__c).Id;
                        }
                        //PricebookEntry.Product2.NS_3PP_Vendor_ID__c, PricebookEntry.Product2.UPID__c
                        if(oppLineItem.PricebookEntry.Product2.Payaway__c == true && oppLineItem.PricebookEntry.Product2.NS_Create_3PP_Event__c == true){
                            //check if the vendor id is there on the product. If not, then stop processing and return
                            if(oppLineItem.PricebookEntry.Product2.NS_3PP_Vendor_ID__c == null || oppLineItem.PricebookEntry.Product2.NS_3PP_Vendor_ID__c == ''){
                                throw new CustomException('The third party product '+ oppLineItem.PricebookEntry.Product2.Name + ' do not have the vendor id', 'The third party product '+ oppLineItem.PricebookEntry.Product2.Name + ' do not have the vendor id');
                            }
                            if(oppLineItem.PricebookEntry.Product2.Vendor_BSch_Trigger__c != null){
                                soItem.Vendor_BSch_Trigger__c = oppLineItem.PricebookEntry.Product2.Vendor_BSch_Trigger__c;
                            } else {
                                soItem.Vendor_BSch_Trigger__c = 'On Payment';
                            }
                            string pName = salesOrder1.NS_Project__r.Name;
                            if(pName != null && pName.length() > 63){
                                pName = salesOrder1.NS_Project__r.Name.substring(0, 62);
                            }
                            string vbsName = pName + oppLineItem.PricebookEntry.Product2.NS_3PP_Vendor_ID__c + oppLineItem.PricebookEntry.Product2.UPID__c;
                            system.debug('vbsName = ' + vbsName);
                            vbsList.add(new NS_Vendor_Billing_Schedule__c(Name = vbsName, NS_Project__c = salesOrder1.NS_Project__c, 
                                                                    SOId_Plus_Line__c = soItem.Sales_Order__c + soItem.Line__c.format(), 
                                                                    SOI_Amount__c = soItem.ThirdParty_Costs_PO_Ccy__c, CurrencyIsoCode = oppLineItem.ThirdParty_PO_Currency__c));
                            thirdPartySOIList.add(soItem);
                        } else {
                            soiList.add(soItem);
                        }
                    }
                }
            }
        }

        //Create Sales Order Items for RLF
        /*
        if(salesOrderList != null && salesOrderList.size() > 0){
            for(Sales_Order__c salesOrder1 : salesOrderList){
                Id obsId = salesOrder1.OBSId__c;
                Opportunity_Billing_Schedule__c oppBillSch = null;
                if(obsMap.containsKey(obsId)){
                    oppBillSch = obsMap.get(obsId);
                }
                system.debug('obsId = ' + obsId);
                system.debug('salesOrder1 = ' + salesOrder1);
                Sales_Order_Item__c soItem;
                Integer i = 1;
                for(OpportunityLineItem oppLineItem : obsOLIMap.get(obsId)){
                    system.debug('oppLineItem.SO_Grouping__c.split = ' + oppLineItem.SO_Grouping__c.split('-')[1]);
                    system.debug('salesOrder1.Order_Sub_Type__c = ' + salesOrder1.Order_Sub_Type__c);
                    system.debug('oppLineItem.Subscription_Plan_Key__c = ' + oppLineItem.Subscription_Plan_Key__c);
                    if(oppLineItem.SO_Grouping__c.split('-')[1] == salesOrder1.Order_Sub_Type__c){
                        oppLineItem.Processed__c = true;
                        updateOLIMap.put(oppLineItem.Id, oppLineItem);
                        soItem = new Sales_Order_Item__c();
                        soItem.Line__c = i++;
                        soItem.Sales_Order__c = salesOrder1.Id;
                        soItem.Name = oppLineItem.PricebookEntry.Product2.Name;
                        soItem.NS_Item__c = oppLineItem.PricebookEntry.Product2.Id;
                        soItem.Non_GA__c = oppLineItem.GA__c;
                        soItem.Software_Delivered__c = false;
                        soItem.Quantity__c = oppLineItem.Quantity;
                        soItem.Amount__c = oppLineItem.TotalPrice;
                        soItem.Rate__c = oppLineItem.UnitPrice;
                        soItem.Rev_Rec_Start_Date__c = salesOrder1.Order_Start_Date__c;
                        soItem.Planned_Recurring_Billing_Start_Date__c = salesOrder1.Order_Start_Date__c;
                        //soItem.Rev_Rec_End_Date__c = salesOrder1.Order_Date__c;
                        soItem.VSOE_Price__c = oppLineItem.Fair_Value__c;
                        //soItem.VSOE_Allocation_Amount__c = oppLineItem.Fair_Value__c;
                        soItem.CurrencyIsoCode = opportunity.CurrencyIsoCode;
                        soItem.Description__c = oppLineItem.PricebookEntry.Product2.Name;
                        soItem.Discount__c = oppLineItem.Discount_Premium__c;
                        soItem.ThirdParty_Recurring_Costs_PO_Ccy__c = oppLineItem.ThirdParty_Recurring_Costs_PO_Ccy__c;
                        if(nsCurrencyMap.containsKey(oppLineItem.ThirdParty_PO_Currency__c)){
                            soItem.ThirdParty_PO_Currency__c = nsCurrencyMap.get(oppLineItem.ThirdParty_PO_Currency__c).Id;
                        }
                        soItem.Vendor_BSch_Trigger__c = 'Manual';
                        soItem.Create_3PP_Event__c = oppLineItem.PricebookEntry.Product2.NS_Create_3PP_Event__c;
                        soItem.X3PP_Discount__c = 0;
                        soItem.Licence_Basis__c = oppLineItem.Licence_Band__c;
                        //if(obsIdSubPlanNameMap.containsKey(obsId)){
                            if(subPlanKeySubPlanMap.containsKey(oppLineItem.Subscription_Plan_Key__c)){
                                soItem.NS_Subscription_Plan__c = subPlanKeySubPlanMap.get(oppLineItem.Subscription_Plan_Key__c).Id;
                            }
                            if(subPlanKeySubPlanItemMap.containsKey(oppLineItem.Subscription_Plan_Key__c)){
                                soItem.NS_Subscription_Plan_Item__c = subPlanKeySubPlanItemMap.get(oppLineItem.Subscription_Plan_Key__c).Id;
                            }
                        //}
                        if(oppBillSch != null){
                            //soItem.Planned_Recurring_Billing_Start_Date__c = oppBillSch.Planned_Recurring_Billing_Start_Date__c;
                            soItem.Rec_Billing_Start_Trigger__c = oppBillSch.RLF_Start_Trigger__c;
                            if(soItem.Rec_Billing_Start_Trigger__c == 'Immediate'){
                                soItem.Start_Type__c = 'Immediate';
                            } else {
                                soItem.Start_Type__c = 'Suspended';
                            }
                        }
                        
                        soiList.add(soItem);
                    }
                }
            }
        }
        */
        //End Create Sales Order Items for RLF
        
        system.debug('vbsList = ' + vbsList);
        
        //Insert VBS and create a map of SOId + line and VBS
        map<string, NS_Vendor_Billing_Schedule__c> soLineVBSMap = new map<string, NS_Vendor_Billing_Schedule__c>();
        set<id> vbsIds = new set<id>();     
        if(vbsList != null && vbsList.size() > 0){
            insert vbsList;
            for(NS_Vendor_Billing_Schedule__c vbs : vbsList){
                vbsIds.add(vbs.id);
            }
            if(vbsIds != null && vbsIds.size() > 0){
                for(NS_Vendor_Billing_Schedule__c vbs1 : [select name, SOId_Plus_Line__c, NS_Project__c, SOI_Amount__c, CurrencyIsoCode from NS_Vendor_Billing_Schedule__c where id in :vbsIds]){
                    if(vbs1.SOId_Plus_Line__c != null){
                        soLineVBSMap.put(vbs1.SOId_Plus_Line__c, vbs1);
                    }
                }
            }
        }
        system.debug('soLineVBSMap = ' + soLineVBSMap);
        
        //Create VBS Lines
        list<NS_Vendor_Billing_Schedule_Line__c> vbsLineList = new list<NS_Vendor_Billing_Schedule_Line__c>();
        if(soLineVBSMap != null && soLineVBSMap.size() > 0){
            for(NS_Vendor_Billing_Schedule__c vbs2 : soLineVBSMap.values()){
                if(projProjMilestonesMap.containsKey(vbs2.NS_Project__c)){
                    for(NS_Project_Milestone__c pm1 : projProjMilestonesMap.get(vbs2.NS_Project__c)){
                        NS_Vendor_Billing_Schedule_Line__c vbsLine = new NS_Vendor_Billing_Schedule_Line__c();
                        vbsLine.CurrencyIsoCode = vbs2.CurrencyIsoCode;
                        vbsLine.NS_Vendor_Billing_Schedule__c = vbs2.id;
                        vbsLine.NS_Project__c = vbs2.NS_Project__c;
                        vbsLine.NS_Project_Milestone__c = pm1.id;
                        vbsLine.Vendor_BSch_Trigger__c = 'On Payment';
                        if(vbs2.SOI_Amount__c != null && pm1.Opportunity_Billing_Schedule_Item__r.Line__c != null){
                            vbsLine.Amount__c = (vbs2.SOI_Amount__c * pm1.Opportunity_Billing_Schedule_Item__r.Line__c) / 100;
                        }
                        vbsLineList.add(vbsLine);
                    }
                }
            }
        }
        
        if(vbsLineList != null && vbsLineList.size() > 0){
            insert vbsLineList;
        }
        
        //set the VBS to SOI if the item is a third party product
        if(thirdPartySOIList != null && thirdPartySOIList.size() > 0){
            for(Sales_Order_Item__c thirdPartySOI : thirdPartySOIList){
                if(soLineVBSMap.containsKey(thirdPartySOI.Sales_Order__c + thirdPartySOI.Line__c.format())){
                    thirdPartySOI.NS_Vendor_Billing_Schedule__c = soLineVBSMap.get(thirdPartySOI.Sales_Order__c + thirdPartySOI.Line__c.format()).id;
                }
            }
        }
        system.debug('thirdPartySOIList = ' + thirdPartySOIList);
        system.debug('soiList = ' + soiList);
        
        if(soiList != null && soiList.size() > 0 && thirdPartySOIList != null && thirdPartySOIList.size() > 0){
            soiList.addAll(thirdPartySOIList);
            system.debug('soiList after adding the thrid party list = ' + soiList);
            insert soiList;
        } else if(soiList != null && soiList.size() > 0 && (thirdPartySOIList == null || thirdPartySOIList.size() == 0)){
            insert soiList;
        } else if(soiList == null || soiList.size() == 0 && (thirdPartySOIList != null && thirdPartySOIList.size() > 0)){
            insert thirdPartySOIList;
        }
        
        if(updateOLIMap != null && updateOLIMap.size() > 0){
            system.debug('updateOLIMap = ' + updateOLIMap);
            update updateOLIMap.values();
        }

        return true;
    }
    
    private static Integer getIntMonth(String month){
        Integer intMonth;
        if(month == 'Jan'){
            intMonth = 1;
        } else if(month == 'Feb'){
            intMonth = 2;
        } else if(month == 'Mar'){
            intMonth = 3;
        } else if(month == 'Apr'){
            intMonth = 4;
        } else if(month == 'May'){
            intMonth = 5;
        } else if(month == 'Jun'){
            intMonth = 6;
        } else if(month == 'Jul'){
            intMonth = 7;
        } else if(month == 'Aug'){
            intMonth = 8;
        } else if(month == 'Sep'){
            intMonth = 9;
        } else if(month == 'Oct'){
            intMonth = 10;
        } else if(month == 'Nov'){
            intMonth = 11;
        } else if(month == 'Dec'){
            intMonth = 12;
        }
        return intMonth;
    }
}

/* Test script
       ce4sf20_001.AeServiceRequest request = new ce4sf20_001.AeServiceRequest();
       request.objectId = '123456789';
       request.objectType = 'TestObject';
       request.addParameter('opportunityId', '006m0000002IQgY');
       request.addParameter('acctBySubId', 'a0nm00000004JXp');
       request.addParameter('contractId', '800m00000000UdX');
       request.addParameter('billToId', 'a0pm00000008WN3');
       request.addParameter('shipToId', 'a0pm00000008ZwT');
    
       // invoke the service
       ce4sf20_001.IAeAutomatedStepService service = new ce4sfStep_CreateILFPackage();
       ce4sf20_001.AeServiceResponse response = service.invoke(request);
        system.debug('response = ' + response);


//Test for PS

       ce4sf20_001.AeServiceRequest request = new ce4sf20_001.AeServiceRequest();
       request.objectId = '123456789';
       request.objectType = 'TestObject';
       request.addParameter('opportunityId', '006m0000002Iapd');
       request.addParameter('acctBySubId', 'a0nm00000004JXp');
       request.addParameter('contractId', '800m00000000Ue6');
       request.addParameter('billToId', 'a0pm00000008WN3');
       request.addParameter('shipToId', 'a0pm00000008ZwT');
    
       // invoke the service
       ce4sf20_001.IAeAutomatedStepService service = new ce4sfStep_CreateILFPackage();
       ce4sf20_001.AeServiceResponse response = service.invoke(request);
        system.debug('response = ' + response);

String s = 'ILF - RA - 102020-ILF';
system.debug('test = ' + s.Split(' - ')[1]);
*/