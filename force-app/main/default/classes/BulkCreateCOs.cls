public class BulkCreateCOs {
    
    public List<NS_Subscriptions__c> subcriptions {get; set;}
    public Map<Id, Integer> sub_contract_asset_count {get; set;}
    public string outputMsg {get; set;}
    
    public BulkCreateCOs(ApexPages.StandardSetController sc){
        subcriptions = new List<NS_Subscriptions__c>();
        subcriptions =  [SELECT Id, Name, NS_Uplift_Effective_Date__c,NS_Uplift_Start_Date__c,SFDC_Billing_Group__c, Uplift_Year__c FROM NS_Subscriptions__c WHERE Id IN: sc.getSelected()];
        // getting contract asset count for respective subscripitons which have 1 or more records //AND Bulk_COs_Completed__c = false
        sub_contract_asset_count = new Map<Id, Integer>();
        
        for(NS_Subscriptions__c ns: subcriptions){
            sub_contract_asset_count.put(ns.Id, 0);
        }
        Integer i = 0;
        for(AggregateResult ar: [SELECT NS_Subscription__c sub, COUNT(Id) astCount  FROM Contract_Asset__c WHERE NS_Subscription__c IN :subcriptions GROUP BY NS_Subscription__c]){
            i = Integer.ValueOf(ar.get('astCount'));
            //if(i > 0){
            sub_contract_asset_count.put(String.valueOf(ar.get('sub')), i); 
            //}
        }
        
        system.debug(sub_contract_asset_count);
    }
    
    public void createChangeOrder(){
        
        List<NS_RLF_Change_Order__c> newChangeOrders = new List<NS_RLF_Change_Order__c>();
        
        for(NS_Subscriptions__c sub: [SELECT Id, Name, NS_Uplift_Effective_Date__c, Uplift_Year__c,Bulk_COs_Completed__c FROM NS_Subscriptions__c WHERE Id IN: sub_contract_asset_count.keySet()]){
            
              Date nsUpliftEffectiveDate = Date.today();
                     if(sub.NS_Uplift_Effective_Date__c != null) {
                        nsUpliftEffectiveDate = sub.NS_Uplift_Effective_Date__c;
                }
            // validatioing for bulk completed = false and should have contract assets
            if(!sub.Bulk_COs_Completed__c && sub_contract_asset_count.get(sub.Id) != null)
                newChangeOrders.add(new NS_RLF_Change_Order__c(
                    NS_Subscription__c = sub.Id,
                    Change_Order_Effective_Date__c = nsUpliftEffectiveDate,
                    New_Advance_Billing_Date_on_Subscription__c = Date.today(),
                    Set_Advance_Billing_Date_after_uplift__c = true,
                    Uplift_Year__c = sub.Uplift_Year__c,
                    Ready_for_Approval__c = true,
                    NS_Push_Token__c = true,
                    Ready_for_Export_to_NS__c = true,
                    Generically_Created__c =  true 
                ));
            
            
        }
        
        if(newChangeOrders.size() > 0){
            
            insert newChangeOrders;
        }
        
        Map <Id, Id> sub_co_map = new Map <Id, Id>();
        for(NS_RLF_Change_Order__c co : [SELECT Id, NS_Subscription__c  FROM NS_RLF_Change_Order__c WHERE Id IN: newChangeOrders]){
            sub_co_map.put(co.NS_Subscription__c , co.Id);
        }
        
        List<NS_RLF_Change_Order_Item__c> new_CO_item = new List<NS_RLF_Change_Order_Item__c>();
        for(Contract_Asset__c ca: [SELECT Id, NS_Uplift_Final__c, NS_Subscription__c, NS_Subscription__r.NS_Uplift_Start_Date__c, NS_Uplift_Start_Date__c  FROM Contract_Asset__c WHERE NS_Subscription__c IN: subcriptions]){
            if(sub_co_map.get(ca.NS_Subscription__c) != null)
                new_CO_item.add(new NS_RLF_Change_Order_Item__c(
                    NS_RLF_Change_Order__c = sub_co_map.get(ca.NS_Subscription__c),
                    Originating_NS_Subscription__c = ca.NS_Subscription__c,
                    Change_Order_Item_Start_Date__c = ca.NS_Subscription__r.NS_Uplift_Start_Date__c, // need to update
                    NS__c = ca.NS_Uplift_Final__c,
                    Contract_Asset__c = ca.Id
                ));
        }
        
        if(new_CO_item.size() > 0){
            insert new_CO_item;
            outputMsg = 'Change Orders created successfully!';
            List<NS_Subscriptions__c> update_subs = new List<NS_Subscriptions__c>();
            for(NS_Subscriptions__c ns: [SELECT Id, Bulk_COs_Completed__c FROM NS_Subscriptions__c WHERE Id IN: sub_contract_asset_count.keySet()]){
                if(sub_contract_asset_count.get(ns.Id) > 0){
                    ns.Bulk_COs_Completed__c = true;
                    update_subs.add(ns);
                }
            }
            
            if(update_subs.size() > 0){
                update update_subs;
            }
        } else {
             outputMsg = 'No Change Orders are created, please check bulk COs completed!';
        }
        
    }
    
    public PageReference redirectListView(){
        PageReference pg = new PageReference('/a3Y?');
        pg.setRedirect(true);
        return pg;
    }
    
}