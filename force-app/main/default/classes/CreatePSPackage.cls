public class CreatePSPackage {

    public static boolean createPackage(Opportunity opportunity, Acct_By_Sub__c acctBySub, Contract contract, id billToId, id shipToId, map<String, NS_Cost_Centre__c> ccMap, map<String, NS_Account__c> defAccMap, NS_Currency__c nsCurrency){
        set<String> salesOrderTypeSet = new set<String>();
        for(String soType : contract.Sales_Order_Type__c.split(';')){
            if(soType.split('-').size() >= 2){
                salesOrderTypeSet.add(soType.split('-')[1]);
            } else {
                salesOrderTypeSet.add(soType);
            }
        }
        map<String, list<OpportunityLineItem>> psTypeOLIMap = new map<String, list<OpportunityLineItem>>();
        map<String, set<Id>> psTypeOBSIdsMap = new map<String, set<Id>>();
        set<Id> obsIdSet;
        set<id> obsItemIds = new set<id>();
        map<id, list<Opportunity_Billing_Schedule_Item__c>> obsOBSIemsMap = new map<id, list<Opportunity_Billing_Schedule_Item__c>>();
        list<OpportunityLineItem> oliList;
        map<id, OpportunityLineItem> updateOLIMap = new map<id, OpportunityLineItem>();
        set<string> nsProductInternalIds = new set<string>();
        set<id> obsIds = new set<id>();
        set<String> revRecItenalIdSet = new set<String>();
        set<String> upidSet = new set<String>();
        
        //Get T&E Customer Settings values
        list<T_And_E_Items__c> tAndEList = T_And_E_Items__c.getall().values();
        for(T_And_E_Items__c te : tAndEList){
            revRecItenalIdSet.add(te.Rev_Rec_Schedule_Internal_Id__c);
            upidSet.add(te.UPID__c);
        }
        
        //get the Products
        map<String, Product2> upidProductMap = new map<String, Product2>();
        if(upidSet != null && salesOrderTypeSet != null && (salesOrderTypeSet.contains('PS') || salesOrderTypeSet.contains('PSS') || salesOrderTypeSet.contains('FED')
        || salesOrderTypeSet.contains('AC')
        
        )){
            for(Product2 prod : [select id, Name, UPID__c from Product2 where UPID__c in :upidSet]){
                upidProductMap.put(prod.UPID__c, prod);
            }
        }
        //get the Rev Rec Schedule for "Move to accrued - PS"
        map<String, NS_Revenue_Recognition_Template__c> revRecScheduleMap = new map<String, NS_Revenue_Recognition_Template__c>();
        if(salesOrderTypeSet != null && salesOrderTypeSet.contains('PS')){
            for(NS_Revenue_Recognition_Template__c revRecS : [select id, name, NS_Internal_Id__c from NS_Revenue_Recognition_Template__c where NS_Internal_Id__c in :revRecItenalIdSet]){
                revRecScheduleMap.put(revRecS.NS_Internal_Id__c, revRecS);
            }
        }
        //populate the map of NS OpenAire Revenue Rules
        map<String, NS_OpenAir_Revenue_Rules__c> internalIdOARevenueRuleMap = new map<String, NS_OpenAir_Revenue_Rules__c>();
        for(NS_OpenAir_Revenue_Rules__c oaRevenueRule : [select id, name, NS_Internal_Id__c from NS_OpenAir_Revenue_Rules__c]){
            internalIdOARevenueRuleMap.put(oaRevenueRule.NS_Internal_Id__c, oaRevenueRule);
        }
        ////populate the map of NS OpenAire Billing Rules
        map<String, NS_List_Table__c> internalIdOABillingRuleMap = new map<String, NS_List_Table__c>();
        for(NS_List_Table__c oaBillingRule : [select id, name, NS_Internal_Id__c from NS_List_Table__c where NS_List_Name__c = 'OpenAirBillingRules']){
            internalIdOABillingRuleMap.put(oaBillingRule.NS_Internal_Id__c, oaBillingRule);
        }
        
        for(OpportunityLineItem oli : [Select Id, OpportunityId, SO_Grouping__c, Opportunity_Billing_Schedule__c, PricebookEntry.Product2.Id, 
                PricebookEntry.Product2.Name, GA__c, Quantity, TotalPrice, UnitPrice, Reimbursable_Costs_Recovery_Value__c, 
                PricebookEntry.Product2.NS_Product_Dimension__c, PricebookEntry.Product2.NS_Product_Dimension_ID__c, Fair_Value__c,
                Reimbursable_Costs_Estimate__c, ThirdParty_Contractor_Cost_Sold_Ccy__c, ThirdParty_Costs_Sold_Ccy__c,
                List_Per_Diem_Value__c, Sold_Per_Diem_Value__c, Unrecoverable_Costs__c, Comm_Man_Price__c, Contractor_Hours_Total__c,
                NonBillable_Hours_Total__c, Travel_Hours_Total__c, PricebookEntry.ProductCode, Internal_Costs__c, Processed__c,
                PricebookEntry.Product2.NS_OpenAir_Rev_Rec_Rule__c, PricebookEntry.Product2.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c,
                PricebookEntry.Product2.NS_Default_OpenAir_Billing_Rule__c, PricebookEntry.Product2.NS_Default_OpenAir_Billing_Rule_Int_ID__c,
                Discount_Premium__c, Fair_Value_Adjustment__c, Total_Chargeable_Hours__c, NS_Item_Cost_Centre_Override_Internal_Id__c, PS_Cost_Centre__c,
                NS_Deferred_Revenue_Acct_ID__c,LineItem_Process_Type__c
                From OpportunityLineItem where SO_Grouping__c like 'PS%' and Processed__c = false and 
                OpportunityId = :opportunity.Id]){
                
                if(oli.PricebookEntry.Product2.NS_Product_Dimension_ID__c != null){
                    nsProductInternalIds.add(oli.PricebookEntry.Product2.NS_Product_Dimension_ID__c);   
                }
                obsIds.add(oli.Opportunity_Billing_Schedule__c);
                if(psTypeOLIMap != null && psTypeOLIMap.containsKey(oli.SO_Grouping__c.split('-')[1])){
                    oliList = psTypeOLIMap.get(oli.SO_Grouping__c.split('-')[1]);
                    oliList.add(oli);
                } else {
                    oliList = new list<OpportunityLineItem>();
                    oliList.add(oli);
                    psTypeOLIMap.put(oli.SO_Grouping__c.split('-')[1], oliList);
                }
                //populate the psTypeOBSIdsMap
                if(psTypeOBSIdsMap != null && psTypeOBSIdsMap.containsKey(oli.SO_Grouping__c.split('-')[1])){
                    obsIdSet = psTypeOBSIdsMap.get(oli.SO_Grouping__c.split('-')[1]);
                    if(oli.Opportunity_Billing_Schedule__c != null){
                        obsIdSet.add(oli.Opportunity_Billing_Schedule__c);
                    }
                } else {
                    obsIdSet = new set<Id>();
                    if(oli.Opportunity_Billing_Schedule__c != null){
                        obsIdSet.add(oli.Opportunity_Billing_Schedule__c);
                        psTypeOBSIdsMap.put(oli.SO_Grouping__c.split('-')[1], obsIdSet);
                    }
                }
        }
        
        system.debug('psTypeOLIMap = ' + psTypeOLIMap);
        system.debug('psTypeOBSIdsMap = ' + psTypeOBSIdsMap);

        list<Opportunity_Billing_Schedule_Item__c> obsItemList;
        
        for(Opportunity_Billing_Schedule_Item__c item : [select id, Name, Narrative__c, Line_Milestone_Sequence__c, 
                Opportunity_Billing_Schedule__c, Line_Estimated_Completion_Date__c, Line_Drop_Dead_Date__c, Line__c
                from Opportunity_Billing_Schedule_Item__c where Opportunity_Billing_Schedule__c in : obsIds]){
                    
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
        
        map<id, Opportunity_Billing_Schedule__c> obsMap = new map<id, Opportunity_Billing_Schedule__c>([select id, name from Opportunity_Billing_Schedule__c where id in :obsIds]);
                                                                                        
        system.debug('obsMap = ' + obsMap);
        
        //Create projects
        list<NS_Project__c> projList = new list<NS_Project__c>();
        NS_Project__c project;
        
        //check if the project already exisits
        List<NS_Project__c> existingNSProjList = [select id from NS_Project__c where Opportunity__c = :opportunity.id and Deferred_Account_Type__c ='PS' limit 1];
        Id exsitingProjectId = null;
       /* if(existingNSProjList.size()>0){
            psProject = existingNSProjList.get(0);
           // projList.add(existingNSProj);
          // projList = existingNSProjList;
        }*/
        
         if(psTypeOLIMap != null && psTypeOLIMap.size() > 0){
            for(String psType : psTypeOLIMap.keySet()){
                if(salesOrderTypeSet != null && salesOrderTypeSet.contains(psType)){
                    project = new NS_Project__c();
                    project.Project_Name__c = opportunity.Order_Number__c + ' - ' + psType;
                    project.NS_Primary_Currency__c = nsCurrency.Id;
                    project.Project_Region__c = acctBySub.Account__r.NS_Finance_Region__c; 
                    project.Subsidiary__c = acctBySub.Misys_Entity__c;
                    project.Opportunity_Number__c = opportunity.Order_Number__c;
                    project.SFDC_Opportunity_Stage__c = opportunity.StageName;
                    project.SFDC_Opportunity_Close_date__c = opportunity.CloseDate;
                    project.CurrencyIsoCode = opportunity.CurrencyIsoCode;
                    project.SFDC_Opportunity_Category__c = opportunity.ForecastCategoryName;
                    project.SFDC_Opportunity_Probability__c = opportunity.Probability;
                    project.PS_Top_Opportunity__c = opportunity.PS_Top_Opportunity__c;
                    project.PS_Forecast_Probability__c = opportunity.PS_Forecast_Probability__c;
                    project.Project_Type__c = 'PS';
                    project.OpenAir_Project_Stage__c = 'Pending - PM';
                    project.Customer__c = acctBySub.Id;
                    project.Deferred_Account_Type__c = psType;
                    if(opportunity.PS_Cost_Centre__c != null){
                        project.Project_Cost_Centre__c = opportunity.PS_Cost_Centre__c;
                    } else if(ccMap.containsKey(psType)){
                        project.Project_Cost_Centre__c = ccMap.get(psType).Id;
                    }
                    project.Export_to_OpenAir__c = true;
                    project.Project_Owner__c = opportunity.OA_Project_Manager__c;
                    project.Project_Director__c = opportunity.OA_Project_Director__c;
                    project.Project_Start_Date__c = opportunity.PS_FC_Start_Date2__c;
                    project.OA_Project_Template__c = opportunity.Project_Template__c;
                    project.NS_Project_Status__c = 'In Progress';
                    project.PS_Practice_Name__c = opportunity.PS_Practice_Name__c;
                    project.PS_Practice_Unique_Code__c = opportunity.PS_Practice_Unique_Code__c;
                    project.NS_Project_Service_Type__c = opportunity.NS_Project_Service_Type__c;
                    
                    if(psTypeOLIMap.containsKey(psType)){
                        OpportunityLineItem firstOppLineItem = psTypeOLIMap.get(psType)[0];
                        if(firstOppLineItem.NS_Deferred_Revenue_Acct_ID__c != null){
                            project.NS_Deferred_Revenue_Account_Internal_Id__c = string.valueof(firstOppLineItem.NS_Deferred_Revenue_Acct_ID__c);
                        }
                        Double fairValue = 0.00;
                        String projProdInternalId = null;
                        for(OpportunityLineItem oppLine : psTypeOLIMap.get(psType)){
                            if(fairValue < oppLine.Fair_Value__c){
                                fairValue = oppLine.Fair_Value__c;
                                projProdInternalId = oppLine.PricebookEntry.Product2.NS_Product_Dimension_ID__c;
                                system.debug('projProdInternalId = ' + projProdInternalId);
                            } else if(fairValue == oppLine.Fair_Value__c && projProdInternalId == null){
                                projProdInternalId = oppLine.PricebookEntry.Product2.NS_Product_Dimension_ID__c;
                                system.debug('projProdInternalId for zero value = ' + projProdInternalId);
                            }
                        }
                        if(projProdInternalId != null && nsProdIntIdMap != null && nsProdIntIdMap.containsKey(projProdInternalId)){
                            project.Project_Product__c = nsProdIntIdMap.get(projProdInternalId);
                        }
                    }
                    
                    if(psType.equals('PS') && existingNSProjList.size()>0)
                    //projList.add(existingNSProjList.get(0));
                    exsitingProjectId =existingNSProjList.get(0).Id;
                    else
                    projList.add(project);
                }
            }
        }
        set<Id> projectIds = new set<Id>();
        if(projList != null && projList.size() > 0){
            system.debug('projList = ' + projList);
            //AM
           // if(existingNSProjList.size()==0)
            insert projList;
            for(NS_Project__c project1 : projList){
                projectIds.add(project1.Id);
            }
        }
             if(exsitingProjectId!=null) // AM - to cater for the exisitng WAR project
                    projectIds.add(exsitingProjectId);
                    
        
        
        //Create NS Project OBS Junctions and Project Milestones
        //list for Junction object - NS Project OBS Junction
        list<NS_Project_OBS_Junction__c> junctionList = new list<NS_Project_OBS_Junction__c>();
        list<NS_Project__c> projectList = [select Id, Project_Cost_Centre__c, Project_Product__c, Deferred_Account_Type__c, PS_Practice_Name__c, 
                                            PS_Practice_Unique_Code__c, NS_Deferred_Revenue_Account_Internal_Id__c 
                                            from NS_Project__c where Id in :projectIds];
        list<NS_Project_Milestone__c> projMileList = new list<NS_Project_Milestone__c>();
        NS_Project_Milestone__c projMilestone;
        
        
        if(projectList != null && projectList.size() > 0){
            for(NS_Project__c proj : projectList){
                //populate junctino list
                if(psTypeOBSIdsMap != null && psTypeOBSIdsMap.containsKey(proj.Deferred_Account_Type__c)){
                    for(Id obsId : psTypeOBSIdsMap.get(proj.Deferred_Account_Type__c)){
                        junctionList.add(new NS_Project_OBS_Junction__c(NS_Project__c = proj.Id /*project.Id*/, Opportunity_Billing_Schedule__c = obsId));
                        //create project milestones based on the OBS Items
                        if(obsOBSIemsMap != null && obsOBSIemsMap.containsKey(obsId)){
                            for(Opportunity_Billing_Schedule_Item__c obsItem : obsOBSIemsMap.get(obsId)){
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
                                projMilestone.NS_Project__c = proj.Id;
                                projMilestone.Don_t_Export_To_NS__c = true;
                                projMilestone.CurrencyIsoCode = opportunity.CurrencyIsoCode;
                                projMileList.add(projMilestone);
                                obsItemIds.add(obsItem.Id);
                            }
                        }
                    }
                }
            }
        }
        if(junctionList != null && junctionList.size() > 0){
            system.debug('junctionList = ' + junctionList);
            insert junctionList;
        }
        if(projMileList != null && projMileList.size() > 0){
            system.debug('projMileList = ' + projMileList);
            insert projMileList;
        }

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
            cbs.Don_t_Export_To_NS__c = true;
            
            cbsList.add(cbs);
        }
        
        if(cbsList != null && cbsList.size() > 0){
            system.debug('cbsList = ' + cbsList);
            insert cbsList;
        }

      /*  // check if there is an acedamy product on opportunity.
        list<opportunityLineItem> academyProduct = [Select Id, PricebookEntry.Product2.NS_Cost_Centre__c, PricebookEntry.Product2.NS_Cost_Centre_ID__c from opportunityLineitem where opportunityId  = :opportunity.Id and SO_Base_Group__c = 'PS-AC' limit 1];
        list<NS_Cost_Centre__c> nsCostCenterID = new list<NS_Cost_Centre__c>();
        if(academyProduct.size()>0)
        nsCostCenterID = [Select id from NS_Cost_Centre__c where name = :academyProduct[0].PricebookEntry.Product2.NS_Cost_Centre__c  limit 1];
     */
        //Create Sales Orders
        Sales_Order__c salesOrder;
        list<Sales_Order__c> soList = new list<Sales_Order__c>();
        if(projectList != null && projectList.size() > 0){
            for(NS_Project__c nsProj : projectList){
                salesOrder = new Sales_Order__c();
                salesOrder.NS_Form_Id__c = '125';
                salesOrder.NS_Project__c = nsProj.Id;
                salesOrder.Bill_To_Customer__c = acctBySub.Id;
                salesOrder.Opportunity__c = opportunity.Id;
                salesOrder.CurrencyIsoCode = opportunity.CurrencyIsoCode;
              //  salesOrder.Order_Sub_Type__c = nsProj.Deferred_Account_Type__c;
                // set the product id instead of the opty cost center id on SO if the opty has a Academy product
              /*  if(academyProduct.size()>0  && nsCostCenterID.size()>0 && salesOrder.Order_Sub_Type__c =='AC')
                salesOrder.NS_Cost_Centre__c = nsCostCenterID[0].Id;
                else*/
                salesOrder.NS_Cost_Centre__c = nsProj.Project_Cost_Centre__c;
                
                salesOrder.NS_Product__c = nsProj.Project_Product__c;
                salesOrder.NS_Term__c = acctBySub.Account__r.NS_Term__c;
                salesOrder.SO_Credit_Controller__c = acctBySub.Account__r.Credit_Controller__c;
                //AK - commenting the below as NS Deferred Revenue Account Internal Id will come from the OLI
                //if(defAccMap != null && defAccMap.containsKey(nsProj.Deferred_Account_Type__c)){
                  //  salesOrder.NS_Deferred_Revenue_Reclassification_Acc__c = defAccMap.get(nsProj.Deferred_Account_Type__c).Id;
                //}
                salesOrder.NS_Deferred_Rev_Rec_Acc_Internal_Id__c = nsProj.NS_Deferred_Revenue_Account_Internal_Id__c;
                salesOrder.NS_Currency__c = nsCurrency.Id;
                salesOrder.Contract__c = contract.Id;
                salesOrder.NS_Rev_Rec_on_Commit__c = false;
                salesOrder.NS_AutoCalculate_VSOE_Allocation__c = false;
                salesOrder.Price_Level__c = 'Custom';
                salesOrder.Invoice_Credit_Body__c = 'PS';
                salesOrder.Order_Status__c = 'Pending Approval';
                salesOrder.Customer_PO_Number__c = opportunity.Customer_PO__c;
                salesOrder.Order_Date__c = opportunity.CloseDate;
                salesOrder.Order_Type__c = 'PS';
                salesOrder.PO_Required__c = acctBySub.Account__r.PO_Required__c;
                salesOrder.Transaction_is_VSOE_Bundle__c = false;
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
               
               //only set the practise name if the opty does not have an acedamy product
              // if(salesOrder.Order_Sub_Type__c !='AC')
                salesOrder.PS_Practice_Name__c = nsProj.PS_Practice_Name__c;
                salesOrder.PS_Practice_Unique_Code__c = nsProj.PS_Practice_Unique_Code__c;
                soList.add(salesOrder);
            }
        }
        
        if(soList != null && soList.size() > 0){
            system.debug('soList = ' + soList);
            insert soList;
            
            //if the NS Export to Open Air flag is not set on the Acct By Sub, then set it to true
            if(acctBySub.NS_Export_to_Openair__c == false){
                acctBySub.NS_Export_to_Openair__c = true;
                update acctBySub;
            }
        }

        //Get the recently created Sales Orders
        map<id, Sales_Order__c> projIdSalesOrderMap1 = new map<id, Sales_Order__c>();
        for(Sales_Order__c so : [select id, NS_Project__c, NS_Project__r.Opportunity_Billing_Schedule__c, NS_Project__r.Deferred_Account_Type__c, Order_Date__c, 
                                NS_Cash_Accounting__c, NS_Project__r.Project_Cost_Centre__c from Sales_Order__c where NS_Project__c in :projectIds]){
                                    
            projIdSalesOrderMap1.put(so.NS_Project__c, so);
        }
        
        //Update the recently created NS_Customer_Billing_Schedule__c with recently created Sales Order
        list<NS_Customer_Billing_Schedule__c> cbsUpdateList = new list<NS_Customer_Billing_Schedule__c>();
        for(NS_Customer_Billing_Schedule__c nsCBS : [select id, Project__c, Sales_Order__c from NS_Customer_Billing_Schedule__c where Project__c in :projectIds]){
            if(projIdSalesOrderMap1.containsKey(nsCBS.Project__c)){
                nsCBS.Sales_Order__c = projIdSalesOrderMap1.get(nsCBS.Project__c).Id;
                cbsUpdateList.add(nsCBS);
            }
        }
        
        if(cbsUpdateList != null && cbsUpdateList.size() > 0){
            update cbsUpdateList;
        }
        
        system.debug('projIdSalesOrderMap1 = ' + projIdSalesOrderMap1);

        //Create Sales Order Items
        list<Sales_Order_Item__c> soiList = new list<Sales_Order_Item__c>();
        if(projIdSalesOrderMap1 != null && projIdSalesOrderMap1.size() > 0){
            for(Sales_Order__c salesOrder1 : projIdSalesOrderMap1.values()){
                system.debug('salesOrder1 = ' + salesOrder1);
                Sales_Order_Item__c soItem;
                Integer i = 1;
                for(OpportunityLineItem oppLineItem : psTypeOLIMap.get(salesOrder1.NS_Project__r.Deferred_Account_Type__c)){
                    system.debug('oppLineItem.SO_Grouping__c.split = ' + oppLineItem.SO_Grouping__c.split('-')[1]);
                    system.debug('salesOrder1.NS_Project__r.Deferred_Account_Type__c = ' + salesOrder1.NS_Project__r.Deferred_Account_Type__c);
                //    if((oppLineItem.PricebookEntry.ProductCode == 'SVFP' || oppLineItem.PricebookEntry.ProductCode == 'DVF2' || oppLineItem.PricebookEntry.ProductCode == 'SVFF' || oppLineItem.PricebookEntry.ProductCode == 'SPFP') 
                    if((oppLineItem.LineItem_Process_Type__c == 'SVFP' || oppLineItem.LineItem_Process_Type__c == 'SVFO' ||  oppLineItem.LineItem_Process_Type__c == 'SVF*'  || oppLineItem.LineItem_Process_Type__c == 'DVF2' || oppLineItem.LineItem_Process_Type__c == 'SVFF' || oppLineItem.LineItem_Process_Type__c == 'SPFP') 
                            && oppLineItem.Opportunity_Billing_Schedule__c != null && obsOBSIemsMap != null 
                            && obsOBSIemsMap.containsKey(oppLineItem.Opportunity_Billing_Schedule__c)){
                        oppLineItem.Processed__c = true;
                        updateOLIMap.put(oppLineItem.Id, oppLineItem);
                        for(Opportunity_Billing_Schedule_Item__c oppBSI : obsOBSIemsMap.get(oppLineItem.Opportunity_Billing_Schedule__c)){
                            if(oppLineItem.SO_Grouping__c.split('-')[1] == salesOrder1.NS_Project__r.Deferred_Account_Type__c){
                                soItem = new Sales_Order_Item__c();
                                soItem.CurrencyIsoCode = opportunity.CurrencyIsoCode;
                                soItem.Line__c = i++;
                                soItem.Sales_Order__c = salesOrder1.Id;
                                if(oppBSI.Narrative__c != null){
                                    soItem.Name = oppBSI.Narrative__c;
                                } else {
                                    soItem.Name = oppBSI.Name;
                                }
                                
                                
                                if(oppLineItem.PS_Cost_Centre__c != null){
                                    soItem.PS_Cost_Centre__c = oppLineItem.PS_Cost_Centre__c;
                                }
                                soItem.NS_Item__c = oppLineItem.PricebookEntry.Product2.Id;
                                soItem.Non_GA__c = oppLineItem.GA__c;
                                soItem.Software_Delivered__c = false;
                                soItem.Quantity__c = oppLineItem.Quantity;
                                soItem.Discount__c = oppLineItem.Discount_Premium__c;
                                soItem.Fair_Value_Adjustment__c = oppLineItem.Fair_Value_Adjustment__c;
                                soItem.Rev_Rec_Start_Date__c = salesOrder1.Order_Date__c;
                                soItem.Rev_Rec_End_Date__c = salesOrder1.Order_Date__c;
                                if(oppLineItem.TotalPrice != null && oppBSI.Line__c != null){
                                    soItem.Amount__c = (oppLineItem.TotalPrice * oppBSI.Line__c) / 100;
                                    soItem.Rate__c = (oppLineItem.UnitPrice * oppBSI.Line__c) / 100;
                                }
                                if(oppLineItem.Fair_Value__c != null && oppBSI.Line__c != null){
                                    soItem.VSOE_Price__c = (oppLineItem.Fair_Value__c * oppBSI.Line__c) / 100;
                                    soItem.VSOE_Allocation_Amount__c = (oppLineItem.Fair_Value__c * oppBSI.Line__c) / 100;
                                }
                                if(oppLineItem.Reimbursable_Costs_Recovery_Value__c != null && oppBSI.Line__c != null){
                                    soItem.Reimbursable_Costs_Recovery_Value__c = (oppLineItem.Reimbursable_Costs_Recovery_Value__c * oppBSI.Line__c) / 100;
                                }
                                if(oppLineItem.Reimbursable_Costs_Estimate__c != null && oppBSI.Line__c != null){
                                    soItem.Reimbursable_Costs_Estimate__c = (oppLineItem.Reimbursable_Costs_Estimate__c * oppBSI.Line__c) / 100;
                                }
                                if(oppLineItem.ThirdParty_Contractor_Cost_Sold_Ccy__c != null && oppBSI.Line__c != null){
                                    soItem.Third_Party_Contractor_Cost_deal_ccy__c = (oppLineItem.ThirdParty_Contractor_Cost_Sold_Ccy__c * oppBSI.Line__c) / 100;
                                }
                                if(oppLineItem.ThirdParty_Costs_Sold_Ccy__c != null && oppBSI.Line__c != null){
                                    soItem.Third_Party_Costs_deal_currency__c = (oppLineItem.ThirdParty_Costs_Sold_Ccy__c * oppBSI.Line__c) / 100;
                                }
                                if(oppLineItem.Unrecoverable_Costs__c != null && oppBSI.Line__c != null){
                                    soItem.Unrecoverable_Costs__c = (oppLineItem.Unrecoverable_Costs__c * oppBSI.Line__c) / 100;
                                }
                                if(oppLineItem.Internal_Costs__c != null && oppBSI.Line__c != null){
                                    soItem.Internal_Costs__c = (oppLineItem.Internal_Costs__c * oppBSI.Line__c) / 100;
                                }
                                if(oppLineItem.Comm_Man_Price__c != null && oppBSI.Line__c != null){
                                    soItem.List_Value__c = (oppLineItem.Comm_Man_Price__c * oppBSI.Line__c) / 100;
                                }
                                if(oppLineItem.Fair_Value__c != null && oppBSI.Line__c != null){
                                    soItem.Fair_Value__c = (oppLineItem.Fair_Value__c * oppBSI.Line__c) / 100;
                                }
                                if(oppLineItem.UnitPrice != null && oppBSI.Line__c != null){
                                    soItem.Sales_Price__c = (oppLineItem.UnitPrice * oppBSI.Line__c) / 100;
                                }
                                if(oppLineItem.Contractor_Hours_Total__c != null && oppBSI.Line__c != null){
                                    soItem.Total_Number_Of_Contractor_Hours__c = (oppLineItem.Contractor_Hours_Total__c * oppBSI.Line__c) / 100;
                                }
                                if(oppLineItem.NonBillable_Hours_Total__c != null && oppBSI.Line__c != null){
                                    soItem.Total_Number_Of_Non_Billable_Hours__c = (oppLineItem.NonBillable_Hours_Total__c * oppBSI.Line__c) / 100;
                                }
                                if(oppLineItem.Travel_Hours_Total__c != null && oppBSI.Line__c != null){
                                    soItem.Total_Number_Of_Travel_Hours__c = (oppLineItem.Travel_Hours_Total__c * oppBSI.Line__c) / 100;
                                }
                                if(oppLineItem.Total_Chargeable_Hours__c != null && oppBSI.Line__c != null){
                                    soItem.Total_Chargeable_Hours__c = (oppLineItem.Total_Chargeable_Hours__c * oppBSI.Line__c) / 100;
                                    soItem.Total_Billable_Hours__c = (oppLineItem.Total_Chargeable_Hours__c * oppBSI.Line__c) / 100;
                                }
                                soItem.Per_Diem_List_Value__c = oppLineItem.List_Per_Diem_Value__c;
                                soItem.Per_Diem_Contracted_Value__c = oppLineItem.Sold_Per_Diem_Value__c;
                                if(oppBSI.Narrative__c != null){
                                    soItem.Description__c = oppBSI.Narrative__c;
                                } else {
                                    soItem.Description__c = oppBSI.Name;
                                }
                                if(oppLineItem.PricebookEntry.Product2.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c != null && internalIdOARevenueRuleMap.containsKey(oppLineItem.PricebookEntry.Product2.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c)){
                                    soItem.OpenAir_Rev_Rec_Rule__c = internalIdOARevenueRuleMap.get(oppLineItem.PricebookEntry.Product2.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c).Id;
                                }
                                if(oppLineItem.PricebookEntry.Product2.NS_Default_OpenAir_Billing_Rule_Int_ID__c != null && internalIdOABillingRuleMap.containsKey(oppLineItem.PricebookEntry.Product2.NS_Default_OpenAir_Billing_Rule_Int_ID__c)){
                                    soItem.OpenAir_Billing_Rule__c = internalIdOABillingRuleMap.get(oppLineItem.PricebookEntry.Product2.NS_Default_OpenAir_Billing_Rule_Int_ID__c).Id;
                                }
                                soiList.add(soItem);
                            }
                        }
                  /*  } else if((oppLineItem.PricebookEntry.ProductCode == 'SVTM' || oppLineItem.PricebookEntry.ProductCode == 'SVFT' || oppLineItem.PricebookEntry.ProductCode == 'SPTM') 
                                || oppLineItem.Opportunity_Billing_Schedule__c == null){ */
                            }  else if((oppLineItem.LineItem_Process_Type__c == 'SVTM' || oppLineItem.LineItem_Process_Type__c == 'SVFT' || oppLineItem.LineItem_Process_Type__c == 'SPTM') 
                                || oppLineItem.Opportunity_Billing_Schedule__c == null) {
                        if(oppLineItem.SO_Grouping__c.split('-')[1] == salesOrder1.NS_Project__r.Deferred_Account_Type__c){
                            oppLineItem.Processed__c = true;
                            updateOLIMap.put(oppLineItem.Id, oppLineItem);
                            soItem = new Sales_Order_Item__c();
                            soItem.CurrencyIsoCode = opportunity.CurrencyIsoCode;
                            soItem.Line__c = i++;
                            soItem.Sales_Order__c = salesOrder1.Id;
                            if(oppLineItem.PS_Cost_Centre__c != null){
                                soItem.PS_Cost_Centre__c = oppLineItem.PS_Cost_Centre__c;
                            }
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
                            soItem.Reimbursable_Costs_Recovery_Value__c = oppLineItem.Reimbursable_Costs_Recovery_Value__c;
                            soItem.Reimbursable_Costs_Estimate__c = oppLineItem.Reimbursable_Costs_Estimate__c;
                            soItem.Third_Party_Contractor_Cost_deal_ccy__c = oppLineItem.ThirdParty_Contractor_Cost_Sold_Ccy__c;
                            soItem.Third_Party_Costs_deal_currency__c = oppLineItem.ThirdParty_Costs_Sold_Ccy__c;
                            soItem.Per_Diem_List_Value__c = oppLineItem.List_Per_Diem_Value__c;
                            soItem.Per_Diem_Contracted_Value__c = oppLineItem.Sold_Per_Diem_Value__c;
                            soItem.Unrecoverable_Costs__c = oppLineItem.Unrecoverable_Costs__c;
                            soItem.Internal_Costs__c = oppLineItem.Internal_Costs__c;
                            soItem.List_Value__c = oppLineItem.Comm_Man_Price__c;
                            soItem.Fair_Value__c = oppLineItem.Fair_Value__c;
                            soItem.Sales_Price__c = oppLineItem.UnitPrice;
                            soItem.Total_Number_Of_Contractor_Hours__c = oppLineItem.Contractor_Hours_Total__c;
                            soItem.Total_Number_Of_Non_Billable_Hours__c = oppLineItem.NonBillable_Hours_Total__c;
                            soItem.Total_Number_Of_Travel_Hours__c = oppLineItem.Travel_Hours_Total__c;
                            soItem.Description__c = oppLineItem.PricebookEntry.Product2.Name;
                            soItem.Discount__c = oppLineItem.Discount_Premium__c;
                            soItem.Fair_Value_Adjustment__c = oppLineItem.Fair_Value_Adjustment__c;
                            soItem.Total_Chargeable_Hours__c = oppLineItem.Total_Chargeable_Hours__c;
                            soItem.Total_Billable_Hours__c = oppLineItem.Total_Chargeable_Hours__c;
                            if(oppLineItem.PricebookEntry.Product2.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c != null && internalIdOARevenueRuleMap.containsKey(oppLineItem.PricebookEntry.Product2.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c)){
                                soItem.OpenAir_Rev_Rec_Rule__c = internalIdOARevenueRuleMap.get(oppLineItem.PricebookEntry.Product2.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c).Id;
                            }
                            if(oppLineItem.PricebookEntry.Product2.NS_Default_OpenAir_Billing_Rule_Int_ID__c != null && internalIdOABillingRuleMap.containsKey(oppLineItem.PricebookEntry.Product2.NS_Default_OpenAir_Billing_Rule_Int_ID__c)){
                                soItem.OpenAir_Billing_Rule__c = internalIdOABillingRuleMap.get(oppLineItem.PricebookEntry.Product2.NS_Default_OpenAir_Billing_Rule_Int_ID__c).Id;
                            }
                            soiList.add(soItem);
                        }
                    }
                }
                //add T&E Items to Sales Order
                if(salesOrder1.NS_Project__r.Deferred_Account_Type__c == 'PS' || salesOrder1.NS_Project__r.Deferred_Account_Type__c == 'PSS' 
                    || salesOrder1.NS_Project__r.Deferred_Account_Type__c == 'FED'
                    || salesOrder1.NS_Project__r.Deferred_Account_Type__c == 'AC'){
                    for(T_And_E_Items__c teItem : tAndEList){
                        if((salesOrder1.NS_Project__r.Deferred_Account_Type__c == 'PS' && teItem.Sales_Order_Type__c == 'PS')
                            || (salesOrder1.NS_Project__r.Deferred_Account_Type__c == 'PSS' && teItem.Sales_Order_Type__c == 'PSS')
                            || (salesOrder1.NS_Project__r.Deferred_Account_Type__c == 'FED' && teItem.Sales_Order_Type__c == 'FED')
                            || (salesOrder1.NS_Project__r.Deferred_Account_Type__c == 'AC' && teItem.Sales_Order_Type__c == 'AC')
                            ){

                            soItem = new Sales_Order_Item__c();
                            soItem.CurrencyIsoCode = opportunity.CurrencyIsoCode;
                            soItem.Line__c = i++;
                            soItem.Sales_Order__c = salesOrder1.Id;
                            soItem.Name = teItem.Name;
                            soItem.Description__c = teItem.Name;
                            soItem.PS_Cost_Centre__c = salesOrder1.NS_Project__r.Project_Cost_Centre__c;
                            //soItem.Rev_Rec_Start_Date__c = salesOrder1.Order_Date__c;
                            //soItem.Rev_Rec_End_Date__c = salesOrder1.Order_Date__c;
                            if(upidProductMap.containsKey(teItem.UPID__c)){
                                soItem.NS_Item__c = upidProductMap.get(teItem.UPID__c).Id;
                            }
                            soItem.Quantity__c = teItem.Quantity__c;
                            soItem.Rate__c = teItem.Rate__c;
                            soItem.Amount__c = teItem.Quantity__c * teItem.Rate__c;
                            if(revRecScheduleMap.containsKey(teItem.Rev_Rec_Schedule_Internal_Id__c)){
                                soItem.Rev_Rec_Schedule__c = revRecScheduleMap.get(teItem.Rev_Rec_Schedule_Internal_Id__c).Id;
                            }
                            if(internalIdOARevenueRuleMap.containsKey(teItem.OA_Rev_Rec_Rule_Internal_Id__c)){
                                soItem.OpenAir_Rev_Rec_Rule__c = internalIdOARevenueRuleMap.get(teItem.OA_Rev_Rec_Rule_Internal_Id__c).Id;
                            }
                            if(internalIdOABillingRuleMap.containsKey(teItem.OA_Billing_Rule_Internal_Id__c)){
                                soItem.OpenAir_Billing_Rule__c = internalIdOABillingRuleMap.get(teItem.OA_Billing_Rule_Internal_Id__c).Id;
                            }
                            soiList.add(soItem);
                        }
                    }
                }
                
                
            }
        }

        if(soiList != null && soiList.size() > 0){
            system.debug('soiList = ' + soiList);
            insert soiList;
        }

        //Update Opportunity Line Item to processed
        if(updateOLIMap != null && updateOLIMap.size() > 0){
            system.debug('updateOLIMap = ' + updateOLIMap);
            update updateOLIMap.values();
        }

        return true;
    }
    
   
}