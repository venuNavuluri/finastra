public class RLF_Utils {
    
    public static string invoke( Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map, Billing_Group__c bg){
        string msgQueue = '';
        boolean isSuccess = true;
        // INIT Maps
        Map < String, String > nsProductMap = SO_SalesOrderMapUtils.getNSProduct_map();
        //Map < Date, NS_Fixed_Billing_Date__c > fixedBillingMap = SO_SalesOrderMapUtils.getFixedBillingDate_map();
        Map < String, NS_Cost_Centre__c > nsCostCenterMap = SO_SalesOrderMapUtils.getNSCostCenter_map();
        Map < String, NS_Currency__c > nsCurrencyMap = SO_SalesOrderMapUtils.getNSCurrency_map();
        Map<String, NS_Revenue_Recognition_Template__c> revRecScheduleMap = SO_SalesOrderMapUtils.getRevScheduleMap();
        
        // finding max sub - with out query
        Map<Id, SBQQ__Subscription__c> bg_subMax_map = new Map<Id, SBQQ__Subscription__c>();
        SBQQ__Subscription__c subMax = new SBQQ__Subscription__c();    
        Double tempMax = 0;
        for(String s: bg_subList_Map.keySet()){
            for(SBQQ__Subscription__c sub: bg_subList_Map.get(s)){
                if(sub.SBQQ__NetPrice__c > tempMax){
                    subMax = sub; 
                }
                tempMax = sub.SBQQ__NetPrice__c;
            }
            if(!bg_subList_Map.get(s).isempty()){
                bg_subMax_map.put(s, subMax);
            }
        } 
        
        system.debug('bg sub max map => '+bg_subMax_map);
        
        Savepoint sp = Database.setSavepoint();
        // calcualte prorata
        List<SBQQ__Subscription__c> noNBD_subList = RLFPackage_ListInit.calculateProrata(bg_subList_Map);       
        
        Set<SBQQ__Subscription__c> noNBD_subSet =  new Set<SBQQ__Subscription__c>();
        if(!noNBD_subList.isempty()) noNBD_subSet.addAll(noNBD_subList);
        
        // Create Sales Order
        List<Sales_Order__c> soList = new List<Sales_Order__c>();
        for(Id bgId: bg_subMax_map.keySet()){
            soList.add(RLFPackage_ListInit.addRLFSalesOrder(bg, nsCurrencyMap, nsProductMap, nsCostCenterMap,/* fixedBillingMap,*/ 'RLF', bg_subMax_map.get(bgId)));    
        }
        
        if(!soList.isempty()){    
            try{
                insert soList;
                msgQueue = 'Recurring SalesOrder Created Successfully.\n';
                
            } Catch (Exception Ex){
                system.debug('Failed to insert sales order'+ex.getMessage());
                msgQueue = 'Unable to create SalesOrder.\n' +ex.getMessage();
                isSuccess = false;
                
            }
        } else {
            msgQueue = 'Unable to create Sales Order. (No matched Subs Found)\n';
            isSuccess = false;
        }
        if(isSuccess){
            Map<Id, Sales_Order__c> bg_so_map = new Map<Id, Sales_Order__c>();
            for(Sales_Order__c so: [SELECT Id, Billing_Group__c, Sub_Group_Type__c,Order_Start_Date__c, Order_End_Date__c FROM Sales_Order__c WHERE Id IN: soList]){
                //type_so_map.put(so.Sub_Group_Type__c, so);
                bg_so_map.put(so.Billing_Group__c, so);
            }
            
            // Create Sales Order Items
            List<Sales_Order_Item__c> soiList = new List<Sales_Order_Item__c>();
            Map<String, Sales_Order__c> tempType_so_map = new Map<String, Sales_Order__c>();
            //Integer i = 1;
            for(Id bgId: bg_so_Map.keySet()){
                //i = 1;
                //tempType_so_map = ;
                for(SBQQ__Subscription__c sub: bg_subList_Map.get(bgId)){
                    soiList.add(RLFPackage_ListInit.addRLFSalesOrderItem(sub, nsCurrencyMap, revRecScheduleMap, 1, bg_so_map.get(bgId)));
                    //i++;
                }
            }               
            
            if(!soiList.isempty()){
                try {
                    insert soiList;    
                    // msgQueue += 'Sales Order Items Created.\n';
                } Catch(Exception Ex){
                    system.debug('Failed to insert sales order items'+ex.getMessage());
                    msgQueue += 'Unable to create Sales Order Items.\n'+ex.getMessage();
                    isSuccess = false;
                }
            } 
            
            // update next billing date
            if(isSuccess){
                Map<Id, String> bgErrorsMap1 = RLFPackage_ListInit.updateNextBillingDate(bg_subList_Map, noNBD_subSet);
                
                List<SBQQ__Subscription__c> subs1 = new List<SBQQ__Subscription__c>();
                
                for(Id ii: bg_subList_Map.keySet()){
                    subs1.addAll(bg_subList_Map.get(ii));
                }
                RLFPackage_ListInit.zeroProrataDays(subs1); 
                List<Id> bgIdList = new List<Id>();
                bgIdList.addAll(bg_subList_Map.keySet());
                bgDatesUpdate(bgIdList); 
            }
            
        }
        if(!isSuccess){
            Database.rollback(sp);
        }
        return msgQueue;
    }
    
    public static void bgDatesUpdate(Id[] bgIdList){
        system.debug('bg id list in finish method => '+bgIdList);
        Map<Id, List<SBQQ__Subscription__c>> bg_subList_Map = new Map<Id, List<SBQQ__Subscription__c>>();
                
        for(SBQQ__Subscription__c sub: [    SELECT 
                                        Id, 
                                        Billing_Group__c,
                                        Next_Billing_Date__c, 
                                        Next_SO_generation_Date__c
                                        FROM
                                        SBQQ__Subscription__c 
                                        WHERE 
                                        Recurring_Sales_Order_Type__c LIKE 'RLF%'                                                 
                                        AND Recurring_NS_Item__c != null
                                        AND Billing_Status__c = 'Active billing'
                                        AND Billing_Group__c in : bgIdList
                                        ORDER BY 
                                        Recurring_Sales_Order_Type__c
                                       ] ){
                                           if(bg_subList_Map.get(sub.Billing_Group__c)!=null) {
                                               bg_subList_Map.get(sub.Billing_Group__c).add(sub);
                                           } else {
                                               bg_subList_Map.put(sub.Billing_Group__c,new List<SBQQ__Subscription__c>{sub});
                                           }
                                       }
        
        system.debug('bg subs map => '+bg_subList_Map);
        boolean hasDate;
        List<Billing_Group__c> update_bgList = new List<Billing_Group__c>();
        for(String bg: bg_subList_Map.keySet()){
            update_bgList.add(RLFPackage_ListInit.updateDates(bg, bg_subList_Map.get(bg)));            
        }
        
        if(!update_bgList.isempty()){
            try{
                update update_bgList;
                system.debug('updated update_bgList');
            } Catch (Exception Ex){
                system.debug('Failed to update update_bgLIst; reason => '+Ex.getMessage());
            }
        }
    }
    
}