public class SO_ExecuteProcess {
    
    public static string createWithContract(Contract contract){
        // STEP 1 - BG Creation     
        //Savepoint sp = Database.setSavepoint();   
        Billing_Group__c bg = SO_BillingGroupHelper.BillingGroupCreation(contract);
        system.debug('Created Billing Group');
        string temp = 'Billing Group & Sales Order Created successfully\n';
        string response = createWithBG(bg, 'pass', contract);
        system.debug('printing response => '+response);
        if(response.contains('Failed')) { 
            //Database.rollback(sp); 
			return response; 
        } 
        return temp;
    }
    
    public static String createWithBG(Billing_Group__c bg, String orderType, Contract con){
        // Initate all helper classes
        String sMsg, eMsg;
        Map < String, String > nsProductMap = SO_SalesOrderMapUtils.getNSProduct_map();
        Map < String, NS_Cost_Centre__c > nsCostCenterMap = SO_SalesOrderMapUtils.getNSCostCenter_map();
        Map < String, NS_Currency__c > nsCurrencyMap = SO_SalesOrderMapUtils.getNSCurrency_map();
        map<String, NS_Revenue_Recognition_Template__c> revRecScheduleMap = SO_SalesOrderMapUtils.getRevScheduleMap();
        map<String, NS_OpenAir_Revenue_Rules__c> internalIdOARevenueRuleMap = SO_SalesOrderMapUtils.getIntIdOARevRuleMap();
        map<String, NS_List_Table__c> internalIdOABillingRuleMap = SO_SalesOrderMapUtils.getIntIdOABillingRuleMap();
        Map<String, Product2> prod2UPID = SO_SalesOrderMapUtils.getUPID();
        Map<String, NS_Account__c>  NsAccountMap = SO_SalesOrderMapUtils.getNsAccMap();
        
        
        // STEP 2 - Assing BG to Subs - needed for ILF/RLF
        
        try{
            //if(orderType == 'RLF' || orderType == 'ILF' || orderType == 'PS')
            SO_BillingGroupHelper.addBGtoSubscriptions(bg);
            sMsg = '• Assigned Billing Group to Subscriptions';
        } Catch(Exception Ex){ return 'Failed to Create STEP 2';                     
        }
        savepoint sp = Database.setSavepoint();
        // STEP 3 - Grouping Subscriptions based on Process Type - needed for ILF/RLF
        
        Map<String, Integer> soType_counter_Map = new Map<String, Integer>();
        Map<String, List<SBQQ__Subscription__c>> ps_subs_map = new Map<String, List<SBQQ__Subscription__c>>();
        try {
            soType_counter_Map = SO_SubscriptionsGrouping.sortbyProcess(bg);       
            ps_subs_map = SO_SubscriptionsGrouping.getSubsByTypeForPs(bg);
            // adding PS values to map
            for(String soType: ps_subs_map.keySet()){
                soType_counter_Map.put(soType, ps_subs_map.get(soType).size());
            }
        } Catch(Exception Ex){ Database.rollback(sp);  return 'Failed to Create STEP 3';
        }
        
        // STEP 4 - building a map which returns subs for each So Type - needed for ILF/RLF
      
        if(soType_counter_Map.size() > 0){
            Map<String, List<SBQQ__Subscription__c>> soType_subs_map = new Map<String, List<SBQQ__Subscription__c>>();
            try{
                soType_subs_map =  SO_SubscriptionsGrouping.getSubsByType(soType_counter_Map, bg.Id);  
                // adding PS values to map
                for(String soType: ps_subs_map.keySet()){
                    soType_subs_map.put(soType, ps_subs_map.get(soType));
                }
            } Catch(Exception Ex){ Database.rollback(sp);  return 'Failed to Create STEP 4';
            }
            
            // Initiate maps for creating NS Project creation ~ Exclusive for ILF/PS
            
            Boolean isHolidayUpdated = false;
            Map<String, List<SBQQ__Subscription__c>> soType_subs_map_rlf = new Map<String, List<SBQQ__Subscription__c>>();
            
            if(orderType != 'RLF'){
                Map<String, String> soType_subId_map = SO_SubscriptionsGrouping.getMaxAmountSubIdsMap(bg);
                system.debug('soType_subId_map => '+soType_subId_map);
                Double tempMax = 0;
                for(String soType: ps_subs_map.keySet()){
                    for(SBQQ__Subscription__c sub: ps_subs_map.get(soType)){
                        if(sub.Sold_Value__c >= tempMax){
                           soType_subId_map.put(soType, sub.Id); 
                        }
                    }
                }
                Map<String, SBQQ__Subscription__c> subs_map = SO_SubscriptionsGrouping.getProjSubMap(soType_subId_map);
                
                system.debug('obs_sub_map =>'+subs_map);
                
                // STEP 5 - Create NS Project        
                Map<String, NS_Project__c> soType_project_map = new Map<String, NS_Project__c>();
                
                try{
                    soType_project_map = SO_NSProjectHelper.createNSProject(soType_subId_map, subs_map, nsCurrencyMap, NsCostCentermap, nsProductMap);            
                    sMsg += '• NS Project Created Successfully\n';
                } Catch(Exception Ex){ Database.rollback(sp);  return 'Failed to Create NS Project - error at line # '+ex.getLineNumber()+' cause => '+ex.getMessage()+' class name '+ex.getStackTraceString();
                }
                
                // STEP 6 - Create Initial Sales Order 
                List<Sales_Order__c> soList = new List<Sales_order__c>();
                try{
                    soList = SO_SalesOrderHelper.createSalesOrder(bg, soType_counter_Map, soType_project_map, nsCurrencyMap, nsProductMap,/* fixedBillingMap,*/ nsCostCenterMap, orderType, subs_map, NsAccountMap);
                } Catch(Exception Ex){ Database.rollback(sp); return 'Failed to Create Sales Order - error at line # '+ex.getLineNumber()+' cause => '+ex.getMessage()+' class name '+ex.getStackTraceString();
                }
                
                // Update Sales Order in Customer Billing Schedule Under NS Project
                
                try{
                    if(soList.size() > 0) {
                        SO_SalesOrderHelper.updateCustomerBillingSchedule(soList);
                    }
                } Catch(Exception Ex){ Database.rollback(sp); return 'Failed to Update SO in NS-CBS - error at line # '+ex.getLineNumber()+' cause => '+ex.getMessage()+' class name '+ex.getStackTraceString();
                }
                
                // STEP 7 - Create Initial Sales Order Items
                try{
                    if(soList.size() > 0) {
                        Map<string, string> proj_obs_map = new Map<String, string>();
                        for(NS_Project__c proj: soType_project_map.values()){
                            proj_obs_map.put(proj.Id, proj.Project_Type__c);
                        }
                        SO_SalesOrderHelper.createSalesOrderItems(soList, soType_subs_map, nsCurrencyMap, revRecScheduleMap, internalIdOARevenueRuleMap, internalIdOABillingRuleMap, proj_obs_map, prod2UPID);
                    }
                    else {
                        system.debug('Zero Sales Order Created for ILF/PS');
                        //response += '\n Zero SO Items';
                            //Database.rollback(sp);
                        //return 'Zero SO items';
                    }
                } Catch(Exception Ex){ Database.rollback(sp); return 'Failed to Create SO items - error at line # '+ex.getLineNumber()+' cause => '+ex.getMessage()+' class name '+ex.getStackTraceString();
                }
                
                // Update Holiday Period if there is any holiday on Contract 
                if(con.Recurring_Fees_Start_Planned__c != null && con.Recurring_Fees_Start_Planned__c > system.today()){
                    // following method updates billing date with holiday end date
                    soType_subs_map_rlf = new Map<String, List<SBQQ__Subscription__c>>();
                    soType_subs_map_rlf = SO_SubscriptionsGrouping.getSubsByType_RLF(soType_counter_Map, bg.Id); 
                    SO_SalesOrderHelper.updateHolidayPeriod(soType_subs_map_rlf, con); 
                    isHolidayUpdated = true;
                }
                
            }// ILF/PS - logic end
            
            // STEP 8 - update holidays in next billing date only for ILF/PS
            system.debug('RLF SO Process =>'+orderType);
            
            if( (orderType != null && !isHolidayUpdated ) || Test.isRunningTest()){
                system.debug('here for creating RLF');            
                if(con.Recurring_Fees_Start_Planned__c <= System.today() || Test.isRunningTest()){
                    soType_subs_map_rlf = new Map<String, List<SBQQ__Subscription__c>>();
                    soType_subs_map_rlf = SO_SubscriptionsGrouping.getSubsByType_RLF(soType_counter_Map, bg.Id); 
                    SO_SalesOrderHelper.calculateProrata(soType_subs_map_rlf, con); 
                }  
                if(soType_subs_map_rlf.size() > 0){
                    SBQQ__Subscription__c subMax = new SBQQ__Subscription__c();
                    Double tempMax = 0;
                    for(String s: soType_subs_map_rlf.keySet()){
                        for(SBQQ__Subscription__c sub: soType_subs_map_rlf.get(s)){
                            if(sub.SBQQ__NetPrice__c >= tempMax){
                                subMax = sub; 
                            }
                            tempMax = sub.SBQQ__NetPrice__c;
                        }
                    } 
                    Sales_Order__c rlfSo;
                    if(subMax != null) {
                        rlfSo = RLFPackage_ListInit.addRLFSalesOrder(bg, nsCurrencyMap, nsProductMap, nsCostCenterMap,/* fixedBillingMap,*/ 'RLF', subMax);                
                        try{
                            insert rlfSo;
                        } Catch (Exception Ex){ Database.rollback(sp);  
                            system.debug('RLF Sales Order Insertion Failed; error => '+ex.getMessage());
                        }
                    }
                    // Create RLF SO Items
                    system.debug('RLF So ITems loop started => '+soType_subs_map_rlf);
                    List < Sales_Order_Item__c > itemsList = new List < Sales_Order_Item__c > ();
                    Integer ii = 0;
                    for(String s: soType_subs_map_rlf.keySet()){
                        for(SBQQ__Subscription__c sub: soType_subs_map_rlf.get(s)){
                            system.debug('adding RLF So Items ');
                            itemsList.add(RLFPackage_ListInit.addRLFSalesOrderItem(sub, nsCurrencyMap, revRecScheduleMap, ii, rlfSo));
                            ii++; 
                        }
                    }               
                    
                    if(itemsList.size() > 0){
                        try{
                            insert itemsList;
                            system.debug('insert rlf so items '+itemsLIst.size());
                            
                            // Updating Next Billing Date
                            SO_SalesOrderHelper.updateNextBillingDate(bg.Id);
                            
                            // updating prorata calculated check box
                            SO_SalesOrderHelper.updateProrataCalculatedCheckBox(itemsList); 
                            
                        } Catch (Exception Ex){                            
                            system.debug('RLF Sales Order Items Insertion Failed; error => '+ex.getMessage());
                            Database.rollback(sp);  return 'RLF Sales Order Items Insertion Failed; error => '+ex.getMessage();
                        }
                    } else {                        
                        Database.rollback(sp); return 'Zero RLF Items';
                    }
                      
                } 
            }      
        }
        
        return sMsg;
    }
    
}