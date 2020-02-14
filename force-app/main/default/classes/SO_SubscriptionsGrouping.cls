public class SO_SubscriptionsGrouping {
    
    public static Map<String, Integer> sortbyProcess(Billing_Group__c bg){
        Map < String, Integer > Sub_by_grouping_Map = new Map < String, Integer > ();
        
        // Grouping ILF 
        
        String temp;
        for (AggregateResult ar: [select Initial_Sales_Order_Type__c soType, 
                                  count(Id) total 
                                  from SBQQ__Subscription__c 
                                  WHERE Billing_Group__c = : bg.Id 
                                  AND Initial_Sales_Order_Type__c LIKE 'ILF%' 
                                  And Inital_NS_Item__c != null
                                  GROUP BY Initial_Sales_Order_Type__c]){                                                                          
                                      Sub_by_grouping_Map.put((String) ar.get('soType'), (Integer) ar.get('total'));                                      
                                  }
                
        // Grouping RLF         
        for (AggregateResult ar: [select Recurring_Sales_Order_Type__c soType, 
                                  count(Id) total, 
                                  MAX(SBQQ__NetPrice__c) amount  
                                  from SBQQ__Subscription__c 
                                  WHERE Billing_Group__c =: bg.Id 
                                  AND Recurring_Sales_Order_Type__c != null 
                                  AND Recurring_NS_Item__c != null
                                  GROUP BY Recurring_Sales_Order_Type__c]){                                      
                                      temp =(String) ar.get('soType');                                                                          
                                      if(temp.contains('RLF')){
                                          Sub_by_grouping_Map.put(temp, (Integer) ar.get('total'));
                                      }
                                  }
        
        system.debug('Sub_by_grouping_Map => ' + Sub_by_grouping_Map);
        
        return Sub_by_grouping_Map;
    }    
    
    public static Map<String, List<SBQQ__Subscription__c>> getSubsByTypeForPs(Billing_Group__c bg){
       // Grouping PS
        Map < String, List < SBQQ__Subscription__c >> ps_sub_map = new Map < String, List < SBQQ__Subscription__c >> ();
        List < SBQQ__Subscription__c > tempSub;
        for (SBQQ__Subscription__c sub: [SELECT Id, Name, SO_Grouping__c,Ship_From_Code__c, opportunity_billing_schedule__c, LineItem_Process_Type__c, Initial_Sales_Order_Type__c, Sold_Value__c, Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode,SBQQ__Product__r.Id,SBQQ__Product__r.NS_Default_OpenAir_Billing_Rule_Int_ID__c,SBQQ__Product__r.Name, 
                                         Inital_NS_Item__c, Inital_NS_Item__r.GA__c, SBQQ__Quantity__c, Discount_Premium__c, Fair_Value_Adjustment__c, Initial_Sovos_Code__c, ThirdParty_Costs_PO_Ccy__c, Fair_Value__c, Reimbursable_Costs_Recovery_Value__c, Reimbursable_Costs_Estimate__c, ThirdParty_Contractor_Cost_Sold_Ccy__c, ThirdParty_Costs_Sold_Ccy__c, Unrecoverable_Costs__c, Internal_Costs__c, Comm_Man_Price__c, SBQQ__UnitCost__c, Contractor_Hours_Total__c,
                                         NonBillable_Hours_Total__c, Travel_Hours_Total__c, Total_Chargeable_Hours__c, Sold_Per_Diem_Value__c, List_Per_Diem_Value__c,SBQQ__Product__r.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c,Inital_NS_Item__r.NS_Default_OpenAir_Billing_Rule_Int_ID__c, Inital_NS_Item__r.NS_Rev_Rec_Template_ID__c
                                         
                                         FROM SBQQ__Subscription__c
                                         WHERE Billing_Group__c = : bg.Id 
                                         AND Initial_Sales_Order_Type__c LIKE 'PS%'
                                         ORDER BY opportunity_billing_schedule__c
                                        ]) {
                                            if (sub.opportunity_billing_schedule__c != null) {
                                                tempSub = new List < SBQQ__Subscription__c > ();
                                                if (ps_sub_map.KeySet().contains('PS-OBS-' + sub.opportunity_billing_schedule__c)) {
                                                    tempSub = ps_sub_map.get('PS-OBS-' + sub.opportunity_billing_schedule__c);                                                    
                                                }
                                                tempSub.add(sub);
                                                ps_sub_map.put('PS-OBS-' + sub.opportunity_billing_schedule__c, tempSub);
                                            } else if (sub.LineItem_Process_Type__c == 'SVTM' || sub.LineItem_Process_Type__c == 'SVFT' || sub.LineItem_Process_Type__c == 'SPTM') {
                                                tempSub = new List < SBQQ__Subscription__c > ();
                                                if (ps_sub_map.KeySet().contains(sub.Initial_Sales_Order_Type__c)) {
                                                    tempSub = ps_sub_map.get(sub.Initial_Sales_Order_Type__c);                                                    
                                                }
                                                tempSub.add(sub);
                                                ps_sub_map.put(sub.Initial_Sales_Order_Type__c, tempSub);
                                            }
                                        }
        
        system.debug('In PS sorting process => '+ps_sub_map);        
        return ps_sub_map;
    } 
    
    public static Map<String, List<SBQQ__Subscription__c>> getSubsByType(Map<String, Integer> groupMap, Id bgId){
        
        Map<String, List<SBQQ__Subscription__c>> group_subList_Map = new Map<String, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        
        for(SBQQ__Subscription__c sub: [SELECT  Id, 
                                        Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode, 
                                        Billing_Day__c, 
                                        Billing_Month__c, 
                                        Comm_Man_Price__c, 
                                        Contractor_Hours_Total__c, 
                                        Discount_premium__c,
                                        Billing_Group__r.CurrencyIsoCode,
                                        Expiry_Date__c ,
                                        Fair_Value__c, 
                                        Fair_Value_Adjustment__c, 
                                        GA__c, 
                                        ILF_Fair_Value__c, 
                                        Inital_NS_Item__c, 
                                        Inital_NS_Item__r.GA__c, 
                                        Inital_NS_Item__r.NS_3PP_Vendor_ID__c, 
                                        Inital_NS_Item__r.NS_Cost_Centre_ID__c, 
                                        Inital_NS_Item__r.NS_Default_Delivered__c, 
                                        Inital_NS_Item__r.NS_Default_OpenAir_Billing_Rule_Int_ID__c,
                                        Inital_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c, 
                                        Inital_NS_Item__r.NS_Product_Dimension_ID__c, 
                                        Inital_NS_Item__r.NS_Rev_Rec_Template_ID__c, 
                                        Inital_NS_Item__r.Payaway__c, 
                                        Inital_NS_Item__r.UPID__c, 
                                        Inital_NS_Item__r.NS_Internal_ID__c,
                                        Initial_Sales_Order_Type__c, 
                                        Initial_Sovos_Code__c,
                                        Internal_Costs__c,
                                        Last_Prorata_Calculated__c, 
                                        Last_Prorata_required__c, 
                                        Licence_Band__c, 
                                        License_Metric__c, 
                                        LineItem_Process_Type__c, 
                                        List_Per_Diem_Value__c, 
                                        Location__c, 
                                        Next_SO_generation_Date__c, 
                                        NonBillable_Hours_Total__c, 
                                        NS_Deferred_Revenue_Acct_ID__c, 
                                        Opportunity_Billing_Schedule__c,
                                        Pearl_Internal_Cost__c,
                                        Pro_Rata_Calculated__c, 
                                        Prorata_Days__c,
                                        Recurring_Sales_Order_Type__c, 
                                        RF_Start_Planned__c,
                                        RF_Start_Planned_Date__c, 
                                        Reimbursable_Costs_Estimate__c, 
                                        Reimbursable_Costs_Recovery_Value__c, 
                                        SBQQ__BillingType__c, 
                                        SBQQ__EndDate__c, 
                                        SBQQ__PartnerDiscount__c, 
                                        SBQQ__Product__c, 
                                        SBQQ__Product__r.GA__c, 
                                        SBQQ__Product__r.Name, 
                                        SBQQ__Product__r.NS_Create_3PP_Event__c, 
                                        SBQQ__Product__r.ThirdParty_PO_Currency__c,
                                        SBQQ__Product__r.NS_Default_OpenAir_Billing_Rule_Int_ID__c, 
                                        SBQQ__Product__r.NS_Deferred_Revenue_Acct_ID__c, 
                                        SBQQ__Product__r.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c, 
                                        SBQQ__Product__r.NS_Rev_Rec_Template_ID__c, 
                                        SBQQ__Quantity__c, 
                                        SBQQ__ListPrice__c,
                                        SBQQ__StartDate__c,
                                        SBQQ__UnitCost__c, 
                                        Sold_Per_Diem_Value__c, 
                                        Sold_Value__c,
                                        Ship_From_Code__c,
                                        ThirdParty_Contractor_Cost_Sold_Ccy__c, 
                                        ThirdParty_Costs_PO_Ccy__c,                                        
                                        ThirdParty_Costs_Sold_Ccy__c, 
                                        ThirdParty_PO_Currency__c, 
                                        Transactional__c ,
                                        Transactions__c ,
                                        ThirdParty_Recurring_Costs_PO_Ccy__c, 
                                        Total_Chargeable_Hours__c, 
                                        Travel_Hours_Total__c, 
                                        unrecoverable_costs__c
                                        FROM
                                        SBQQ__Subscription__c
                                        WHERE
                                        //Initial_Sales_Order_Type__c in: groupMap.keySet() 
                                        Initial_Sales_Order_Type__c LIKE 'ILF%' 
                                        And Inital_NS_Item__c != null
                                        AND Billing_Group__c = : bgId
                                        ORDER BY
                                        Initial_Sales_Order_Type__c
                                       ]){
                                           
                                           subList.add(sub);                                            
                                           String str = sub.Initial_Sales_Order_Type__c;    
                                           group_subList_Map.put(str, subList);
                                           system.debug('total soitem size => ' + group_subList_Map);
                                           if(groupMap.get(str) == subList.size()){                                                 
                                               subList = new List<SBQQ__Subscription__c>();
                                           }
                                       }
        system.debug('mark here ILF => '+group_subList_Map.values());
        
        for(String s: group_subList_Map.KeySet()){
            system.debug(' soType => '+s+' , size => '+group_subList_Map.get(s).size());
        }
        return group_subList_Map;
    }
    
    public static Map<String, List<SBQQ__Subscription__c>> getSubsByType_RLF(Map<String, Integer> groupMap, Id bgId){    
        Map<String, List<SBQQ__Subscription__c>> group_subList_Map = new Map<String, List<SBQQ__Subscription__c>>();   
        List<SBQQ__Subscription__c> refList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub2: [SELECT
                                         Id, 
                                         Billing_Day__c,
                                         Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode, 
                                         Billing_Group__r.CurrencyIsoCode,
                                         Billing_Month__c, 
                                         Comm_Man_Price__c, 
                                         Contractor_Hours_Total__c, 
                                         Discount_premium__c,
                                         Expiry_Date__c, 
                                         Fair_Value__c, 
                                         Fair_Value_Adjustment__c,
                                         ILF_Fair_Value__c ,
                                         Inital_NS_Item__c, 
                                         Inital_NS_Item__r.GA__c, 
                                         Inital_NS_Item__r.NS_Cost_Centre_ID__c, 
                                         Inital_NS_Item__r.NS_Default_Delivered__c, 
                                         Inital_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c, 
                                         Inital_NS_Item__r.NS_Product_Dimension_ID__c, 
                                         Inital_NS_Item__r.NS_Rev_Rec_Template_ID__c, 
                                         Inital_NS_Item__r.Payaway__c, 
                                         Inital_NS_Item__r.UPID__c,
                                         Inital_NS_Item__r.NS_Internal_ID__c,
                                         Initial_Sales_Order_Type__c,
                                         Initial_Sovos_Code__c,
                                         Internal_Costs__c, 
                                         Last_Prorata_Calculated__c, 
                                         Last_Prorata_required__c, 
                                         Licence_Band__c, 
                                         License_Metric__c, 
                                         LineItem_Process_Type__c, 
                                         List_Per_Diem_Value__c, 
                                         Location__c, 
                                         Next_billing_Date__c,  
                                         Next_SO_generation_Date__c, 
                                         NonBillable_Hours_Total__c, 
                                         NS_Deferred_Revenue_Acct_ID__c, 
                                         Opportunity_Billing_Schedule__c, 
                                         Pearl_Internal_Cost__c,
                                         Pro_Rata_Calculated__c, 
                                         Prorata_Days__c,
                                         Recurring_NS_Item__c,
                                         Recurring_NS_Item__r.GA__c,
                                         Recurring_NS_Item__r.NS_Default_Delivered__c,
                                         Recurring_NS_Item__r.NS_Cost_Centre_ID__c,
                                         Recurring_NS_Item__r.NS_Form_ID__c,
                                         Recurring_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c,
                                         Recurring_NS_Item__r.NS_Internal_ID__c,
                                         Recurring_NS_Item__r.NS_Product_Dimension_ID__c,
                                         Recurring_NS_Item__r.NS_Rev_Rec_Template_ID__c,
                                         Recurring_Sales_Order_Type__c, 
                                         RF_Start_Planned__c,
                                         RF_Start_Planned_Date__c,
                                         Recurring_Sovos_Code__c,
                                         Reimbursable_Costs_Estimate__c, 
                                         Reimbursable_Costs_Recovery_Value__c, 
                                         SBQQ__BillingFrequency__c, 
                                         SBQQ__BillingType__c, 
                                         SBQQ__EndDate__c, 
                                         SBQQ__NetPrice__c, 
                                         SBQQ__PartnerDiscount__c, 
                                         SBQQ__Product__c, 
                                         SBQQ__Product__r.GA__c, 
                                         SBQQ__Product__r.Name, 
                                         SBQQ__Product__r.NS_Create_3PP_Event__c, 
                                         SBQQ__Product__r.NS_Default_OpenAir_Billing_Rule_Int_ID__c, 
                                         SBQQ__Product__r.NS_Deferred_Revenue_Acct_ID__c, 
                                         SBQQ__Product__r.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c, 
                                         SBQQ__Product__r.NS_Rev_Rec_Template_ID__c, 
                                         SBQQ__Quantity__c, 
                                         SBQQ__StartDate__c,
                                         SBQQ__ListPrice__c,
                                         SBQQ__UnitCost__c, 
                                         SO_Generation_Advance__c, 
                                         Sold_Per_Diem_Value__c, 
                                         Sold_Value__c,
                                         Ship_From_Code__c,
                                         ThirdParty_Contractor_Cost_Sold_Ccy__c, 
                                         ThirdParty_Costs_PO_Ccy__c, 
                                         ThirdParty_PO_Currency__c,
                                         ThirdParty_Costs_Sold_Ccy__c, 
                                         ThirdParty_Recurring_Costs_PO_Ccy__c, 
                                         Total_Chargeable_Hours__c, 
                                         Transactional__c ,
                                         Transactions__c ,
                                         Travel_Hours_Total__c, 
                                         unrecoverable_costs__c, 
                                         X3PP_Discount__c,
                                         X3PP_Currency__c
                                         FROM
                                         SBQQ__Subscription__c
                                         WHERE
                                         Recurring_Sales_Order_Type__c in: groupMap.keySet() 
                                         AND Billing_Group__c = : bgId 
                                         AND Recurring_Sales_Order_Type__c != null
                                         AND Recurring_NS_Item__c != null
                                         ORDER BY
                                         Recurring_Sales_Order_Type__c
                                        ]){
                                            refList.add(sub2);
                                            
                                            if(groupMap.get(sub2.Recurring_Sales_Order_Type__c) == refList.size()){   
                                                group_subList_Map.put(sub2.Recurring_Sales_Order_Type__c, refList);
                                                refList = new List<SBQQ__Subscription__c>();
                                            }
                                        }
        system.debug('mark here RLF => '+group_subList_Map.values());
        
        for(String s: group_subList_Map.KeySet()){
            system.debug(' soType => '+s+' , size => '+group_subList_Map.get(s).size());
        }
        return group_subList_Map;
    } 
    
    // new ns proj proces 
    public static Map<String, String> getMaxAmountSubIdsMap(Billing_Group__c bg){
        Map < String, String > Sub_by_grouping_Map = new Map < String, String > ();
        
        // sorting ILF and PS Process
        Integer currValue = 0, prevValue = 0;
        String temp;
        for (AggregateResult ar: [select Initial_Sales_Order_Type__c soType, Id record, MAX(Sold_Value__c) amount from SBQQ__Subscription__c WHERE Billing_Group__c = : bg.Id AND Initial_Sales_Order_Type__c LIKE 'ILF%' and Sold_Value__c != null GROUP BY Initial_Sales_Order_Type__c,Id]){
            temp =(String) ar.get('soType');
            currValue = Integer.valueOf((Decimal) ar.get('amount'));
            if(temp.contains('ILF') && prevValue <= currValue){
                Sub_by_grouping_Map.put(temp, (String) ar.get('record'));
                prevValue = currValue;
            } else if(temp.contains('PS')){
                Sub_by_grouping_Map.put(temp, (String) ar.get('record'));
            }            
        }        
        system.debug('NS proj map => ' + Sub_by_grouping_Map);
        
        return Sub_by_grouping_Map;
    }
    
    public static Map<String, SBQQ__Subscription__c> getProjSubMap(Map<String, String> soType_subs_map){
        Map<String, SBQQ__Subscription__c> returnMap = new Map<String, SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub: [SELECT Id, 
                                        Billing_Day__c, 
                                        Billing_Month__c, 
                                        Billing_Group__c, 
                                        Billing_Group__r.Account_by_Sub__c, 
                                        Billing_Group__r.Account_by_Sub__r.Account__r.NS_Finance_Region__c, 
                                        Billing_Group__r.Account_by_Sub__r.Misys_Entity__c, 
                                        Billing_Group__r.CurrencyIsoCode, 
                                        Billing_Group__r.Original_Contract__r.CustomerSignedDate, 
                                        Billing_Group__r.Original_Opportunity__c, 
                                        Billing_Group__r.Original_Opportunity__r.CloseDate, 
                                        Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode, 
                                        Billing_Group__r.Original_Opportunity__r.ForecastCategoryName, 
                                        Billing_Group__r.Original_Opportunity__r.NS_Project_Service_Type__c, 
                                        Billing_Group__r.Original_Opportunity__r.OA_Project_Director__c, 
                                        Billing_Group__r.Original_Opportunity__r.OA_Project_Manager__c, 
                                        Billing_Group__r.Original_Opportunity__r.Order_Number__c, 
                                        Billing_Group__r.Original_Opportunity__r.Probability, 
                                        Billing_Group__r.Original_Opportunity__r.Project_Template__c, 
                                        Billing_Group__r.Original_Opportunity__r.PS_FC_Start_Date2__c, 
                                        Billing_Group__r.Original_Opportunity__r.PS_Forecast_Probability__c, 
                                        Billing_Group__r.Original_Opportunity__r.PS_Practice_Name__c, 
                                        Billing_Group__r.Original_Opportunity__r.PS_Practice_Unique_Code__c, 
                                        Billing_Group__r.Original_Opportunity__r.PS_Top_Opportunity__c, 
                                        Billing_Group__r.Original_Opportunity__r.StageName, 
                                        Comm_Man_Price__c, 
                                        Contractor_Hours_Total__c, 
                                        Discount_Premium__c,
                                        Expiry_Date__c ,
                                        Fair_Value__c, 
                                        Fair_Value_Adjustment__c, 
                                        GA__c, 
                                        ILF_Fair_Value__c ,
                                        Inital_NS_Item__c, 
                                        Inital_NS_Item__r.GA__c, 
                                        Inital_NS_Item__r.NS_3PP_Vendor_ID__c, 
                                        Inital_NS_Item__r.NS_Cost_Centre_ID__c, 
                                        Inital_NS_Item__r.NS_Default_Delivered__c, 
                                        Inital_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c, 
                                        Inital_NS_Item__r.NS_Product_Dimension_ID__c, 
                                        Inital_NS_Item__r.NS_Rev_Rec_Template_ID__c, 
                                        Inital_NS_Item__r.Payaway__c, 
                                        Inital_NS_Item__r.UPID__c, 
                                        Initial_Price__c,
                                        Initial_Sovos_Code__c,
                                        Initial_Sales_Order_Type__c, 
                                        Initial_SO_Formula__c, 
                                        Internal_Costs__c,
                                        Last_Prorata_Calculated__c, 
                                        Last_Prorata_required__c, 
                                        Licence_Band__c, 
                                        License_Metric__c, 
                                        LineItem_Process_Type__c, 
                                        List_Per_Diem_Value__c, 
                                        Location__c, 
                                        Name, 
                                        Next_SO_generation_Date__c, 
                                        NonBillable_Hours_Total__c, 
                                        NS_Deferred_Revenue_Acct_ID__c, 
                                        Opportunity_Billing_Schedule__c, 
                                        Opportunity_Billing_Schedule__r.Name, 
                                        Pearl_Internal_Cost__c,
                                        Pro_Rata_Calculated__c,
                                        Prorata_Days__c,
                                        Recurring_NS_Item__c, 
                                        Recurring_NS_Item__r.NS_Rev_Rec_Template_ID__c,
                                        Recurring_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c,
                                        Recurring_Sales_Order_Type__c,
                                        RF_Start_Planned__c,
                                        RF_Start_Planned_Date__c, 
                                        Reimbursable_Costs_Estimate__c, 
                                        Reimbursable_Costs_Recovery_Value__c, 
                                        SBQQ__BillingType__c, 
                                        SBQQ__EndDate__c, 
                                        SBQQ__NetPrice__c, 
                                        SBQQ__PartnerDiscount__c, 
                                        SBQQ__Product__c, 
                                        SBQQ__Product__r.GA__c, 
                                        SBQQ__Product__r.Name, 
                                        SBQQ__Product__r.NS_Cost_Centre_ID__c, 
                                        SBQQ__Product__r.NS_Create_3PP_Event__c, 
                                        SBQQ__Product__r.NS_Default_OpenAir_Billing_Rule_Int_ID__c, 
                                        SBQQ__Product__r.NS_Deferred_Revenue_Acct_ID__c, 
                                        SBQQ__Product__r.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c, 
                                        SBQQ__Product__r.NS_Product_Dimension_ID__c, 
                                        SBQQ__Product__r.NS_Rev_Rec_Template__c, 
                                        SBQQ__Product__r.NS_Rev_Rec_Template_ID__c, 
                                        SBQQ__Quantity__c,
                                        SBQQ__StartDate__c,
                                        SBQQ__UnitCost__c, 
                                        SO_Grouping__c, 
                                        Sold_Per_Diem_Value__c, 
                                        Sold_Value__c, 
                                        Ship_From_Code__c,
                                        ThirdParty_Contractor_Cost_Sold_Ccy__c, 
                                        ThirdParty_Costs_Sold_Ccy__c, 
                                        ThirdParty_PO_Currency__c, 
                                        
                                        ThirdParty_Recurring_Costs_PO_Ccy__c, 
                                        Total_Chargeable_Hours__c, 
                                        Transactional__c ,
                                        Transactions__c ,
                                        Travel_Hours_Total__c, 
                                        Unrecoverable_Costs__c, 
                                        X3PP_Discount__c
                                        FROM
                                        SBQQ__Subscription__c
                                        WHERE
                                        Id = : soType_subs_map.Values() 
                                        AND Initial_Sales_Order_Type__c != null
                                        And Inital_NS_Item__c != null
                                       ]){
                                           returnMap.put(sub.Id, sub);
                                       }
        
        return returnMap;
    }
    
    public static Map<Id, List<Date>> sortBillingDates(SBQQ__Subscription__c[] subs){
        Map<Id, List<SBQQ__Subscription__c>> bg_subs_map = new Map<Id, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> tempList;
        for(SBQQ__Subscription__c sub: subs){
            tempList = new List<SBQQ__Subscription__c>();
            if(bg_subs_map.get(sub.Billing_Group__c) != null){
                tempList = bg_subs_map.get(sub.Billing_Group__c);
            } 
            tempList.add(sub);
            bg_subs_map.put(sub.Billing_Group__c, tempList);            
        }
        system.debug(bg_subs_map);
        return sortBdSubs(bg_subs_map);
    }
    
    @TestVisible private static Map<Id, List<Date>> sortBdSubs(Map<Id, List<SBQQ__Subscription__c>> bg_subs_map){
        
        Map<Id, List<Date>> returnMap = new Map<Id, List<Date>>();
        Date earliestNextBillingDate, earliestNextSoDate;
        
        for(Id billingId: bg_subs_map.keySet()){
            // init dates
            earliestNextBillingDate = Date.newInstance(9999, 12, 31);
            earliestNextSoDate = Date.newInstance(9999, 12, 31);
            for(SBQQ__Subscription__c sub: bg_subs_map.get(billingId)){
                if (sub.Next_billing_Date__c < earliestNextBillingDate) {
                    earliestNextBillingDate = sub.Next_Billing_Date__c;
                }
                if (sub.Next_SO_generation_Date__c < earliestNextSoDate) {
                    earliestNextSoDate = sub.Next_SO_generation_Date__c;
                }
            }
            returnMap.put(billingId, new List<Date>{earliestNextBillingDate, earliestNextSoDate});
        }  
        
        return returnMap;
    }
    
    // Add On Subs
    // Needed for CPQ billing(Including Quote)
    public static Map<String, List<SBQQ__Subscription__c>> getIlfRlfAddonSubsCount(Id bgId){
        Map<String, List<SBQQ__Subscription__c>> returnMap = new Map<String, List<SBQQ__Subscription__c>>();
        List<SBQQ__Subscription__c> tempSubs = new List<SBQQ__Subscription__c>();
        try{
            tempSubs = [SELECT Id, 
                        Billing_Day__c, 
                        Billing_Month__c, 
                        Billing_Group__c, 
                        Billing_Group__r.Account_by_Sub__c, 
                        Billing_Group__r.Account_by_Sub__r.Account__r.NS_Finance_Region__c, 
                        Billing_Group__r.Account_by_Sub__r.Misys_Entity__c, 
                        Billing_Group__r.CurrencyIsoCode, 
                        Billing_Group__r.Original_Contract__r.CustomerSignedDate, 
                        Billing_Group__r.Original_Opportunity__c, 
                        Billing_Group__r.Original_Opportunity__r.CloseDate, 
                        Billing_Group__r.Original_Opportunity__r.CurrencyIsoCode, 
                        Billing_Group__r.Original_Opportunity__r.ForecastCategoryName, 
                        Billing_Group__r.Original_Opportunity__r.NS_Project_Service_Type__c, 
                        Billing_Group__r.Original_Opportunity__r.OA_Project_Director__c, 
                        Billing_Group__r.Original_Opportunity__r.OA_Project_Manager__c, 
                        Billing_Group__r.Original_Opportunity__r.Order_Number__c, 
                        Billing_Group__r.Original_Opportunity__r.Probability, 
                        Billing_Group__r.Original_Opportunity__r.Project_Template__c, 
                        Billing_Group__r.Original_Opportunity__r.PS_FC_Start_Date2__c, 
                        Billing_Group__r.Original_Opportunity__r.PS_Forecast_Probability__c, 
                        Billing_Group__r.Original_Opportunity__r.PS_Practice_Name__c, 
                        Billing_Group__r.Original_Opportunity__r.PS_Practice_Unique_Code__c, 
                        Billing_Group__r.Original_Opportunity__r.PS_Top_Opportunity__c, 
                        Billing_Group__r.Original_Opportunity__r.StageName, 
                        Comm_Man_Price__c, 
                        Contractor_Hours_Total__c, 
                        Discount_Premium__c,
                        Expiry_Date__c ,
                        Fair_Value__c, 
                        Fair_Value_Adjustment__c, 
                        GA__c, 
                        ILF_Fair_Value__c ,
                        Inital_NS_Item__c, 
                        Inital_NS_Item__r.GA__c, 
                        Inital_NS_Item__r.NS_3PP_Vendor_ID__c, 
                        Inital_NS_Item__r.NS_Cost_Centre_ID__c, 
                        Inital_NS_Item__r.NS_Default_Delivered__c, 
                        Inital_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c, 
                        Inital_NS_Item__r.NS_Product_Dimension_ID__c, 
                        Inital_NS_Item__r.NS_Rev_Rec_Template_ID__c, 
                        Inital_NS_Item__r.Payaway__c, 
                        Inital_NS_Item__r.UPID__c, 
                        Initial_Price__c,
                        Initial_Sovos_Code__c,
                        Initial_Sales_Order_Type__c, 
                        Initial_SO_Formula__c, 
                        Internal_Costs__c,
                        Last_Prorata_Calculated__c, 
                        Last_Prorata_required__c, 
                        Licence_Band__c, 
                        License_Metric__c, 
                        LineItem_Process_Type__c, 
                        List_Per_Diem_Value__c, 
                        Location__c, 
                        Name, 
                        Next_SO_generation_Date__c, 
                        NonBillable_Hours_Total__c, 
                        NS_Deferred_Revenue_Acct_ID__c, 
                        Opportunity_Billing_Schedule__c, 
                        Opportunity_Billing_Schedule__r.Name, 
                        Pearl_Internal_Cost__c,
                        Pro_Rata_Calculated__c,
                        Prorata_Days__c,
                        Recurring_NS_Item__c, 
                        Recurring_NS_Item__r.NS_Rev_Rec_Template_ID__c,
                        Recurring_NS_Item__r.NS_Deferred_Revenue_Acct_ID__c,
                        Recurring_Sales_Order_Type__c,
                        RF_Start_Planned__c,
                        RF_Start_Planned_Date__c, 
                        Reimbursable_Costs_Estimate__c, 
                        Reimbursable_Costs_Recovery_Value__c, 
                        SBQQ__BillingType__c, 
                        SBQQ__EndDate__c, 
                        SBQQ__NetPrice__c,
                        SBQQ__ListPrice__c, 
                        SBQQ__PartnerDiscount__c, 
                        SBQQ__Product__c, 
                        SBQQ__Product__r.GA__c, 
                        SBQQ__Product__r.Name, 
                        SBQQ__Product__r.NS_Cost_Centre_ID__c, 
                        SBQQ__Product__r.NS_Create_3PP_Event__c, 
                        SBQQ__Product__r.NS_Default_OpenAir_Billing_Rule_Int_ID__c, 
                        SBQQ__Product__r.NS_Deferred_Revenue_Acct_ID__c, 
                        SBQQ__Product__r.NS_OpenAir_Rev_Rec_Rule_Internal_ID__c, 
                        SBQQ__Product__r.NS_Product_Dimension_ID__c, 
                        SBQQ__Product__r.NS_Rev_Rec_Template__c, 
                        SBQQ__Product__r.NS_Rev_Rec_Template_ID__c,
                        SBQQ__Product__r.ThirdParty_PO_Currency__c,
                        SBQQ__Quantity__c,
                        SBQQ__StartDate__c,
                        SBQQ__UnitCost__c, 
                        Ship_From_Code__c,
                        SO_Grouping__c, 
                        Sold_Per_Diem_Value__c, 
                        Sold_Value__c, 
                        ThirdParty_Contractor_Cost_Sold_Ccy__c, 
                        ThirdParty_Costs_Sold_Ccy__c, 
                        ThirdParty_Costs_PO_Ccy__c, 
                        ThirdParty_PO_Currency__c, 
                        
                        ThirdParty_Recurring_Costs_PO_Ccy__c, 
                        Total_Chargeable_Hours__c, 
                        Transactional__c ,
                        Transactions__c ,
                        Travel_Hours_Total__c, 
                        Unrecoverable_Costs__c, 
                        X3PP_Discount__c FROM SBQQ__Subscription__c WHERE Initial_Sales_Order_Type__c LIKE 'ILF%' And Inital_NS_Item__c != null AND Billing_Group__c =: bgId AND Origin__c = 'Add On' and Create_Add_On_ILF_RLF__c = true];
            returnMap.put('ILF', tempSubs);
        } Catch(Exception Ex){
            system.debug('No ILF Addon Subs found for Billing Group');
        }
        
        try{
            tempSubs = new List<SBQQ__Subscription__c>();
            tempSubs = [SELECT Id, Name FROM SBQQ__Subscription__c WHERE Recurring_Sales_Order_Type__c LIKE 'RLF%' And Inital_NS_Item__c != null AND Billing_Group__c =: bgId AND Origin__c = 'Add On' AND Create_Add_On_ILF_RLF__c = true AND RF_Start_planned_date__c = TODAY]; 
            returnMap.put('RLF', tempSubs);
        } Catch(Exception Ex){
            system.debug('No RLF Addon Subs found for Billing Group');
        }
        system.debug('In Addon Subs Sorting => '+returnMap);
        return returnMap;
    }
    
}