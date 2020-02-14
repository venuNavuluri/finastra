public  Class RLFSO_Manual {
    
    public static String manualRLF(Id billingId){
      
        //Map<Id, Billing_Group__c> bg_map = SO_SalesOrderMapUtils.getbg_map(billingId);
        
        Map<Id, Billing_Group__c> bg_map = SO_RevenueTypeGrouping.getmanualbg_map(billingId);
        
        Map<Id, List<SBQQ__Subscription__c>> RLF_subs_map = SO_RevenueTypeGrouping.getManualRLFsubs(billingId);
       
        if(!RLF_subs_map.values().isEmpty()){
            return RLFSO_Manual.manualRLF(RLF_subs_map, bg_map.get(billingId));
        } else {
            return  'Billing Group has no matching subscriptions, Please check Subscriptions Billing Status, Next SO Generation Date, Expiry Date, Recurring NS Item';
        }
    }
     
    public static String manualRLF(Map<Id, List<SBQQ__Subscription__c>> RLF_subs_map, Billing_Group__c bg){
     
        String sMsg, eMsg;
        sMsg = 'Recurring SalesOrder Created Successfully';
        savepoint sp = Database.setSavepoint();
        Map < String, NS_Currency__c > nsCurrencyMap = SO_SalesOrderMapUtils.getNSCurrency_map();
        Double RLFMax = 0;
        Map<Id, SBQQ__Subscription__c> bg_subMax_map = new Map<Id, SBQQ__Subscription__c>();
        SBQQ__Subscription__c subMax = new SBQQ__Subscription__c(); 
        
        for(String s: RLF_subs_map.keySet()){
            for(SBQQ__Subscription__c sub: RLF_subs_map.get(s)){
                if(sub.SO_Amount__c > = RLFMax){
                    subMax = sub; 
                }
                RLFMax = sub.SO_Amount__c;
            }
            if(!RLF_subs_map.get(s).isempty()){
                bg_subMax_map.put(s, subMax);
            }
        }
        system.debug('bg sub max map => '+bg_subMax_map);
        
        List<SBQQ__Subscription__c> prorated_subList = RLF_SOCreation.calculateProrata(RLF_subs_map);
        Set<SBQQ__Subscription__c> prorated_subSet =  new Set<SBQQ__Subscription__c>();
        if(!prorated_subList.isempty()) prorated_subSet.addAll(prorated_subList);
        
        Sales_Order__c RLFso;
        
        RLFso = RLF_SOCreation.addRLFSalesOrder(bg, nsCurrencyMap,bg_subMax_map.get(bg.Id)); 
        
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
                            
                            // updating prorata calculated check box
                            //RLF_SOCreation.updateProrataCalculatedCheckBox(itemsList); 
                        }
                        Catch (Exception Ex){                            
                            eMsg = 'Error at line # '+ex.getLineNumber()+' cause => '+ex.getMessage()+' class name '+ex.getStackTraceString();
                            Database.rollback(sp);
                            return eMsg;
                        }
                    }
        
        Map<Id, String> bgNBDMap = RLF_SOCreation.updateNextBillingDate(RLF_subs_map);
        
        List<SBQQ__Subscription__c> final_subList = new List<SBQQ__Subscription__c>();
        
        for(Id bgID: RLF_subs_map.keySet()){
                    final_subList.addAll(RLF_subs_map.get(bgID));
                }
        //RLFSO_Manual.zeroProrataDays(final_subList); 
       RLF_SOCreation.updateProrataCalculatedCheckBox(itemsList); 
        
        List<Id> bgIdList = new List<Id>();
        bgIdList.addAll(RLF_subs_map.keySet());
        RLF_SOCreation.bgDatesUpdate(bgIdList);
        
        return sMsg;
    }
    
     /*public static void zeroProrataDays(List<SBQQ__Subscription__c> subsList){
        List<SBQQ__Subscription__c> sub_updateList = new List<SBQQ__Subscription__c>();
        for(SBQQ__Subscription__c sub: [SELECT Id, Pro_Rata_Calculated__c,Expiry_Date__c,Next_SO_generation_Date__c,Exclude__c,Next_Billing_Date__c, Prorata_Days__c FROM SBQQ__Subscription__c WHERE Id IN: subsList]){
            if(!sub.Pro_Rata_Calculated__c)
            sub.Pro_Rata_Calculated__c = true;
            sub.Prorata_Days__c = 0;
            if(sub.Next_Billing_Date__c >= sub.Expiry_Date__c){
                sub.Last_Prorata_Calculated__c = true;
                sub.Next_SO_generation_Date__c = null;
                sub.Next_Billing_Date__c = null;
                sub.Exclude__c = true;
            }
            sub_updateList.add(sub);
        }
        
        if(sub_updateList.size() > 0){
            update sub_updateList;
        }
    }*/
   
}