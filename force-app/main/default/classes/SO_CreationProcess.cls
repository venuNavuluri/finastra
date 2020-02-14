/**
    * @File Name          : SO_CreationProcess.cls
    * @Description        : 
    * @Author             : venu.navuluri@finastra.com
    * @Group              : 
    * @Last Modified By   : venu.navuluri@finastra.com
    * @Last Modified On   : 04/06/2019, 11:46:33
    * @Modification Log   : 
    *==============================================================================
    * Ver         Date                     Author      		      Modification
    *==============================================================================
    * 1.0    15/05/2019, 15:15:57   venu.navuluri@finastra.com     Initial Version
    **/
    public class SO_CreationProcess {
        
        public static string createBGFromContract(Contract contract){
            
            savepoint sp = Database.setSavepoint();
            Billing_Group__c bg = SO_BillingGroupHelper.BillingGroupCreation(contract);
            string success = 'Billing Group & Sales Order(s) Created successfully\n';
            string response = createSOsfromContract(bg, contract);
            if(response.contains('Error')) { 
                Database.rollback(sp);
                return response; 
            } 
            return success;
        }
        public static String createSOsfromContract(Billing_Group__c bg,  Contract con){
            String sMsg, eMsg;
            savepoint sp = Database.setSavepoint();
            try{
                SO_BillingGroupHelper.addBGtoSubscriptions(bg);
                sMsg = '• Assigned Billing Group to Subscriptions';
            } Catch(Exception Ex){
                eMsg = 'Error at line # '+ex.getLineNumber()+' cause => '+ex.getMessage()+' class name '+ex.getStackTraceString();
                Database.rollback(sp);
                return eMsg;                     
            }
            
            Map < String, NS_Currency__c > nsCurrencyMap = SO_SalesOrderMapUtils.getNSCurrency_map();
            Map<String, Integer> soType_counter_Map = new Map<String, Integer>();
            Map<String, List<SBQQ__Subscription__c>> ILF_subs_map = new Map<String, List<SBQQ__Subscription__c>>();
            Map<String, List<SBQQ__Subscription__c>> PS_subs_map = new Map<String, List<SBQQ__Subscription__c>>();
            Map<String, List<SBQQ__Subscription__c>> RLF_subs_map = new Map<String, List<SBQQ__Subscription__c>>();
            Map<String, List<SBQQ__Subscription__c>> soType_subs_map = new Map<String, List<SBQQ__Subscription__c>>();
            
            try {
                ILF_subs_map = SO_RevenueTypeGrouping.getILFsubs(con);
                system.debug('enter ilf revenue type  => '+ILF_subs_map); 
                
                for(String soType: ILF_subs_map.keySet()){
                    soType_counter_Map.put(soType, ILF_subs_map.get(soType).size());
                    soType_subs_map.put(soType, ILF_subs_map.get(soType));
                }
                
                PS_subs_map = SO_RevenueTypeGrouping.getGSsubs(con);
                system.debug('enter PS revenue type  => '+PS_subs_map.keyset().size()); 
                
                for(String soType: ps_subs_map.keySet()){
                    soType_counter_Map.put(soType, ps_subs_map.get(soType).size());
                    soType_subs_map.put(soType, ps_subs_map.get(soType));
                }
                
                RLF_subs_map = SO_RevenueTypeGrouping.getRLFsubs(con);
                system.debug('enter RLF revenue type  => '+RLF_subs_map.keyset().size()); 
                
                for(String soType: RLF_subs_map.keySet()){
                    soType_counter_Map.put(soType, RLF_subs_map.get(soType).size());
                    soType_subs_map.put(soType, RLF_subs_map.get(soType));
                }
            } Catch(Exception Ex){ 
                eMsg = 'Error at line # '+ex.getLineNumber()+' cause => '+ex.getMessage()+' class name '+ex.getStackTraceString();
                Database.rollback(sp);
                return eMsg;
            }
            system.debug('so size => '+soType_counter_Map.size());
            
            if(soType_counter_Map.size() > 0){
                
                Map<String, String> soType_sub_max = new Map<String, String>();
                
                if(ILF_subs_map.size() > 0){
                    Double ILFmax = 0;
                    for(String sMax: ILF_subs_map.keySet()){
                        for(SBQQ__Subscription__c sub: ILF_subs_map.get(sMax)){
                            if(sub.SBQQ__NetPrice__c >= ILFmax){
                                soType_sub_max.put(sMax, sub.Id); 
                            }
                        }
                        // system.debug('ILF max sub => '+soType_sub_max.get(sMax));
                    }
                    system.debug(' Proj list => '+soType_sub_max);
                }
                
                if(PS_subs_map.size() > 0){
                    system.debug('soType_sub_max => '+soType_sub_max);
                    Double GSMax = 0;
                    for(String sMax: ps_subs_map.keySet()){
                        for(SBQQ__Subscription__c sub: ps_subs_map.get(sMax)){
                            if(sub.SBQQ__NetPrice__c >= GSMax){
                                soType_sub_max.put(sMax, sub.Id); 
                            }
                            // system.debug('GS max sub => '+soType_sub_max.get(sMax));
                        }
                        // system.debug('max sub => '+soType_sub_max.get(sMax));
                    }
                    system.debug(' Proj list => '+soType_sub_max);
                }
                
                if(RLF_subs_map.size() > 0){
                    system.debug('soType_sub_max => '+soType_sub_max);
                    Double RLFMax = 0;
                    for(String sMax: RLF_subs_map.keySet()){
                        for(SBQQ__Subscription__c sub: RLF_subs_map.get(sMax)){
                            if(sub.SO_Amount__c >= RLFMax){
                                soType_sub_max.put(sMax, sub.Id); 
                            }
                            //system.debug('RLF max sub => '+soType_sub_max.get(sMax));
                        }
                        // system.debug('max sub => '+soType_sub_max.get(sMax));
                    }
                    system.debug(' Proj list => '+soType_sub_max);
                }
                
                Map<String, SBQQ__Subscription__c> maxSub_map = SO_RevenueTypeGrouping.getProjSubMap(soType_sub_max);
                //system.debug('obs_sub_map =>'+maxSub_map);
                
                // STEP 5 - Create NS Project        
                Map<String, NS_Project__c> soType_project_map = new Map<String, NS_Project__c>();
                
                try{
                    soType_project_map = SO_NSProjectHelper.NSProjectCreation(soType_sub_max, maxSub_map, nsCurrencyMap);            
                    sMsg += '• NS Project Created Successfully\n';
                    system.debug('ns project keysey' + soType_project_map.keyset());
                } Catch(Exception Ex){ 
                    eMsg = 'Error at line # '+ex.getLineNumber()+' cause => '+ex.getMessage()+' class name '+ex.getStackTraceString();
                    Database.rollback(sp);
                    return eMsg;
                }
                
                // STEP 6 - Create Initial Sales Order 
                List<Sales_Order__c> soList = new List<Sales_order__c>();
                try{
                    soList = SO_SOCreationHelper.createSalesOrder(con, bg, soType_counter_Map, soType_project_map, nsCurrencyMap, maxSub_map, soType_sub_max);
                } Catch(Exception Ex){ 
                    eMsg = 'Error at line # '+ex.getLineNumber()+' cause => '+ex.getMessage()+' class name '+ex.getStackTraceString();
                    Database.rollback(sp);
                    return eMsg;
                }
                
                // Update Sales Order in Customer Billing Schedule Under NS Project
                
                try{
                    if(soList.size() > 0) {
                        SO_SOCreationHelper.updateCustomerBillingSchedule(soList);
                    }
                } Catch(Exception Ex){ 
                    eMsg = 'Error at line # '+ex.getLineNumber()+' cause => '+ex.getMessage()+' class name '+ex.getStackTraceString();
                    Database.rollback(sp);
                    return eMsg;
                }
                
                // STEP 7 - Create Initial Sales Order Items
                try{
                    if(soList.size() > 0) {
                        Map<string, string> proj_so_map = new Map<String, string>();
                        for(NS_Project__c proj: soType_project_map.values()){
                            proj_so_map.put(proj.Id, proj.Project_Type__c);
                        }
                        SO_SOCreationHelper.createSalesOrderItems(soList, soType_subs_map, nsCurrencyMap, proj_so_map);
                    }
                } Catch(Exception Ex){ 
                    eMsg = 'Error at line # '+ex.getLineNumber()+' cause => '+ex.getMessage()+' class name '+ex.getStackTraceString();
                    Database.rollback(sp);
                    return eMsg;
                }
                
                
                if(RLF_subs_map.size() > 0){
                    
                    Map<Id, List<SBQQ__Subscription__c>> RLF_prorated_map = new Map<Id, List<SBQQ__Subscription__c>>();
                    List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        
                     for(String s: RLF_subs_map.keySet()){
                            for(SBQQ__Subscription__c sub: RLF_subs_map.get(s)){
                                       subList.add(sub);  
                                       RLF_prorated_map.put(sub.Billing_Group__c, subList);
                                }
                             }
                        system.debug(' prorated list => '+RLF_prorated_map);
                    
                    // Prorate calculation
                    try{
                        RLF_SOCreation.calculateProrata(RLF_prorated_map);
                    } Catch (Exception Ex){
                        eMsg = 'Error at line # '+ex.getLineNumber()+' cause => '+ex.getMessage()+' class name '+ex.getStackTraceString();
                        Database.rollback(sp);
                        return eMsg;
                    }
                    
                    Sales_Order__c RLFso;
                    system.debug('RLF max sub' +maxSub_map.get(soType_sub_max.get('RLF')));
                    RLFso = RLF_SOCreation.addRLFSalesOrder(bg, nsCurrencyMap, maxSub_map.get(soType_sub_max.get('RLF'))); 
                    
                    try{
                        insert RLFso;
                    } Catch (Exception Ex){
                        eMsg = 'Error at line # '+ex.getLineNumber()+' cause => '+ex.getMessage()+' class name '+ex.getStackTraceString();
                        Database.rollback(sp);
                        return eMsg;
                    }
                    
                    // Create RLF SO Items
                    
                    List < Sales_Order_Item__c > itemsList = new List < Sales_Order_Item__c > ();
                    Integer ii = 0;
                    for(String s: RLF_subs_map.keySet()){
                        for(SBQQ__Subscription__c sub: RLF_subs_map.get(s)){
                            system.debug('adding RLF So Items ');
                            itemsList.add(RLF_SOCreation.addRLFSalesOrderItem(sub, nsCurrencyMap, ii, RLFso));
                            ii++; 
                        }
                    }               
                    
                    if(itemsList.size() > 0){
                        try{
                            insert itemsList;
                            RLF_SOCreation.updateProrataCalculatedCheckBox(itemsList); 
                            
                            
                        }
                        Catch (Exception Ex){                            
                            eMsg = 'Error at line # '+ex.getLineNumber()+' cause => '+ex.getMessage()+' class name '+ex.getStackTraceString();
                            Database.rollback(sp);
                            return eMsg;
                        }
                    }
                    
                }
                
                try{
                    List<Id> bgIdList = new List<Id>();
                    bgIdList.add(bg.id);
                    RLF_SOCreation.bgDatesUpdate(bgIdList);
                }
                Catch (Exception Ex){                            
                    eMsg = 'Error at line # '+ex.getLineNumber()+' cause => '+ex.getMessage()+' class name '+ex.getStackTraceString();
                    Database.rollback(sp);
                    return eMsg;
                }
                
            }
            
            return sMsg;
        }
    }